local RESISTOR = "hidden-electric-resistance"
local pole_filter = { { filter = "type", type = "electric-pole" } }

local function add_resistor(pole)
  if not (pole and pole.valid) then return end
  -- защита от дубля (fast-replace / повторные события)
  if pole.surface.find_entity(RESISTOR, pole.position) then return end
  local r = pole.surface.create_entity {
    name = RESISTOR,
    position = pole.position,
    force = pole.force,
    create_build_effect_smoke = false,
  }
  if r then r.destructible = false end
end

local function remove_resistor(pole)
  if not (pole and pole.valid) then return end
  local r = pole.surface.find_entity(RESISTOR, pole.position)
  if r then r.destroy() end
end

local function on_built(event) add_resistor(event.entity) end
local function on_removed(event) remove_resistor(event.entity) end

script.on_event(defines.events.on_built_entity, on_built, pole_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, pole_filter)
script.on_event(defines.events.script_raised_built, on_built, pole_filter)
script.on_event(defines.events.script_raised_revive, on_built, pole_filter)

script.on_event(defines.events.on_player_mined_entity, on_removed, pole_filter)
script.on_event(defines.events.on_robot_mined_entity, on_removed, pole_filter)
script.on_event(defines.events.on_entity_died, on_removed, pole_filter)
script.on_event(defines.events.script_raised_destroy, on_removed, pole_filter)

-- Полная пересборка: сносим все резисторы и создаём заново актуальным прототипом.
-- energy_source (буфер/потребление) фиксируется у сущности при создании — при смене
-- настройки consumption старые резисторы иначе остались бы на прежнем значении.
-- Срабатывает на on_init и on_configuration_changed (в т.ч. при смене startup-настроек).
local function resync()
  for _, surface in pairs(game.surfaces) do
    for _, r in pairs(surface.find_entities_filtered { name = RESISTOR }) do
      r.destroy()
    end
    for _, pole in pairs(surface.find_entities_filtered { type = "electric-pole" }) do
      add_resistor(pole)
    end
  end
end

script.on_init(resync)
script.on_configuration_changed(resync)
