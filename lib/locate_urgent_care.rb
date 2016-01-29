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
    doc = Nokogiri::HTML(html)
    number_of_entries = doc.css('span.locations-found')[0].text.to_i
    number_of_pages = (number_of_entries/5.0).floor + (number_of_entries % 5 == 0 ? 0:1)
    case 
    when number_of_pages == 0
      nil
    when number_of_pages == 1
      doc.css('div.description')
    when number_of_pages > 1
      results =[] + doc.css('div.description')
      
      (2..number_of_pages).each do |page|
        page_url = Base_url + "search?q=#{zip_code}&page=#{page}&open=1&category_ids= #{catergory_id}"
        visit(page_url)
        results += Nokogiri::HTML(html).css('div.description')
      end
      results
    end
    #binding.pry
  end

  

  def self.scrape_clinic_info(clinic_pages)
     
    clinics_array = clinic_pages.each.map do |clinic|
      next if clinic.css('div.coming-soon').text.match(/Coming Soon!/)
      clinic_hash = {}
      clinic_hash[:name]       = clinic.css('h2>a').text
      clinic_hash[:distance]   = clinic.css("span.distance").text.match(/\(([\w\s.]+)\)/)[1]
      clinic_hash[:tel]        = clinic.css("a.mobile-only").text.match(/(\d{3}-\d{3}-\d{3})/)[1]
      clinic_hash[:directions] = clinic.css("div.cta> ul li")[1].css('a')[0]["href"]
      clinic_hash[:rating]     = clinic.css("span.rating").to_s.match(/stars\sstar-[0-9]/)[0][-1].to_i
      clinic_hash[:url]        = clinic.css("h2>a")[0]['href']
      clinic_hash
      #binding.pry
    end.compact

  end
  	

end


class LocateUrgentCare::Clinic

  attr_accessor :name, :url, :tel, :rating, :distance, :directions
  
  @all = []

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=",value)
    end
    self.class.all << self
  end

  def self.all
    @all
  end

  def self.create_clinics(clinics_array)
    clinics_array.each do |clinic_hash|
      self.new(clinic_hash)
    end
    self.all
  end

end



