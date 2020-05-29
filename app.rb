require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
# require 'sqlite3'

# configure do
#   db = get_db
#   db.execute 'CREATE TABLE IF NOT EXESTS Users (
#     id INTEGER PRIMARY KEY AUTOINCREMENT,
#     username TEXT,
#     phone TEXT,
#     datestamp TEXT,
#     barber TEXT,
#     color TEXT
#   )'
# end

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb :index
end

get '/visit' do
  erb :visit
end

get '/contacts' do
  erb :contacts
end

get '/barbers' do
  erb :barbers
end

get '/about' do
  erb :about
end

get '/login/form' do
  erb :login_form
end

get '/logout' do
  session.delete(:identity)
  erb :index
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

get '/public/users/users.txt' do
  erb '<a href="http://localhost:4567/users/users.txt">'
end

get '/show_users' do

end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

post '/visit' do
  @username = params[:username]
  @phone = params[:phone]
  @date_time = params[:date_time]
  @barber = params[:barber]
  @color = params[:color]
  @signup = params[:signup]

  f = File.open 'public/users/users.txt', 'a'
  f.write "Name: #{@username} | Phone: #{@phone} | Date and time: #{@date_time} | Barber: #{@barber} | Color: #{@color}\n"
  f.close

  hh = {
    username: 'Input your name',
    phone: 'Input your phone',
    date_time: 'Input date and time',
    barber: 'Input barber',
    color: 'Input color'
  }

  @error = hh.select { |key,_| params[key] == '' }.values.join(', ')

  # First validation version:
  # hh.each do |k, v|
  #   @error = hh[k] if params[k] == ''
  # end

  if @signup
    @message = "Name: #{@username} | Phone: #{@phone} | Visit at: #{@date_time} | Barber: #{@barber} | Hear color: #{@color}"
  end

  # db = get_db
  # db.execute 'INSERT INTO Users (username, phobe, datestamp, barber, color)
  #   VALUES (?, ?, ?, ?, ?)', [@username, @phobe, @date_time, @barber, @color]

  erb :visit
end

# def get_db
#   db = SQLite::Database.new 'barbershop.sqlite'
#   db.results_as_hash = true
#   return db
# end
