class Champion < ActiveRecord::Base
	has_many :match_participants

	def self.refresh_all_champions
		riot_champion_list = LolApiHelper.get_all_champions
		riot_champion_list.each do |champion|
			db_champion = Champion.find_or_create_by(id: champion[1]['id'].to_i)
			db_champion.key = champion[1]['key']
			db_champion.name = champion[1]['name']
			db_champion.title = champion[1]['title']
			db_champion.image = champion[1]['image']['full']
			db_champion.save
		end
	end
end