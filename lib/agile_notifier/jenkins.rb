require 'uri'
require 'json'
require 'httparty'
require_relative 'ci'
require_relative 'response_helper'
require_relative 'servable'

module AgileNotifier
  class Jenkins < CI
    extend ResponseHelper

    JSON_API = '/api/json'

    def self.get_value(key, url)
      get_value_of_key(key, url.gsub(/\/$/, '') + JSON_API)
    end
    
    def initialize(url, job_name, build_number = nil)
      @url = url
      job_url = URI.encode("#{@url}/job/#{job_name}/")
      @job = Job.new(job_name, job_url, build_number)
    end

    def get_all_jobs
      jobs = self.class.get_value('jobs', @url)
      if jobs.nil?
        return nil
      else
        jobs.inject([]) do |all_jobs, job|
          all_jobs.push(Job.new(job['name'], job['url']))
        end
      end
    end

    class Job < CI::Job
      def get_specific_build(build_number)
        Build.new(build_number, @url + build_number.to_s + '/')
      end
      
      def get_last_build
        last_build = Jenkins.get_value('lastBuild', @url)
        last_build.nil? ? nil : Build.new(last_build['number'], last_build['url'])
      end

      class Build < CI::Job::Build
        include Servable
        
        def is_building?
          Jenkins.get_value('building', @url)
        end

        def get_result
          result = Jenkins.get_value('result', @url)
          result.nil? ? nil : result
        end

        def get_revision
          revision = Jenkins.get_value('lastBuiltRevision', @url)
          revision.nil? ? nil : revision['SHA1']
        end

        def get_branch
          revision = Jenkins.get_value('lastBuiltRevision', @url)
          revision.nil? ? nil : revision['branch'][0]['name']
        end

        def get_previous_build
          previous_number = @number - 1
          while previous_number > 0
            previous_url = @url.gsub(/\/#{@number}\//, "/#{previous_number}/")
            if is_available?(previous_url)
              previous_build = Build.new(previous_number, previous_url)
              previous_branch = previous_build.get_branch
              if (get_branch == previous_branch)
                return previous_build
              end
            end
            previous_number -= 1
          end
          return nil
        end

        def get_previous_result
          previous_build = get_previous_build
          if previous_build
            return previous_build.get_result
          else
            return nil
          end
        end

        def is_triggered_manually?
          previous_build = get_previous_build
          if previous_build && @revision == previous_build.get_revision
            return true
          else
            return false
          end
        end

        def passed?
          @result == 'SUCCESS'
        end

        def failed?
          if @result == 'FAILURE' && !is_triggered_manually?
            return true
          else
            return false
          end
        end
        
        def unstable?
          if @result == 'UNSTABLE' && !is_triggered_manually?
            return true
          else
            return false
          end
        end

        def fixed?
          previous_result = get_previous_result
          if !previous_result.nil? && previous_result != 'SUCCESS'
            return passed?
          else
            return nil # if previous result is SUCCESS, doesn't make sense, then return nil
          end
        end
      end
    end
  end
end
