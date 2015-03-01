class DropTableTeamTier < ActiveRecord::Migration
	def change
		drop_table :team_tier
	end
end
