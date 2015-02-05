class TeamType < ActiveRecord::Base
	has_many :teams
	validates :number_players, :name, :key, presence: true
end
