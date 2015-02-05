class CreateRelationTeamAppUsers < ActiveRecord::Migration
	def change
		create_table :relation_team_app_users do |t|
			t.integer :app_user_id
			t.integer :team_id
			t.timestamps
		end
		add_index :relation_team_app_users, :app_user_id
		add_index :relation_team_app_users,:team_id
	end
end
