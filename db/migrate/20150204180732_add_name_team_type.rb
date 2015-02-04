class AddNameTeamType < ActiveRecord::Migration
	def change
		add_column :team_types, :name, :string
	end
end
