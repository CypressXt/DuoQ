module LolApiHelper
	require 'net/http'
	require 'json'



	# Summoner -------------------------------------------------------------------------------------
	def get_summoner_by_name(name)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v1.4/summoner/by-name/"+name.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if result && result!="404"
			summoner = JSON.parse(result).first[1]
			summoner.delete("profileIconId")
			summoner.delete("revisionDate")
			return summoner
		else
			if(result=="404")
				return nil
			end
			get_summoner_by_name(name)
		end
	end

	def get_summoner_by_id(id)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v1.4/summoner/"+id.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if result && result!="404"
			summoner = JSON.parse(result).first[1]
			summoner.delete("profileIconId")
			summoner.delete("revisionDate")
			return summoner
		else
			if(result=="404")
				return nil
			end
			get_summoner_by_id(id)
		end
	end

	def get_summoner_league_by_id(summoner)
		result = perform_request()
		if result && result!="404"
		else

		end
	end
	# -------------------------------------------------------------------------------------------


	# Teams -------------------------------------------------------------------------------------
	def refresh_teams_from_api_by_appuser(appuser)
		appuser.summoners.each do |summonerFromUser|
			t5v5 = LolApiHelper.get_teams5v5_by_summoner(summonerFromUser)
			if t5v5 != nil
				t5v5.each do |team5v5|
					db_team=Team.find_by(name: team5v5['name'])
					if db_team && team5v5['modifyDate'] < db_team.updated_at.to_i*1000
						t = ((db_team.updated_at.to_i*1000-team5v5['modifyDate'])/1000)
						mm, ss = t.divmod(60)
						hh, mm = mm.divmod(60)
						dd, hh = hh.divmod(24)
						lastChange = " last change "+dd.to_s+" days "+hh.to_s+" hours "+mm.to_s+" min "+ss.to_s+" sec"
						Rails.logger.info("[Refresh_team_skipped] "+team5v5['name']+" riot_version:"+ team5v5['modifyDate'].to_s+" db_version:"+ (db_team.updated_at.to_i*1000).to_s+lastChange)
						refresh_team_league_by_team(db_team)
						next
					end
					Rails.logger.info("[Refresh_team_skipped] "+team5v5['name'])
					new5v5 = Team.find_or_create_by(name: team5v5['name'])
					new5v5.tag = team5v5['tag']
					new5v5.key = team5v5['fullId']
					new5v5.team_type = TeamType.find_by(key: "RANKED_TEAM_5x5")
					if new5v5.save
						relationAppUserTeam = RelationTeamAppUser.find_or_create_by(team_id: new5v5.id, app_user_id: appuser.id)
						relationAppUserTeam.save
						team5v5['roster']['memberList'].each do |teamMember|
							riotSum = Summoner.new(LolApiHelper.get_summoner_by_id(teamMember['playerId']))
							newSumm = Summoner.find_or_create_by(id: riotSum.id, name: riotSum.name)
							newSumm.summonerLevel = riotSum.summonerLevel
							newSumm.summonerToken = rand(36**25).to_s(36)
							if newSumm.save
								teamComposition = TeamComposition.find_or_create_by(team_id: new5v5.id, summoner_id: newSumm.id)
								teamComposition.save
							end
						end
						refresh_team_league_by_team(new5v5)
					end
				end
			end
		end
		return true
	end

	def get_teams5v5_by_summoner(summoner)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.4/team/by-summoner/"+summoner.id.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if result && result!="404"
			team = JSON.parse(result).first[1]
			return team
		else
			if(result=="404")
				return nil
			end
			get_teams5v5_by_summoner(summoner)
		end
	end

	def refresh_team_league_by_team(team)
		teamLeagueInfo = LolApiHelper.get_team5v5_league_by_team(team)
		if teamLeagueInfo
			team.team_tier = LeagueTier.find_by(name: teamLeagueInfo['tier'].downcase)
			team.team_division = LeagueDivision.find_by(name: teamLeagueInfo['entries'].first['division'])
		else
			team.league_tier = nil
			team.league_division = nil
		end
		team.save
	end

	def get_team5v5_league_by_team(team)	
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.5/league/by-team/"+team.key.to_s+"/entry?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if result && result!="404"
			teamLeague = JSON.parse(result).first[1][0]
			return teamLeague
		else
			if(result=="404")
				return nil
			end
			get_team5v5_league_by_team(team)
		end
	end
	# -------------------------------------------------------------------------------------------



	# Teams -------------------------------------------------------------------------------------


	# -------------------------------------------------------------------------------------------

	def perform_request(url)
		Rails.logger.info "[RiotRequest] "+url
		resp = Net::HTTP.get_response(URI.parse(URI.encode(url)))
		Rails.logger.info "[RiotReply] "+resp.message.to_s
		if resp.code.to_s == "200" || resp.code.to_s == "404"
			if (resp.code.to_s == "404")
				return "404"
			else
				return resp.body
			end
		else
			return nil
		end
	end

	module_function :get_summoner_by_name, :get_summoner_by_id, :get_teams5v5_by_summoner, :get_team5v5_league_by_team, :refresh_teams_from_api_by_appuser, :refresh_team_league_by_team, :perform_request
end
