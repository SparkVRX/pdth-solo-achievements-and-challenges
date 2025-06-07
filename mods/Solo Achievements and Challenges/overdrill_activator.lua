if Global then
	local amount_of_players = managers.network:game():amount_of_members()
	local is_bank = Global.level_data.level_id == "bank"

	if is_bank and amount_of_players == 1 then
		for _, script in pairs(managers.mission:scripts()) do
			for id, element in pairs(script:elements()) do
				for _, trigger in pairs(element:values().trigger_list or {}) do
					if trigger.notify_unit_sequence == "light_on" then
						element:on_executed()
					end
				end
			end
		end
	end
end