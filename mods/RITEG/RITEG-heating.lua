-- optional, only with a mod that brings the freezing mechanic (Space Age).
--
-- on a cold planet a building has to touch a heat source above 30 degrees, there
-- is no heating radius in the game. so every RITEG gets a hidden heat source of
-- its own size placed under it, and the buildings around the RITEG can draw from
-- that one. suggested by tabr:
-- https://mods.factorio.com/mod/RITEG/discussion/6772c389ef4345a5520ca647

local mod_name = "__RITEG__"
local size = 3

if not (feature_flags and feature_flags.freezing) then
	return -- nothing to heat
end

if not settings.startup[mod_name .. "heating"].value then
	return
end

data:extend({
	{
		type = "heat-interface",
		name = "RITEG-heater",
		icon = mod_name .. "/graphics/icons/RITEG-1.png",
		icon_size = 32,
		flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable",
			"not-upgradable", "hide-alt-info", "no-automated-item-removal", "no-automated-item-insertion"},
		hidden = true,
		hidden_in_factoriopedia = true,
		selectable_in_game = false,
		gui_mode = "none",
		max_health = 1,
		-- the same footprint as the RITEG, so the buildings next to the RITEG
		-- touch it, but no collision at all so both stand on the same tiles
		collision_box = {{-size / 2 + 0.23, -size / 2 + 0.23}, {size / 2 - 0.23, size / 2 - 0.23}},
		collision_mask = {layers = {}},
		selection_box = {{0, 0}, {0, 0}},
		heat_buffer =
		{
			max_temperature = 100, -- warm enough against the frost, too cold for a heat exchanger
			specific_heat = "10MJ",
			max_transfer = "1MW",
			-- the engine wants min_working_temperature >= default_temperature, so
			-- both stay at zero like the heat interface of the game. the control
			-- script sets the real temperature right after it creates the entity
			default_temperature = 0,
			min_working_temperature = 0,
			connections =
			{
				{position = {0, -2}, direction = defines.direction.north},
				{position = {2, 0}, direction = defines.direction.east},
				{position = {0, 2}, direction = defines.direction.south},
				{position = {-2, 0}, direction = defines.direction.west}
			}
		}
	}
})
