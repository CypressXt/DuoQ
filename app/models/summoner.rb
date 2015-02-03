class Summoner < ActiveRecord::Base
	belongs_to :app_user
	validates :id, :name, :summonerLevel, :summonerToken, presence: true
	validates :summonerToken, uniqueness: true
end