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
		hashed_password = Digest::SHA1.hexdigest(@user[:password])
		@user.attributes = {password: hashed_password}
		if @user.save
			flash[:notice] = "Your account has been successfully created !"
			redirect_to new_app_user_path
		else
			flash[:notice] = "Failed to create your account"
			redirect_to new_app_user_path
		end
	end
end
