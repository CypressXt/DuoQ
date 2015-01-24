class AppUser < ActiveRecord::Base

	def authenticate(email, password)
		user = find_by_email(email)
		if user && user.password == Digest::SHA1.hexdigest(password)
			user
		end
	end
end