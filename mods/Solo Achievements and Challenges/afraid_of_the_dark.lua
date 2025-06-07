if Global then
	if Global.level_data.level_id == "hospital" then
		local element = managers.mission._scripts["default"]._elements[702491]

		element._values.on_executed[1].delay = 10
	end
end