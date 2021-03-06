class TeamsController < ApplicationController
	before_action :connected?, :proprietary?, :except => [:show]
	before_action :get_user
	before_action :get_current_team, :only => [:refresh_team_matches]


	def index
		@teamsDuo = Array.new
		@teams5v5 = Array.new
		if @user.summoners.first!=nil
			@teamsDuo = Array.new
			@teams5v5 = Array.new
			teams = @user.team
			teams.each do |team|
				if team.team_type.key=="RANKED_SOLO_5x5"
					@teamsDuo.push(team)
				elsif team.team_type.key=="RANKED_TEAM_5x5"
					@teams5v5.push(team)
				end
			end
		end
	end


	def show
		if (@user && Team.find_by(id: params[:id]) && @user.team.find_by(id: params[:id]))
			@team = @user.team.find_by(id: params[:id])
		else
			throw_404
		end
	end

	def new
		@team = Team.new
		@type = TeamType.all
	end

	def create
		if !team_already_exist(params)
			team = Team.new(team_params)
			team.team_type=TeamType.find_by(key: "RANKED_SOLO_5x5")
			if team.save
				# Adding the second summoner to the db
				summoner2 = Summoner.new(LolApiHelper.get_summoner_by_name(params[:sumName2]))
				summoner2.generate_token
				
				if summoner2.name==nil
					@message = { "danger" => "Error while adding your mate's summoner, please enter a valid summoner name..."}
					render 'global_info' and return
				end
				Summoner.find_or_create_by(id: summoner2.id) do |summoner|
					summoner.id = summoner2.id
					summoner.name = summoner2.name
					summoner.summonerToken = summoner2.summonerToken
					summoner.summonerLevel = summoner2.summonerLevel
					summoner.get_tier_and_division
					summoner.region = Region.find_by(name: "euw") # BEFORE REGION MIGRATION
				end
				if !Summoner.find_by(id: summoner2.id)
					@message = { "danger" => "Error while adding your mate's summoner to our database..."}
					render 'global_info' and return
				end
				#----------------------------------------------------

				# Adding first summoners to the new duo team (app_user's selected game account)
				teamMember1 = TeamComposition.new(team_id: team.id, summoner_id: params[:you])
				if !teamMember1.save
					@message = { "danger" => "Error while adding your personal summoner's account to your duo team..."}
					raise ActiveRecord::Rollback, "Db error while adding your mate summoner's"
					render 'global_info' and return
				end
				#----------------------------------------------------


				# Adding the second summoner to the new duo team
				teamMember2 = TeamComposition.new(team_id: team.id, summoner_id: summoner2.id)
				if !teamMember2.save
					@message = { "danger" => "Error while adding your mate summoner's account to your duo team..."}
					raise ActiveRecord::Rollback, "Db error while adding your mate summoner's"
					render 'global_info' and return
				end
				#----------------------------------------------------

				# Link duo team with user's DuoQ account
				if !RelationTeamAppUser.link_team_to_appuser(team, @user)
					@message = { "danger" => "Error while linking your duo with your DuoQ account..."}
					raise ActiveRecord::Rollback, "Db error while linking your duo"
					render 'global_info' and return
				else
					@message = { "success" => "Your team has been created !"}
					render 'global_info' and return
				end
				#----------------------------------------------------
			else
				@message = { "danger" => "Something goes wrong while creating your team !"}
				raise ActiveRecord::Rollback, "Something goes wrong while creating your team"
				render 'global_info' and return
			end
		else
			@message = { "warning" => "This team already exist and has been linked to your account !"}
			render 'global_info' and return
		end
	end

	def update

	end

	def destroy
		team = Team.find_by(id: params[:id])
		if team
			relationTeamAppUser = RelationTeamAppUser.find_by(team_id: params[:id], app_user_id: @user.id)
			relationTeamAppUser.destroy
			if !RelationTeamAppUser.find_by(team_id: params[:id])
				teamCompositions=TeamComposition.all.where(team_id: team.id)
				teamCompositions.each do |teamCompo|
					teamCompo.destroy
				end
				team.destroy
			end
			@message = { "success" => "Your team has been destroyed !"}
			render 'global_info'
		else
			@message = { "danger" => "Something goes wrong while destroying your team !"}
			render 'global_info'
		end
	end

	def refresh_teams
		if @user.summoners.first!=nil
			if LolApiHelper.refresh_teams_from_api_by_appuser(@user)
				redirect_to app_user_teams_path(@user.id)
			else
				@message = { "danger" => "Something goes wrong while updating your teams !"}
				render 'global_info'
			end
		else
			@message = { "danger" => "You need to register a summoner account first (Account>Game account>Link an account)"}
			render 'global_info'
		end
	end

	def refresh_team_matches
		@team.refresh_matches
		redirect_to app_user_team_path(@user.id, @team.id)
	end

	def team_already_exist(parameters)
		you = Summoner.find_by(id: parameters['you']).id
		mate = Summoner.new(LolApiHelper.get_summoner_by_name(parameters['sumName2'])).id
		yourTeamMembership = TeamComposition.where(summoner_id: you).map(&:team_id)
		mateTeamMembership = TeamComposition.where(summoner_id: mate).map(&:team_id)
		commonMembership = yourTeamMembership & mateTeamMembership
		commonMembership.each do |commonTeamId|
			commonTeam = Team.find_by(id: commonTeamId)
			if commonTeam.team_type == TeamType.find_by(key: "RANKED_SOLO_5x5")
				RelationTeamAppUser.link_team_to_appuser(commonTeam, @user)
				return true
			end
		end
		return false
	end

	def team_params
		params.permit(:team).permit(:id, :name)
	end

	def get_user
		@user = AppUser.find_by(id: params[:app_user_id])
	end

	def get_current_team
		self.get_user
		@team = AppUser.find_by(id: params[:app_user_id]).team.find_by(id: params[:team_id])
	end

	def connected?
		if !logged_in?
			redirect_to login_path
		end
	end

	def proprietary?
		if (current_logged_user.id != params[:app_user_id].to_i ) 
			@message = { "danger" => "You're not proprietary of this resource !"}
			render 'global_info'
		end
	end
end