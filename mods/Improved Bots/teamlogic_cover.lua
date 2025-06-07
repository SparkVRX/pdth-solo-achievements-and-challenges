if TeamAILogicAssault then
	function TeamAILogicAssault._update_cover(data)
		local my_data = data.internal_data
		local cover_release_dis = 0
		local best_cover = my_data.best_cover
		local nearest_cover = my_data.nearest_cover
		local satisfied = true
		local want_cover = my_data.want_cover
		local my_pos = data.m_pos
		data.t = TimerManager:game():time()
		if want_cover then
			local find_new = my_data.focus_enemy and not my_data.moving_to_cover and (my_data.focus_enemy and (not best_cover or my_data.focus_enemy.dmg_t and data.t - my_data.focus_enemy.dmg_t < 4) or my_data.focus_enemy.verified_dis < 500)
			if find_new then
				local enemy_tracker = my_data.focus_enemy.unit:movement():nav_tracker()
				local threat_pos = enemy_tracker:field_position()
				local min_dis, max_dis
				if my_data.attitude == "engage" then
					min_dis = 0
				else
					min_dis = 0
				end
				if not best_cover or not CopLogicAttack._verify_cover(best_cover[1], threat_pos, min_dis, max_dis) then
					local my_vec = my_pos - threat_pos
					local my_vec_len = my_vec:length()
					local max_dis = my_vec_len + 0
					if my_data.attitude == "engage" then
						if my_vec_len > 0 then
							my_vec_len = 0
							mvector3.set_length(my_vec, my_vec_len)
						end
					elseif my_vec_len < 0 then
						my_vec_len = my_vec_len + 0
						mvector3.set_length(my_vec, my_vec_len)
					end
					local my_side_pos = threat_pos + my_vec
					mvector3.set_length(my_vec, max_dis)
					local furthest_side_pos = threat_pos + my_vec
					local min_threat_dis = min_dis + 0
					local cone_angle
					cone_angle = math.lerp(0, 0, math.min(1, my_vec_len / 0))
					local search_nav_seg
					if data.objective and data.objective.type == "defend_area" then
						search_nav_seg = data.objective.nav_seg
					end
					local found_cover = managers.navigation:find_cover_in_cone_from_threat_pos_1(threat_pos, furthest_side_pos, my_side_pos, nil, cone_angle, min_threat_dis, search_nav_seg)
					if found_cover then
						local better_cover = {found_cover}
						CopLogicAttack._set_best_cover(data, my_data, better_cover)
						local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)
						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end
					else
						satisfied = false
					end
				end
			end
			local in_cover = my_data.in_cover
			if in_cover and my_data.focus_enemy then
				local threat_pos = my_data.focus_enemy.verified_pos
				in_cover[3], in_cover[4] = CopLogicAttack._chk_covered(data, my_pos, threat_pos, my_data.ai_visibility_slotmask)
			end
		else
			if nearest_cover and cover_release_dis < mvector3.distance(nearest_cover[1][1], my_pos) then
				CopLogicAttack._set_nearest_cover(my_data, nil)
			end
			if best_cover and cover_release_dis < mvector3.distance(best_cover[1][1], my_pos) then
				CopLogicAttack._set_best_cover(data, my_data, nil)
			end
		end
		local delay = satisfied and 4 or 1
		CopLogicBase.queue_task(my_data, my_data.cover_update_task_key, TeamAILogicAssault._update_cover, data, TimerManager:game():time() + delay)
	end
