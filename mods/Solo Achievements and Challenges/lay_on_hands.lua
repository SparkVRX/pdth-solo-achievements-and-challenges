if RequiredScript == "lib/managers/experiencemanager" then
	function ExperienceManager:_level_up()
		local target_tree = managers.upgrades:current_tree()
		managers.upgrades:aquire_target()
		self._global.level = self._global.level + 1
		self:_set_next_level_data(self._global.level + 1)
		local player = managers.player:player_unit()
		if alive(player) and tweak_data:difficulty_to_index(Global.game_settings.difficulty) < 4 then
			player:base():replenish()
		end

		managers.challenges:check_active_challenges()

		local revives = managers.statistics._global.session.revives.npc_count + managers.statistics._global.session.revives.player_count

		if managers.groupai:state():is_AI_enabled() then
			if target_tree == 1 and managers.groupai:state():get_assault_mode() then
				managers.challenges:set_flag("aint_afraid")
			elseif target_tree == 2 and managers.statistics._last_kill == "sniper" then
				managers.challenges:set_flag("crack_bang")
			elseif target_tree == 3 and revives >= 1 then
				managers.challenges:set_flag("lay_on_hands")
			end

		end

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_level_up", managers.network:session():local_peer():id(), self._global.level)
		end

		if self._global.level >= 145 then
			managers.challenges:set_flag("president")
		end

	end
end