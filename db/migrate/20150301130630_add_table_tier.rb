class AddTableTier < ActiveRecord::Migration
	def change
		create_table :team_tier do |t|
			t.string :name
		end
		add_column(:teams, :tier_id, :integer)
		add_index :teams, :tier_id
	end
end
