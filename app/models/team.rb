class Team < ActiveRecord::Base
	belongs_to :team_type
	belongs_to :league_tier
	belongs_to :league_division
	has_many :team_compositions
	has_many :summoners, through: :team_compositions
	has_many :relation_team_app_users
	has_many :relation_team_matches
	has_many :matches, through: :relation_team_matches
	has_many :app_users, through: :relation_team_app_users
	validates :team_type_id, presence: true

	def refresh_matches
		if self.team_type.key == "RANKED_TEAM_5x5"
			# Team 5v5 refresh 
			match_ids = LolApiHelper.get_team5v5_recent_match_ids(self)
		else
			# Team Duo refresh
			match_ids_sum1 = LolApiHelper.get_duo_match_id_by_summoner(self.summoners.first)
			match_ids_sum2 = LolApiHelper.get_duo_match_id_by_summoner(self.summoners.last)
			match_ids = match_ids_sum1 & match_ids_sum2
		end
		if match_ids
			match_ids.each do |match_id|
				if(Match.need_to_refresh(match_id))
					match = LolApiHelper.get_match_by_id(match_id)
					if match
						RelationTeamMatch.link_match_to_team(self, match)
					end
				else
					match = Match.find_by(riot_id: match_id)
					RelationTeamMatch.link_match_to_team(self, match)
				end
			end
		end
	end

	def self.refresh_all_team_matches
		cron_logger = Logger.new("#{Rails.root}/log/cron_jobs.log")
		cron_logger.info "[refresh_all_team_matches] starting match refreshing for all teams... "+Time.zone.now.to_s
		all_teams = self.all
		all_teams.each do |team|
			team.refresh_matches
		end
		cron_logger.info "[refresh_all_team_matches] Ended match refreshing for all teams... "+Time.zone.now.to_s
	end
end