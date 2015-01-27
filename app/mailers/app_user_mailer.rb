class AppUserMailer < ActionMailer::Base

	def confirmation(appUser)
		@user = appUser
		@validationUrl = "http://url.onch"
		mail to: @user.email,
		from: "\"DuoQ\" <duoq@cypressxt.net>",
		subject: 'Mail confirmation'
	end
end
