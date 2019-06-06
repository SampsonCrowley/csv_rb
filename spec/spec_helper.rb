# encoding: utf-8

require 'coveralls'
Coveralls.wear!

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'

puts "Testing Rails 5"
require File.expand_path("../dummy/config/environment", __FILE__)

require 'bundler'
require 'bundler/setup'
require 'rspec/rails'
require 'capybara/rspec'
require 'csv_rb'
require 'roo'
require 'pry'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.color = true
  config.formatter     = 'documentation'
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end

module ::RSpec::Core
  class ExampleGroup
    include Capybara::DSL
    include Capybara::RSpecMatchers
  end
end

def mime_type
  Mime[:csv]
end
