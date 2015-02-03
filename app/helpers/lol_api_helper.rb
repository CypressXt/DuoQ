module LolApiHelper
	require 'net/http'
	require 'json'


	def get_summoner_id_by_name(name)
		result = perform_request("https://euw.api.pvp.net/api/lol/euw/v1.4/summoner/by-name/"+name+"?api_key="+Rails.application.secrets.riot_api_key.to_s)	
		if result
			summoner = JSON.parse(result).first[1]
			summoner.delete("profileIconId")
			summoner.delete("revisionDate")
			return summoner
		else
			return result
		end
	end


	def perform_request(url)
		Rails.logger.info "[RiotRequest] "+url
		resp = Net::HTTP.get_response(URI.parse(URI.encode(url)))
		Rails.logger.info "[RiotReply] "+resp.message.to_s
		if resp.code.to_s == "200"
			return resp.body
		else
			return nil
		end
	end

	module_function :get_summoner_id_by_name, :perform_request

end
