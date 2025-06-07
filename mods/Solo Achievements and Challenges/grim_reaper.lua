if RequiredScript == "lib/managers/statisticsmanager" then
	function StatisticsManager:_bullet_challenges(data)
		managers.challenges:count_up(data.type .. "_kill")
		managers.challenges:count_up(data.name .. "_kill")
		if data.head_shot then
			managers.challenges:count_up(data.type .. "_head_shot")
		else
			managers.challenges:count_up(data.type .. "_body_shot")
		end

		if data.attacker_state and data.attacker_state == "bleed_out" then
			local weapon_name_id = data.weapon_unit:base():get_name_id()
			if weapon_name_id ~= "sentry_gun" then
				managers.challenges:count_up("bleed_out_kill")
				managers.challenges:count_up("bleed_out_multikill")
			end

			if weapon_name_id == "sentry_gun" then
				managers.challenges:count_up("grim_reaper")
			end
		end

		local weapon_tweak_data = data.weapon_unit:base():weapon_tweak_data()
		if weapon_tweak_data.challenges then
			if weapon_tweak_data.challenges.weapon then
				managers.challenges:count_up(weapon_tweak_data.challenges.weapon .. "_" .. data.type .. "_kill")
				managers.challenges:count_up(weapon_tweak_data.challenges.weapon .. "_" .. data.name .. "_kill")
			else
				managers.challenges:count_up((weapon_tweak_data.challenges.group or weapon_tweak_data.challenges.prefix) .. "_kill")
			end

			if data.head_shot then
				if weapon_tweak_data.challenges.weapon then
					managers.challenges:count_up(weapon_tweak_data.challenges.weapon .. "_" .. data.type .. "_head_shot")
					managers.challenges:count_up(weapon_tweak_data.challenges.weapon .. "_" .. data.name .. "_head_shot")
				else
					managers.challenges:count_up((weapon_tweak_data.challenges.group or weapon_tweak_data.challenges.prefix) .. "_head_shot")
				end

			elseif weapon_tweak_data.challenges.weapon then
				managers.challenges:count_up(weapon_tweak_data.challenges.weapon .. "_" .. data.type .. "_body_shot")
				managers.challenges:count_up(weapon_tweak_data.challenges.weapon .. "_" .. data.name .. "_body_shot")
			else
				managers.challenges:count_up((weapon_tweak_data.challenges.group or weapon_tweak_data.challenges.prefix) .. "_body_shot")
			end

		end

	end

function StatisticsManager:_explosion_challenges(data)
	if game_state_machine:last_queued_state_name() == "ingame_waiting_for_respawn" or game_state_machine:last_queued_state_name() == "ingame_bleed_out" then
		managers.challenges:count_up("grim_reaper")
	end

	local weapon_id = data.weapon_unit and data.weapon_unit:base():get_name_id()

	if weapon_id == "m79" then
		managers.challenges:count_up("m79_law_simultaneous_kills")
		if data.name == "shield" or data.name == "spooc" or data.name == "tank" or data.name == "taser" then
			managers.challenges:count_up("m79_simultaneous_specials")
		end

	elseif weapon_id == "trip_mine" and data.type == "law" then
		managers.challenges:count_up("trip_mine_law_kill")
	end

end

end