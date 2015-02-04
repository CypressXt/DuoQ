class RenameFkTeamTypeInTeam < ActiveRecord::Migration
	def change
		remove_column :teams, :team_type_id, :integer
		add_column :teams, :type_id, :integer
		add_index :teams, :type_id
	end
end
