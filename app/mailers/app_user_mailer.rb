class AppUserMailer < ActionMailer::Base

	def confirmation(appUser)
		@user = appUser
		mail to: @user.email,
		from: "\"DuoQ\" <duoq@cypressxt.net>",
		subject: 'Mail confirmation'
	end
end
