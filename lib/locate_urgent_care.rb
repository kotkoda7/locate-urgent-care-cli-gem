require "locate_urgent_care/version"

module LocateUrgentCare
  # Your code goes here...
end


class LocateUrgentCare :: Scraper

  base_url : "https://www.urgentcarelocations.com/"

  def self.generate_url(zip_code, catergory_id)
    base_url + "search?q=#{zip_code}&page=1&open=1&category_ids= #{catergory_id}"
  end


  def self.scrape_clinic_name(search_url)
  	index_page = Nokogiri::HTML(open(search_url, "User-Agent" => "Mozilla"))
    names_hash = 
    
  end

  def self.scrape_clinic_info(profile_url)
  end
  	

end
