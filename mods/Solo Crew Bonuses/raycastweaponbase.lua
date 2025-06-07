if RequiredScript == "lib/units/weapons/raycastweaponbase" then
	function RaycastWeaponBase:replenish()
		local ammo_max_multiplier = managers.player:equipped_upgrade_value("extra_start_out_ammo", "player", "extra_ammo_multiplier")

		local is_single_player = Global.game_settings.single_player
		local more_ammo_chosen = managers.player:crew_bonus_in_slot(1) == "more_ammo"
		local more_ammo_value = tweak_data.upgrades.values.crew_bonus.more_ammo[1]

		if is_single_player and more_ammo_chosen then
			ammo_max_multiplier = (ammo_max_multiplier == 0 and 1 or ammo_max_multiplier) * more_ammo_value
		else
			ammo_max_multiplier = (ammo_max_multiplier == 0 and 1 or ammo_max_multiplier) * managers.player:synced_crew_bonus_upgrade_value("more_ammo", 1, true)
		end

		self._ammo_max_per_clip = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")
		self._ammo_max = math.round((tweak_data.weapon[self._name_id].AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_amount_increase") * self._ammo_max_per_clip) * ammo_max_multiplier)
		self._ammo_total = self._ammo_max
		self._ammo_remaining_in_clip = self._ammo_max_per_clip
		self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP
		self:update_damage()
	end

	function RaycastWeaponBase:reload_speed_multiplier()
		local multiplier = managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)

		local is_single_player = Global.game_settings.single_player
		local speed_reloaders_chosen = managers.player:crew_bonus_in_slot(1) == "speed_reloaders"
		local speed_reloaders_value = tweak_data.upgrades.values.crew_bonus.speed_reloaders[1]

		if is_single_player and speed_reloaders_chosen then
			multiplier = multiplier * speed_reloaders_value
		else
			multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("speed_reloaders", 1)
		end

		return multiplier
	end

	function RaycastWeaponBase:damage_multiplier()
		local multiplier = managers.player:upgrade_value(self._name_id, "damage_multiplier", 1)

		local is_single_player = Global.game_settings.single_player
		local aggressor_chosen = managers.player:crew_bonus_in_slot(1) == "aggressor"
		local aggressor_value = tweak_data.upgrades.values.crew_bonus.aggressor[1]

		if is_single_player and aggressor_chosen then
			multiplier = multiplier * aggressor_value
		else
			multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("aggressor", 1)
		end

		return multiplier
	end

	function RaycastWeaponBase:spread_multiplier()
		local multiplier = managers.player:upgrade_value(self._name_id, "spread_multiplier", 1)

		local is_single_player = Global.game_settings.single_player
		local sharpshooters_chosen = managers.player:crew_bonus_in_slot(1) == "sharpshooters"
		local sharpshooters_value = tweak_data.upgrades.values.crew_bonus.sharpshooters[1]

		if is_single_player and sharpshooters_chosen then
			multiplier = multiplier * sharpshooters_value
		else
			multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("sharpshooters", 1)
		end

		return multiplier
	end
end