local mod_name = "__RITEG__"
local ln_2 = 0.69314718
local heater_name = "RITEG-heater"
local rtg_names_list = { 'RITEG-1', 'RITEG-cyan', 'RITEG-breeder' }
local RTG_prop =
{
  ['RITEG-1'] = { energy = 40 * 10 ^ 9 },      -- 40 GJ
  ['RITEG-cyan'] = { energy = 200 * 10 ^ 9 },  -- 200 GJ
  ['RITEG-breeder'] = { energy = 40 * 10 ^ 9 } -- 40GJ
}

-- everything is local, writing into the top scope of control.lua is not allowed

local function is_rtg_name(name)
  for _, rtg_name in pairs(rtg_names_list) do
    if name == rtg_name then return true end
  end
  return false
end

local function add_glow(entity)
  -- the object is kept, otherwise a second glow is drawn every time the mod
  -- configuration changes and the old ones stay forever
  return rendering.draw_light
  {
    sprite = "utility/light_small",
    surface = entity.surface,
    target = entity
  }
end

-- the hidden heat source under the RITEG, only there with the freezing mechanic
local function add_heater(entity)
  if not prototypes.entity[heater_name] then return nil end
  local heater = entity.surface.create_entity
  {
    name = heater_name,
    position = entity.position,
    force = entity.force,
    create_build_effect_smoke = false
  }
  if heater then
    heater.destructible = false
    heater.temperature = 100
  end
  return heater
end

local function drop_rtg_extras(rtg)
  if rtg.render_obj and rtg.render_obj.valid then rtg.render_obj.destroy() end
  if rtg.heater and rtg.heater.valid then rtg.heater.destroy() end
  rtg.render_obj = nil
  rtg.heater = nil
end

local function try_init()
  storage.rtgs = storage.rtgs or {}
  storage.tick_id = storage.tick_id or 1
  storage.total_rtgs = storage.total_rtgs or 0
end

local function update_settings()
  storage.threshold = settings.global[mod_name .. "autodeconstruct-health-threshold"].value
end

local function update_ritegs()
  for _, rtg in pairs(storage.rtgs) do
    local entity = rtg.entity
    if entity and entity.valid then
      rtg.health_threshold = entity.max_health * storage.threshold / 100
    end
  end
end

local function update_recipes()
  for _, force in pairs(game.forces) do
    force.reset_technology_effects()
  end
end

local function power_of_RITEG(rtg)
  return rtg.first_power / (2 ^ ((game.tick - rtg.first_tick) / (rtg.half_life * 60))) / 60
end

local function make_rtg_prototype(data)
  local entity = data.entity
  local quality_multiplier = 1.0 + (entity.quality.level * 0.3)
  local rtg = {
    name = data.name,
    first_tick = data.tick,
    first_energy = RTG_prop[data.name].energy * quality_multiplier, -- 40 GJ
    entity = entity,
    first_power = (entity.health * 10 ^ 3),                         -- 600 kW
    health_threshold = entity.max_health * storage.threshold / 100,
    pause_to_tick = data.tick + 120
  }
  rtg.half_life = rtg.first_energy * ln_2 / rtg.first_power
  rtg.power = power_of_RITEG(rtg)
  rtg.render_obj = add_glow(entity)
  rtg.heater = add_heater(entity)
  return rtg
end

-- rebuilds the list from what is really on the surfaces. the old code appended
-- to the existing list on every configuration change, so every RITEG was in it
-- twice after an update and got a second glow
local function rebuild_rtg_table()
  for _, rtg in pairs(storage.rtgs) do
    drop_rtg_extras(rtg)
  end
  storage.rtgs = {}
  storage.total_rtgs = 0
  storage.tick_id = 1

  local tick = game.tick
  for _, surface in pairs(game.surfaces) do
    for _, rtg_name in pairs(rtg_names_list) do
      if prototypes.entity[rtg_name] then
        for _, entity in pairs(surface.find_entities_filtered { name = rtg_name }) do
          table.insert(storage.rtgs, make_rtg_prototype { name = rtg_name, tick = tick, entity = entity })
          storage.total_rtgs = storage.total_rtgs + 1
        end
      end
    end
  end

  -- a heater of a RITEG that is gone would stay on the map forever
  for _, surface in pairs(game.surfaces) do
    if prototypes.entity[heater_name] then
      for _, heater in pairs(surface.find_entities_filtered { name = heater_name }) do
        local kept = false
        for _, rtg in pairs(storage.rtgs) do
          if rtg.heater == heater then kept = true break end
        end
        if not kept then heater.destroy() end
      end
    end
  end
