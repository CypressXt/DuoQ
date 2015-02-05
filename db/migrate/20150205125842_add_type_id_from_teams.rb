class AddTypeIdFromTeams < ActiveRecord::Migration
	def change
		add_reference :teams, :type, index:true
	end
end
