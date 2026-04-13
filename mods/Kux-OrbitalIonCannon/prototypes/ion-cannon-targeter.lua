local function createTargeterItem(name)
	data:extend{
		{
			type = "item",
			name = name,
			icon = mod.path.."graphics/crosshairs64.png",
			icon_size = 64,
			place_result = name,
			subgroup = "capsule",
			order = "c[target]",
			stack_size = 1,
			flags = {"not-stackable", "only-in-cursor","spawnable"}
		}--[[@as data.ItemPrototype]]
	}
end
createTargeterItem("ion-cannon-targeter")
createTargeterItem("ion-cannon-targeter-mk2")

local function createTargetRecipe(name)
	data:extend({
		{
			type = "recipe",
			name = name,
			energy_required = 0.5,
			enabled = false,
			category = "crafting",
			ingredients =
			{
				{type="item", name ="processing-unit", amount=1},
				{type="item", name ="plastic-bar", amount=2},
				{type="item", name ="battery", amount=1}
			},
			results = {
				{type="item", name=name, amount=1}
			}
		},
	})
end
createTargetRecipe("ion-cannon-targeter")
createTargetRecipe("ion-cannon-targeter-mk2")

local ion_cannon_targeter = util.table.deepcopy(data.raw["ammo-turret"]["gun-turret"])
--local ion_cannon_targeter = util.table.deepcopy(data.raw["capsule"]["artillery-targeting-remote"])
-- artillery-wagon-cannon (item)
-- artillery-turret (entity)
-- artillery-targeting-remote

ion_cannon_targeter.name = "ion-cannon-targeter"
ion_cannon_targeter.icon = mod.path.."graphics/crosshairs64.png"
ion_cannon_targeter.icon_size = 64
ion_cannon_targeter.flags = {--[["placeable-off-grid",]] "not-on-map"} --"placeable-off-grid" prevents placement via the map. TODO: verify
ion_cannon_targeter.collision_mask = {layers ={}}
ion_cannon_targeter.is_military_target = false
ion_cannon_targeter.fast_replaceable_group=nil
ion_cannon_targeter.next_upgrade = nil
ion_cannon_targeter.max_health = 1
ion_cannon_targeter.inventory_size = 0
ion_cannon_targeter.collision_box = {{0, 0}, {0, 0}}
ion_cannon_targeter.selection_box = {{0, 0}, {0, 0}}
ion_cannon_targeter.folded_animation =
{
	layers =
	{
		{
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			frame_count = 1,
			line_length = 1,
			run_mode = "forward",
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0, 0}
		}
	}
}
--[[
ion_cannon_targeter.base_picture{
	layers =
	{
		{
			filename = mod.path.."graphics/crosshairs64.png",
			line_length = 1,
			width = 64,
			height = 64,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0, 0}
		}
	}
}--]]
ion_cannon_targeter.graphics_set  = {
	base_visualisation = {
		animation = {
			north = {
				layers =
				{
					{
						filename = mod.path.."graphics/crosshairs64.png",
						line_length = 1,
						width = 64,
						height = 64,
						frame_count = 1,
						axially_symmetrical = false,
						direction_count = 1,
						shift = {0, 0}
					}
				}
			}
		}
	}
}
ion_cannon_targeter.water_reflection=nil
ion_cannon_targeter.preparing_animation = nil
ion_cannon_targeter.prepared_animation = nil
ion_cannon_targeter.preparing_sound = nil
ion_cannon_targeter.attacking_animation = nil
ion_cannon_targeter.corpse = nil
ion_cannon_targeter.damaged_trigger_effect=nil
ion_cannon_targeter.folding_sound=nil
--ion_cannon_targeter.folded_animation=nil required
ion_cannon_targeter.circuit_connector=nil
ion_cannon_targeter.minable = nil
ion_cannon_targeter.automated_ammo_count=0
ion_cannon_targeter.attack_parameters =
{
	type = "projectile",
	ammo_category = "melee",
	cooldown = 1,
	projectile_center = {0, 0},
	projectile_creation_distance = 1.4,
	range = settings.startup["ion-cannon-radius"].value --[[@as number]],
	damage_modifier = 1,
	ammo_type =
	{
		type = "projectile",
		category = "melee",
		energy_consumption = "0J",
		action =
		{
			{
				type = "direct",
				action_delivery =
				{
					{
						type = "projectile",
						projectile = "dummy-crosshairs",
						starting_speed = 0.28
					}
				}
			}
		}
	}
}

data:extend({ion_cannon_targeter})

local ion_cannon_targeter_mk2 = util.table.deepcopy(data.raw["ammo-turret"]["ion-cannon-targeter"])
ion_cannon_targeter_mk2.name = "ion-cannon-targeter-mk2"
ion_cannon_targeter_mk2.attack_parameters.range = ion_cannon_targeter.attack_parameters.range * 1.5
data:extend({ion_cannon_targeter_mk2})

data:extend{
	{
		type = "selection-tool",
		name = "orbital-ion-cannon-area-targeter",
		icon = mod.path.."graphics/crosshairs64.png",
		icon_size = 64,
		subgroup = "capsule",
		order = "a[tool]-b[custom-tool]",
		skip_fog_of_war = true,
		flags = {"not-stackable", "only-in-cursor","spawnable"},
		stack_size = 1,
		mouse_cursor = nil,
		select={
			border_color = {r = 1, g = 0, b = 0},
			mode = {"enemy"},
			cursor_box_type = "not-allowed",
		},
		alt_select = {
			border_color = {r = 1, g = 0, b = 0},
			mode = {"enemy"},
			cursor_box_type = "not-allowed"
		},
	}
}