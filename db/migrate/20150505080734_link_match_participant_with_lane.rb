class LinkMatchParticipantWithLane < ActiveRecord::Migration
	def change
		add_column :match_participants, :player_lane_id, :integer
		add_index :match_participants, :player_lane_id
	end
end
