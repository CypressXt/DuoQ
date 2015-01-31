module XmppLeagueHelper
	require 'xmpp4r'
	require 'xmpp4r/muc'
	require 'xmpp4r/roster'
	require 'xmpp4r/client'
	include Jabber


	def connect
		Jabber::debug = true
		client = Jabber::Client::new(Jabber::JID::new("duoqterminal@pvp.net"))
		client.use_ssl = true;
		client.connect("chat.euw1.lol.riotgames.com",5223)
		client.auth("AIR_NN3oQW4kzvR6Hwp")
		client.send(Jabber::Presence.new(:chat, "<body><profileIcon>21</profileIcon><level>30</level><wins>+9000</wins><leaves>30</leaves><odinWins>11</odinWins><odinLeaves>1</odinLeaves><queueType /><rankedLosses>0</rankedLosses><rankedRating>0</rankedRating><tier>GOLD</tier><rankedSoloRestricted>false</rankedSoloRestricted><rankedLeagueName /><rankedLeagueDivision /><rankedLeagueTier /><rankedLeagueQueue /><gameStatus>outOfGame</gameStatus><statusMsg /></body>"))
		#@client.send(Jabber::Presence.new.set_type(:available))
		roster = Roster::Helper.new(client)

		# new friend callback
		roster.add_subscription_callback do |item,pres|
			if pres.type.to_s == subscribed
				puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ NEW FRIEND BIIITCHHH "+pres.from.to_s+" "+pres.type.to_s+" ###########"
				send_a_message(pres.from.to_s, "Nice subscribtion")
			end
		end


		# Message callback
		client.add_message_callback do |m|
			puts m.body
			puts "................................Callback working"
		end
		return client
	end


	def send_a_message(summoner, data, client)
		# send a message with a content of "data" to the summoner
		message = " <message from='sum57467554@pvp.net' id='m_40' to='"+summoner+"' type='chat' xmlns='jabber:client'><body>"+data+"</body></message>"
		client.send(message)
	end

	def invite(sumId, client)
		# send a friend request to the summoner passed
		pres = Jabber::Presence.new.set_type(:subscribe).set_to("sum"+sumId.to_s+"@pvp.net")
		client.send(pres)
	end

	def get_friend_list(client)
		# request roster from jabber server, wait for response
		roster = Roster::Helper.new(client)
		roster.get_roster()
		roster.wait_for_roster()
		return roster
	end

	def friend_with?(sumId, roster)
		# check if the terminal is friend with the passed summoner
		roster.items.each do |jid, contact|
			if jid.to_s ==  "sum"+sumId.to_s+"@pvp.net" && contact.subscription=='both'
				return true
			else
				return false
			end
		end
	end

	module_function :connect, :send_a_message, :invite, :friend_with?, :get_friend_list
end
