class MatchParticipant < ActiveRecord::Base
	belongs_to :match_team 
	belongs_to :summoner
	belongs_to :league_tier
	belongs_to :league_division
end