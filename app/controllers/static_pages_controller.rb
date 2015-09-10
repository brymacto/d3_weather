class StaticPagesController < ApplicationController
  include HTTParty
  def home
  end

  def weather
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/history/city?q=Toronto,CA&APPID=#{ENV['open_weather_key']}")
    @hours = response['list']
  end
end
