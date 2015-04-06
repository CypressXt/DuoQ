class Summoner < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :region
	belongs_to :league_tier
	belongs_to :league_division
	has_many :TeamComposition
	has_many :team, through: :TeamComposition
	validates :id, :name, :summonerLevel, :summonerToken, presence: true
	validates :summonerToken, uniqueness: true


	def get_tier_and_division
		sumTier  = LolApiHelper.get_summoner_tier_by_id(self)
		sumDivision = LolApiHelper.get_summoner_division_by_id(self)
		if sumDivision!=nil && sumTier!=nil
			self.league_division = sumDivision
			self.league_tier = sumTier
			self.save
		end
	end
end