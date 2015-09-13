class CitiesController < ApplicationController
  include HTTParty
  def index
    @cities = City.all.order(name: :asc)
  end

  def show
    @city = City.find(params[:id])
    get_hours
  end

  def edit
    @city = City.find(params[:id])
  end

  def create
    @city = City.new(city_params)

    if @city.save
      @city.get_hours
      redirect_to cities_path
    else
      render 'new'
    end
  end

  def get_hours
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/history/city?q=Toronto,CA&APPID=#{ENV['open_weather_key']}")
    hours_details = response['list']
    @hours = []
    hours_details.each do |hour_details|
      @hours << Hour.new(
        temp: hour_details['main']['temp'], 
        pressure: hour_details['main']['pressure'], 
        humidity: hour_details['main']['humidity'],
        temp_min: hour_details['main']['temp_min'],
        temp_max: hour_details['main']['temp_max'],
        wind_speed: hour_details['wind']['speed'],
        wind_deg: hour_details['wind']['deg'],
        cloudiness: hour_details['clouds']['all'],
        # description:
        # icon:
        # For 2 above, API provides array.  TODO: handle arrays of weather.
        city_id: params[:id]
      )
    end
    binding.pry
    # puts @hours
  end
  # helper_method :get_hours
  # Uncomment the above to access method from view.

  def new
    @city = City.new
  end

  private
    def city_params
      params.require(:city).permit(:name, :country)
    end
end


# :temp, :pressure, :humidity, :temp_min, :temp_max, :wind_speed, :wind_deg, :cloudiness, :description, :icon, :city_id