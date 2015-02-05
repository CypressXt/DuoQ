class TeamComposition < ActiveRecord::Base
	belongs_to :team
	belongs_to :summoner
	validates :team_id, :summoner_id, presence: true
end
