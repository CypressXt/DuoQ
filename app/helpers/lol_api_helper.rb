module LolApiHelper
	require 'net/http'
	require 'json'
	# Summoner -------------------------------------------------------------------------------------

	# This function return RIOT informations about a given summoner by name
	#
	# * *Args*    :
	#   - +name+ -> the summoner's name
	# * *Returns* :
	#   - A JSON array containing data like this: {"id"=>21734138, "name"=>"Naytskai", "summonerLevel"=>1}
	def get_summoner_by_name(name)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v1.4/summoner/by-name/"+name.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			summoner = JSON.parse(result).first[1]
			summoner.delete("profileIconId")
			summoner.delete("revisionDate")
			return summoner
		else
			check_query_resut(result, "get_summoner_by_name", name)
		end
	end

	# This function return RIOT informations about a given summoner by id
	#
	# * *Args*    :
	#   - +id+ -> the summoner's id
	# * *Returns* :
	#   - A JSON array containing data like this: {"id"=>21734138, "name"=>"Naytskai", "summonerLevel"=>1}
	def get_summoner_by_id(id)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v1.4/summoner/"+id.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			summoner = JSON.parse(result).first[1]
			summoner.delete("profileIconId")
			summoner.delete("revisionDate")
			return summoner
		else
			check_query_resut(result, "get_summoner_by_id", id)
		end
	end

	# This function return a LeagueTier object from a given Summoner object
	#
	# * *Args*    :
	#   - +summoner+ -> object from class Summoner
	# * *Returns* :
	#   - Object of class type LeagueTier
	def get_summoner_tier_by_id(summoner)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.5/league/by-summoner/"+summoner.id.to_s+"/entry?api_key="+Rails.application.secrets.riot_api_key.to_s)
		if check_http_error_code(result)
			riotTierName = JSON.parse(result).first[1][0]['tier'].downcase 
			return LeagueTier.find_by(name: riotTierName)
		else
			check_query_resut(result, "get_summoner_tier_by_id", summoner)
		end
	end

	# This function return a LeagueDivision object from a given Summoner object
	#
	# * *Args*    :
	#   - +summoner+ -> object from class Summoner
	# * *Returns* :
	#   - Object of class type LeagueDivision
	def get_summoner_division_by_id(summoner)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.5/league/by-summoner/"+summoner.id.to_s+"/entry?api_key="+Rails.application.secrets.riot_api_key.to_s)
		if check_http_error_code(result)
			riotDivisionName = JSON.parse(result).first[1][0]['entries'][0]['division']
			puts riotDivisionName
			return LeagueDivision.find_by(name: riotDivisionName)
		else
			check_query_resut(result, "get_summoner_division_by_id", summoner)
		end
	end
	# -------------------------------------------------------------------------------------------


	# Teams -------------------------------------------------------------------------------------

	# This function create/update 5v5 team's from an AppUser.
	# The team's informations are coming from RIOT API.
	#
	# * *Args*    :
	#   - +appuser+ -> object from class AppUser
	# * *Returns* :
	#   - True if all goes well
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
						RelationTeamAppUser.link_team_to_appuser(db_team, appuser)
						db_team.summoners.each do |summoner|
							summoner.get_tier_and_division
						end
						next
					end
					new5v5 = Team.find_or_create_by(name: team5v5['name'])
					new5v5.tag = team5v5['tag']
					new5v5.key = team5v5['fullId']
					new5v5.team_type = TeamType.find_by(key: "RANKED_TEAM_5x5")
					if new5v5.save
						RelationTeamAppUser.link_team_to_appuser(new5v5, appuser)
						#relationAppUserTeam = RelationTeamAppUser.find_or_create_by(team_id: new5v5.id, app_user_id: appuser.id)
						#relationAppUserTeam.save
						team5v5['roster']['memberList'].each do |teamMember|
							riotSum = Summoner.new(LolApiHelper.get_summoner_by_id(teamMember['playerId']))
							newSumm = Summoner.find_or_create_by(id: riotSum.id, name: riotSum.name)
							newSumm.summonerLevel = riotSum.summonerLevel
							newSumm.summonerToken = rand(36**25).to_s(36)
							if newSumm.save
								teamComposition = TeamComposition.find_or_create_by(team_id: new5v5.id, summoner_id: newSumm.id)
								teamComposition.save
								newSumm.get_tier_and_division
							end
						end
						refresh_team_league_by_team(new5v5)
					end
				end
			end
		end
		return true
	end


	# This function return RIOT infromation about all 5v5 teams by Summoner.
	#
	# * *Args*    :
	#   - +summoner+ -> object from class Summoner
	# * *Returns* :
	#   - A JSON array containing team's data
	def get_teams5v5_by_summoner(summoner)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.4/team/by-summoner/"+summoner.id.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			team = JSON.parse(result).first[1]
			return team
		else
			check_query_resut(result, "get_teams5v5_by_summoner", summoner)
		end
	end


	# This function update a Team LeagueTier and LeagueDivision.
	# Save the actual Team's LeagueTier and LeagueDivision directly in DB.
	#
	# * *Args*    :
	#   - +team+ -> object from class Team
	# * *Returns* :
	#   - VOID
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


	# This function get league information about a 5v5 Team object.
	#
	# * *Args*    :
	#   - +team+ -> object from class Team
	# * *Returns* :
	#   - A JSON array containing team's league data
	def get_team5v5_league_by_team(team)	
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.5/league/by-team/"+team.key.to_s+"/entry?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			teamLeague = JSON.parse(result).first[1][0]
			return teamLeague
		else
			check_query_resut(result, "get_team5v5_league_by_team", team)
		end
	end
	# -------------------------------------------------------------------------------------------

	# Matches -----------------------------------------------------------------------------------


	# This function get the last 10th matches from a given summoner.
	#
	# * *Args*    :
	#   - +summoner+ -> object from class Summoner
	# * *Returns* :
	#   - If all goes well, return the getted JSON array
	#   - Else return the http error code
	def get_duo_match_by_summoner(summoner)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v1.3/game/by-summoner/"+summoner.id.to_s+"/recent?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			
		else
			check_query_resut(result, "get_match_by_summoner", summoner)
		end
	end


	def get_match_by_id(match_id)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.2/match/"+match_id.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			
		else
			check_query_resut(result, "get_match_by_id", match_id)
		end
	end
	# -------------------------------------------------------------------------------------------




	# Generals ----------------------------------------------------------------------------------

	# This function execute an http get request on the asked url.
	#
	# * *Args*    :
	#   - +url+ -> String, asked url
	# * *Returns* :
	#   - If all goes well, return the getted JSON array
	#   - Else return the http error code
	def perform_request(url)
		Rails.logger.info "[RiotRequest] "+url
		resp = Net::HTTP.get_response(URI.parse(URI.encode(url)))
		Rails.logger.info "[RiotReply] "+resp.message.to_s
		if resp.code.to_s == "200"
			return resp.body
		else
			return resp.code.to_s
		end
	end

	# This function check if the result passed is an http error code.
	#
	# * *Args*    :
	#   - +result+ -> String, result of an http request
	# * *Returns* :
	#   - "True" if result is an http error code like 400 401 404 429 500 or 503
	#   - Else return "false"
	def check_http_error_code(result)
		if result && result!="400" && result!="401" && result!="404" && result!="429" && result!="500" && result!="503"
			return true
		else
			return false
		end
	end


	# This function call the function named by "functionName" and pass it the "functionItem".
	# This function check if the passed result is a 429 http's error code.
	# If the result is a 429 http's error code the function named by "functionName" is called. 
	#
	# * *Args*    :
	#   - +result+ -> String, result of an http request
	#   - +functionName+ -> String, name of the called function if result == 429 error
	#   - +functionItem+ -> Object, passed directly to the called function "functionName"
	# * *Returns* :
	#   - nill, if the result error code isn't a 429 or a 200 code 
	def check_query_resut(result, functionName, functionItem)
		if(result=="429")
			self.send functionName , functionItem
		elsif(result != "200")
			return nil
		end
	end
	# -------------------------------------------------------------------------------------------


	module_function :get_summoner_by_name, :get_summoner_by_id, :get_teams5v5_by_summoner, :get_team5v5_league_by_team, :refresh_teams_from_api_by_appuser, :refresh_team_league_by_team, :perform_request
	module_function :check_query_resut, :check_http_error_code, :get_summoner_tier_by_id, :get_summoner_division_by_id
end
