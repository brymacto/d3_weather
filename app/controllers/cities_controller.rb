class CitiesController < ApplicationController
  include ActiveModel::Validations
  
  include HTTParty
  def index
    @cities = City.all.order(name: :asc)
  end

  def show
    @city = City.find(params[:id])
    get_hours(@city)
  end

  def edit
    @city = City.find(params[:id])
  end

  def create
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/history/city?q=#{params[:city][:name]},#{params[:city] [:country]}&APPID=#{ENV['open_weather_key']}")
    http_resp = response['cod']
    @city = City.new(city_params.merge(:http_response => http_resp))
    @city.open_weather_id = response['city_id']

    if (@city.open_weather_id)
      response_coords = HTTParty.get("http://api.openweathermap.org/data/2.5/weather?id=#{@city.open_weather_id}")
      @city.long = response_coords['coord']['lon']
      @city.lat = response_coords['coord']['lat']
    end 

    flickr_api_url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=#{ENV['flickr_key']}&text=#{@city.name}&license=1%2C2%2C3%2C4%2C5%2C6%2C7&sort=relevance&accuracy=11&lat=#{@city.lat}&lon=#{@city.long}&format=json&nojsoncallback=1"
    flickr_response = HTTParty.get(flickr_api_url)
    flickr_photo = flickr_response['photos']['photo'][0]
    flickr_userId = flickr_photo['owner']
    flickr_user_api_url = "https://api.flickr.com/services/rest/?method=flickr.urls.getUserProfile&api_key=#{ENV['flickr_key']}&user_id=#{flickr_userId}&format=rest"
    flickr_user_response = HTTParty.get(flickr_user_api_url)
    @city.photo_user_url = flickr_user_response['rsp']['user']['url']
    @city.photo_url = "https://farm#{flickr_photo['farm']}.staticflickr.com/#{flickr_photo['server']}/#{flickr_photo['id']}_#{flickr_photo['secret']}_b.jpg"
    # @flickr_photo_thumb_url = "https://farm#{flickr_photo['farm']}.staticflickr.com/#{flickr_photo['server']}/#{flickr_photo['id']}_#{flickr_photo['secret']}_q.jpg"


    if @city.save
      redirect_to cities_path
    else
      render 'new'
    end
  end


  def get_hours(city)
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/history/city?q=#{city.name},#{city.country}&APPID=#{ENV['open_weather_key']}")
    hours_details = response['list']
    @hours = []
    hours_details.each do |hour_details|
      @hours << Hour.new(
        
        temp: k_to_celsius(hour_details['main']['temp']), 
        pressure: hour_details['main']['pressure'], 
        humidity: hour_details['main']['humidity'],
        temp_min:  k_to_celsius(hour_details['main']['temp_min']),
        temp_max:  k_to_celsius(hour_details['main']['temp_max']),
        wind_speed: hour_details['wind']['speed'],
        wind_deg: hour_details['wind']['deg'],
        cloudiness: hour_details['clouds']['all'],
        weather_time: Time.at(hour_details['dt']),
        # description:
        # icon:
        # For 2 above, API provides array.  TODO: handle arrays of weather.
        city_id: params[:id]
      )
    end
  end

  def k_to_celsius(kelvins)
    (kelvins - 273.15).round(2)
  end

  # helper_method :get_hours
  # Uncomment the above to access method from view.

  def new
    @city = City.new
  end

  def destroy
    @city = City.find(params[:id])
    @city.destroy
 
    redirect_to cities_path
  end


  private
    def city_params
      params.require(:city).permit(:name, :country, :http_response)
    end

end


# :temp, :pressure, :humidity, :temp_min, :temp_max, :wind_speed, :wind_deg, :cloudiness, :description, :icon, :city_id