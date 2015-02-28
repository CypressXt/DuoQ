class LinkTeamCompositionWithTeamPlayerStatuses < ActiveRecord::Migration
	def change
		add_index :team_compositions, :player_status_id
	end
end
