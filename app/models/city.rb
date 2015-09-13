class City < ActiveRecord::Base
  # include HTTParty
  # base_uri 'api.openweathermap.org/'
  has_many :hours, dependent: :destroy



end
