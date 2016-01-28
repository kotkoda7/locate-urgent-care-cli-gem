require "locate_urgent_care/version"
require 'nokogiri'
require 'open-uri'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.run_server = false

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, 
  #phantomjs_options: ['--load-images=false', '--disk-cache=false'],
  debug: false, :default_wait_time => 30, :timeout => 90 )
end



module LocateUrgentCare
  # Your code goes here...
end


class LocateUrgentCare::Scraper
  extend Capybara::DSL

  Base_url = "https://www.urgentcarelocations.com/"

  


  def self.scrape_clinic_pages(zip_code, catergory_id)
    search_url = Base_url + "search?q=#{zip_code}&page=1&open=1&category_ids= #{catergory_id}"
  	visit(search_url)
    doc1 = Nokogiri::HTML(open(search_url))
    doc = Nokogiri::HTML(html)


    #index_page = Nokogiri::HTML(open(search_url, "User-Agent" => "Mozilla"))  
    binding.pry  
  end

  def self.scrape_clinic_info(profile_url)
  end
  	

end


