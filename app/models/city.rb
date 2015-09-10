class City < ActiveRecord::Base
  has_many :hours, dependent: :destroy
end
