class DropColumnTeam < ActiveRecord::Migration
	def change
		remove_column :teams, :riot_key, :nb_player
	end
end
