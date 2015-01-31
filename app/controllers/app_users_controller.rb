class AppUsersController < ApplicationController
	before_action :connected?, only: [:edit, :update, :send_mail]
	before_action :proprietary?, only: [:edit]
	after_action :send_mail, only: [:create]


	def user_params
		params.require(:app_user).permit(:username, :email, :password, :password_confirmation)
	end


	def show
		if (logged_in? && current_logged_user.id == params[:id].to_i)
			@user=current_logged_user
		else
			@user=AppUser.find_by(id: params[:id].to_i)
		end
		@gravatar_img_url = gravatar_url(@user)
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
			redirect_to app_user_path(@user.id)
		else
			render 'new'
		end
	end

	def edit
		@user = current_logged_user
		render 'update'
	end

	def update
		@user = AppUser.find(params[:id])
		if @user.update_attributes(user_params)
			hashed_password = Digest::SHA1.hexdigest(@user[:password])
			hashed_password_conf = Digest::SHA1.hexdigest(user_params[:password_confirmation])
			@user.update_attribute(:password, hashed_password)
			@user.update_attribute(:password_confirmation, hashed_password_conf)
			@gravatar_img_url = gravatar_url(@user)
			@message = { "success" => "Your personal information has correctly been updated !"}
			render 'global_info'
		else
			@gravatar_img_url = gravatar_url(@user)
			render 'update'
		end
	end

	def confirmation
		@user = AppUser.find_by(id: params[:id])
		if @user
			@validationResult="Hello "+@user.username
			if params[:token] == Digest::SHA1.hexdigest(@user.username+@user.email+@user.created_at.to_s).to_s
				if @user.mailConfirmed
					@message = { "info" => "Your email has already been validated, genius !"}
					render 'global_info'
				else
					@message = { "success" => "Your email has been validated, thanks !"}
					@user.update_attribute(:mailConfirmed, true)
					render 'global_info'
				end
			else
				@message = { "danger" => "Your email cannot be validated !"}
				render 'global_info'
			end
		else
			@message = { "danger" => "Dead link, nice try !"}
			render 'global_info'
		end
	end

	def send_mail
		user = current_logged_user
		if user && !user.mailConfirmed
			AppUserMailer.confirmation(user).deliver
		end
	end

	def resend_mail
		user = current_logged_user
		if user && !user.mailConfirmed
			AppUserMailer.confirmation(user).deliver
		end
		@message = { "success" => "A new mail has been sent to "+user.email}
		render 'global_info'
	end

	def gravatar_url(user)
		default_url = "#{root_url}images/guest.png"
		gravatar_id = Digest::MD5.hexdigest(user.email.downcase) 
		gravatar_img_url = "http://gravatar.com/avatar/#{gravatar_id}.png?s=800&d=#{CGI.escape(default_url)}"
		return gravatar_img_url
	end

	def connected?
		if !logged_in?
			redirect_to login_path
		end
	end

	def proprietary?
		if (current_logged_user.id != params[:id].to_i ) 
			@message = { "danger" => "You're not proprietary of this resource !"}
			render 'global_info'
		end
	end
end
