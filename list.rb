class List < ActiveRecord::Base
  belongs_to :user
  belongs_to :station

  before_create :before_create_callback
  after_create :after_create_callback

  validates_presence_of :station_id, :user_id

  def before_create_callback
    puts "List: before_create_callback #{self.user_id}"
  end

  def after_create_callback
    puts "List: after_create_callback #{self.user_id}"
  end
end
