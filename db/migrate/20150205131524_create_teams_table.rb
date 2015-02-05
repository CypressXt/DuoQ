class CreateTeamsTable < ActiveRecord::Migration
	def change
		create_table :teams do |t|
			t.string :name
			t.string :riot_key
			t.integer :nb_player
			t.belongs_to :team_types, index:true
		end
	end
end
