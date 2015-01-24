class SessionsController < ApplicationController

	def new
		@user = AppUser.new
		render 'login'
	end

	def create
		
	end
end