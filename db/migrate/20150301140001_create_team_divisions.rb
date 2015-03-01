class CreateTeamDivisions < ActiveRecord::Migration
	def change
		create_table :team_divisions do |t|
			t.string :name
			t.integer :value
			t.timestamps
		end
		add_column :teams, :team_division_fk, :integer
		add_index :teams, :team_division_fk
	end
end
