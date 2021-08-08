require("MushroomCloudInBuilt.explosions")
require("MushroomCloudInBuilt.radiation_noise")
require("MushroomCloudInBuilt.ground_zero")
require("MushroomCloudInBuilt.explosion_sizes")

	
local fireutil = require("__base__.prototypes.fire-util")

data:extend({
fireutil.add_basic_fire_graphics_and_effects_definitions
{
  type = "fire",
  name = "thermobaric-wave-fire",
  flags = {"placeable-off-grid", "not-on-map"},
  damage_per_tick = {amount = 13 / 60, type = "fire"},
  maximum_damage_multiplier = 6,
  damage_multiplier_increase_per_added_fuel = 1,
  damage_multiplier_decrease_per_tick = 0.005,

  spawn_entity = "fire-flame-on-tree",

  spread_delay = 300,
  spread_delay_deviation = 180,
  maximum_spread_count = 100,

  emissions_per_second = 0.005,

  initial_lifetime = 5,
  lifetime_increase_by = 150,
  lifetime_increase_cooldown = 4,
  maximum_lifetime = 1800,
  delay_between_initial_flames = 10,
  --initial_flame_count = 1,

}})
if(settings.startup["enable-thermobaric-cannons"].value or settings.startup["enable-thermobaric-rockets"].value or settings.startup["enable-thermobaric-artillery"].value) then
	require("prototypes.thermobarics.data-thermobaric")
end
if (not settings.startup["keep-atomic-bomb-without-changes"]) and not (settings.startup["enable-atomic-bomb"].value or settings.startup["enable-big-atomic-bomb"].value or settings.startup["enable-very-big-atomic-bomb"].value) then
	table.remove(data.raw.technology["atomic-bomb"].effects, 1)
end

require("prototypes.nukes.data-nuke-terrain")

if(settings.startup["enable-atomic-ammo"].value or settings.startup["enable-big-atomic-ammo"].value
    	or settings.startup["enable-atomic-cannons"].value or settings.startup["enable-big-atomic-cannons"].value
    	or settings.startup["enable-atomic-bomb"].value or settings.startup["enable-big-atomic-bomb"].value or settings.startup["enable-very-big-atomic-bomb"].value
    	or settings.startup["enable-small-atomic-artillery"].value or settings.startup["enable-atomic-artillery"].value
    	or settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value
    	or settings.startup["enable-fusion-building"].value or settings.startup["enable-mega-fusion-building"].value) then
	require("prototypes.nukes.data-nukes")
elseif (not(settings.startup["keep-atomic-research-without-weapons"].value or settings.startup["keep-atomic-bomb-without-changes"])) then
	data.raw.technology["atomic-bomb"] = nil
end


if(settings.startup["enable-fire-shield"].value) then
	data:extend({
	  {
		type = "energy-shield-equipment",
		name = "fire-shield-equipment",
		sprite =
		{
		  filename = "__True-Nukes__/graphics/fire-shield-equipment.png",
		  width = 64,
		  height = 64,
		  priority = "medium"
		},
		shape =
		{
		  width = 2,
		  height = 2,
		  type = "full"
		},
		max_shield_value = 1,
		energy_source =
		{
		  type = "electric",
		  buffer_capacity = "2000kJ",
		  input_flow_limit = "250kW",
		  usage_priority = "primary-input"
		},
		energy_per_shield = "20kJ",
		categories = {"armor"}
	  },
	  {
		type = "item",
		name = "fire-shield-equipment",
		icon = "__True-Nukes__/graphics/fire-shield-equipment-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		placed_as_equipment_result = "fire-shield-equipment",
		subgroup = "military-equipment",
		order = "a[shield]-aA[fire-shield-equipment]",
		default_request_amount = 5,
		stack_size = 10
	  },
	  {
		type = "recipe",
		name = "fire-shield-equipment",
		enabled = false,
		energy_required = 30,
		ingredients =
		{
		  {"low-density-structure", 10},
		  {"empty-barrel", 10}
		},
		result = "fire-shield-equipment"
	  }
	  })
end
  
  
  
  
  

function add_mushroom_cloud_effect(effect, prefix)
    table.insert(effect, 2, {
	                    type = "create-entity",
	                    entity_name = prefix .. "uranium-explosion-LUQ",
	                })
    table.insert(effect, 3, {
	                    type = "create-entity",
	                    entity_name = prefix .. "uranium-explosion-RUQ"
	                })
    table.insert(effect, 4, {
	                    type = "create-entity",
	                    entity_name = prefix .. "uranium-explosion-LLQ"
	                })
    table.insert(effect, 5, {
	                    type = "create-entity",
	                    entity_name = prefix .. "uranium-explosion-RLQ"
	                })
    table.insert(effect, 6, {
	                    type = "create-entity",
	                    entity_name = "nuclear-scorchmark",
	                    check_buildability = true
	                })



end
if(settings.startup["enable-thermobaric-rockets"].value) then
	add_mushroom_cloud_effect(data.raw.projectile["thermobaric-rocket"].action.action_delivery.target_effects, "small-")
end
if(settings.startup["enable-thermobaric-artillery"].value) then
	add_mushroom_cloud_effect(data.raw["artillery-projectile"]["thermobaric-artillery-projectile"].action.action_delivery.target_effects, "")
end
if(settings.startup["enable-thermobaric-cannons"].value) then
	if mods["SchallTankPlatoon"] then
		add_mushroom_cloud_effect(data.raw.projectile["thermobaric-cannon-H2-projectile"].action.action_delivery.target_effects, "small-")
	end
end






if(settings.startup["enable-menu-backgrounds"].value)then
	if(settings.startup["enable-atomic-bomb"].value or settings.startup["enable-big-atomic-bomb"].value or settings.startup["enable-very-big-atomic-bomb"].value) then
		require("menu-simulations.nuke-1x20t")
	end

	if(settings.startup["enable-atomic-cannons"].value or settings.startup["enable-big-atomic-cannons"].value) then
		require("menu-simulations.nuke-2x2t")
	end

	if(settings.startup["enable-atomic-artillery"].value or settings.startup["enable-big-atomic-artillery"].value or settings.startup["enable-very-big-atomic-artillery"].value) then
		require("menu-simulations.nuke-1x1kt")
	end
end








