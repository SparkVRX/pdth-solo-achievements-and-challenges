if RequiredScript == "lib/units/equipment/sentry_gun/sentrygunbase" then
	function SentryGunBase.spawn(pos, rot, ammo_upgrade_lvl, armor_upgrade_lvl)
		local attached_data = SentryGunBase._attach(pos, rot)
		if not attached_data then
			return
		end

		local unit = World:spawn_unit(Idstring("units/equipment/sentry_gun/sentry_gun"), pos, rot)
		unit:base():setup(ammo_upgrade_lvl, armor_upgrade_lvl, attached_data)
		unit:brain():set_active(true)
		SentryGunBase.deployed = (SentryGunBase.deployed or 0) + 1
		if SentryGunBase.deployed == managers.network:game():amount_of_members() then
			managers.challenges:set_flag("sentry_gun_resources")
		end

		return unit
	end
end