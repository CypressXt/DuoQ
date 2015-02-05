class RelationTeamAppUser < ActiveRecord::Base
	belongs_to :team
	belongs_to :app_user
end
