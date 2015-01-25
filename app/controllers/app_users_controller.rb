class AppUsersController < ApplicationController

	def user_params
		params.require(:app_user).permit(:username, :email, :password, :password_confirmation)
	end

	def new
		@user=AppUser.new
	end

	def create
		@user=AppUser.new(user_params)
		@user.attributes = {mailConfirmed: false}
		hashed_password = Digest::SHA1.hexdigest(@user[:password])
		hashed_password_conf = Digest::SHA1.hexdigest(user_params[:password_confirmation])
		@user.attributes = {password: hashed_password}
		@user.attributes = {password_confirmation: hashed_password_conf}
		if @user.save
			redirect_to @user
		else
			render 'new'
		end
	end
end
