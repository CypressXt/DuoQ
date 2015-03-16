# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#Populate the TeamType table
TeamType.find_or_create_by("number_players"=>"2","name"=>"ranked duo","key"=>"RANKED_SOLO_5x5")
TeamType.find_or_create_by("number_players"=>"5","name"=>"ranked 5v5","key"=>"RANKED_TEAM_5x5")

#Populate the TeamDivision table
TeamDivision.find_or_create_by("name"=>"I", "value"=>"1")
TeamDivision.find_or_create_by("name"=>"II", "value"=>"2")
TeamDivision.find_or_create_by("name"=>"III", "value"=>"3")
TeamDivision.find_or_create_by("name"=>"IV", "value"=>"4")
TeamDivision.find_or_create_by("name"=>"V", "value"=>"5")

#Populate the TeamTier table
TeamTier.find_or_create_by("name"=>"bronze")
TeamTier.find_or_create_by("name"=>"silver")
TeamTier.find_or_create_by("name"=>"gold")
TeamTier.find_or_create_by("name"=>"platinum")
TeamTier.find_or_create_by("name"=>"diamond")
TeamTier.find_or_create_by("name"=>"master")
TeamTier.find_or_create_by("name"=>"challenger")

#Populate the Region table
region = Region.find_or_create_by("name"=>"br", "endpoint"=>"br.api.pvp.net")
region.chat_endpoint = "chat.br.lol.riotgames.com"
region.save
region = Region.find_or_create_by("name"=>"eune", "endpoint"=>"eune.api.pvp.net")
region = Region.find_or_create_by("name"=>"euw", "endpoint"=>"euw.api.pvp.net")
region.chat_endpoint = "chat.euw1.lol.riotgames.com"
region.save
region = Region.find_or_create_by("name"=>"kr", "endpoint"=>"kr.api.pvp.net")
region = Region.find_or_create_by("name"=>"lan", "endpoint"=>"lan.api.pvp.net")
region.chat_endpoint = "chat.la1.lol.riotgames.com"
region.save
region = Region.find_or_create_by("name"=>"las", "endpoint"=>"las.api.pvp.net")
region.chat_endpoint = "chat.la2.lol.riotgames.com"
region.save
region = Region.find_or_create_by("name"=>"na", "endpoint"=>"na.api.pvp.net")
region = Region.find_or_create_by("name"=>"oce", "endpoint"=>"oce.api.pvp.net")
region = Region.find_or_create_by("name"=>"tr", "endpoint"=>"tr.api.pvp.net")
region.chat_endpoint = "chat.tr.lol.riotgames.com"
region.save
region = Region.find_or_create_by("name"=>"ru", "endpoint"=>"ru.api.pvp.net")
region.chat_endpoint = "chat.ru.lol.riotgames.com"
region.save
region = Region.find_or_create_by("name"=>"global", "endpoint"=>"global.api.pvp.net")




