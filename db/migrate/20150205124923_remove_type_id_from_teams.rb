class RemoveTypeIdFromTeams < ActiveRecord::Migration
	def change
		remove_column :teams, :team_type
	end
end
