class CreateMatches < ActiveRecord::Migration
	def change
		create_table :matches do |t|
			t.decimal :riot_id
			t.datetime :match_date
			t.integer :duration
			t.integer :team_type_id
			t.string :version
			t.integer :season_id
			t.timestamps null: false
		end
		add_index :matches, :team_type_id
		add_index :matches, :season_id
	end
end
