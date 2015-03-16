class AddEndpointRegionTable < ActiveRecord::Migration
	def change
		add_column :regions, :endpoint, :string
	end
end
