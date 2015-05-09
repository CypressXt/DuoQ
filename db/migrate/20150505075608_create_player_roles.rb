class CreatePlayerRoles < ActiveRecord::Migration
	def change
		create_table :player_roles do |t|
			t.string :name
			t.string :key
			t.timestamps null: false
		end
	end
end
