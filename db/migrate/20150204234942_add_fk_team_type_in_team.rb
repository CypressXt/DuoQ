class AddFkTeamTypeInTeam < ActiveRecord::Migration
	def change
		add_column :teams, :team_type_id, :integer
		add_index :teams, :team_type_id
	end
end
