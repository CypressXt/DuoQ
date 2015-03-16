class AddChatUrlToRegion < ActiveRecord::Migration
	def change
		add_column :regions, :chat_endpoint, :string
	end
end
