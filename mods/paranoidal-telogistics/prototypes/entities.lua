local tiers = require("shared.tiers")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")
require("circuit-connector-sprites")

local G = "__paranoidal-telogistics__/graphics/"
local KG = 1000 -- grams

local function icons(tier, path, size)
	return {{icon = G .. path, icon_size = size, tint = tier.tint}}
end

local function picture(tier)
	return {
		layers = {
			{
				filename = G .. "entity/teleporter.png",
				priority = "high",
				width = 386,
				height = 386,
				shift = util.by_pixel(0, -14),
				scale = 0.5,
				tint = tier.tint,
			},
			{
				filename = G .. "entity/teleporter-shadow.png",
				priority = "high",
				width = 579,
				height = 386,
				draw_as_shadow = true,
				shift = util.by_pixel(38.5, -14),
				scale = 0.5,
			},
		},
	}
end

-- 2.1: a container takes a list of connector definitions (one per direction; the teleporter has one).
local connector = circuit_connector_definitions.create_vector(universal_connector_template,
	{{variation = 27, main_offset = util.by_pixel(55.5, 39.5), shadow_offset = util.by_pixel(56.5, 39.5), show_shadow = true}})

local prototypes = {
	{
		type = "item-subgroup",
		name = "ptl-teleporters",
		group = "logistics",
		order = "fz",
	},
	{
		type = "sound",
		name = "ptl-send",
		filename = "__paranoidal-telogistics__/sound/teleportation-beam.ogg",
		category = "game-effect",
		volume = 0.6,
	},
	{
		type = "sound",
		name = "ptl-arrive",
		filename = "__paranoidal-telogistics__/sound/teleportation-finish.ogg",
		category = "game-effect",
		volume = 0.8,
	},
}

for index, tier in ipairs(tiers.tiers) do
	local next_tier = tiers.tiers[index + 1]
	local stats = {"", tostring(tier.power_mw), tostring(tier.cycle_s), tostring(tier.slots)}
	prototypes[#prototypes + 1] = {
		type = "item",
		name = tier.name,
		icons = icons(tier, "icons/teleporter.png", 64),
		localised_description = {"item-description.ptl-teleporter", tostring(tier.power_mw), tostring(tier.cycle_s),
			tostring(tier.slots), tostring(tier.power_mw * tier.cycle_s / 1000), tostring(tier.receive_mw)},
		subgroup = "ptl-teleporters",
		order = "a[ptl]-" .. index,
		inventory_move_sound = item_sounds.mechanical_large_inventory_move,
		pick_sound = item_sounds.mechanical_large_inventory_pickup,
		drop_sound = item_sounds.mechanical_large_inventory_move,
		place_result = tier.name,
		stack_size = 10,
		weight = 1000 * KG,
	}
	prototypes[#prototypes + 1] = {
		type = "container",
		name = tier.name,
		icons = icons(tier, "icons/teleporter.png", 64),
		localised_description = {"entity-description.ptl-teleporter", tostring(tier.power_mw), tostring(tier.cycle_s),
			tostring(tier.slots), tostring(tier.power_mw * tier.cycle_s / 1000), tostring(tier.receive_mw)},
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1, result = tier.name},
		max_health = tier.health,
		corpse = "big-remnants",
		dying_explosion = "big-explosion",
		resistances = {
			{type = "fire", percent = 90},
			{type = "impact", percent = 50},
			{type = "physical", decrease = 10, percent = 30},
		},
		collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
		selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
		damaged_trigger_effect = hit_effects.entity(),
		fast_replaceable_group = "ptl-teleporter",
		next_upgrade = next_tier and next_tier.name or nil,
		inventory_size = tier.slots,
		inventory_type = "with_filters_and_bar",
		open_sound = sounds.machine_open,
		close_sound = sounds.machine_close,
		icon_draw_specification = {scale = 0, scale_for_many = 0},
		picture = picture(tier),
		circuit_connector = connector,
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		-- Not on space platforms (no gravity); data-final-fixes also keeps it out of Factorissimo buildings.
		surface_conditions = {{property = "gravity", min = 0.1}},
	}
	-- The charger: hidden, not selectable, under the container. For a sender its buffer is one send; it draws from the
	-- electric network at the tier's power, so a full charge takes the recharge time (longer on a weak network). For a
	-- receiver control.lua sets a constant usage (tier.receive_mw) with a small buffer.
	prototypes[#prototypes + 1] = {
		type = "electric-energy-interface",
		name = tier.charger,
		localised_name = {"entity-name." .. tier.name},
		localised_description = {"entity-description.ptl-charger"},
		icons = icons(tier, "icons/teleporter.png", 64),
		flags = {"not-on-map", "not-blueprintable", "not-deconstructable", "not-repairable", "not-upgradable",
			"not-in-kill-statistics", "no-copy-paste", "hide-alt-info", "not-flammable", "not-selectable-in-game"},
		hidden = true,
		hidden_in_factoriopedia = true,
		selectable_in_game = false,
		max_health = tier.health,
		collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
		collision_mask = {layers = {}},
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			buffer_capacity = tostring(tier.energy_j) .. "J",
			input_flow_limit = tostring(tier.power_mw) .. "MW",
			output_flow_limit = "0W",
			render_no_power_icon = false,
			render_no_network_icon = false,
		},
		energy_production = "0W",
		energy_usage = "0W",
		gui_mode = "none",
		allow_copy_paste = false,
	}
	prototypes[#prototypes + 1] = {
		type = "animation",
		name = tier.flash,
		filename = G .. "entity/teleporter-anim.png",
		priority = "high",
		width = 386,
		height = 386,
		frame_count = 60,
		line_length = 10,
		scale = 0.5,
		shift = util.by_pixel(0, -14),
		blend_mode = "additive",
		draw_as_glow = true,
		tint = tier.glow,
	}
	prototypes[#prototypes + 1] = {
		type = "recipe",
		name = tier.name,
		enabled = false,
		energy_required = 30 * index,
		categories = {"crafting"},
		ingredients = {}, -- set below
		results = {{type = "item", name = tier.name, amount = 1}},
		requester_paste_multiplier = 1,
	}
