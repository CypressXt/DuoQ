class SummonersController < ApplicationController
	@@sumId
	@@sumName


	def summoner_params
		params.require(:summoner).permit(:name, :id)
	end

	before_action :get_user, :connected?, :proprietary?
	def get_user
		@user = AppUser.find_by(id: params[:app_user_id])
	end


	def index
		@summoners = @user.summoners
	end


	def new
		@summoner = Summoner.new
	end


	def create_token
		@summoner = Summoner.new(summoner_params)
		req = LolApiHelper.get_summoner_id_by_name(@summoner.name)
		sumId = req.first[1]['id']
		@@sumId=sumId
		@@sumName=@summoner.name
		puts "@@@@@@@@@@@@@@@@@@@@@ "+sumId.to_s
		token = ""
		token = rand(36**25).to_s(36)
		session[:sent_summoner_token]=token
		client = XmppLeagueHelper.connect_xmpp(token, sumId)
		XmppLeagueHelper.invite_xmpp(sumId,client)
	end

	def create
		if params[:summoner_token] == session[:sent_summoner_token]
			summoner = Summoner.new({id: @@sumId, name: @@sumName, app_user_id: @user.id})
			if summoner.save
				@message = { "success" => "Your League of Legends account is now confirmed, thanks !"}
				render 'global_info'
			end
		else
			@message = { "danger" => "You send the wrong summoner's authentication key !"}
			render 'global_info'
		end
	end


	def destroy

	end

	def connected?
		if !logged_in?
			redirect_to login_path
		end
	end

	def proprietary?
		if (current_logged_user.id != params[:app_user_id].to_i ) 
			@message = { "danger" => "You're not proprietary of this resource !"}
			render 'global_info'
		end
	end

end