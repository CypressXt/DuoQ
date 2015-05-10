class WelcomeController < ApplicationController
	def index
		@nbMatches = Match.all.count
		@nbPlayers =  Summoner.all.where(validated: true).count
		@nbTeams = Team.all.count
	end

end