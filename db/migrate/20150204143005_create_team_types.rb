class CreateTeamTypes < ActiveRecord::Migration
	def change
		create_table :team_types do |t|
			t.name
			t.integer :number_players
			t.timestamps
		end
	end
end
