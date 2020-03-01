--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: saveGrid.lua
 * Description: Saves and restores the contents of an equipment grid.
 *    Includes energy, shield, and burner equipment properties.
 *    Depends on saveBurner.lua.
--]]


function saveGrid(grid)
	if grid and grid.valid then
		gridContents = {}
		for _,v in pairs(grid.equipment) do
			local item = {name=v.name,position={x=v.position.x,y=v.position.y}}
			local burner = saveBurner(v.burner)
			table.insert(gridContents,{item=item,energy=v.energy,shield=v.shield,burner=burner})
		end
		return gridContents
	else
		return nil
	end
end

function restoreGrid(grid,savedItems)
	for _,v in pairs(savedItems) do
		local e = grid.put(v.item)
		if v.energy then
			e.energy = v.energy
		end
		if v.shield and v.shield > 0 then
			e.shield = v.shield
		end
		if v.burner then
			restoreBurner(e.burner,v.burner)
		end
	end
end

return saveGrid
