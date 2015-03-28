class RenameTeamDivisionAndTierTable < ActiveRecord::Migration
	def change
		rename_table :team_tiers, :league_tiers
		rename_table :team_divisions, :league_divisions
	end
end
