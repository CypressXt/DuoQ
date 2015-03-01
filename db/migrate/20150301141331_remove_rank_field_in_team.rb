class RemoveRankFieldInTeam < ActiveRecord::Migration
	def change
		remove_column :teams, :rank
	end
end
