class SummonersController < ApplicationController

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
		sumIdReq = req.first[1]['id']
		flash[:sumId]=sumIdReq
		flash[:sumName]=req.first[0]
		token = ""
		token = rand(36**25).to_s(36)
		flash[:sent_summoner_token]=token
		client = XmppLeagueHelper.connect_xmpp(flash[:sent_summoner_token], flash[:sumId])
		XmppLeagueHelper.invite_xmpp(flash[:sumId],client)
	end

	def create
		if params[:summoner_token] == flash[:sent_summoner_token]
			summoner = Summoner.new({id: flash[:sumId].to_s, name: flash[:sumName].to_s, app_user_id: @user.id})
			if summoner.save
				@message = { "success" => "Your League of Legends account is now confirmed, thanks !"}
				render 'global_info'
			end
		else
			@message = { "danger" => "You send the wrong summoner's authentication key ! "+params[:summoner_token].to_s+" \n "+flash[:sent_summoner_token].to_s}
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