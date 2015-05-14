class MatchParticipant < ActiveRecord::Base
	belongs_to :match_team 
	belongs_to :summoner
	belongs_to :league_tier
	belongs_to :league_division
	belongs_to :player_role
	belongs_to :player_lane
	belongs_to :champion


	def is_your_summoner(appUser_summoners)
		appUser_summoners.each do |appUser_summoner|
			if appUser_summoner.id == self.summoner_id 
				return true
			end
		end
		team = self.match_team.match.team.first
		if team.team_type.key == "RANKED_SOLO_5x5"
			team.summoners.each do |summoner|
				if summoner.id == self.summoner_id
					return true
				end
			end
		end
		return false
	end

	def has_won
		match_team = self.match_team
		return match_team.won
	end
end