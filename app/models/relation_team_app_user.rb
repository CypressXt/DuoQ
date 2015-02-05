class RelationTeamAppUser < ActiveRecord::Base
	belongs_to :team
	belongs_to :app_user
	validates :team_id, :app_user_id, presence: true
end
