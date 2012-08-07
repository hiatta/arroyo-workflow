require 'rubygems'
require 'bundler'
Bundler.require

require 'arroyo/workflow'

module SpecHelpers
end

RSpec.configure do |config|
  config.mock_framework = :rr
  config.include SpecHelpers
end
