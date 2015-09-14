class AddLatLongToCities < ActiveRecord::Migration
  def change
    add_column :cities, :lat, :float
    add_column :cities, :long, :float
  end
end
