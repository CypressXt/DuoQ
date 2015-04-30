class CreateRelationTeamMatches < ActiveRecord::Migration
	def change
		create_table :relation_team_matches do |t|
			t.belongs_to :team, index: true
			t.belongs_to :match, index: true
			t.timestamps null: false
		end
	end
end
