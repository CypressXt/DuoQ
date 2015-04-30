class RelationTeamMatch < ActiveRecord::Base
	belongs_to :team
	belongs_to :match

	def self.link_match_to_team(team, match)
		relationMatchTeam = RelationTeamMatch.find_or_create_by(team_id: team.id, match_id: match.id)
		return relationMatchTeam.save
	end
end
