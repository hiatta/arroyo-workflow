$:.push File.expand_path("../lib", __FILE__)
require './lib/arroyo/workflow/version'

Gem::Specification.new do |s|
  s.name        = "arroyo-workflow"
  s.version     = Arroyo::Workflow.version
  s.authors     = ["Adam Hiatt"]
  s.email       = ["adam@goodguide.com"]
  s.homepage    = "https://github.com/GoodGuide/arroyo"
  s.summary     = "Arroyo ESB workflow gem"
  s.description = "Client gem for defining workflows that can be executed as Arroyo ESB jobs"
#  s.rubyforge_project = "arroyo"  
  s.files = Dir['Gemfile', 'arroyo-workflow.gemspec', 'lib/**/*.rb']

  s.add_dependency('i18n')  
  s.add_dependency('ruote')
  s.add_dependency('threadz')
  s.add_dependency('uuidtools')
  s.add_dependency('activesupport')
end
