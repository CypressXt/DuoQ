class PasswordResetMailer < ActionMailer::Base
	def resetPassword(appUser, newPassword)
		@new_password = newPassword
		@user = appUser
		mail to: @user.email,
		from: "\"DuoQ\" <duoq@cypressxt.net>",
		subject: 'Password reset'
	end
end
