class CreateRelationTeamAppUser < ActiveRecord::Migration
	def change
		create_table :relation_team_app_users do |t|
			t.belongs_to :team, index: true
			t.belongs_to :app_user, index: true
		end
	end
end
