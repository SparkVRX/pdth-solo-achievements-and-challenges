if Global then
	if Global.level_data.level_id == "slaughter_house" then
		local element = managers.mission._scripts["deafult"]._elements[101505]

		element._values.on_executed[11].delay = 1020
		element._values.on_executed[17].delay = 1020
	end
end