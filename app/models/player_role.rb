class PlayerRole < ActiveRecord::Base
	has_many :match_participants
end
