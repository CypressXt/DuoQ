class AppUser < ActiveRecord::Base
	has_many :summoners
	attr_accessor :password_confirmation

	validates :username, :email, :password, :password_confirmation, presence: true
	validates :password, confirmation: true
	validates :username, length: { in: 4..20 }
	validates :email, :username, uniqueness: true

	def changePassword(pass)
		user=AppUser.find_by(email: email)
		password=Digest::SHA1.hexdigest(pass)
		user.update_attribute(:password, password)
		user.save
	end

	def authenticate(pass)
		if pass == password
			true
		end
	end
end