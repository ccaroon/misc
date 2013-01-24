class Game < ActiveRecord::Base
  belongs_to :platform
  belongs_to :genre
end
