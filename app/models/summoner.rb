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

	def get_5_most_played_by_role(role_key)
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
end