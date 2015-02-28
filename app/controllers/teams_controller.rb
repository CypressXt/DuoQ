class TeamsController < ApplicationController
	after_filter "save_previous_url", :only => [:index, :new]
	before_action :get_user, :connected?, :proprietary?


	def index
		@teams = []
		teamsLocals = @user.team
		teamsLocals.each do |team|
			@teams.push(team)
		end
	end

	def new
		@team = Team.new
		@type = TeamType.all
	end

	def create
		team = Team.new(team_params)
		team.team_type_id=TeamType.find_by(key: "RANKED_SOLO_5x5").id
		if team.save
			# Adding the second summoner to the db
			summoner2 = Summoner.new(LolApiHelper.get_summoner_id_by_name(params[:sumName2]))
			summoner2.summonerToken = rand(36**25).to_s(36)
			
			if summoner2.name==nil
				@message = { "danger" => "Error while adding your mate's summoner, please enter a valid summoner name..."}
				render 'global_info' and return
			end
			Summoner.find_or_create_by(id: summoner2.id) do |summoner|
				summoner.id = summoner2.id
				summoner.name = summoner2.name
				summoner.app_user_id = @user.id
				summoner.summonerToken = summoner2.summonerToken
				summoner.summonerLevel = summoner2.summonerLevel
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
			relationAppUserTeam = RelationTeamAppUser.new
			relationAppUserTeam.team_id=team.id
			relationAppUserTeam.app_user_id=@user.id
			if !relationAppUserTeam.save
				@message = { "danger" => "Error while linking your duo with your DuoQ account..."}
				raise ActiveRecord::Rollback, "Db error while linking your duo"
				render 'global_info' and return
			else
				@message = { "success" => "Your team has been created !"}
				render 'global_info' and return
			end
			#----------------------------------------------------
		else
			@message = { "danger" => "Something goes wrong while creating your team !"+params.to_s}
			raise ActiveRecord::Rollback, "Something goes wrong while creating your team"
			render 'global_info' and return
		end
	end

	def edit
		@team = Team.find_by(id: params[:id])
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

	def team_params
		params.require(:team).permit(:id, :name)
	end

	def get_user
		@user = AppUser.find_by(id: params[:app_user_id])
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


	def save_previous_url
		session[:previous_url] = URI(request.referer).path
	end
end