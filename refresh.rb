require 'active_record'
require 'telegram/bot'

require_relative 'parsing'
require_relative 'station'
require_relative 'user'
require_relative 'list'
require_relative 'module'

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

  azs = Station.find_by(id: azs_id)
  if (azs.m95_cash && azs.m95_cash != record['m95_cash']) || (azs.m95_talon && azs.m95_talon != record['m95_talon']) ||
    (azs.a95_cash && azs.a95_cash != record['a95_cash']) || (azs.a95_talon && azs.a95_talon != record['a95_talon']) ||
    (azs.mdp_cash && azs.mdp_cash != record['mdp_cash']) || (azs.mdp_talon && azs.mdp_talon != record['mdp_talon']) ||
    (azs.dp_cash && azs.dp_cash != record['dp_cash']) || (azs.dp_talon && azs.dp_talon != record['dp_talon']) ||
    (azs.gas_cash && azs.gas_cash != record['gas_cash']) || (azs.gas_talon && azs.gas_talon != record['m95_talon'])

    azs.save
  else
    azs.save
    next
  end

  text = text_availability_fuel(azs)
  azs.users.to_a.each do |user|
    Telegram::Bot::Client.run(@token) do |bot|
      puts text
      bot.api.send_message(chat_id: user.chatid, text: text)
    end
  end
end


# Station.all.to_a.each do |azs|
#   text = text_availability_fuel(azs)
#   puts text

#     puts "Відправляємо повідомлення #{user.id}:#{user.chatid} для АЗС: #{azs.id}, якщо для такого користувача чат запущено - #{user.run}"

#     next unless user.run
#     # puts "#{user.id} - #{user.chatid}"

#     Telegram::Bot::Client.run(@token) do |bot|
#       puts text
#       bot.api.send_message(chat_id: user.chatid, text: text)
#     end
#   end
# end
