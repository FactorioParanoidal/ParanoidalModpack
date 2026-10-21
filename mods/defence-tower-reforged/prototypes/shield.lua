-- Shield buffers of the defence towers: one hidden electric-energy-interface per tower once the force
-- has "Shield generation", one prototype per pair of completed capacity and regeneration levels
-- (kts-gen-<size>-<rate>): the input flow limit (regeneration + drain) and the drain are
-- prototype-only properties and depend on both levels. The electric network recharges the buffer
-- without any Lua.
local shared = require("kts_shared")

local cfg = shared.read(settings.startup)
local max_level = cfg.research and cfg.max_level or 0
local path = shared.root .. "/graphics/"

local function flags()
	return {
		"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-repairable",
		"not-flammable", "not-selectable-in-game", "not-upgradable", "not-in-kill-statistics",
		"not-in-made-in", "no-copy-paste", "hide-alt-info",
	}
end

local list = {}
for size = 0, max_level do
	for rate = 0, max_level do
		local stats = shared.stats(cfg, size, rate)
		list[#list + 1] = {
			type = "electric-energy-interface",
			name = shared.buffer_name(size, rate),
			localised_name = {"entity-name.kts-shield-buffer"},
			localised_description = {"entity-description.kts-shield-buffer"},
			icon = path .. "entity_icon.png",
			icon_size = 128,
			flags = flags(),
			hidden = true,
			hidden_in_factoriopedia = true,
			max_health = 1,
			-- Collides with nothing; the box (the tower footprint) only decides which poles power the
			-- buffer: those whose supply area reaches the tower.
			collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
			collision_mask = {layers = {}},
			selectable_in_game = false,
			allow_copy_paste = false,
			gui_mode = "none",
			energy_source = {
				type = "electric",
				usage_priority = "secondary-input",
				buffer_capacity = shared.energy(stats.buffer, "J"),
				input_flow_limit = shared.energy(stats.recharge + stats.drain, "W"),
				output_flow_limit = "0W",
				drain = shared.energy(stats.drain, "W"),
			},
		}
	end
end
data:extend(list)
