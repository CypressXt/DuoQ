class CreateTeamPlayerStatus < ActiveRecord::Migration
	def change
		create_table :team_player_statuses do |t|
			t.string :label
		end
	end
end
