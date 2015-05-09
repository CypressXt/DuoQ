class MatchesController < ApplicationController
	before_action :get_user
	before_action :is_match_existing


	def show
		@match = @user.team.find_by(id: params[:team_id]).matches.find_by(id: params[:id])
		@ddragon_version = LolApiHelper.get_lastest_ddragon_version
	end

	def is_match_existing
		if (@user && @user.team.find_by(id: params[:team_id]) && @user.team.find_by(id: params[:team_id]).matches.find_by(id: params[:id]) )
			return true
		else
			throw_404
		end
	end

	def get_user
		@user = AppUser.find_by(id: params[:app_user_id])
	end

end