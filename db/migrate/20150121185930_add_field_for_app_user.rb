class AddFieldForAppUser < ActiveRecord::Migration
	def up
		add_column :app_users, :username, :string
		add_column :app_users, :email, :string
		add_column :app_users, :password, :string
		add_column :app_users, :mailConfirmed, :boolean
	end
	def down
		remove_column :app_users, :username
		remove_column :app_users, :email
		remove_column :app_users, :password
		remove_column :app_users, :mailConfirmed
	end
end
