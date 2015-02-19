require 'active_record'

class Dailyevent < ActiveRecord::Base
  belongs_to :favorite
end
