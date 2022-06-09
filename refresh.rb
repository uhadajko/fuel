require 'active_record'
require 'telegram/bot'

require_relative 'parsing'
require_relative 'station'
require_relative 'user'
require_relative 'list'

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'my_db'
)

@token = '5366630914:AAGSSWDadjb0HI8FZorCoyLVG6jakISIHNQ'

# модуль для отримання переліку ід заправних АЗС
puts "Оновлюємо дані АЗС"
wog_list = Station.where(brand: 'WOG').ids
okko_list = Station.where(brand: 'OKKO').ids

# обєднуємо дані в один файл, для подальшого опрацювання
data = parsing_wog(wog_list)
data.merge!(parsing_okko(okko_list))

data.each_pair do |azs_id, record|
  Station.create(id: azs_id) unless Station.find_by(id: azs_id)
  Station.update(azs_id, record)
  puts "update #{azs_id}"
end

puts "--  " * 10
puts "Відправляємо повідомлення по всіх АЗС всім користувачам"

Station.all.to_a.each do |azs|
  text_cash = []
  text_cash << 'PULLS 95' if azs.m95_cash
  text_cash << 'A-95' if azs.a95_cash
  text_cash << 'PULLS ДП' if azs.mdp_cash
  text_cash << 'ДП' if azs.dp_cash
  text_cash << 'ГАЗ' if azs.dp_cash
  text_talon = []
  text_talon << 'PULLS 95' if azs.m95_talon
  text_talon << 'A-95' if azs.a95_talon
  text_talon << 'PULLS ДП' if azs.mdp_talon
  text_talon << 'ДП' if azs.dp_talon
  text_talon << 'ГАЗ' if azs.dp_talon

  text = "#{azs.brand} #{azs.adresa}\n"

  if text_cash.any?
    string_cash =  "За готівку і банківські карти доступно: #{text_cash.join(', ')}\n" 
    text += string_cash
  end

  if text_talon.any?
    string_talon =  "З паливною картою і талонами доступно: #{text_talon.join(', ')}\n"
    text += string_talon
  end

  # puts text
  azs.users.to_a.each do |user|
    puts "Відправляємо повідомлення #{user.id}:#{user.chatid} для АЗС: #{azs.id}, якщо для такого користувача чат запущено - #{user.run}"
    next unless user.run
    # puts "#{user.id} - #{user.chatid}"

    Telegram::Bot::Client.run(@token) do |bot|
      puts text if text_cash.any? || text_talon.any?
      bot.api.send_message(chat_id: user.chatid, text: text) if text_cash.any? || text_talon.any?
    end
  end
end