end

-- Paranoidal prices (user 2026-11-11): each tier is made of its planet's materials and the previous tier.
-- Tier 1, Muluna: a light lunar body (lunite, microcellular plastic), navigation (data cable of the telescope, the
-- satellite flight computer) and storage for the charge (large accumulators 3). Tier 2, Vulcanus: a heat-proof body for
-- twice the power (refractory beams, pobedit, low density structures). Tier 3, Fulgora: the 5 s recharge
-- (superconductors, supercapacitors, holmium). No rocket control unit here: zzzparanoidal creates it only in its
-- data-final-fixes and RITEG drops ingredients missing before that.
local ingredients = {
	["ptl-teleporter-1"] = {
		{type = "item", name = "aluminum-plate", amount = 100},
		{type = "item", name = "muluna-microcellular-plastic", amount = 50},
		{type = "item", name = "muluna-data-cable", amount = 20},
		{type = "item", name = "satellite-flight-computer", amount = 2},
		{type = "item", name = "bob-large-accumulator-3", amount = 10},
	},
	["ptl-teleporter-2"] = {
		{type = "item", name = "ptl-teleporter-1", amount = 1},
		{type = "item", name = "paranoidal-refractory-beam", amount = 100},
		{type = "item", name = "paranoidal-pobedit", amount = 100},
		{type = "item", name = "low-density-structure", amount = 30},
	},
	["ptl-teleporter-3"] = {
		{type = "item", name = "ptl-teleporter-2", amount = 1},
		{type = "item", name = "superconductor", amount = 200},
		{type = "item", name = "supercapacitor", amount = 100},
		{type = "item", name = "holmium-plate", amount = 100},
	},
}
for _, prototype in ipairs(prototypes) do
	if prototype.type == "recipe" then prototype.ingredients = ingredients[prototype.name] end
end

data:extend(prototypes)
