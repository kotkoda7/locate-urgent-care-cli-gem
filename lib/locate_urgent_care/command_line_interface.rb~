class LocateUrgentCare::CommandLineInterface

  attr_accessor :zip_code, :category_id

  def run
    get_user_input
    find_clinics
    display_clinic_names
    run_again?
  end

  def get_user_input
    puts "Welcome to Locate Urgent Care."
    get_zip_code
    get_category_id
  end

  def get_zip_code
    puts "\nPlease enter your zip code:"
    @zip_code = gets.chomp.to_s
    if @zip_code.size != 5 || @zip_code.to_region.nil?
      puts "\nInvalid zip code."
      get_zip_code
    end
    #binding.pry
  end

  def get_category_id
    puts "\nPlease select from the following categories:"
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
    binding.pry
  end

  def display_clinic_names
    num = LocateUrgentCare::Clinic.all.size
    puts "\nWe found #{num} clinics near you zip codes open now:"
    
    if num > 0
      (1..num).each do |i|
        puts "#{i}. #{LocateUrgentCare::Clinic.all[i-1].name}."
      end
      return_clinic_info
    end
  end

  def return_clinic_info
    num = LocateUrgentCare::Clinic.all.size
    puts "\nWhich clinic you want to look into further? (1- #{num}):"
    input = gets.chomp.to_i
    if (1..num).include?(input)
      clinic = LocateUrgentCare::Clinic.all[input-1]
      puts "\nName      : #{clinic.name}"
      puts "Tel       : #{clinic.tel}"
      puts "Distance  : #{clinic.distance}"
      puts "url       : #{clinic.url}"
      puts "rating    : #{clinic.rating}"
      puts "directions: #{clinic.directions}"
      puts "\nDo you want to look at another clinic?(Y/N)"
      input1 = gets.chomp.upcase
      return_clinic_info if input1 == "Y"
    else
      return_clinic_info
    end 
  end

  def run_again?
    puts "\nDo you want to search another zip code? (Y/N):"
    inputs = gets.chomp.upcase
    if inputs != "Y"
      puts "\nThank you for using Locate Urgent Care. Have a nice day!"
    else
      run
    end
  end

end