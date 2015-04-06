require 'test_helper'

class LolApiHelperTest < ActionView::TestCase

	test "the truth" do
		assert true
	end


	test "get_teams5v5_by_summoner - Valide" do
		summonerFromRiot = LolApiHelper.get_summoner_by_name("Naytskai")
		Summoner.new(summonerFromRiot)
		summoner = Summoner.find_by(id: 19469066)
		puts summoner
		team = LolApiHelper.get_teams5v5_by_summoner(summoner)
		puts team
	end

	test "get_teams5v5_by_summoner - Unexisting summoner " do

	end


end
