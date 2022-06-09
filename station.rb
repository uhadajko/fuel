class Station < ActiveRecord::Base
  has_many :lists
  has_many :users, through: :lists

  before_create :before_create_callback
  after_create :after_create_callback

  def before_create_callback
    puts "Station: before_create_callback #{self}"
  end

  def after_create_callback
    puts "Station: after_create_callback #{self}"
    puts "New station object created: #{self.id}, #{self.brand} - #{self.adresa}"
  end

end
