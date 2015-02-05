class ReCreateTeamTable < ActiveRecord::Migration
	def change
		create_table :teams do |t|
			t.string :name
			t.belongs_to :team_type, index:true
		end
	end
end
