class MatchTeam < ActiveRecord::Base
	belongs_to :match
	has_many :match_participants, dependent: :destroy
end
