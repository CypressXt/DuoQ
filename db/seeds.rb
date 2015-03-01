# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#Populate the TeamType table
TeamType.create("number_players"=>"2","name"=>"ranked duo","key"=>"RANKED_SOLO_5x5")
TeamType.create("number_players"=>"5","name"=>"ranked 5v5","key"=>"RANKED_TEAM_5x5")

#Populate the TeamDivision table
TeamDivision.create("name"=>"I", "value"=>"1")
TeamDivision.create("name"=>"II", "value"=>"2")
TeamDivision.create("name"=>"III", "value"=>"3")
TeamDivision.create("name"=>"IV", "value"=>"4")
TeamDivision.create("name"=>"V", "value"=>"5")

#Populate the TeamTier table
TeamTier.create("name"=>"bronze")
TeamTier.create("name"=>"silver")
TeamTier.create("name"=>"gold")
TeamTier.create("name"=>"platinum")
TeamTier.create("name"=>"diamond")
TeamTier.create("name"=>"master")
TeamTier.create("name"=>"challenger")