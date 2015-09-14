class AddHttpResponseToCities < ActiveRecord::Migration
  def change
    add_column :cities, :http_response, :string
  end
end
