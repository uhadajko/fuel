require 'telegram/bot'
require 'active_record'

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

token = '5366630914:AAGSSWDadjb0HI8FZorCoyLVG6jakISIHNQ'

Telegram::Bot::Client.run(token) do |bot|
  puts 'start bot'
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name} id:#{message.from.id}")

      if User.find_by(id: message.from.first_name).nil?
        bot.api.send_message(chat_id: message.chat.id, text: "Додаємо нового користувача #{message.from.first_name}")
        User.create(id: message.from.first_name, chatid: message.chat.id, run: true)
      end

      list = User.where(user_id: message.from.first_name).stations.to_a
      list.each do |azs|
        text = azs.id
        bot.api.send_message(chat_id: message.chat.id, text: text)
      end

      bot.api.send_message(chat_id: message.chat.id, text: "Додаємо нового користувача #{message.from.first_name}")


      bot.api.send_message(chat_id: message.chat.id, text: "Додайте АЗС які Ви бажаєте відслідковувати")
    # when '/add'
    #   bot.api.send_message(chat_id: message.chat.id, text: "ця функція платна")
    # when '/delete'
    #   bot.api.send_message(chat_id: message.chat.id, text: "а ця ще дорожча")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
      user = User.find_by(login: message.from.first_name)
      puts user
      user.run = false
      user.save

    else
      bot.api.send_message(chat_id: message.chat.id, text: "only: /start, /stop")
    end
  end
end