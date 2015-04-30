module SessionsHelper
	
	def log_in_session(user)
		session[:AppUserLoggedId] = user.id
	end

	def current_logged_user
		user = AppUser.find_by(id: session[:AppUserLoggedId])
	end

	def logged_in?
		!session[:AppUserLoggedId].nil?
	end

	def log_out
		session.delete(:AppUserLoggedId)
	end

	def is_proprietary
		if current_logged_user != nil
			if (current_logged_user.id == params[:app_user_id].to_i ) 
				return true
			end
		end
		return false
	end
end