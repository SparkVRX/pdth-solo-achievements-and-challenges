if RequiredScript == "lib/units/beings/player/playerdamage" then
	function PlayerDamage:_regenerated()
		self._health = self:_max_health()
		self._revive_health_i = 1

		local is_single_player = Global.game_settings.single_player
		local more_blood_to_bleed_chosen = managers.player:crew_bonus_in_slot(1) == "more_blood_to_bleed"
		local more_blood_to_bleed_value = tweak_data.upgrades.values.crew_bonus.more_blood_to_bleed[1]

		if is_single_player and more_blood_to_bleed_chosen then
			self._down_time = tweak_data.player.damage.DOWNED_TIME + more_blood_to_bleed_value
		else
			self._down_time = tweak_data.player.damage.DOWNED_TIME + managers.player:synced_crew_bonus_upgrade_value("more_blood_to_bleed", 0)
		end

		self._regenerate_timer = nil
		self:_send_set_health()
		self:_set_health_effect()
		self._said_hurt = false
	end

	function PlayerDamage:_max_armor()
		local multiplier = self._ARMOR_INIT + managers.player:body_armor_value()

		local is_single_player = Global.game_settings.single_player
		local protector_chosen = managers.player:crew_bonus_in_slot(1) == "protector"
		local protector_value = tweak_data.upgrades.values.crew_bonus.protector[1]

		if is_single_player and protector_chosen then
			multiplier = multiplier * protector_value
		else
			multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("protector", 1)
		end

		return multiplier
	end
end