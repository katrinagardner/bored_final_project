require 'active_record'

class Favorite < ActiveRecord::Base
  has_many :dailyevents
  belongs_to :user
end
