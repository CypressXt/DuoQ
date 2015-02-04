class TeamComposition < ActiveRecord::Base
	belongs_to :team
	belongs_to :summoner
end
