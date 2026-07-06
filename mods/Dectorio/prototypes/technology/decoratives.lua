-- technology/decoratives

if DECT.ENABLED["decoratives"] then

	-- Add Traffic Bollard to Plastics technology
	local base_plastic = data.raw["technology"]["plastics"]
	table.insert(base_plastic.effects, {type="unlock-recipe", recipe="dect-traffic-bollard"})

end