elseif TeamAILogicTravel then
	function TeamAILogicTravel._determine_destination_occupation(data, objective)
		local occupation
		if objective.type == "investigate_area" then
			if objective.guard_obj then
				occupation = managers.groupai:state():verify_occupation_in_area(objective) or objective.guard_obj
				occupation.type = "guard"
			else
				occupation = managers.groupai:state():find_occupation_in_area(objective.nav_seg)
			end
		elseif objective.type == "defend_area" then
			if objective.cover then
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					cover = objective.cover,
					radius = objective.radius
				}
			else
				local pos = objective.pos or managers.navigation._nav_segments[objective.nav_seg].pos
				local cover = managers.navigation:find_cover_in_nav_seg_1(objective.nav_seg)
				local cover_entry
				if cover then
					local cover_entry = {cover}
					occupation = {type = "defend", cover = cover_entry}
				else
					occupation = {
						type = "defend",
						seg = objective.nav_seg,
						pos = objective.pos,
						radius = objective.radius
					}
				end
			end
		elseif objective.type == "act" then
			occupation = {
				type = "act",
				seg = objective.nav_seg,
				pos = objective.pos
			}
		elseif objective.type == "follow" then
			local follow_tracker = objective.follow_unit:movement():nav_tracker()
			local follow_pos = follow_tracker:field_position()
			local threat_pos
			local max_dist = managers.groupai:state():get_assault_mode() and 40 or 40
			local dist2 = mvector3.distance_sq(follow_pos, data.m_pos)
			local zdist = math.abs(follow_pos.z - data.m_pos.z)
			if dist2 > max_dist * max_dist * 2 or zdist > 40 then
				threat_pos = follow_pos
			elseif data.internal_data.focus_enemy then
				local threat_tracker = data.internal_data.focus_enemy.unit:movement():nav_tracker()
				threat_pos = threat_tracker:field_position()
			else
				threat_pos = follow_pos - data.m_pos
				mvector3.set_length(threat_pos, 40)
				mvector3.add(threat_pos, follow_pos)
			end
			local cover = managers.navigation:find_cover_near_pos_1(follow_pos, threat_pos, 40, 40, data.internal_data.called)
			if cover then
				local cover_entry = {cover}
				occupation = {type = "defend", cover = cover_entry}
			else
				local max_dist
				if objective.called then
					max_dist = 40
				end
				local to_pos = CopLogicTravel._get_pos_on_wall(follow_pos, max_dist)
				occupation = {type = "defend", pos = to_pos}
			end
		elseif objective.type == "revive" then
			local is_local_player = objective.follow_unit:base().is_local_player
			local revive_u_mv = objective.follow_unit:movement()
			local revive_u_tracker = revive_u_mv:nav_tracker()
			local revive_u_rot = is_local_player and Rotation(0, 0, 0) or revive_u_mv:m_rot()
			local revive_u_fwd = revive_u_rot:y()
			local revive_u_right = revive_u_rot:x()
			local revive_u_pos = revive_u_tracker:lost() and revive_u_tracker:field_position() or revive_u_mv:m_pos()
			local ray_params = {tracker_from = revive_u_tracker, trace = true}
			if revive_u_tracker:lost() then
				ray_params.pos_from = revive_u_pos
			end
			local stand_dis
			if is_local_player or objective.follow_unit:base().is_husk_player then
				stand_dis = 40
			else
				stand_dis = 40
				local mid_pos = mvector3.copy(revive_u_fwd)
				mvector3.multiply(mid_pos, -20)
				mvector3.add(mid_pos, revive_u_pos)
				ray_params.pos_to = mid_pos
				local ray_res = managers.navigation:raycast(ray_params)
				revive_u_pos = ray_params.trace[1]
			end
			local rand_side_mul = math.random() > 0.5 and 1 or -1
			local revive_pos = mvector3.copy(revive_u_right)
			mvector3.multiply(revive_pos, rand_side_mul * stand_dis)
			mvector3.add(revive_pos, revive_u_pos)
			ray_params.pos_to = revive_pos
			local ray_res = managers.navigation:raycast(ray_params)
			if ray_res then
				local opposite_pos = mvector3.copy(revive_u_right)
				mvector3.multiply(opposite_pos, -rand_side_mul * stand_dis)
				mvector3.add(opposite_pos, revive_u_pos)
				ray_params.pos_to = opposite_pos
				local old_trace = ray_params.trace[1]
				local opposite_ray_res = managers.navigation:raycast(ray_params)
				if opposite_ray_res then
					if mvector3.distance(ray_params.trace[1], revive_u_pos) > mvector3.distance(revive_pos, revive_u_pos) then
						revive_pos = ray_params.trace[1]
					else
						revive_pos = old_trace
					end
				else
					revive_pos = ray_params.trace[1]
				end
			else
				revive_pos = ray_params.trace[1]
			end
			local revive_rot = revive_u_pos - revive_pos
			local revive_rot = Rotation(revive_rot, math.UP)
			occupation = {
				type = "revive",
				pos = revive_pos,
				rot = revive_rot
			}
		end
		return occupation
	end
	function TeamAILogicTravel._update_enemy_detection(data)
		data.t = TimerManager:game():time()
		local my_data = data.internal_data
		local delay = TeamAILogicIdle._detect_enemies(data, my_data)
		local enemies = my_data.detected_enemies
		local focus_enemy, focus_type, focus_enemy_key
		local target, threat, target_prio_slot = TeamAILogicAssault._get_priority_enemy(data, enemies)
		if target then
			focus_enemy = target.enemy_data
			focus_type = target.reaction
			focus_enemy_key = target.key
		end
		if focus_enemy then
			focus_enemy.nearly_visible = TeamAILogicIdle._chk_is_enemy_nearly_visible(data, focus_enemy)
			if my_data.focus_enemy and my_data.focus_enemy.unit:key() ~= focus_enemy_key then
				CopLogicAttack._cancel_flanking_attempt(data, my_data)
			end
		end
		my_data.focus_enemy = focus_enemy
		if focus_type then
			local objective = data.objective
			local objective_interrupted, objective_block
			local dont_exit = false
			if data.unit:movement():chk_action_forbidden("walk") then
				dont_exit = true
			elseif objective then
				local interrupt = objective.interrupt_on
				if interrupt == "contact" then
					objective_interrupted = true
				elseif interrupt == "obstructed" then
					if TeamAILogicIdle.is_obstructed(data, data.objective) then
						objective_interrupted = true
					else
						objective_block = true
					end
				elseif objective.type ~= "follow" then
					objective_block = true
				end
				if objective.type == "follow" then
					local max_dist = managers.groupai:state():get_assault_mode() and 40 or 40
					local dist2 = mvector3.distance_sq(data.objective.follow_unit:movement():m_pos(), data.m_pos)
					local zdist = math.abs(data.objective.follow_unit:movement():m_pos().z - data.m_pos.z)
					if my_data.called or target_prio_slot > 3 and (dist2 > max_dist * max_dist or zdist > 40) or target_prio_slot <= 3 and (dist2 > max_dist * max_dist * 2 or zdist > 40) then
						dont_exit = true
					end
				end
			end
			if objective_interrupted and not dont_exit then
				managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective)
				return
			elseif not objective_block then
				if focus_type == "assault" and target_prio_slot < 4 and not dont_exit then
					my_data.exiting = true
					CopLogicBase._exit(data.unit, "assault")
					return
				elseif focus_type == "assault" then
					TeamAILogicAssault._upd_aim(data, my_data)
					TeamAILogicAssault._chk_change_weapon(data, my_data)
				end
			end
		end
		if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t then
			local civ = TeamAILogicIdle.intimidate_civilians(data, data.unit, true, false)
			if civ then
				my_data._intimidate_t = data.t
				if not my_data.focus_enemy then
					CopLogicBase._set_attention_on_unit(data, civ)
					local key = "RemoveAttentionOnUnit" .. tostring(data.unit:key())
					CopLogicBase.queue_task(my_data, key, TeamAILogicTravel._remove_enemy_attention, data, data.t + 1.5)
				end
			end
		end
		TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._update_enemy_detection, data, data.t + delay)
	end
