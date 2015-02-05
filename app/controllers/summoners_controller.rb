class SummonersController < ApplicationController
	after_filter "save_previous_url", :only => [:index, :new]
	before_action :get_user, :connected?, :proprietary?

	attr_accessor :sumId
	attr_accessor :sumName
	attr_accessor :sumToken

	def summoner_params
		params.require(:summoner).permit(:id, :name, :summonerLevel, :summonerToken)
	end

	def get_user
		@user = AppUser.find_by(id: params[:app_user_id])
	end


	def index
		@summoners = @user.summoners.where(validated: true).order(:id)
	end


	def new
		@summoner = Summoner.new
	end


	def create_token
		summoner = Summoner.find_or_create_by(summoner_params)
		summonerFromRiot = LolApiHelper.get_summoner_id_by_name(summoner.name)
		if summonerFromRiot
			if summoner.app_user_id == nil || summoner.validated == false
				@summoner = Summoner.find_or_create_by(summonerFromRiot)
				sumIdReq = @summoner.id
				sum_name = @summoner.name
				token = rand(36**25).to_s(36)
				@summoner.summonerToken = token
				@summoner.validated = false
				@summoner.save
				client = XmppLeagueHelper.connect_xmpp(token, sumIdReq)
				XmppLeagueHelper.invite_xmpp(sumIdReq,client)
			else
				@message = { "danger" => "This summoner is already linked to a DuoQ account ! "}
				render 'global_info'
			end
		else
			@previouse_url = session[:previous_url]
			@message = { "danger" => "Enter a valide summoner's name ! "}
			render 'global_info'
		end
	end

	def create
		summoner = Summoner.find_by(summonerToken: params[:summoner_token])
		if summoner
			summoner.app_user_id = params[:app_user_id]
			summoner.validated = true
			if summoner.save
				@message = { "success" => "Your League of Legends account is now confirmed, thanks !"}
				render 'global_info'
			end
		else
			@message = { "danger" => "You send the wrong summoner's authentication key ! "}
			render 'global_info'
		end
	end


	def destroy
		summoner = Summoner.find_by(id: params[:id])
		if summoner
			summoner.app_user_id=nil
			if summoner.save
				@message = { "success" => "Your League of Legends account has been unlinked !"}
				render 'global_info'
			else
				@message = { "danger" => "Something went wrong while unlinking your League of Legends account! "}
				render 'global_info'
			end
		end
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


	def save_previous_url
		session[:previous_url] = URI(request.referer).path
	end
end