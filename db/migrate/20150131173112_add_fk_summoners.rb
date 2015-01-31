class AddFkSummoners < ActiveRecord::Migration
	def change
		def up
			add_column :app_user_id, :integer
			add_index :summoners, :app_user_id
		end
		def down
			remove_column :app_user_id, :integer
			remove_index :summoners, :app_user_id
		end
	end
end
