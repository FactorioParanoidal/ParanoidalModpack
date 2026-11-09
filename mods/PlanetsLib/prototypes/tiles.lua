if (not settings.startup["PlanetsLib-enable-blocking-empty-space-tile"].value) or (not mods["space-age"]) then
    return
end

local function merge(old, new)
	old = util.table.deepcopy(old)

	for k, v in pairs(new) do
		if v == "nil" then
			old[k] = nil
		else
			old[k] = v
		end
	end

	return old
end

local tile = merge(data.raw.tile["empty-space"], {
    subgroup = data.raw.tile["empty-space"].subgroup,
    localised_name = {"tile-name.empty-space"},
    localised_description = {"tile-description.empty-space"},
    name = "planetslib-empty-space",
    destroys_dropped_items = true,
    default_cover_tile = nil,
    collision_mask = {
        colliding_with_tiles_only = true,
        not_colliding_with_itself = true,
        layers = data.raw.tile["empty-space"].collision_mask.layers,
    },
})
table.insert(out_of_map_tile_type_names, tile.name)

data:extend({ tile })
