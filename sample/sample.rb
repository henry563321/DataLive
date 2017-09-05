require_relative '../lib/db_associate'

class Food < DataLive
  belongs_to :restaurant
  has_one_through :manager, :restaurant, :owner
end

class Restaurant < DataLive
  has_many :foods
  belongs_to(:owner, class_name: "Human")
end

class Human < DataLive
  has_many(:restaurants, foreign_key: :owner_id)
end
