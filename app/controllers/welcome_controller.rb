class WelcomeController < ApplicationController
	def index
		@nbMatches = Match.all.count
		@nbPlayers =  Summoner.all.where(validated: true).count
		@nbTeams = Team.all.count
		@nbRiotRequest = 0
		@nbDelayedRiotRequest = 0
		@nb404RiotRequest = 0
		# if File.exist?("log/riot_api.log")
		# 	@nbRiotRequest = open("log/riot_api.log").grep(/RiotRequest/).count
		# 	@nbDelayedRiotRequest = open("log/riot_api.log").grep(/429/).count
		# 	@nb404RiotRequest = open("log/riot_api.log").grep(/Not Found/).count
		# end
	end

	def riot
		riot_check_key = Rails.application.secrets.riot_verifaction_key.to_s
		render inline: riot_check_key
	end

end