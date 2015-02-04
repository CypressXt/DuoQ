class Team < ActiveRecord::Base
	has_one :TeamType
	has_many :TeamComposition
	has_many :summoner, through: :TeamComposition
end
