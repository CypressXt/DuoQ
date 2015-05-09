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
						team5v5['roster']['memberList'].each do |teamMember|
							riotSum = Summoner.new(LolApiHelper.get_summoner_by_id(teamMember['playerId']))
							newSumm = Summoner.find_or_create_by(id: riotSum.id, name: riotSum.name)
							newSumm.summonerLevel = riotSum.summonerLevel
							newSumm.region = Region.find_by(name: "euw") # BEFORE REGION MIGRATION
							newSumm.generate_token
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


	# This function get all the recent matches from a 5v5team and return an array
	# containing only matches ids.
	#
	# * *Args*    :
	#   - +team+ -> object from class Team
	# * *Returns* :
	#   - A array containing matches's ids
	def get_team5v5_recent_match_ids(team)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.4/team/"+team.key.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			historyJsonArray = JSON.parse(result).first[1]['matchHistory']
			matches_ids_array = []
			historyJsonArray.each do |match|
				matches_ids_array << match['gameId']
			end
			return matches_ids_array
		else
			check_query_resut(result, "get_team5v5_recent_match_ids", team)
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
	def get_duo_match_id_by_summoner(summoner)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.2/matchhistory/"+summoner.id.to_s+"?rankedQueues=RANKED_SOLO_5x5&api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			if(JSON.parse(result).first)
				matches = JSON.parse(result).first[1]
				duo_ranked_matches_id = []
				matches.each do |match|
					duo_ranked_matches_id << match['matchId']
				end
			end
			return duo_ranked_matches_id
		else
			check_query_resut(result, "get_duo_match_id_by_summoner", summoner)
		end
	end

	# This function get all the information about a match.
	#
	# * *Args*    :
	#   - +match_id+ -> Id of the concerned match
	# * *Returns* :
	#   - an object from class Match
	#   - nill if the match wasn't found on the riot api
	def get_match_by_id(match_id)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.2/match/"+match_id.to_s+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			jsonMatch = JSON.parse(result)
			if jsonMatch
				# Add new match in the match DB Table
				newDbMatch = Match.find_or_create_by(riot_id: jsonMatch['matchId'])
				newDbMatch.match_date = Time.at(jsonMatch['matchCreation']/1000)
				newDbMatch.team_type = TeamType.find_by(key: jsonMatch['queueType'])
				newDbMatch.version = jsonMatch['matchVersion'].to_s
				newDbMatch.duration = jsonMatch['matchDuration']
				newDbMatch.season = Season.find_by(riot_key: jsonMatch['season'])
				newDbMatch.save

				# Add the two team in the match_teams table
				teams = jsonMatch['teams']
				team100 = ""
				team200 = ""
				teams.each do |team|
					matchTeam = MatchTeam.find_or_create_by({ match_id: newDbMatch.id, riot_id: team['teamId']})
					matchTeam.riot_id = team['teamId']
					matchTeam.won = team['winner']
					matchTeam.first_blood = team['firstBlood']
					matchTeam.first_tower = team['firstTower']
					matchTeam.first_inhibitor = team['firstInhibitor']
					matchTeam.first_baron = team['firstBaron']
					matchTeam.first_dragon = team['firstDragon']
					matchTeam.tower_kills = team['towerKills']
					matchTeam.inhibitor_kills = team['inhibitorKills']
					matchTeam.baron_kills = team['baronKills']
					matchTeam.dragon_kills = team['dragonKills']
					matchTeam.vilemaw_kills = team['vilemawKills']
					matchTeam.save
					if matchTeam.riot_id == 100
						team100 = matchTeam
					else
						team200 = matchTeam
					end
				end

				# Add all participants in the match_participants table
				participants = jsonMatch['participants']
				participants.each do |participant|
					summoners = jsonMatch['participantIdentities']
					db_summoner = nil
					summoners.each do |summoner|
						if summoner['participantId'] == participant['participantId']
							db_summoner = Summoner.find_by(id: summoner['player']['summonerId'].to_i)
							if db_summoner== nil || db_summoner.name == ""
								db_summoner = Summoner.new(LolApiHelper.get_summoner_by_id(summoner['player']['summonerId']))
								db_summoner.generate_token
								db_summoner.save
							end
							db_summoner.region = Region.find_by(name: "euw") # BEFORE REGION MIGRATION
							db_summoner.save
							db_summoner.get_tier_and_division
							break
						end
					end

					if participant['teamId'] == 100
						dbParticipant = MatchParticipant.find_or_create_by({ match_team_id:  team100.id, summoner_id: db_summoner.id, participant_number: participant['participantId']})
					else
						dbParticipant = MatchParticipant.find_or_create_by({ match_team_id:  team200.id, summoner_id: db_summoner.id, participant_number: participant['participantId']})
					end
					
					# Set MatchParticipant stats
					dbParticipant.league_tier = db_summoner.league_tier
					dbParticipant.league_division = db_summoner.league_division
					dbParticipant.summoner_level = db_summoner.summonerLevel
					dbParticipant.spell1_id = participant['spell1Id']
					dbParticipant.spell2_id = participant['spell2Id']
					dbParticipant.champion_id = participant['championId']
					dbParticipant.champion_level = participant['stats']['champLevel']
					dbParticipant.item0_id = participant['stats']['item0']
					dbParticipant.item1_id = participant['stats']['item1']
					dbParticipant.item2_id = participant['stats']['item2']
					dbParticipant.item3_id = participant['stats']['item3']
					dbParticipant.item4_id = participant['stats']['item4']
					dbParticipant.item5_id = participant['stats']['item5']
					dbParticipant.item6_id = participant['stats']['item6']
					dbParticipant.kills = participant['stats']['kills']
					dbParticipant.double_kills = participant['stats']['doubleKills']
					dbParticipant.triple_kills = participant['stats']['tripleKills']
					dbParticipant.quadra_kills = participant['stats']['quadraKills']
					dbParticipant.penta_kills = participant['stats']['pentaKills']
					dbParticipant.unreal_kills = participant['stats']['unrealKills']
					dbParticipant.largest_killing_spree = participant['stats']['largestKillingSpree']
					dbParticipant.deaths = participant['stats']['deaths']
					dbParticipant.assists = participant['stats']['assists']
					dbParticipant.total_damage_dealt = participant['stats']['totalDamageDealt']
					dbParticipant.total_damage_dealt_to_champions = participant['stats']['totalDamageDealtToChampions']
					dbParticipant.total_damage_taken = participant['stats']['totalDamageTaken']
					dbParticipant.largest_critical_strike = participant['stats']['largestCriticalStrike']
					dbParticipant.total_heal = participant['stats']['totalHeal']
					dbParticipant.minions_killed = participant['stats']['minionsKilled']
					dbParticipant.neutral_minions_killed = participant['stats']['neutralMinionsKilled']
					dbParticipant.neutral_minions_killed_team_jungle = participant['stats']['neutralMinionsKilledTeamJungle']
					dbParticipant.neutral_minions_killed_enemy_jungle = participant['stats']['neutralMinionsKilledEnemyJungle']
					dbParticipant.gold_earned = participant['stats']['goldEarned']
					dbParticipant.gold_spent = participant['stats']['goldSpent']
					dbParticipant.combat_player_score = participant['stats']['combatPlayerScore']
					dbParticipant.objective_player_score = participant['stats']['objectivePlayerScore']
					dbParticipant.total_player_score = participant['stats']['totalPlayerScore']
					dbParticipant.total_score_rank = participant['stats']['totalScoreRank']
					dbParticipant.magic_damage_dealt_to_champions = participant['stats']['magicDamageDealtToChampions']
					dbParticipant.physical_damage_dealt_to_champions = participant['stats']['physicalDamageDealtToChampions']
					dbParticipant.true_damage_dealt_to_champions = participant['stats']['trueDamageDealtToChampions']
					dbParticipant.vision_wards_bought_in_game = participant['stats']['visionWardsBoughtInGame']
					dbParticipant.sight_wards_bought_in_game = participant['stats']['sightWardsBoughtInGame']
					dbParticipant.magic_damage_dealt = participant['stats']['magicDamageDealt']
					dbParticipant.physical_damage_dealt = participant['stats']['physicalDamageDealt']
					dbParticipant.true_damage_dealt = participant['stats']['trueDamageDealt']
					dbParticipant.magic_damage_taken = participant['stats']['magicDamageTaken']
					dbParticipant.physical_damage_taken = participant['stats']['physicalDamageTaken']
					dbParticipant.true_damage_taken = participant['stats']['trueDamageTaken']
					dbParticipant.first_blood_kill = participant['stats']['firstBloodKill']
					dbParticipant.first_blood_assist = participant['stats']['firstBloodAssist']
					dbParticipant.first_tower_kill = participant['stats']['firstTowerKill']
					dbParticipant.first_tower_assist = participant['stats']['firstTowerAssist']
					dbParticipant.first_inhibitor_kill = participant['stats']['firstInhibitorKill']
					dbParticipant.first_inhibitor_assist = participant['stats']['firstInhibitorAssist']
					dbParticipant.inhibitor_kills = participant['stats']['inhibitorKills']
					dbParticipant.tower_kills = participant['stats']['towerKills']
					dbParticipant.wards_placed = participant['stats']['wardsPlaced']
					dbParticipant.wards_killed = participant['stats']['wardsKilled']
					dbParticipant.largest_multi_kill = participant['stats']['largestMultiKill']
					dbParticipant.killing_sprees = participant['stats']['killingSprees']
					dbParticipant.total_units_healed = participant['stats']['totalUnitsHealed']
					dbParticipant.total_time_crowd_control_dealt = participant['stats']['totalTimeCrowdControlDealt']
					dbParticipant.player_lane = PlayerLane.find_by(key: participant['timeline']['lane'])
					dbParticipant.player_role = PlayerRole.find_by(key: participant['timeline']['role'])
					dbParticipant.save
				end
			end
			return newDbMatch
		else
			check_query_resut(result, "get_match_by_id", match_id)
		end
	end
	# -------------------------------------------------------------------------------------------

	# Champions ---------------------------------------------------------------------------------

	# This function get the last 10th matches from a given summoner.
	#
	# * *Args*    :
	#   - +champion_id+ -> ID of the champion asked
	# * *Returns* :
	#   - 
	def get_all_champions
		result = perform_request("https://global.api.pvp.net/api/lol/static-data/euw/v1.2/champion?dataById=true&champData=image&api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			jsonChampions = JSON.parse(result)['data']
		else
			check_query_resut(result, "get_champion_by_id", champion_id)
		end
	end

	# This function get the last 10th matches from a given summoner.
	#
	# * *Args*    :
	#   - +champion_id+ -> ID of the champion asked
	# * *Returns* :
	#   - 
	def get_champion_by_id(champion_id)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v2.2/matchhistory/"+summoner.id.to_s+"?rankedQueues=RANKED_SOLO_5x5&api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			
		else
			check_query_resut(result, "get_champion_by_id", champion_id)
		end
	end

	# -------------------------------------------------------------------------------------------


	# DDragon external resources
	
	# This function get lastest version number of DDragon resources.
	#
	# * *Args*    :
	#   - 
	# * *Returns* :
	#   - version number
	def get_lastest_ddragon_version
		result = perform_request("https://global.api.pvp.net/api/lol/static-data/euw/v1.2/versions?&api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if check_http_error_code(result)
			jsonVersion = JSON.parse(result).first
		else
			check_query_resut(result, "get_lastest_ddragon_version", "")
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
		riot_logger = Logger.new("#{Rails.root}/log/riot_api.log")
		riot_logger.info "[RiotRequest] "+url
		resp = Net::HTTP.get_response(URI.parse(URI.encode(url)))
		riot_logger.info "[RiotReply] "+resp.message.to_s
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
	module_function :check_query_resut, :check_http_error_code, :get_summoner_tier_by_id, :get_summoner_division_by_id, :get_team5v5_recent_match_ids, :get_duo_match_id_by_summoner
	module_function :get_match_by_id, :get_all_champions, :get_lastest_ddragon_version
end
