if Global then
	if Global.level_data.level_id == "hospital" then
		local element = managers.mission._scripts["default"]._elements[702481]

		element._values.difficulty_normal = true
		element._values.difficulty_hard = true
	end
end