class RenameTierIdAndDivisionIdInSummonerTable < ActiveRecord::Migration
	def change
		rename_column :summoners, :tier_id, :league_tier_id
		rename_column :summoners, :division_id, :league_division_id
	end
end
