class CreateHours < ActiveRecord::Migration
  def change
    create_table :hours do |t|
      t.float :temp
      t.integer :pressure
      t.integer :humidity
      t.float :temp_min
      t.float :temp_max
      t.float :wind_speed
      t.integer :wind_deg
      t.integer :cloudiness
      t.string :description
      t.string :icon

      t.timestamps null: false
    end
  end
end
