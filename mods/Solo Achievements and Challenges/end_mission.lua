-- AFFECTED ACHIEVEMENTS
-- I ain't afraid no more
-- Crack-bang
-- Lay on hands
-- Last man standing
-- Left for dead
-- Noob herder
-- Easy street
-- Pacifist
-- Blow-out

if RequiredScript == "lib/states/missionendstate" then
	local original = MissionEndState.at_enter

	function MissionEndState:at_enter(old_state, params)
		original(self, old_state, params)

		local characters = managers.criminals._characters
		local criminals_in_custody = 0

		for _, data in pairs(characters) do
			if managers.trade:is_criminal_in_custody(data.name) then
				criminals_in_custody = criminals_in_custody + 1
			end
		end

		local amount_of_criminals = managers.groupai:state():amount_of_ai_criminals() + managers.network:game():amount_of_members() + criminals_in_custody
		local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		local current_level = managers.experience:current_level()
		local player_is_alive = alive(managers.player:player_unit())
		local is_assault = managers.groupai:state():get_assault_mode()
		local accuracy = managers.statistics:session_hit_accuracy()
		local total_kills = managers.statistics._global.session.killed.total.count
		local melee_kills = managers.statistics._global.session.killed.total.melee
		local last_kill = managers.statistics._last_kill
		local used_weapons = managers.statistics._global.session.killed_by_weapon
		local used_weapons_count = 0
		local revives = managers.statistics._global.session.revives.npc_count + managers.statistics._global.session.revives.player_count

		for _, _ in pairs(used_weapons) do
			used_weapons_count = used_weapons_count + 1
		end

		local is_heat_street = Global.level_data.level_id == "heat_street"
		local is_counterfeit = Global.level_data.level_id == "suburbia"
		local is_undercover = Global.level_data.level_id == "secret_stash"

		if self._success then
			if current_level >= 193 then
				if is_assault then
					managers.challenges:set_flag("aint_afraid")
				end

				if last_kill == "sniper" then
					managers.challenges:set_flag("crack_bang")
				end

				if revives >= 1 then
					managers.challenges:set_flag("lay_on_hands")
				end
			end

			if is_heat_street and current_difficulty >= 3 and accuracy >= 60 then
				managers.challenges:set_flag("cant_touch")
			end

			if total_kills == 0 and is_counterfeit and current_difficulty >= 3 then
				managers.challenges:set_flag("pacifist")
			end

			if melee_kills == 0 and is_undercover and used_weapons_count == 1 then
				if used_weapons["m79"] then
					managers.challenges:set_flag("blow_out")
				end
			end

			if params.num_winners == 1 and player_is_alive then
				managers.challenges:set_flag("last_man_standing")

				if current_level >= 193 and current_difficulty >= 4 and amount_of_criminals == 1 then
					managers.challenges:set_flag("noob_herder")
				end
			end

			if params.num_winners == 3 and amount_of_criminals == 4 then
				managers.challenges:set_flag("left_for_dead")
			end
		end
	end
end