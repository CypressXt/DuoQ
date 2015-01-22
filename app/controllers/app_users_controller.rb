class AppUsersController < ApplicationController

	def user_params
		params.required(:app_user).permit(:username, :email, :password, :password_confirmation)
	end

	def new
		@user=AppUser.new
	end

	def create
		@user=AppUser.new(user_params)
		@user.attributes = {mailConfirmed: false}
		if @user.save
			redirect_to root_path
		else
			render 'new'
		end
	end
end
