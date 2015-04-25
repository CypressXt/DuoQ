class RelationTeamAppUser < ActiveRecord::Base
	belongs_to :team
	belongs_to :app_user
	validates :team_id, :app_user_id, presence: true


	def self.link_team_to_appuser(team, appUser)
		relationAppUserTeam = RelationTeamAppUser.find_or_create_by(team_id: team.id, app_user_id: appUser.id)
		return relationAppUserTeam.save
	end

end
