class AddFkSummonersOnceAgain < ActiveRecord::Migration
	def change
		add_column :summoners, :app_user_id, :integer
		add_index :summoners, :app_user_id
	end
end
