class AddValidaeColomnSummoner < ActiveRecord::Migration
	def change
		add_column :summoners, :validated, :boolean
	end
end
