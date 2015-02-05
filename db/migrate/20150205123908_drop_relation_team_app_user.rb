class DropRelationTeamAppUser < ActiveRecord::Migration
	def change
		drop_table :relation_team_app_users
	end
end
