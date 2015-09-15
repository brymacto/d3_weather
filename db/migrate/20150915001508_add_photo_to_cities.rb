class AddPhotoToCities < ActiveRecord::Migration
  def change
    add_column :cities, :photo_url, :string
    add_column :cities, :photo_user_url, :string
  end
end
