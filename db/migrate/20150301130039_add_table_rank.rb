class AddTableRank < ActiveRecord::Migration
	def change
		create_table :team_division do |t|
			t.integer :value
			t.string :name
		end
		add_index :teams, :id
	end
end
