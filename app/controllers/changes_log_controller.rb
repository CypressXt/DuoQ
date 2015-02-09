class ChangesLogController < ApplicationController

	def get_commits
		github = Github.new login:Rails.application.secrets.github_user, password:Rails.application.secrets.github_password
		@commits=[]
		data = github.repos.commits.all 'CypressXt', 'DuoQ', per_page: 10
		data.each do |commit|
			@commits << commit.commit
		end
	end



end