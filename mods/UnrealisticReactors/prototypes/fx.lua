local Setting = require "scripts.setting"

-- ENTITIES FOR CLOUDS AND FALLOUT AND ATOMIC EXPLOSION
local function make_action(radius, effect_id) return {
	type = "direct",
	action_delivery = {
		type = "instant",
		target_effects = {
			type = "nested-result",
			action = {
				type = "area",
				radius = radius,
				entity_flags = {"placeable-off-grid"},
				action_delivery = {
					type = "instant",
					target_effects = {
						type = "script",
						effect_id = effect_id,
						--probability = 0.5,
					}
				}
			}
		}
	}
} end


-- fallout radiation 
local perma_radiation = {
	type = "smoke-with-trigger",
	name = "permanent-radiation",
	flags = {"not-on-map"},
	render_layer = "item-in-inserter-hand",
	show_when_smoke_off = true,
	random_animation_offset = true,
	animation = {
		filename = "__UnrealisticReactors__/graphics/fallout/fallout_spritesheet.png",
		random_animation_offset = true,

		priority = "low",
		width = 249,
		height = 211,
		frame_count = 14,
		animation_speed = 0.15,
		line_length = 7,
		scale = 2,
		blend_mode = "additive-soft",
		apply_runtime_tint=true,
	},
	slow_down_factor = 0,
	affected_by_wind = false,
	cyclic = true,
	duration = Setting.protoduration("fallout") * 60,
	fade_away_duration = math.min(180,Setting.protoduration("fallout")/3) * 60,
	--fade_in_duration = math.min(5,Setting.protoduration("fallout")/3) * 60, --doesn't work
	spread_duration = math.min(5,Setting.protoduration("fallout")/3) * 60,
	movement_slow_down_factor = 0,
	color = { r = 1, g = 1, b = 1},
	action = make_action(7,"radiation-damage"),
	action_cooldown = 30
}

-- fallout appearance
if Setting.appearance("fallout") == "invisible" then
	perma_radiation.animation = {
		filename = "__UnrealisticReactors__/graphics/transparent32.png",
		random_animation_offset = true,
		flags = { "compressed" },
		priority = "low",
		width = 32,
		height = 32,
		frame_count = 1,
		animation_speed = 0.2,
		line_length = 1,
		scale = 1,
	}
	perma_radiation.action = make_action(14,"radiation-damage")

elseif Setting.appearance("fallout") == "half-transparent" then
	perma_radiation.animation = {
		filename = "__UnrealisticReactors__/graphics/fallout/fallout_spritesheet_half.png",
		random_animation_offset = true,
		priority = "low",
		width = 249,
		height = 211,
		frame_count = 14,
		animation_speed = 0.15,
		line_length = 7,
		scale = 2,
		blend_mode = "additive-soft",
		apply_runtime_tint = true,
	}

elseif Setting.appearance("fallout") == "green-veil" then
	perma_radiation.animation = {
		filename = "__UnrealisticReactors__/graphics/fallout/fallout-green.png",
		random_animation_offset = true,
		flags = { "compressed" },
		priority = "low",
		width = 256,
		height = 256,
		frame_count = 1,
		animation_speed = 0.2,
		line_length = 1,
		scale = 4,
		blend_mode = "additive-soft",
		apply_runtime_tint = true,
		--premul_alpha= false,
		tint =  {r=0, g=1, b=0, a=0.01},
	}
	perma_radiation.action = make_action(15,"radiation-damage")

end

data:extend{
	perma_radiation,

	-- fallout cloud
	{
		type = "smoke-with-trigger",
		name = "fallout-cloud",
		flags = {"not-on-map","placeable-off-grid"},
		render_layer = "entity-info-icon-above",
		show_when_smoke_off = true,
		animation = {
			filename = "__UnrealisticReactors__/graphics/fallout/cloud-45-frames.png",
			flags = {"compressed"},
			priority = "low",
			width = 256,
			height = 256,
			frame_count = 45,
			animation_speed = 0.2,
			line_length = 7,
			scale = 6,
		},
		slow_down_factor = 0,
		affected_by_wind = true,
		cyclic = true,
		duration = Setting.protoduration("clouds") * 60,
		--fade_in_duration =  math.min(20,Setting.protoduration("clouds")/3) * 60, --doesnt work
		fade_away_duration = math.min(20,Setting.protoduration("clouds")/3) * 60,
		--spread_duration = 50,
		spread_duration = 300,
		movement_slow_down_factor = 1,
		color = { r = 1, g = 1, b = 1},
		action = make_action(20,"radiation-damage-strong"),
		action_cooldown = 30,
	},

	-- geiger counter sounds
	{
		type = "sound",
		name = "RR-geiger-0",
		filename = "__UnrealisticReactors__/sound/geiger0.ogg",
	},
	{
		type = "sound",
		name = "RR-geiger-1",
		filename = "__UnrealisticReactors__/sound/geiger1.ogg",
	},

}
