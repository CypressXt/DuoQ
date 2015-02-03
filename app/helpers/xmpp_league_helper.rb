module XmppLeagueHelper
	require 'xmpp4r'
	require 'xmpp4r/muc'
	require 'xmpp4r/roster'
	require 'xmpp4r/client'
	include Jabber


	def connect_xmpp(token, sumId)
		Jabber::debug = Rails.application.secrets.xmpp_debug
		client = Jabber::Client::new(Jabber::JID::new(Rails.application.secrets.xmpp_riot_account))
		client.use_ssl = true;
		client.connect("chat.euw1.lol.riotgames.com",5223)
		client.auth(Rails.application.secrets.xmpp_riot_password)
		client.send(Jabber::Presence.new(:chat, "<body><profileIcon>21</profileIcon><level>30</level><wins>+9000</wins><leaves>30</leaves><odinWins>11</odinWins><odinLeaves>1</odinLeaves><queueType /><rankedLosses>0</rankedLosses><rankedRating>0</rankedRating><tier>GOLD</tier><rankedSoloRestricted>false</rankedSoloRestricted><rankedLeagueName /><rankedLeagueDivision /><rankedLeagueTier /><rankedLeagueQueue /><gameStatus>outOfGame</gameStatus><statusMsg /></body>"))
		#@client.send(Jabber::Presence.new.set_type(:available))
		roster = get_xmpp_friend_list(client)

		if xmpp_friend_with?(sumId, roster)
			send_xmpp_message("sum"+sumId.to_s+"@pvp.net", " Hello\nI'm sending you your authentication key: \n"+token+"\nsee you ;)", client)
		else
			roster.add_subscription_callback do |item,pres|
				if pres.type.to_s == "subscribed" && pres.from.to_s == "sum"+sumId.to_s+"@pvp.net"
					send_xmpp_message(pres.from.to_s, " Hello\nI'm sending you your authentication key: \n"+token+"\nsee you ;)", client)
				end
			end
		end

		# Message callback
		#client.add_message_callback do |m|
		#	puts m.body
		#	puts "................................Callback working"
		#end
		return client
	end


	def send_xmpp_message(summoner, data, client)
		# send a message with a content of "data" to the summoner
		Rails.logger.info "[RiotXmppSend] to:"+summoner
		message = " <message from='sum57467554@pvp.net' id='m_40' to='"+summoner+"' type='chat' xmlns='jabber:client'><body>"+data+"</body></message>"
		client.send(message)
	end

	def invite_xmpp(sumId, client)
		# send a friend request to the summoner passed
		Rails.logger.info "[RiotXmppFriend] to: sum"+sumId.to_s+"@pvp.net"
		pres = Jabber::Presence.new.set_type(:subscribe).set_to("sum"+sumId.to_s+"@pvp.net")
		client.send(pres)
	end

	def get_xmpp_friend_list(client)
		# request roster from jabber server, wait for response
		roster = Roster::Helper.new(client)
		roster.get_roster()
		roster.wait_for_roster()
		return roster
	end

	def xmpp_friend_with?(sumId, roster)
		# check if the terminal is friend with the passed summoner
		roster.items.each do |jid, contact|
			if jid.to_s ==  "sum"+sumId.to_s+"@pvp.net" && contact.subscription.to_s=='both'
				return true
			else
				return false
			end
		end
	end

	module_function :connect_xmpp, :send_xmpp_message, :invite_xmpp, :xmpp_friend_with?, :get_xmpp_friend_list
end
