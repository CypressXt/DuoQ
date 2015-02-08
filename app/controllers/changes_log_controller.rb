class ChangesLogController < ApplicationController

	def get_commits
		nbCommits=10
		github = Github.new login:Rails.application.secrets.github_user, password:Rails.application.secrets.github_password
		@commits=[]
		data = github.repos.commits.all 'CypressXt', 'DuoQ'
		data.each do |commit|
			@commits << commit.commit
			nbCommits=nbCommits-1
			if nbCommits == 0
				break
			end
		end
	end



end
