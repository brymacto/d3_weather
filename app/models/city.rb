class City < ActiveRecord::Base
  validate :city_in_open_weather
  # include HTTParty
  # base_uri 'api.openweathermap.org/'
  has_many :hours, dependent: :destroy

  def city_in_open_weather
    if http_response != '200'
      errors.add(:base, "This city/country combination is not available in the Open Weather database (error #{http_response}).  Please select another city and country name.")
    end
  end

  def full_country
    case country
    when 'CA'
      'Canada'
    when 'US'
      'United States'
    when 'FR'
      'France'
    when 'PH'
      'Philippines'
    end
  end

  def full_city
    name.titleize
  end

  def full_name 
    "#{full_city}, #{full_country}"
  end

end
