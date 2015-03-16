class Summoner < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :region
	has_many :TeamComposition
	has_many :team, through: :TeamComposition
	validates :id, :name, :summonerLevel, :summonerToken, presence: true
	validates :summonerToken, uniqueness: true
end