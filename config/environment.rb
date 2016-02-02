require "locate_urgent_care/version"
require 'nokogiri'
require 'open-uri'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'area'

require_relative '../lib/locate_urgent_care/scraper.rb'
require_relative '../lib/locate_urgent_care/clinic.rb'
require_relative '../lib/locate_urgent_care/command_line_interface.rb'

Capybara.default_driver = :poltergeist
Capybara.run_server = false

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, 
  js_error: false,
  debug: false, :default_wait_time => 30, :timeout => 90 )
end