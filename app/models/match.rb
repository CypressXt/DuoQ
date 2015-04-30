class Match < ActiveRecord::Base
	belongs_to :team_type
	belongs_to :season
	has_many :match_teams
	has_many :relation_team_matches
	has_many :team, through: :relation_team_matches




	def is_won(team)
		summoner = team.summoners.first
		match_teams = self.match_teams
		match_teams.each do |match_team|
			match_participants = match_team.match_participants
			match_participants.each do |participant|
				if summoner.id == participant.summoner.id
					return match_team.won
				end
			end
		end
	end



	
end
