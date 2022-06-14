require 'telegram/bot'
require 'active_record'

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

token = '5366630914:AAGSSWDadjb0HI8FZorCoyLVG6jakISIHNQ'

Telegram::Bot::Client.run(token) do |bot|
  puts 'start bot'
  bot.listen do |message|
    case message.text
    when '/start'
      user = User.find_by(id: message.from.first_name)
      puts "Start bot for #{user.id}"

      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name} id:#{message.from.id}")

      if User.find_by(id: message.from.first_name).nil?
        bot.api.send_message(chat_id: message.chat.id, text: "Додаємо нового користувача #{message.from.first_name}")
        User.create(id: message.from.first_name, chatid: message.chat.id, run: true)
      end

      user.run = true
      user.save

      user.stations.to_a.each do |azs|
        text = text_availability_fuel(azs)
        bot.api.send_message(chat_id: message.chat.id, text: text)
      end

    # when '/add'
    #   bot.api.send_message(chat_id: message.chat.id, text: "ця функція платна")
    # when '/delete'
    #   bot.api.send_message(chat_id: message.chat.id, text: "а ця ще дорожча")
    when '/stop'
      user = User.find_by(id: message.from.first_name)
      puts "Stop bot for #{user.id}"

      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
      user.run = false
      user.save
    else
      bot.api.send_message(chat_id: message.chat.id, text: "only: /start, /stop")
    end
  end
end
