if TeamAILogicAssault then
	function TeamAILogicAssault._upd_aim(data, my_data)
		local shoot, aim, expected_pos
		local focus_enemy = my_data.focus_enemy
		if focus_enemy then
			if focus_enemy.verified then
				aim = true
				if focus_enemy.alert_t and data.t - focus_enemy.alert_t < 4 then
					shoot = true
				elseif my_data.attitude == "engage" then
					if focus_enemy.verified_dis < 9000000 then
						shoot = true
					end
					elseif focus_enemy.verified_dis < 9000000 then
					shoot = true
				end
				elseif focus_enemy.verified_t then
				local weapons_down_delay = focus_enemy.nearly_visible and 4 or 1
				if weapons_down_delay > data.t - focus_enemy.verified_t and focus_enemy.verified_dis < 9000000 and math.abs(focus_enemy.verified_pos.z - data.m_pos.z) < 250 then
					aim = true
					if my_data.shooting and data.t - focus_enemy.verified_t < 3 then
						shoot = true
					end
					else
					expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)
					if expected_pos then
						aim = true
					elseif data.t - focus_enemy.verified_t < 20 or focus_enemy.verified_dis < 9000000 then
						aim = true
						if my_data.shooting and data.t - focus_enemy.verified_t < 3 and data.unit:anim_data().still then
							shoot = true
						end
						end
					end
				else
				expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)
				if expected_pos then
					aim = true
				end
				end
			end
			if data.logic.chk_should_turn(data, my_data) and not my_data._turning_to_intimidate and (focus_enemy or expected_pos) then
			local enemy_pos = expected_pos or (focus_enemy.verified or focus_enemy.nearly_visible) and focus_enemy.m_pos or focus_enemy.verified_pos
			CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
		end
			if aim or shoot then
			if expected_pos then
				if my_data.attention_unit ~= expected_pos then
					CopLogicBase._set_attention_on_pos(data, mvector3.copy(expected_pos))
					my_data.attention_unit = mvector3.copy(expected_pos)
				end
				elseif focus_enemy.verified then
				if my_data.attention ~= focus_enemy.unit:key() then
					CopLogicBase._set_attention_on_unit(data, focus_enemy.unit)
					my_data.attention = focus_enemy.unit:key()
				end
				elseif shoot or focus_enemy.nearly_visible then
				if my_data.attention ~= focus_enemy.verified_pos then
					CopLogicBase._set_attention_on_pos(data, mvector3.copy(focus_enemy.verified_pos))
					my_data.attention = mvector3.copy(focus_enemy.verified_pos)
				end
				elseif my_data.attention then
				CopLogicBase._reset_attention(data)
				my_data.attention = nil
			end
				if not my_data.shooting and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("aim") then
				local shoot_action = {}
				shoot_action.type = "shoot"
				shoot_action.body_part = 3
				if data.unit:brain():action_request(shoot_action) then
					my_data.shooting = true
				end
				end
			else
			if my_data.shooting then
				local new_action
				if data.unit:anim_data().reload then
					new_action = {type = "reload", body_part = 3}
				else
					new_action = {type = "idle", body_part = 3}
				end
					data.unit:brain():action_request(new_action)
			end
				if my_data.attention then
				CopLogicBase._reset_attention(data)
				my_data.attention = nil
			end
			end
			if shoot then
			if not my_data.firing then
				data.unit:movement():set_allow_fire(true)
				my_data.firing = true
			end
			elseif my_data.firing then
			data.unit:movement():set_allow_fire(false)
			my_data.firing = nil
		end
		end
elseif TeamAILogicIdle then
	function TeamAILogicIdle._update_enemy_detection(data)
		data.t = TimerManager:game():time()
		local my_data = data.internal_data
		local delay = TeamAILogicIdle._detect_enemies(data, my_data)
		local enemies = my_data.detected_enemies
		local focus_enemy, focus_type, focus_enemy_key
		local target, threat = TeamAILogicAssault._get_priority_enemy(data, enemies)
		if target then
			focus_enemy = target.enemy_data
			focus_type = target.reaction
			focus_enemy_key = target.key
		end
			if focus_enemy then
			my_data.focus_enemy = focus_enemy
			my_data.focus_type = focus_type
			local exit_state
			if my_data.performing_act_objective then
				local interrupt = my_data.performing_act_objective.interrupt_on
				if interrupt == "contact" then
					exit_state = focus_type
				elseif interrupt == "obstructed" then
					if TeamAILogicIdle.is_obstructed(data, data.objective) then
						exit_state = focus_type
					end
						local objective = data.objective.type
					if objective.type == "revive" then
						local revive_unit = objective.follow_unit
						local timer
						if revive_unit:base().is_local_player then
							timer = revive_unit:character_damage()._downed_timer
						elseif revive_unit:interaction().get_waypoint_time then
							timer = revive_unit:interaction():get_waypoint_time()
						end
							if timer and timer <= 10 then
							exit_state = nil
						end
						end
					end
				else
				exit_state = focus_type
			end
				if exit_state then
				my_data.detection_task_key = nil
				my_data.focus_enemy = focus_enemy
				my_data.focus_type = focus_type
				my_data.exiting = true
				if data.objective and data.objective.type ~= "follow" then
					managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective, true)
					local old_objective = data.objective
					data.objective = nil
					CopLogicBase.on_new_objective(data, old_objective)
				end
					if my_data == data.internal_data then
					CopLogicBase._exit(data.unit, exit_state)
				end
					return
			end
			end
			if (not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t) and not my_data._turning_to_intimidate and not my_data.acting then
			local can_turn = not data.unit:movement():chk_action_forbidden("walk")
			local civ = TeamAILogicIdle.find_civilian_to_intimidate(data.unit, can_turn and 180 or 180, 9000000)
			if civ then
				my_data._intimidate_t = data.t
				if can_turn and CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, civ:movement():m_pos()) then
					my_data._turning_to_intimidate = true
					my_data._primary_intimidation_target = civ
				else
					TeamAILogicIdle.intimidate_civilians(data, data.unit, true, true)
				end
				end
			end
			CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicIdle._update_enemy_detection, data, data.t + delay)
	end
end