end

local function remove_rtg(tick_id)
  local rtg = storage.rtgs[tick_id]
  if rtg then drop_rtg_extras(rtg) end
  table.remove(storage.rtgs, tick_id)
  storage.total_rtgs = storage.total_rtgs - 1
end

local function onBuildHandler(event)
  local entity = event.entity
  table.insert(storage.rtgs, make_rtg_prototype { name = entity.name, tick = game.tick, entity = entity })
  storage.total_rtgs = storage.total_rtgs + 1
end

local function onMinedHandler(event)
  local buffer = event.buffer
  if not buffer then return end
  for i = 1, #buffer do
    buffer[i].health = 1
  end
end

local function autodeconstruct_rtg(entity)
  entity.order_deconstruction(entity.force)
end

local function replace_rtg(entity)
  entity.surface.create_entity {
    name = 'entity-ghost', position = entity.position,
    force = entity.force, inner_name = entity.name
  }
end

script.on_init(function()
  try_init()
  update_settings()
  update_recipes()
end)

script.on_configuration_changed(function()
  try_init()
  update_settings()
  rebuild_rtg_table()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function()
  update_settings()
  update_ritegs()
end)

local build_filter = {}
for _, rtg_name in pairs(rtg_names_list) do
  table.insert(build_filter, { filter = "name", name = rtg_name })
end

script.on_event(defines.events.on_built_entity, onBuildHandler, build_filter)
script.on_event(defines.events.on_robot_built_entity, onBuildHandler, build_filter)
if defines.events.on_space_platform_built_entity then
  script.on_event(defines.events.on_space_platform_built_entity, onBuildHandler, build_filter)
end

script.on_event(defines.events.on_player_mined_entity, onMinedHandler, build_filter)
script.on_event(defines.events.on_robot_mined_entity, onMinedHandler, build_filter)
if defines.events.on_space_platform_mined_entity then
  script.on_event(defines.events.on_space_platform_mined_entity, onMinedHandler, build_filter)
end

script.on_event(defines.events.on_tick, function()
  if storage.total_rtgs == 0 then return end
  local tick_id = storage.tick_id
  if tick_id > storage.total_rtgs then
    tick_id = 1
    storage.tick_id = 1
  end

  local rtg = storage.rtgs[tick_id]
  if not (rtg and rtg.entity and rtg.entity.valid) then
    remove_rtg(tick_id)
    return
  end

  local tick = game.tick
  if tick < (rtg.pause_to_tick or 0) then
    return
  end

  local power = power_of_RITEG(rtg)
  local entity = rtg.entity
  entity.power_production = power
  rtg.power = power

  -- the heat source is topped up while its RITEG is alive
  if rtg.heater and rtg.heater.valid then
    rtg.heater.temperature = 100
  end

  local power_was = rtg.power_was or (entity.health * (50 / 3))
  if power_was > power then
    local last_update_tick = rtg.last_update_tick or (tick - 1)
    local pause = tick - last_update_tick
    rtg.last_update_tick = tick
    rtg.pause_to_tick = tick + pause
    rtg.power_was = math.floor(power)
    local health_was = math.floor(power / (50 / 3))
    if entity.health > health_was then
      entity.health = health_was
    end
  end

  local threshold_health = rtg.health_threshold or 60
  if entity.health < threshold_health then
    autodeconstruct_rtg(entity)
    replace_rtg(entity)
    remove_rtg(tick_id)
    return
  end

  storage.tick_id = tick_id + 1
end)
