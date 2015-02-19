require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'pry'
require 'sqlite3'
require 'active_record'
require 'json'
require 'bcrypt'
require_relative './lib/connection'
require_relative './lib/favorites'
require_relative './lib/user'
require_relative './lib/dailyevents'
require_relative './methods/methods.rb'


# Create >> -user
# Read >> -events multiple -favorites list
# Update >> -list will update with newly saved event
# Destroy >> -destroy favorites list(remove an event)

db = SQLite3::Database.new "favorites.db"

use Rack::Session::Pool, :cookie_only => false

after do
  ActiveRecord::Base.connection.close
end


#login
get '/' do
  erb(:'user/login')
end

get '/login' do
  redirect '/'
end

#sessions
post '/session' do
  username = params[:username]
  password = params[:password]

  check_db(username, password)
end

post '/signup' do
  new_user = {
    firstname: params[:first_name],
    lastname: params[:last_name],
    email: params[:user_email],
    password: params[:password],
    confirm: params[:confirm]
  }


  user = User.create(new_user)
  Favorite.create(user_id: user.id)
  session[:id] = user.id
  session[:valid_user] = true
  redirect '/events'
end

#after login
get '/events' do
  if authenticated?
    response = events_call(@@api_key)
    erb(:'events/index', {locals: { response: response['results'] }})
  else
    redirect '/login'
  end
end

#filtered by specific date
post '/selected' do
  if authenticated?
    the_date = params[:selected_date].gsub("-", "/")
    response = date_filter(the_date)['results']
    erb(:'events/selected', {locals: {response: response}})
  else
    redirect '/login'
  end
end

#save event on the click then redirect to our favorites list
post '/save' do
  if authenticated?
    #favorite list captures finding the favorite list id by the sessions id(session = current_user id)
    favorite_list = Favorite.find_by(user_id: session[:id])
    new_evt = {
      evt_name: params[:name],
      evt_detail_url: params[:detail],
      evt_description: params[:description],
      evt_address: params[:address],
      evt_city: params[:city],
      evt_state: params[:state],
      evt_phone: params[:telephone],
      evt_date: params[:date],
      evt_lat: params[:lat],
      evt_long: params[:long],
      favorite_id: favorite_list.id
    }
    Dailyevent.create(new_evt)
    redirect '/favorite'
  else
    redirect '/login'
  end
end

#remove event
put '/remove' do
  if authenticated?
    destroy_evt = Dailyevent.find_by(evt_name: params["eventname"])
    destroy_evt.destroy
    redirect '/favorite'
  else
    redirect '/login'
  end
end

get '/favorite' do
  if authenticated?
    #user favorite list is the daily events found by the logged in users id
    user_name = User.find_by(id: session[:id])
    user_faves = Favorite.find_by(user_id: session[:id])
    faves = Dailyevent.where(favorite_id: user_faves.id)
    erb(:'events/favorite', {locals: {faves: faves, username: user_name}})
  else
    redirect '/login'
  end
end

#log out
put '/logout' do
  session[:valid_user] = false
  redirect '/login'
end

#Google Maps
post '/map' do
  location = {
    lat: params[:lat],
    long: params[:long],
    address: params[:address],
    city: params[:city],
    state: params[:state]
  }
  api_map = map_call(params['lat'], params['long'])
  erb(:'events/map', {locals: {object: location, map: api_map}})
end
