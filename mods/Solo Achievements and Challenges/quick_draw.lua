if Global then
	if Global.level_data.level_id == "apartment" then
		local element = managers.mission._scripts["default"]._elements[101871]

		element._values.on_executed[18].delay = 91
	end
end