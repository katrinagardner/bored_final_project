DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  firstname TEXT,
  lastname TEXT,
  email TEXT,
  password TEXT,
  confirm TEXT
);


DROP TABLE IF EXISTS favorites;
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY,
  list TEXT,
  user_id INTEGER references users
);


DROP TABLE IF EXISTS dailyevents;
CREATE TABLE dailyevents (
  id INTEGER PRIMARY KEY,
  evt_name TEXT,
  evt_detail_url TEXT,
  evt_description TEXT,
  evt_address TEXT,
  evt_city TEXT,
  evt_state TEXT,
  evt_phone TEXT,
  evt_date TEXT,
  evt_lat TEXT,
  evt_long TEXT,
  favorite_id INTEGER references favorites
);
