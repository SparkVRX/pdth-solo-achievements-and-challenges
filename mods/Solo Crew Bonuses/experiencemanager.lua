if RequiredScript == "lib/managers/experiencemanager" then
	function ExperienceManager:add_points(points, present_xp, debug)
		if not debug and managers.platform:presence() ~= "Playing" and managers.platform:presence() ~= "Mission_end" then
			return
		end

		local multiplier

		local is_single_player = Global.game_settings.single_player
		local welcome_to_the_gang_chosen = managers.player:crew_bonus_in_slot(1) == "welcome_to_the_gang"
		local welcome_to_the_gang_value = tweak_data.upgrades.values.crew_bonus.welcome_to_the_gang[1]
		local mr_nice_guy_chosen = managers.player:crew_bonus_in_slot(1) == "mr_nice_guy"
		local mr_nice_guy_value = tweak_data.upgrades.values.crew_bonus.mr_nice_guy[1]

		if is_single_player and welcome_to_the_gang_chosen then
			multiplier = welcome_to_the_gang_value
		else
			multiplier = managers.player:synced_crew_bonus_upgrade_value("welcome_to_the_gang", 1)
		end

		if is_single_player and mr_nice_guy_chosen then
			multiplier = multiplier * mr_nice_guy_value
		else
			multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("mr_nice_guy", 1)
		end

		points = math.floor(points * multiplier)
		if not managers.dlc:has_full_game() and self._global.level >= 10 then
			self._global.total = self._global.total + points
			self._global.next_level_data.current_points = 0
			self:present()
			managers.challenges:aquired_money()
			managers.statistics:aquired_money(points)
			return
		end

		if self._global.level >= self:level_cap() then
			self._global.total = self._global.total + points
			managers.challenges:aquired_money()
			managers.statistics:aquired_money(points)
			return
		end

		if present_xp then
			self:_present_xp(points)
		end

		local points_left = self._global.next_level_data.points - self._global.next_level_data.current_points
		if points < points_left then
			self._global.total = self._global.total + points
			self._global.next_level_data.current_points = self._global.next_level_data.current_points + points
			self:present()
			managers.challenges:aquired_money()
			managers.statistics:aquired_money(points)
			return
		end

		self._global.total = self._global.total + points_left
		self._global.next_level_data.current_points = self._global.next_level_data.current_points + points_left
		self:present()
		self:_level_up()
		managers.statistics:aquired_money(points_left)
		self:add_points(points - points_left)
	end
end