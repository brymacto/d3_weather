class AddCityIdToHours < ActiveRecord::Migration
  def change
    add_column :hours, :city_id, :integer
  end
end
