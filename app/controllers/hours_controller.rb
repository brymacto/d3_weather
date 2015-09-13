class HoursController < ApplicationController


  def create
    @hour = Hour.new(hour_params)
    @hour.save
    # if @hour.save
    #   redirect_to cities_path
    # else
    #   render 'new'
    # end
  end

  def new
    @hour = Hour.new
  end

  private
  def hour_params
    params.require(:hour).permit(:temp, :pressure, :humidity, :temp_min, :temp_max, :wind_speed, :wind_deg, :cloudiness, :description, :icon, :weather_time, :city_id)
  end
end


