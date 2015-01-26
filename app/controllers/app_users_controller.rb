class AppUsersController < ApplicationController

	def user_params
		params.require(:app_user).permit(:username, :email, :password, :password_confirmation)
	end


	def show
		@logged_user=current_logged_user
		default_url = "#{root_url}images/guest.png"
		gravatar_id = Digest::MD5.hexdigest(@logged_user.email.downcase) 
		@gravatar_img_url= "http://gravatar.com/avatar/#{gravatar_id}.png?s=800&d=#{CGI.escape(default_url)}"
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
			log_in_session @user
			redirect_to @user
		else
			render 'new'
		end
	end
end
