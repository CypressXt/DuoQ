module LolApiHelper
	require 'net/http'


	def get_summoner_id_by_name(name)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v1.4/summoner/by-name/CýpressXt?api_key=b9e12604-3a32-44f1-b766-64028b22cbd7")	
		puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"+result.to_s
		summoner = JSON.parse(result)
		return summoner
	end


	def perform_request(url)
		return Net::HTTP.get(URI.parse(URI.encode(url)))
	end

	module_function :get_summoner_id_by_name, :perform_request

end
