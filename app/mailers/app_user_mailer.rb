class AppUserMailer < ActionMailer::Base

	def confirmation(appUser)
		@user = appUser
		mail to:      @user.email,
		from: "\"DuoQ\" duoq@cypressxt.net",
		subject: 'Confirmation de votre email'
		@validationUrl = "http://url.onch"
	end
end
