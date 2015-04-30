class TeamType < ActiveRecord::Base
	has_many :teams
	has_many :matches
	validates :number_players, :name, :key, presence: true
end
