-- Paranoidal fork: the build ships no Space Exploration graphics; the telescope is drawn as the base radar dish turning
-- while it works (3 x 3 like the radar).
local function paranoidal_telescope_dish()
    local function sheet(filename, width, height, shift, shadow)
        return {filename = filename, priority = "low", width = width, height = height, frame_count = 64, line_length = 8,
            shift = shift, scale = 0.5, animation_speed = 0.25, draw_as_shadow = shadow}
    end
    return {
        animation = {layers = {
            sheet("__base__/graphics/entity/radar/radar.png", 196, 254, {0.03125, -0.5}, nil),
            sheet("__base__/graphics/entity/radar/radar-shadow.png", 336, 170, {1.21875, 0.1875}, true),
        }},
    }
end

--Extends Assembling machine
local telescope = Muluna.rro.merge(data.raw["assembling-machine"]["assembling-machine-3"],{
    type = "assembling-machine", --Extends Assembling machine
    name = "muluna-telescope",
    muluna_is_telescope = true,
    next_upgrade = "_nil",
    module_slots = 2,
    crafting_speed = 1,
    crafting_categories = {"muluna-telescope"},
    selection_box = Muluna.flib_bounding_box.from_dimensions({0,0},3,3),
    collision_box = Muluna.flib_bounding_box.from_dimensions({0,0},3-0.5,3-0.5),
    energy_usage = "10MW",
    --energy_source = table.deepcopy(data.raw["assembling-machine-3"].energy_source),
    effect_receiver = "_nil",
    --per_surface_limit = 1, --Custom field: Number of telescopes per surface
    --circuit_connector = table.deepcopy(data.raw["assembling-machine-3"].circuit_connector),
    minable = {
        mining_time = 1,
        result = "muluna-telescope",
        amount = 1,
    },
    icon = mods["space-exploration-graphics"] and "__space-exploration-graphics__/graphics/icons/telescope.png" or data.raw["radar"]["radar"].icon,
    icon_size = 64,
    icons = "_nil",
    graphics_set = mods["space-exploration-graphics-4"] and {
      working_visualisations = {{
        constant_speed = true,
        always_draw = true,
        animation =
        {
          layers =
          {
            {
              filename = "__space-exploration-graphics-4__/graphics/entity/telescope/telescope.png",
              priority = "high",
              width = 2080/8,
              height = 2128/8,
              frame_count = 64,
              line_length = 8,
              shift = util.by_pixel(6, -19),
              animation_speed = 0.25,
              max_advance = 0.25,
              scale = 0.5,
            },
            {
              draw_as_shadow = true,
              filename = "__space-exploration-graphics-4__/graphics/entity/telescope/telescope-shadow.png",
              priority = "high",
              width = 2608/8,
              height = 1552/8,
              frame_count = 64,
              line_length = 8,
              shift = util.by_pixel(32, 7),
              animation_speed = 0.25,
              max_advance = 0.25,
              scale = 0.5,
            },
          },
        },
      }}
      
    } or paranoidal_telescope_dish(), -- Paranoidal fork: without Space Exploration graphics a turning radar dish
    --icon = data.raw["item"]["muluna-telescope"].icon,
})
if not mods["space-exploration-graphics"] then -- Paranoidal: the radar icon of the build
    telescope = Muluna.rro.merge(telescope, Muluna.img.radar_icon_fields(data.raw["radar"]["radar"]))
end

telescope.energy_source.emissions_per_minute={}

-- for _,animation in pairs({"south_animation","east_animation","west_animation"}) do
--   telescope.graphics_set.working_visualisations[animation] = telescope.graphics_set.working_visualisations["north_animation"]
-- end

table.remove(telescope.fluid_boxes,1)
telescope.fluid_boxes[1].pipe_connections[1].connection_category = "data"
telescope.fluid_boxes[1].filter = "muluna-astronomical-data"
telescope.fluid_boxes[1].pipe_covers = nil
telescope.fluid_boxes[1].pipe_covers_frozen = nil
telescope.fluid_boxes[1].pipe_picture = nil
telescope.fluid_boxes[1].pipe_picture_frozen = nil

Muluna:extend{telescope}

-- Muluna.rro.copy_fields(telescope,data.raw["assembling-machine"]["assembling-machine-3"],

--     {
--         "selection_box",
--         "collision_box",
--         "energy_source",
--         "effect_receiver",
--         "circuit_connector",
--         "graphics_set",
--     }
-- )

--Extends Assembling machine
-- local space_telescope = {
--     type = "muluna-space-telescope", 
--     name = "muluna-space-telescope",
--     crafting_speed = 1,
--     distance_speed_factor = 1, --Custom field: How much distance from Muluna adds to productivity
--     circuit_connector = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"].circuit_connector),
-- }

Muluna.rro.soft_insert(Muluna.constants.telescope_entities, --Entities with limited number of placements
    {name = "muluna-telescope",
    count = 1,    

})



-- rro.soft_insert(Muluna.constants.telescope_entities , {
--   name = "muluna-telescope",
--   combinator = 
-- })



Muluna:extend{
  {
    type = "recipe-category",
    name = "muluna-telescope"
  },

}