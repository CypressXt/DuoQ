class AppUsersController < ApplicationController


	def new
		@user=AppUser.new
	end
end
