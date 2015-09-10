class City < ActiveRecord::Base
  include HTTParty
  base_uri 'api.openweathermap.org/'
  has_many :hours, dependent: :destroy

  attr_accessor :name, :country, :open_weather_id
  attr_reader :id
end
