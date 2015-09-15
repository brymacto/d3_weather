class CitiesController < ApplicationController
  include ActiveModel::Validations

  include HTTParty
  def index
    @cities = City.all.order(name: :asc)
  end

  def show
    @city = City.find(params[:id])
    @hours = @city.hours.order(weather_time: :asc)
    if (time_diff(@city.hours.first.updated_at, Time.now) > 59)
      get_hours(@city)
    end
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
    

    flickr_api_url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=#{ENV['flickr_key']}&text=#{@city.name}&license=1%2C2%2C3%2C4%2C5%2C6%2C7&sort=relevance&accuracy=11&lat=#{@city.lat}&lon=#{@city.long}&format=json&nojsoncallback=1"
    flickr_response = HTTParty.get(flickr_api_url)
    flickr_photo = flickr_response['photos']['photo'][0]
    flickr_userId = flickr_photo['owner']
    flickr_user_api_url = "https://api.flickr.com/services/rest/?method=flickr.urls.getUserProfile&api_key=#{ENV['flickr_key']}&user_id=#{flickr_userId}&format=rest"
    flickr_user_response = HTTParty.get(flickr_user_api_url)
    @city.photo_user_url = flickr_user_response['rsp']['user']['url']
    @city.photo_url = "https://farm#{flickr_photo['farm']}.staticflickr.com/#{flickr_photo['server']}/#{flickr_photo['id']}_#{flickr_photo['secret']}_b.jpg"
    @city.photo_thumb_url = "https://farm#{flickr_photo['farm']}.staticflickr.com/#{flickr_photo['server']}/#{flickr_photo['id']}_#{flickr_photo['secret']}_q.jpg"
    end
    if @city.save
      get_hours(@city)
      redirect_to city_path(@city)
    else
      render 'new'
    end
  end

  def get_hours(city)
    puts "*********** GETTING HOURS"
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/history/city?q=#{city.name},#{city.country}&APPID=#{ENV['open_weather_key']}")
    hours_details = response['list']
    # @hours = []
    if (city.hours.count == 24)
      puts "******* About to edit hours"
      hours_details.each_with_index do |hour_details, index|
        city.hours[index].update(
        # Hour.create(

          temp: k_to_celsius(hour_details['main']['temp']), 
          pressure: hour_details['main']['pressure'], 
          humidity: hour_details['main']['humidity'],
          temp_min:  k_to_celsius(hour_details['main']['temp_min']),
          temp_max:  k_to_celsius(hour_details['main']['temp_max']),
          wind_speed: hour_details['wind']['speed'],
          wind_deg: hour_details['wind']['deg'],
          cloudiness: hour_details['clouds']['all'],
          weather_time: Time.at(hour_details['dt']),
          city_id: city.id
          )
      end
    else
      puts "******* About to create hours"
      city.hours.delete_all
      hours_details.each do |hour_details|
        Hour.create(          
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
          city_id: city.id
          )
      end

    end

  end

  def update
    @city = City.find(params[:id])
    if @city.update(city_params)
      redirect_to @city
    else
      render 'edit'
    end
  end

  def k_to_celsius(kelvins)
    (kelvins - 273.15).round(2)
  end

  def time_diff(start_time, end_time)
    seconds_diff = (start_time - end_time).to_i.abs

    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600

    minutes = seconds_diff / 60
    # seconds_diff -= minutes * 60

    # seconds = seconds_diff

    # "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end

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