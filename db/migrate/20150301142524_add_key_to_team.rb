class AddKeyToTeam < ActiveRecord::Migration
	def change
		add_column :teams, :key, :string
	end
end
