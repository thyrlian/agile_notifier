require_relative 'scm'

module AgileNotifier
  class Git < SCM
    attr_accessor :repo

    def initialize(dir)
      @repo = Repository.new(dir)
    end

    class << self
      def combine_commands(*commands)
        separator = ' && '
        combined_commands = commands.inject('') do |cmds, cmd|
          cmds += "#{cmd}#{separator}"
        end
        combined_commands.gsub!(/#{separator}$/, '')
      end

      def run_command(command)
        `#{command}`
      end
    end

    class Repository < SCM::Repository
      def initialize(repo)
        @repo = repo
      end

      def get_committer_of_a_commit(revision)
        go_to_repo = "cd #{@repo}"
        show_author_name = "git show #{revision} --pretty=format:%an | head -1"
        cmd = Git.combine_commands(go_to_repo, show_author_name)
        Git.run_command(cmd).chomp
      end
    end
  end
end