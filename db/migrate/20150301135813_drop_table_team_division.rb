class DropTableTeamDivision < ActiveRecord::Migration
	def change
		drop_table :team_division
	end
end
