class RemoveFieldDivisionAndTierInTeam < ActiveRecord::Migration
	def change
		remove_column(:teams, :tier, :string)
		remove_column(:teams, :division, :string)
	end
end
