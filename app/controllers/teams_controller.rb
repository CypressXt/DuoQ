class TeamsController < ApplicationController
	before_action :get_user, :connected?, :proprietary?


	def index
		@teams = []
		summoners = @user.summoners
		summoners.each do |summoner|
			summoner.team.each do |team|
				@teams << team
			end
		end
	end

	def new
		@team = Team.new
		@type = TeamType.all
	end

	def create
		team = Team.new(team_params)
		team.type_id=params[:game_type]
		if team.save
			@message = { "success" => "Your team has been created !"}
			render 'global_info'
		else
			@message = { "danger" => "Something goes wrong while creating your team !"}
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
end