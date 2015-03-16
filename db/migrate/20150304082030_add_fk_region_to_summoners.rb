class AddFkRegionToSummoners < ActiveRecord::Migration
	def change
		add_column :summoners, :region_id, :integer
		add_index :summoners, :region_id
	end
end
