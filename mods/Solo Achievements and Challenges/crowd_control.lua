if Global then
	if Global.level_data.level_id == "suburbia" then
		local element = managers.mission._scripts["default"]._elements[102366]

		element._values.on_executed[1] = nil
	end
end