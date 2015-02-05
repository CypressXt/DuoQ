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
		team.team_type_id=params[:game_type]
		if team.save
			relationAppUserTeam = RelationTeamAppUser.new
			relationAppUserTeam.team_id=team.id
			relationAppUserTeam.app_user_id=@user.id
			teamMember1 = TeamComposition.new(team_id: team.id, summoner_id: params[:you])
			summoner1 = Summoner.find_or_create_by(LolApiHelper.get_summoner_id_by_name(params[:sumName1]))
			teamMember2 = TeamComposition.new(team_id: team.id, summoner_id: summoner1.id)
			if relationAppUserTeam.save && teamMember1.save && teamMember2.save && summoner1.save
				@message = { "success" => "Your team has been created !"}
				render 'global_info'
			else
				@message = { "danger" => "Something goes wrong while creating your team !"}
				render 'global_info'
			end
		else
			@message = { "danger" => "Something goes wrong while creating your team !"}
			render 'global_info'
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