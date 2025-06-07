if Global then
	if Global.level_data.level_id == "bank" then
		local element = managers.mission._scripts["default"]._elements[100632]

		element._values.on_executed[15].delay = 40
	end
end