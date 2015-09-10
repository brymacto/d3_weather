class StaticPagesController < ApplicationController
  include HTTParty
  def home
  end

  def weather
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/history/city?q=Toronto,CA&APPID=#{ENV['open_weather_key']}")
    puts response.body, response.code, response.message, response.headers.inspect
  end
end
