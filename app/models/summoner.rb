class Summoner < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :region
	belongs_to :league_tier
	belongs_to :league_division
	has_many :TeamComposition
	has_many :match_participants
	has_many :team, through: :TeamComposition
	validates :id, :name,:summonerToken, :summonerLevel, presence: true
	validates :id, :summonerToken, uniqueness: true

	def generate_token
		self.summonerToken = rand(36**25).to_s(36)
	end

	def get_tier_and_division
		sumTier  = LolApiHelper.get_summoner_tier_by_id(self)
		sumDivision = LolApiHelper.get_summoner_division_by_id(self)
		if sumDivision!=nil && sumTier!=nil
			self.league_division = sumDivision
			self.league_tier = sumTier
			self.save
		end
	end

	def get_played_champ
		champion_hash={}
		all_match_participations=self.match_participants.all
		all_match_participations.each do |match_participation|
			champ_id = match_participation.champion.id
			champion_hash[champ_id]=champion_hash[champ_id].to_i+1
		end
		champion_hash = champion_hash.sort_by{|champ_id, game_played| game_played}.reverse
		return champion_hash
	end

	def get_5_most_played_champ
		champ_array = Array.new()
		get_played_champ.each_with_index do |champ,index|
			if index<5
				champ_array << Champion.find_by(id: champ[0])
			end
		end
		return champ_array
	end

	def get_champ_played_by_role(role_key)
		champ_hash = {}
		all_match_participations=self.match_participants.all
		all_match_participations.each do |match_participation|
			if PlayerRole.find_by(key: role_key)
				if match_participation.player_role.key == role_key
					champ_hash[match_participation.champion.id] = Champion.find_by(id: match_participation.champion.id)
				end
			else
				if match_participation.player_lane.key == role_key
					champ_hash[match_participation.champion.id] = Champion.find_by(id: match_participation.champion.id)
				end
			end
		end
		champ_array = Array.new
		champ_hash.each do |champ|
			champ_array << champ[1]
		end

		return champ_array
	end

	def get_win_loose_by_champ(champion, laneOrRole)
		result={}
		if laneOrRole!=""
			if PlayerLane.find_by(key: laneOrRole)
				match_results = self.match_participants.where(champion_id: champion.id).where(player_lane_id: PlayerLane.find_by(key: laneOrRole).id)
			else
				match_results = self.match_participants.where(champion_id: champion.id).where(player_role_id: PlayerRole.find_by(key: laneOrRole).id)
			end
		else
			match_results = self.match_participants.where(champion_id: champion.id)
		end
		match_results.each do |match_result|
			if match_result.has_won
				result['win']=result['win'].to_i+1
			else
				result['loose']=result['loose'].to_i+1
			end
		end
		return result
	end


	def get_nb_game_by_champ_and_role(champion, laneOrRole)
		games = get_win_loose_by_champ(champion, laneOrRole)
		total_game_played = games['win'].to_i+games['loose'].to_i
		return total_game_played
	end

	def get_win_loose_ratio_by_champ(champion, laneOrRole)
		match_played = get_win_loose_by_champ(champion, laneOrRole)
		total_game_played = match_played['loose'].to_i + match_played['win'].to_i
		if total_game_played.to_i!=0
			return (match_played['win'].to_f/total_game_played.to_i.to_f*100).round(1)
		else
			return 0
		end
	end

	def get_all_games_ordered_by_date
		matches = Array.new()
		self.match_participants.each do |match_participant|
			matches<<[match_participant.match_team.match, match_participant.league_tier, match_participant.league_division]
		end
		return matches.sort_by{|match| match[0].match_date}
	end

	def get_main_roles
		all_games = self.match_participants
		all_roles = {Support: Array.new(), ADC: Array.new(), Mid: Array.new(), Top: Array.new(), Jungle: Array.new}
		all_games.each do |player_result|
			if player_result.player_role.key == "DUO_CARRY" && player_result.player_lane.key == "BOTTOM"
				all_roles[:ADC] = all_roles[:ADC]<<player_result
			elsif player_result.player_role.key == "DUO_SUPPORT" && player_result.player_lane.key == "BOTTOM"
				all_roles[:Support] = all_roles[:Support] << player_result
			elsif player_result.player_lane.key == "TOP" && player_result.player_role.key == "SOLO"
				all_roles[:Top] = all_roles[:Top] << player_result
			elsif player_result.player_lane.key == "MIDDLE" && player_result.player_role.key == "SOLO"
				all_roles[:Mid] = all_roles[:Mid] << player_result
			elsif player_result.player_lane.key == "JUNGLE" && player_result.player_role.key == "NONE"
				all_roles[:Jungle] = all_roles[:Jungle] << player_result
			end
		end
		return Hash[all_roles.sort_by{|key, value| value.count}.reverse]
	end

	def get_average_info_by_match_participants_and_role(info, role)
		all_match_participations = self.get_main_roles[role.to_sym]
		total_infos = 0
		if all_match_participations
			number_of_games = all_match_participations.count

			all_match_participations.each do |match_participation|
				total_infos += match_participation.send(info)
			end
			if number_of_games > 0
				return (total_infos.to_f / number_of_games.to_f).to_f
			end
		end
		return 0
	end

	def get_total_info_by_match_participants_and_role(info, role)
		all_match_participations = self.get_main_roles[role.to_sym]
		total_infos = 0
		if all_match_participations
			number_of_games = all_match_participations.count

			all_match_participations.each do |match_participation|
				total_infos += match_participation.send(info)
			end
			if number_of_games > 0
				return total_infos
			end
		end
		return 0
	end


	def get_info_per_minutes_by_match_participants_and_role(info, role)
		all_match_participations = self.get_main_roles[role.to_sym]
		total_infos = 0
		total_playing_time = 0
		if all_match_participations
			number_of_games = all_match_participations.count

			all_match_participations.each do |match_participation|
				total_playing_time += match_participation.match_team.match.duration
				total_infos += match_participation.send(info)
			end
			if total_playing_time > 0
				return (total_infos.to_f/(total_playing_time.to_f/60)).to_f
			end
		end
		return 0
	end

	def get_win_rate(role)
		all_match_participations = self.get_main_roles[role.to_sym]
		total_game_played = 0
		total_won_game = 0
		if all_match_participations
			total_game_played = all_match_participations.count
			all_match_participations.each do |match_participation|
				if match_participation.match_team.won
					total_won_game = total_won_game+1
				end
			end
		end
		puts total_game_played
		puts total_won_game

		if total_game_played > 0
			return ((total_won_game.to_f/total_game_played.to_f)*100)
		end
		return 0
	end

	def get_kda_by_role(role)
		average_kills = self.get_average_info_by_match_participants_and_role("kills", role).round(1)
		average_assits = self.get_average_info_by_match_participants_and_role("assists", role).round(1)
		average_death = self.get_average_info_by_match_participants_and_role("deaths", role).round(1)
		return average_kills.to_s+"/"+average_death.to_s+"/"+average_assits.to_s
	end

	def get_teams
		return self.team
	end
end