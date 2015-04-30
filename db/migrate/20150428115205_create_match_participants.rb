class CreateMatchParticipants < ActiveRecord::Migration
	def change
		create_table :match_participants do |t|
			t.integer :participant_number
			t.integer :match_team_id
			t.integer :summoner_id
			t.integer :league_tier_id
			t.integer :league_division_id
			t.integer :summoner_level
			t.integer :spell1_id
			t.integer :spell2_id
			t.integer :champion_id
			t.integer :champion_level
			t.integer :item0_id
			t.integer :item1_id
			t.integer :item2_id
			t.integer :item3_id
			t.integer :item4_id
			t.integer :item5_id
			t.integer :item6_id
			t.integer :kills
			t.integer :double_kills
			t.integer :triple_kills
			t.integer :quadra_kills
			t.integer :penta_kills
			t.integer :unreal_kills
			t.integer :largest_killing_spree
			t.integer :deaths
			t.integer :assists
			t.integer :total_damage_dealt
			t.integer :total_damage_dealt_to_champions
			t.integer :total_damage_taken
			t.integer :largest_critical_strike
			t.integer :total_heal
			t.integer :minions_killed
			t.integer :neutral_minions_killed
			t.integer :neutral_minions_killed_team_jungle
			t.integer :neutral_minions_killed_enemy_jungle
			t.integer :gold_earned
			t.integer :gold_spent
			t.integer :combat_player_score
			t.integer :objective_player_score
			t.integer :total_player_score
			t.integer :total_score_rank
			t.integer :magic_damage_dealt_to_champions
			t.integer :physical_damage_dealt_to_champions
			t.integer :true_damage_dealt_to_champions
			t.integer :vision_wards_bought_in_game
			t.integer :sight_wards_bought_in_game
			t.integer :magic_damage_dealt
			t.integer :physical_damage_dealt
			t.integer :true_damage_dealt
			t.integer :magic_damage_taken
			t.integer :physical_damage_taken
			t.integer :true_damage_taken
			t.boolean :first_blood_kill
			t.boolean :first_blood_assist
			t.boolean :first_tower_kill
			t.boolean :first_tower_assist
			t.boolean :first_inhibitor_kill
			t.boolean :first_inhibitor_assist
			t.integer :inhibitor_kills
			t.integer :tower_kills
			t.integer :wards_placed
			t.integer :wards_killed
			t.integer :largest_multi_kill
			t.integer :killing_sprees
			t.integer :total_units_healed
			t.integer :total_time_crowd_control_dealt
			t.timestamps null: false
		end
		add_index :match_participants, :match_team_id
		add_index :match_participants, :summoner_id
		add_index :match_participants, :league_tier_id
		add_index :match_participants, :league_division_id
		add_index :match_participants, :spell1_id
		add_index :match_participants, :spell2_id
		add_index :match_participants, :champion_id
		add_index :match_participants, :item0_id
		add_index :match_participants, :item1_id
		add_index :match_participants, :item2_id
		add_index :match_participants, :item3_id
		add_index :match_participants, :item4_id
		add_index :match_participants, :item5_id
		add_index :match_participants, :item6_id
	end
end