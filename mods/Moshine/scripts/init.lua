local common = require("common")

local Public = {}

function Public.initialize_moshine(surface) -- Must run before terrain generation

  if not surface then
    surface = game.planets["moshine"].create_surface()
    --log("no surface, generated")
  end

  if not surface.valid then
    game.delete_surface("moshine")
    surface = game.planets["moshine"].create_surface()
  end

  --log("initialize_moshine")
  --surface.min_brightness = 0.2
  --surface.brightness_visual_weights = { 0.12, 0.15, 0.12 }

  Public.create_lab_ruin(surface)

  return surface
end

function Public.create_lab_ruin(surface)
  local entities = surface.find_entities_filtered({
    area = {
      { common.LAB_POSITION.x - 4, common.LAB_POSITION.y - 4 },
      { common.LAB_POSITION.x + 4, common.LAB_POSITION.y + 4 },
    },
  })
  surface.destroy_decoratives({
    area = {
      { common.LAB_POSITION.x - 8, common.LAB_POSITION.y - 8 },
      { common.LAB_POSITION.x + 8, common.LAB_POSITION.y + 8 },
    },
  })

  for _, entity in pairs(entities) do
    if entity and entity.valid then
      if entity.type == "character" then
        entity.teleport({ 0, 0 })
      end
    else
      entity.destroy()
    end
  end

  local e = surface.create_entity({
      type = "resource",
    name = "fulgoran-data-source",
    position = common.LAB_POSITION,
    force = "neutral",
    create_build_effect_smoke = false,
  })

  e.minable_flag = false
  e.destructible = false

  --log("testlog create_entity")
end

script.on_event(defines.events.on_surface_created, function(event)
  local surface_index = event.surface_index
  local surface = game.surfaces[surface_index]

  if not (surface and surface.valid and surface.name == "moshine") then
    return
  end

  Public.initialize_moshine(surface)
  --log("testlog max")
end)

return Public
