class Match < ActiveRecord::Base
	belongs_to :team_type
	belongs_to :season
	has_many :match_teams, dependent: :destroy
	has_many :relation_team_matches, dependent: :destroy
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
					result['100'] = result['100'].to_i+participant.kills
				else
					result['200'] = result['200'].to_i+participant.kills
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

	def get_your_sum_champion(appUser)
		summoners_ids = Array.new
		appUser.summoners.each do |appUsersum|
			summoners_ids << appUsersum.id
		end
		self.match_teams.each do |match_team|
			match_team.match_participants.each do |match_participant|
				if summoners_ids.include?(match_participant.summoner_id)
					return match_participant.champion
				end
			end
		end
		return nil
	end

	def get_match_date_and_time
		return self.match_date.strftime("%R - %d %h %Y")
	end

	def self.need_to_refresh(match_id) 
		if(!Match.find_by(riot_id: match_id))
			return true
		else
			match = Match.find_by(riot_id: match_id)
			match_teams = match.match_teams
			match_teams.each do |match_team|
				match_team.match_participants.each do |player|
					if player.player_lane == nil || player.player_role == nil
						return true
					end
				end
			end
			return false
		end
	end
end