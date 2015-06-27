class PerfStatusController < ApplicationController
	def index
		api_key = "6fbf67c07f4bc670da154cafae059fbb56adfb921c529db"
		app_id = "4915523"
		data = HTTParty.get('https://api.newrelic.com/v2/applications/'+app_id+'.json', headers: {'X-Api-Key' => api_key})
		@rep_time = data["application"]['application_summary']['response_time']
		@error_rate = data["application"]['application_summary']['error_rate']
		@score = data["application"]['application_summary']['apdex_score']
	end
end