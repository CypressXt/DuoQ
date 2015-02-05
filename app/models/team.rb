class Team < ActiveRecord::Base
	belongs_to :TeamType
	has_many :TeamComposition
	has_many :summoner, through: :TeamComposition
	has_many :RelationTeamAppUser
	has_many :app_user, through: :RelationTeamAppUser
end
