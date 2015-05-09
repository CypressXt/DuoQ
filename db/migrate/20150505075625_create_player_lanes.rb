class CreatePlayerLanes < ActiveRecord::Migration
	def change
		create_table :player_lanes do |t|
			t.string :name
			t.string :key
			t.timestamps null: false
		end
	end
end
