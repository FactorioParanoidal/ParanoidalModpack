-- local assembler_pictures = require("__base__.prototypes.entity.assembler-pictures")
-- local pipe_picture = assembler_pictures.assembler3pipepictures
-- pipe_picture.north = util.empty_sprite()
-- pipe_picture.south.filename = "__PlanetsLib__/graphics/entity/centrifuge/centrifuge-pipe-S.png"
-- pipe_picture.east.filename = "__PlanetsLib__/graphics/entity/centrifuge/centrifuge-pipe-E.png"
-- pipe_picture.west.filename = "__PlanetsLib__/graphics/entity/centrifuge/centrifuge-pipe-W.png"

local pipe_picture = {
    north = util.empty_sprite(),
    east =
    {
      filename = "__PlanetsLib__/graphics/entity/centrifuge/centrifuge-pipe-E.png",
      priority = "extra-high",
      width = 42,
      height = 76,
      shift = util.by_pixel(-24.5, 1),
      scale = 0.5
    },
    south =
    {
      filename = "__PlanetsLib__/graphics/entity/centrifuge/centrifuge-pipe-S.png",
      priority = "extra-high",
      width = 88,
      height = 61,
      shift = util.by_pixel(0, -31.25),
      scale = 0.5
    },
    west =
    {
      filename = "__PlanetsLib__/graphics/entity/centrifuge/centrifuge-pipe-W.png",
      priority = "extra-high",
      width = 39,
      height = 73,
      shift = util.by_pixel(25.75, 1.25),
      scale = 0.5
    }
  }

local fluid_boxes = {
	{
		production_type = "input",
		pipe_picture = pipe_picture,
		pipe_covers = pipecoverspictures(),
		volume = 1000,
		pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } } },
	},
	{
		production_type = "output",
		pipe_picture = pipe_picture,
		pipe_covers = pipecoverspictures(),
		volume = 1000,
		pipe_connections = { { flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } } },
	},
	--[[
	{
		production_type = "input",
		pipe_picture = pipe_picture,
		pipe_covers = pipecoverspictures(),
		volume = 1000,
		pipe_connections = { { flow_direction = "input", direction = defines.direction.west, position = { -1, 0 } } },
	},
	{
		production_type = "output",
		pipe_picture = pipe_picture,
		pipe_covers = pipecoverspictures(),
		volume = 1000,
		pipe_connections = { { flow_direction = "output", direction = defines.direction.east, position = { 1, 0 } } },
	},
	--]]
}
if settings.startup["PlanetsLib-enable-additional-centrifuge-fluidboxes"].value then
	table.insert(
		fluid_boxes,
		{
			production_type = "input",
			pipe_picture = pipe_picture,
			pipe_covers = pipecoverspictures(),
			volume = 1000,
			pipe_connections = { { flow_direction = "input", direction = defines.direction.west, position = { -1, 0 } } },
		}
	)
	table.insert(
		fluid_boxes,
		{
			production_type = "output",
			pipe_picture = pipe_picture,
			pipe_covers = pipecoverspictures(),
			volume = 1000,
			pipe_connections = { { flow_direction = "output", direction = defines.direction.east, position = { 1, 0 } } },
		}
	)
end

-- Ensure centrifuges can accept fluid recipes. It isn't ideal that we change modded centrifuges this way, as the fluid boxes may be in the wrong positions, but on the other hand they're only visible when fluid recipes are used.
for _, machine in pairs(data.raw["assembling-machine"]) do
	if machine.crafting_categories and not machine.fluid_boxes then
		for _, category in pairs(machine.crafting_categories) do
			if category == "centrifuging" then
				machine.fluid_boxes = util.table.deepcopy(fluid_boxes)
				machine.fluid_boxes_off_when_no_fluid_recipe = true
				break
			end
		end
	end
end

-- Paranoidal fork: no centrifuge tower tint, the home centrifuge keeps its look (nothing before the rocket changes).
