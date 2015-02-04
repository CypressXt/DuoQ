class CreateTeamCompositions < ActiveRecord::Migration
	def change
		create_table :team_compositions do |t|
			t.integer :team_id
			t.integer :summoner_id
			t.timestamps
		end
		add_index :team_compositions, :team_id
		add_index :team_compositions, :summoner_id
	end
end
