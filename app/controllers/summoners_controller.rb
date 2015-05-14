class SummonersController < ApplicationController
	before_action :get_user
	before_action :connected?, :except => [:show]
	before_action :proprietary?, :except => [:show]

	def summoner_params
		params.require(:summoner).permit(:id, :name, :summonerLevel, :summonerToken, :region_id)
	end

	def index
		@summoners = @user.summoners.where(validated: true).order(:id)
	end

	def show
		@summoner = @user.summoners.find_by(id: params['id'])
		@ddragon_version = LolApiHelper.get_lastest_ddragon_version
	end

	def new
		@summoner = Summoner.new
	end

	def create_token
		summoner = Summoner.find_or_create_by(summoner_params)
		summonerFromRiot = LolApiHelper.get_summoner_by_name(summoner.name)
		if summonerFromRiot
			if summoner.app_user_id == nil || summoner.validated == false
				@summoner = Summoner.find_or_create_by(summonerFromRiot)
				@summoner.summonerToken = rand(36**25).to_s(36)
				@summoner.validated = false
				@summoner.region = Region.find_by(name: "euw") # BEFORE REGION MIGRATION
				#@summoner.region = Region.find_by(id: summoner_params['region_id']) AFTER REGION MIGRATION
				@summoner.get_tier_and_division
				@summoner.save
				client = XmppLeagueHelper.connect_xmpp(@summoner, @summoner.summonerToken)
				XmppLeagueHelper.invite_xmpp(@summoner,client)
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


	
	def get_user
		@user = AppUser.find_by(id: params[:app_user_id])
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