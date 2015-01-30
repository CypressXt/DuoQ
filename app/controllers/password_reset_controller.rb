class PasswordResetController < ApplicationController
	
	def new
	end

	def create
		user = AppUser.find_by(email: params[:email])
		if user
			length = 12
			new_password = rand(36**length).to_s(36)
			user.changePassword(new_password)
			PasswordResetMailer.resetPassword(user, new_password).deliver
		end
		@message = { "success" => "A new password has been sent to "+user.email}
		render 'global_info'
	end
end