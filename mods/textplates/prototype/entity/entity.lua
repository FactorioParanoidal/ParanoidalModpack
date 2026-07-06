local function text_blank_sprite()
    return {
        filename = "__textplates__/graphics/blank.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = {0, 0},
    }
end

local function text_sprite(size, material, symbol)
  if symbol == "blank" then symbol = "square" end -- this is the one you visually place
  return {
    layers = {
      {
        filename = "__textplates__/graphics/entity/"..material.."/"..symbol..".png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 1,
        scale = size == "large" and 0.5 or 0.25,
        shift = {1/32, -1/32},
      },
      {
        draw_as_shadow = true,
        filename = "__textplates__/graphics/entity/shadow/"..symbol..".png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 1,
        scale = size == "large" and 0.5 or 0.25,
        shift = {2/32, 0},
      },
      material == "uranium" and
      {
        draw_as_light = true,
        filename = "__textplates__/graphics/entity/"..material.."_glow/"..symbol..".png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 1,
        scale = size == "large" and 0.5 or 0.25,
        shift = {1/32, -1/32},
      } or nil,
    }
  }
end

for _, type in pairs(textplates.types) do
  local size = type.size
  local material = type.material
  local icon = "__textplates__/graphics/entity/"..material.."/blank.png"
  if size == "large" then
    icon = "__textplates__/graphics/entity/"..material.."/square.png"
  end
  local entity = {
    name = type.name,
    type = "simple-entity-with-force",
    icon = icon,
    icon_size = 128,
    localised_name = { "entity-name.textplate", { "textplates."..size }, {"textplates.".. material } },
    fast_replaceable_group = "textplates-" .. size,
    flags = {"placeable-neutral", "player-creation"},
    minable = {
        count=1,
        hardness = 0,
        mining_time = 0.1,
        result = type.name,
    },
    render_layer = "lower-object-above-shadow",
    collision_mask = {
      layers = {
        floor = true,
        water_tile = true
      },
    },
    resistances = {
        {type = "fire", percent = 80},
    },
    pictures = {},

    max_health = 25,
    collision_box = { {-0.45, -0.45}, {0.45, 0.45} },
    selection_box = { {-0.5, -0.5}, {0.5, 0.5} },
    corpse = "small-remnants",
  }

  for id, symbol in ipairs(type.symbols) do
     entity.pictures[id] = text_sprite(size, material, symbol)
  end

  if size == "large" then
    entity.corpse = "medium-remnants"
    entity.max_health = 100
    entity.collision_box = {{-0.9, -0.9}, {0.9, 0.9}}
    entity.selection_box = {{-1, -1}, {1, 1}}
    entity.minable.mining_time = 0.2
  end

  data:extend({entity})
end
