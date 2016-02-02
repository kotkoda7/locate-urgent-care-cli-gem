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
      results = []
    when number_of_pages == 1
      results = doc.css('div.description')
    when number_of_pages > 1
      results =[] + doc.css('div.description')
      
      (2..number_of_pages).each do |page|
        page_url = Base_url + "search?q=#{zip_code}&page=#{page}&open=1&category_ids= #{catergory_id}"
        visit(page_url)
        results += Nokogiri::HTML(html).css('div.description')
      end
      results
    end
  end

  

  def self.scrape_clinic_info(clinic_pages)
     
    clinics_array = clinic_pages.map do |clinic|
      next if clinic.css('div.coming-soon').text.match(/Coming Soon!/)
      clinic_hash = {}
      clinic_hash[:name]       = clinic.css('h2>a').text
      clinic_hash[:distance]   = clinic.css("span.distance").text.match(/\(([\w\s.]+)\)/)[1]
      clinic_hash[:address]    = clinic.css("span.address.no-mobile").text.match(/\w[\w., ]+/)[0]
      clinic_hash[:tel]        = clinic.css("a.mobile-only").text.match(/(\d{3}-\d{3}-\d{3})/)[1]
      clinic_hash[:directions] = clinic.css("div.cta> ul li")[1].css('a')[0]["href"]
      clinic_hash[:rating]     = clinic.css("span.rating").to_s.match(/stars\sstar-[0-9]/)[0][-1].to_i
      clinic_hash[:url]        = clinic.css("h2>a")[0]['href']
      clinic_hash
    end.compact

  end
  	

end
