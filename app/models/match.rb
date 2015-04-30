class Match < ActiveRecord::Base
	belongs_to :team_type
	belongs_to :season
	has_many :match_teams
	has_many :relation_team_matches
	has_many :team, through: :relation_team_matches




	def is_won(team)
		match_teams = self.match_teams
		match_teams.each do |match_team|
			participants = match_team.match_participants
			participants.each do |participant|
				team_summoners = team.summoners
				team_summoners.each do |sum|
					if sum.id == participant.summoner_id
						return match_team.won
					end
				end
			end
		end
	end

	def get_score
		result = Hash.new
		self.match_teams.each do |match_team|
			match_team.match_participants.each do |participant|
				if match_team.riot_id == 100
					result['100'] = participant.kills
				else
					result['200'] = participant.kills
				end
			end
		end
		return result
	end

	def get_team_side(team)
		self.match_teams.each do |match_team|
			match_team.match_participants.each do |match_participant|
				team.summoners.each do |sum|
					if sum.id == match_participant.summoner_id
						return match_team.riot_id
					end
				end
			end
		end
	end
end