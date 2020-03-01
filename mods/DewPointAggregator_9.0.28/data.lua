require "biometypes"

local function createConnections()
	local conn = {}
	for i = -1,1,2 do
		table.insert(conn, {position = {i, 3}, type = "output"})
		table.insert(conn, {position = {i, -3}, type = "output"})
		table.insert(conn, {position = {3, i}, type = "output"})
		table.insert(conn, {position = {-3, i}, type = "output"})
	end
	return conn
end

local smooth = 25--4

local function createSprite(shadow)
     return {
        filename = "__DewPointAggregator__/graphics/" .. (shadow and "shadow" or "sprite2") .. ".png",
        width = 207,
        height = 199,
        frame_count = shadow and 1 or 8,
        line_length = shadow and 1 or 4,
        animation_speed = 2,
		scale = 0.8,
        draw_as_shadow = shadow,
      }
end

local function createRecipe(name, factor)
	return {
		type = "recipe",
		name = "dpa-action-" .. name,
		energy_required = 1/smooth,
		enabled = true,
		category = "dpa",
		ingredients = {},
		results = {{type = "fluid", name = "water", amount = math.floor(100/smooth*factor+0.5)}},
		hidden = true,
	}
end

data:extend(
{
  {
    type = "assembling-machine",
    name = "dpa",
    icon = "__DewPointAggregator__/graphics/icon2.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "dpa"},
    max_health = 200,
    crafting_categories = {"dpa"},
    crafting_speed = 1,
    ingredient_count = 1,
    module_specification = nil,
    allowed_effects = nil,
    fast_replaceable_group = nil,
    corpse = "big-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    fluid_boxes =
    {
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        base_area = 25,
        base_level = 1,
        pipe_connections = createConnections()
      },
      off_when_no_fluid_recipe = false
    },
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.01,
	  drain = "160kW",
    },
    energy_usage = "1900KW",
    working_sound =
    {
      sound =
      {
        {
          filename = "__DewPointAggregator__/sound.ogg",
          volume = 0.8
        },
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5
    },
    animation =
    {
      layers =
      {
		createSprite(false),
      },
      {
		createSprite(true),
      }
    }
  },
	{
		type = "recipe",
		name = "dpa",
		energy_required = 15,
		enabled = false,
		ingredients =
		{
			{"iron-plate", 56},
			{"iron-gear-wheel", 30},
			{"engine-unit", 16},
			{"pipe", 25},
		},
		result = "dpa"
	},
	{
		type = "recipe-category",
		name = "dpa"
	},
	{
		type = "item",
		name = "dpa",
		icon = "__DewPointAggregator__/graphics/icon2.png",
		icon_size = 32,
		--flags = {},
		subgroup = "extraction-machine",
		order = "b[fluids]-a[dpa]",
		place_result = "dpa",
		stack_size = 10
	},
	{
		type = "technology",
		name = "dpa",
		icon = "__DewPointAggregator__/graphics/tech.png",
		icon_size = 128,
		prerequisites =
		{
		  "fluid-handling",
		  "engine",
		},
		effects =
		{
		  {
			type = "unlock-recipe",
			recipe = "dpa"
		  },
		},
		unit =
		{
		  count = 40,
		  ingredients =
		  {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
		  },
		  time = 30
		},
		upgrade = true,
		order = "a-f",
	},
})

for type,fac in pairs(biomeTypes) do
	data:extend({createRecipe(type, fac)})
	log("Creating DPA function for biome " .. type .. ": " .. fac .. "x yield")
end
