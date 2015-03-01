class AddFieldDivisionAndTierInTeam < ActiveRecord::Migration
	def change
		add_column(:teams, :tier, :string)
		add_column(:teams, :division, :string)
	end
end
