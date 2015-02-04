class AddKeyTeamType < ActiveRecord::Migration
	def change
		add_column :team_types, :key, :string
	end
end
