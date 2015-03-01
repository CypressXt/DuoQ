class Team < ActiveRecord::Base
	belongs_to :team_type
	belongs_to :team_tier
	belongs_to :team_division
	has_many :team_compositions
	has_many :summoners, through: :team_compositions
	has_many :relation_team_app_users
	has_many :app_users, through: :relation_team_app_users
	validates :team_type_id, presence: true
end
