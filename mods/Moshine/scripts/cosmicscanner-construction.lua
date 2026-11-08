-- Script by Talandar

local prestage_number = 4
local required_crafts = 40

script.on_init(function()
  storage.megastructure_progress = storage.megastructure_progress or {}
  storage.megastructure_text_ids = storage.megastructure_text_ids or {}
end)

script.on_configuration_changed(function()
  storage.megastructure_progress = storage.megastructure_progress or {}
  storage.megastructure_text_ids = storage.megastructure_text_ids or {}
end)

local stage_names = {
  "moshine_cosmicscanner-construction-stage-1",
  "moshine_cosmicscanner-construction-stage-2",
  "moshine_cosmicscanner-construction-stage-3",
  "moshine_cosmicscanner-construction-stage-4",
  "moshine_cosmicscanner",
}

local function create_or_update_text(entity, progress)
  storage.megastructure_text_ids = storage.megastructure_text_ids or {}
  local unit_number = entity.unit_number
  local old_id = storage.megastructure_text_ids[unit_number]

  if old_id then
    local obj = rendering.get_object_by_id(old_id)
    if obj then
      obj.destroy()
    end
  end

  local new_obj = rendering.draw_text({
    text = progress .. "/" .. required_crafts,
    surface = entity.surface,
    target = entity,
    target_offset = {0, 4.5},
    color = { r = 1, g = 1, b = 1 },
    alignment = "center",
    scale = 1.2,
  })

  storage.megastructure_text_ids[unit_number] = new_obj.id
end

local function construct_megastructure(entity, next_stage_name, is_final)
  storage.megastructure_progress = storage.megastructure_progress or {}
  storage.megastructure_text_ids = storage.megastructure_text_ids or {}

  local surface = entity.surface
  local position = entity.position
  local force = entity.force
  local old_unit_number = entity.unit_number
  --local quality = entity.quality

  storage.megastructure_progress[old_unit_number] = nil

  local old_id = storage.megastructure_text_ids[old_unit_number]
  if old_id then
    local obj = rendering.get_object_by_id(old_id)
    if obj then
      obj.destroy()
    end
    storage.megastructure_text_ids[old_unit_number] = nil
  end

  local new_entity = surface.create_entity({
    name = next_stage_name,
    position = position,
    --quality = quality,
    force = force,
    fast_replace = true,
    create_build_effect_smoke = true,
  })

  if not is_final and new_entity and new_entity.valid then
    storage.megastructure_progress[new_entity.unit_number] = 0
    create_or_update_text(new_entity, 0)
  end

  entity.destroy()
end

for i = 1, prestage_number do
  local recipe_name = "moshine_cosmicscanner-construct-" .. i
  local next_stage_name = stage_names[i + 1]
  local is_final = (i == prestage_number)

  script.on_event(prototypes.recipe[recipe_name].on_crafted_event, function(event)
    local entity = event.entity
    if not entity or not entity.valid then
      return
    end

    storage.megastructure_progress = storage.megastructure_progress or {}
    local unit_number = entity.unit_number
    local current_progress = (storage.megastructure_progress[unit_number] or 0) + 1
    storage.megastructure_progress[unit_number] = current_progress

    if current_progress >= required_crafts then
      construct_megastructure(entity, next_stage_name, is_final)
    else
      create_or_update_text(entity, current_progress)
      entity.surface.play_sound({
        path = "utility/build_medium",
        position = entity.position,
        volume_modifier = 0.8,
      })
    end
  end)
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id == "moshine_cosmicscanner-built" then
    local entity = event.target_entity or event.source_entity
    if not entity or not entity.valid then
      return
    end

    if entity.name == "moshine_cosmicscanner-construction-stage-1" then
      storage.megastructure_progress = storage.megastructure_progress or {}
      storage.megastructure_progress[entity.unit_number] = 0
      create_or_update_text(entity, 0)
    end
  end
end)

local function on_entity_removed(event)
  local entity = event.entity
  if entity.valid and entity.name:find("moshine_cosmicscanner") then
    storage.megastructure_progress = storage.megastructure_progress or {}
    storage.megastructure_text_ids = storage.megastructure_text_ids or {}

    local unit_number = entity.unit_number
    storage.megastructure_progress[unit_number] = nil

    local old_id = storage.megastructure_text_ids[unit_number]
    if old_id then
      local obj = rendering.get_object_by_id(old_id)
      if obj then
        obj.destroy()
      end
      storage.megastructure_text_ids[unit_number] = nil
    end
  end
end

local destroy_filters = {
  {filter = "name", name = "moshine_cosmicscanner-construction-stage-1" },
  {filter = "name", name = "moshine_cosmicscanner-construction-stage-2" },
  {filter = "name", name = "moshine_cosmicscanner-construction-stage-3" },
  {filter = "name", name = "moshine_cosmicscanner-construction-stage-4" },
  {filter = "name", name = "moshine_cosmicscanner" },
}

script.on_event(defines.events.on_player_mined_entity, on_entity_removed, destroy_filters)
script.on_event(defines.events.on_robot_mined_entity, on_entity_removed, destroy_filters)
script.on_event(defines.events.on_entity_died, on_entity_removed, destroy_filters)
script.on_event(defines.events.script_raised_destroy, on_entity_removed, destroy_filters)

