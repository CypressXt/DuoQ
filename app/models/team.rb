class Team < ActiveRecord::Base
	belongs_to :team_type
	belongs_to :league_tier
	belongs_to :league_division
	has_many :team_compositions
	has_many :summoners, through: :team_compositions
	has_many :relation_team_app_users
	has_many :relation_team_matches
	has_many :matches, through: :relation_team_matches
	has_many :app_users, through: :relation_team_app_users
	validates :team_type_id, presence: true
end
