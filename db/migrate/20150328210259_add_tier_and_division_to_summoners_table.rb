class AddTierAndDivisionToSummonersTable < ActiveRecord::Migration
	def change
		add_column :summoners, :tier_id, :integer
		add_column :summoners, :division_id, :integer
		add_index :summoners, :tier_id
		add_index :summoners, :division_id
	end
end
