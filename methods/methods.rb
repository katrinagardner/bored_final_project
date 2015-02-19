
json = ''

File.open('./secret.json', 'r') do |key|
  key.each_line do |line|
    json << line
  end
end

@@api_key = JSON.parse(json)


#for the nytimes API our main query event -> comey and ballet
def comedy_uri
  comedy_uri = "http://api.nytimes.com/svc/events/v2/listings.json?filters=category%3AComedy&date_range="
end

def dance_uri
  dance_uri = "http://api.nytimes.com/svc/events/v2/listings.json?filters=category%3ADance&date_range="
end

def google_map
  map = "https://maps.googleapis.com/maps/api/staticmap?center="
end

#current date range with current date
def current_date
  time = Time.now.strftime("20%y/%m/%d")
  current_date = "#{time}%3A#{time}"
end

#google map api call
def map_call(lat, long)
  location = google_map + lat + "," + long + "&zoom=14&size=600x800" + @@api_key["map_key"]
end

#our api call for daily events for the main index page
def events_call(api_key)
  url_call = dance_uri + current_date + api_key["api_key"]
  response = HTTParty.get(url_call)
end

#filter option for events range
def date_filter(date)
  url_call = dance_uri + date + "%3A" + date + @@api_key["api_key"]
  response = HTTParty.get(url_call)
end

#authentication
def authenticated?
  session[:valid_user] == true
end

#check database for username and password before authenticating
def check_db(username, password)
  db_username = User.find_by(email: username)

  if(db_username['email'] == username && db_username['password'] == password)
    session[:valid_user] = true
    session[:id] = db_username.id
    redirect '/events'
  else
    redirect '/login'
  end
end
