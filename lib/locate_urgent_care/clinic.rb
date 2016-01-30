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
