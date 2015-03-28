class Summoner < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :region
	belongs_to :league_tier
	belongs_to :league_division
	has_many :TeamComposition
	has_many :team, through: :TeamComposition
	validates :id, :name, :summonerLevel, :summonerToken, presence: true
	validates :summonerToken, uniqueness: true
end