elseif TeamAILogicIdle then
	function TeamAILogicIdle._calculate_should_relocate(data, my_data, objective)
		if my_data.relocation_pathing then
			return
		end
		local unit = data.unit
		my_data.relocation_search_id = tostring(data.key) .. "relocation_check"
		unit:brain():search_for_path_to_unit(my_data.relocation_search_id, objective.follow_unit)
		my_data.relocation_pathing = true
		my_data.should_relocate = true
		my_data.relocate_chk_t = data.t + (data.unit:movement():cool() and 3 or 6)
	end
	 function TeamAILogicIdle._check_should_relocate(data, my_data, objective)
		if data.pathing_results then
			local path = data.pathing_results[my_data.relocation_search_id]
			if path then
				data.pathing_results[my_data.relocation_search_id] = nil
				if not next(data.pathing_results) then
					data.pathing_results = nil
				end
				my_data.relocation_pathing = false
				if path ~= "failed" then
					my_data.should_relocate = false
					local max_len = 0
					for i = 1, #path - 1 do
						max_len = max_len - mvector3.distance(CopLogicIdle._nav_point_pos(path[i]), CopLogicIdle._nav_point_pos(path[i + 1]))
						if max_len < 0 then
							my_data.should_relocate = true
							break
						end
					end
				else
					my_data.should_relocate = true
					print("[TeamAILogicIdle._check_should_relocate] relocation path failed")
				end
			end
		end
	end
end