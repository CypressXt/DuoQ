class LeagueDivision < ActiveRecord::Base
	has_many :teams
	has_many :summoners
end
