class SessionsController < ApplicationController

	def new
		render 'login'
	end

	def create
		user = AppUser.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(Digest::SHA1.hexdigest(params[:session][:password]))
			log_in_session(user)
			redirect_to user
		else
			flash[:danger] = 'Invalid email and password combination'
			render 'login'
		end
	end

	def destroy
		log_out
		redirect_to root_url
	end
end