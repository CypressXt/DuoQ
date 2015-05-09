class PlayerLane < ActiveRecord::Base
	has_many :match_participants
end
