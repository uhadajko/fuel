class User < ActiveRecord::Base
  has_many :lists
  has_many :stations, through: :lists

  before_create :before_create_callback
  after_create :after_create_callback

  # Ensure name and age fields are present
  validates_presence_of :chatid, :id

  # Ensure field is unique
  validates_uniqueness_of :chatid, :id


  def before_create_callback
    puts "User: before_create_callback #{self.id}"
  end

  def after_create_callback
    puts "User: after_create_callback #{self.id}"
    [1104, 1108, 1109, 1118, 1119].each do |station_id|
      List.create(user_id: self.id, station_id: station_id)
    end 

    [40511900, 40510100, 40510200, 40510300, 40510400, 40510500, 40510600, 40510700].each do |station_id|
      List.create(user_id: self.id, station_id: station_id)
    end 

    puts "New user object created: #{self.id}"
  end
end
