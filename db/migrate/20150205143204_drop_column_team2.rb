class DropColumnTeam2 < ActiveRecord::Migration
	def change
		remove_column :teams, :nb_player
	end
end
