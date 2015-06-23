class CreateMatchParticipantEvents < ActiveRecord::Migration
	def change
		create_table :match_participant_events do |t|
			t.integer :position_x
			t.integer :position_y
			t.integer :current_gold
			t.integer :total_gold
			t.integer :level
			t.integer :xp
			t.integer :minions_killed
			t.integer :jungle_minions_killed
			t.integer :timing
			t.belongs_to :match_participant, index:true
			t.timestamps null: false
		end
	end
end