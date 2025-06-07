if Global then
	if Global.level_data.level_id == "suburbia" then
		local element = managers.mission._scripts["default"]._elements[102041]

		element._values.on_executed[9].delay = 34
	end
end