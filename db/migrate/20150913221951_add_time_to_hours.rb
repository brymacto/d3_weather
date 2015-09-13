class AddTimeToHours < ActiveRecord::Migration
  def change
    add_column :hours, :weather_time, :time
  end
end
