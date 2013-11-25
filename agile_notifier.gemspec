# encoding: utf-8

require File.expand_path('./lib/agile_notifier', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'agile_notifier'
  s.version     = AgileNotifier::VERSION
  s.license     = 'MIT'
  s.date        = '2013-05-22'
  s.summary     = %q{agile_notifier alerts you via making wonderful noises}
  s.description = %q{agile_notifier alerts you via making wonderful noises, make software development more fun}
  s.authors     = ['Jing Li']
  s.email       = ['thyrlian@gmail.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.homepage    = 'https://github.com/thyrlian/AgileNotifier'

  s.add_runtime_dependency('json', '~> 1.8.0')
  s.add_runtime_dependency('httparty', '~> 0.11.0')
  s.add_development_dependency('mocha', '~> 0.14.0')
end