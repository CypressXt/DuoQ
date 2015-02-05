class Team < ActiveRecord::Base
	belongs_to :team_type
	has_many :team_compositions
	has_many :summoners, through: :team_compositions
	has_many :relation_team_app_users
	has_many :app_users, through: :relation_team_app_users
	validates :name, :team_type_id, presence: true
end
