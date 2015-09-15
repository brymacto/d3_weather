class AddThumbnailToCities < ActiveRecord::Migration
  def change
    add_column :cities, :photo_thumb_url, :string
  end
end
