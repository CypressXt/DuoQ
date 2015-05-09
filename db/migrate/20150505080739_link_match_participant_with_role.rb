class LinkMatchParticipantWithRole < ActiveRecord::Migration
	def change
		add_column :match_participants, :player_role_id, :integer
		add_index :match_participants, :player_role_id
	end
end
