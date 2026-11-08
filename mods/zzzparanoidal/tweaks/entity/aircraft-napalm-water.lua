if not mods["Aircraft-space-age"] then return end

local napalm = data.raw.fire["napalm_fire_flame"]
if not napalm then return end

local original_biomes = mods["alien-biomes"] ~= nil
local reforged_biomes = mods["Paranoidal-Alien-biomes"] ~= nil
if original_biomes == reforged_biomes then return end

local variations = napalm.burnt_patch_alpha_variations
local water_tiles = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" }

-- Aircraft 2.3.4 checks alien-biomes; this pack uses Paranoidal-Alien-biomes.
for _, tile in ipairs(water_tiles) do
	if data.raw.tile[tile] then
		if reforged_biomes then
			-- Remove the appended entry, preserving inherited entries for the same tile.
			for i = #variations, 1, -1 do
				if variations[i].tile == tile and variations[i].alpha == 0 then
					table.remove(variations, i)
					break
				end
			end
		else
			table.insert(variations, { tile = tile, alpha = 0 })
		end
	end
end
