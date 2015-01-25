class AppUser < ActiveRecord::Base
	attr_accessor :password_confirmation

	validates :username, :email, :password, :password_confirmation, presence: true
	validates :password, confirmation: true
	validates :username, length: { in: 4..20 }
	validates :email, :username, uniqueness: true

	def authenticate(email, password)
		user = find_by_email(email)
		if user && user.password == Digest::SHA1.hexdigest(password)
			user
		end
	end
end