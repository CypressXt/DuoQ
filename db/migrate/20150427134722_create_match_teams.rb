class CreateMatchTeams < ActiveRecord::Migration
	def change
		create_table :match_teams do |t|
			t.integer :riot_id
			t.boolean :won
			t.boolean :first_blood
			t.boolean :first_tower
			t.boolean :first_inhibitor
			t.boolean :first_baron
			t.boolean :first_dragon
			t.integer :tower_kills
			t.integer :inhibitor_kills
			t.integer :baron_kills
			t.integer :dragon_kills
			t.integer :vilemaw_kills
			t.integer :match_id
			t.timestamps null: false
		end
		add_index :match_teams, :match_id
	end
end
