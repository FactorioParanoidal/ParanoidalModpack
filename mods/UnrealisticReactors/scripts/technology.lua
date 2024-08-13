
local function init()
	for _,force in pairs (game.forces) do --bugfix for reactor recipe not showing up
		if force.technologies["nuclear-power"].researched then
			force.recipes["realistic-reactor"].enabled = true
			force.recipes["rr-cooling-tower"].enabled = true
			force.recipes["reactor-sarcophagus"].enabled = true
		end
		--force.recipes["breeder-reactor"].enabled = true
	end
end


return { -- exports
	init = init,
}

