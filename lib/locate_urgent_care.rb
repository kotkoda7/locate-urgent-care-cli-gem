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
  end

end


class LocateUrgentCare::CommandLineInterface

  attr_accessor :zip_code, :category_id

  def run
    get_user_input
    find_clinics
    display_clinic_names
  end

  def get_user_input
    puts "Welcome to Locate Urgent Care."
    get_zip_code
    get_category_id
  end

  def get_zip_code
    puts "Please enter your zip code:"
    @zip_code = gets.chomp.to_i
  end

    

  def get_category_id
    puts "Please select from the following categories:"
    puts "1.Urgent Care."
    puts "2.Occuptaional Medicine."
    puts "3.Primary Care."
    puts "4.Pediatric Urgent Care."
    puts "5.Retail Clinic."
    puts "Input 1-5:"
    @category_id = gets.chomp.to_i
    get_category_id if !(1..5).include?(@category_id)
  end

  def find_clinics
    clinic_pages = LocateUrgentCare::Scraper.scrape_clinic_pages(@zip_code,@category_id)
    clinics_array = LocateUrgentCare::Scraper.scrape_clinic_info(clinic_pages)
    LocateUrgentCare::Clinic.create_clinics(clinics_array)
  end

  def display_clinic_names
    num = LocateUrgentCare::Clinic.all.size
    puts "We found #{num} clinics near you zip codes open now:"
    if num > 0
      (1..num).each do |i|
        puts "#{i}. #{LocateUrgentCare::Clinic.all[i-1].name}."
      end
      return_clinic_info
    end
  end

  def return_clinic_info
    num = LocateUrgentCare::Clinic.all.size
    puts "Which clinic you want to look into further? (1- #{num}):"
    input = gets.chomp.to_i
    return_clinic_info if !(1..num).include?(input)

    clinic = LocateUrgentCare::Clinic.all[input-1]
    puts "Name      : #{clinic.name}"
    puts "Tel       : #{clinic.tel}"
    puts "Distance  : #{clinic.distance}"
    puts "url       : #{clinic.url}"
    puts "rating    : #{clinic.rating}"
    puts "directions: #{clinic.directions}"

    puts "Do you want to look at another clinic?(Y/N)"
    input1 = gets.chomp.to_s.upcase
    return_clinic_info if input1 == "Y"
    
  end

end