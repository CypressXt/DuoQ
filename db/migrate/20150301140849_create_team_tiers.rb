class CreateTeamTiers < ActiveRecord::Migration
	def change
		remove_column :teams, :tier_id
		create_table :team_tiers do |t|
			t.string :name
			t.timestamps
		end
		add_column :teams, :team_tier_id, :integer
		add_index :teams, :team_tier_id
		remove_column :teams, :team_division_fk
		add_column :teams, :team_division_id, :integer
		add_index :teams, :team_division_id
	end
end
