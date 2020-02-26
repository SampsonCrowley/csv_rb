$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "csv_rb/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "csv_rb"
  s.version     = CSVRb::VERSION
  s.authors     = ["Sampson Crowley"]
  s.email       = ["sampsonsprojects@gmail.com"]
  s.homepage    = "https://github.com/SampsonCrowley/csv_rb"
  s.summary     = "A simple rails plugin to provide a streaming csv renderer using the csv gem."
  s.description = "csv_rb provides an csv renderer so you can move all your spreadsheet code from your controller into view files. Now you can keep your controllers thin!"

  s.files = Dir["{app,config,db,lib}/**/*"] + Dir['[A-Z]*'] - ['Guardfile']
  s.test_files = Dir["spec/**/*"] + ['Guardfile']

  s.add_dependency "actionpack", ">= 5.2"
  s.add_dependency "csv", ">= 3.1.0"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "capybara"
  s.add_development_dependency "roo"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "growl"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
end
