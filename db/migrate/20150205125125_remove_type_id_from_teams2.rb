class RemoveTypeIdFromTeams2 < ActiveRecord::Migration
	def change
		remove_column :teams, :type_id
	end
end
