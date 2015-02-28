class AddTeamCompositionMemberStatus < ActiveRecord::Migration
	def change
		add_column :team_compositions, :player_status_id, :integer
	end
end
