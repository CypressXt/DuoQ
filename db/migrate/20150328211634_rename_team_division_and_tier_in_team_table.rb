class RenameTeamDivisionAndTierInTeamTable < ActiveRecord::Migration
	def change
		rename_column :teams, :team_tier_id, :league_tier_id
		rename_column :teams, :team_division_id, :league_division_id
	end
end
