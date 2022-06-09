require 'active_record'

require_relative 'parsing.rb'
require_relative 'station.rb'
require_relative 'user.rb'
require_relative 'list.rb'


ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'my_db'
)




