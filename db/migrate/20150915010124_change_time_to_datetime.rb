class ChangeTimeToDatetime < ActiveRecord::Migration
  def change
    remove_column :hours, :weather_time
    add_column :hours, :weather_time, :datetime
  end
end
