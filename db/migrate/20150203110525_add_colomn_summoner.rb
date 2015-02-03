class AddColomnSummoner < ActiveRecord::Migration
	def change
		add_column :summoners, :summonerLevel, :integer
		add_column :summoners, :summonerToken, :string
	end
end
