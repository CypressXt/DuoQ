class AppUser < ActiveRecord::Base
	attr_accessor :password_confirmation

	validates :username, :email, :password, :password_confirmation, presence: true
	validates :password, confirmation: true
	validates :username, length: { in: 4..20 }
	validates :email, :username, uniqueness: true



	def authenticate(pass)
		if pass == password
			true
		end
	end
end