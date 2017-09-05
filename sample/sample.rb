require_relative '../lib/db_associate'

class Food < DataLive
  finalize!
  belongs_to :restaurant
  has_one_through :manager, :restaurant, :owner
end

class Restaurant < DataLive
  finalize!
  has_many :foods
  belongs_to(:owner, class_name: "Human")
end

class Human < DataLive
  finalize!
  has_many(:restaurants, foreign_key: :owner_id)
end
