class WelcomeController < ApplicationController
	before_action :get_user, :connected?, :proprietary?


	def index

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