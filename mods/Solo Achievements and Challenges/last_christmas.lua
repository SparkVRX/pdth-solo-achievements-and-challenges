if RequiredScript == "lib/units/props/christmaspresentbase" then
	function ChristmasPresentBase:init(unit)
		UnitBase.init(self, unit, false)
		self._unit = unit
	end
end