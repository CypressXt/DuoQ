class AddTagAndStatusFieldTeam < ActiveRecord::Migration
	def change
		add_column(:teams, :tag, :string)
		add_column(:teams, :rank, :string)
	end
end
