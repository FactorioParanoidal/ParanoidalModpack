-- Lighted poles: every "lighted-<pole>" gets a hidden lamp "lighted-<pole>-lamp" at its position.
-- The pole is registered with register_on_object_destroyed, so its lamp goes away however the pole is
-- removed (mined, killed, upgraded, destroyed by a script without an event).
-- storage.lamps: registration number of a pole -> its lamp.

local PREFIX, SUFFIX = "lighted-", "-lamp"

-- Prototype lookups; prototypes do not change while the game runs, so a local cache is safe.
local lamp_of = {} -- pole name -> lamp name or false
local function lamp_name(pole_name)
  local name = lamp_of[pole_name]
  if name == nil then
    name = false
    if pole_name:sub(1, #PREFIX) == PREFIX and prototypes.entity[pole_name .. SUFFIX] then
      name = pole_name .. SUFFIX
    end
    lamp_of[pole_name] = name
  end
  return name
end

local is_lamp -- lamp name -> true
local function lamp_names()
  if not is_lamp then
    is_lamp = {}
    for name in pairs(prototypes.get_entity_filtered({{filter = "type", type = "electric-pole"}})) do
      local lamp = lamp_name(name)
      if lamp then is_lamp[lamp] = true end
    end
  end
  return is_lamp
end

local function remove_lamp(registration)
  local lamp = storage.lamps[registration]
  if lamp then
    storage.lamps[registration] = nil
    if lamp.valid then lamp.destroy() end
  end
end

local function place_lamp(pole)
  local name = lamp_name(pole.name)
  if not name then return end
  local registration = script.register_on_object_destroyed(pole)
  remove_lamp(registration)
  local lamp = pole.surface.create_entity({name = name, position = pole.position, force = pole.force})
  if lamp then
    lamp.destructible = false
    lamp.minable_flag = false -- Factorio 2.1: LuaEntity::minable is read-only
    storage.lamps[registration] = lamp
  end
end

local function on_built(event)
  local entity = event.entity or event.destination
  if entity and entity.valid then place_lamp(entity) end
end

local function on_cloned(event)
  local entity = event.destination
  if not (entity and entity.valid) then return end
  if lamp_names()[entity.name] then
    entity.destroy() -- the cloned pole gets its own lamp
  else
    place_lamp(entity)
  end
end

local function on_destroyed(event)
  remove_lamp(event.registration_number)
end

-- Even Pickier Dollies moved a pole: move its lamp along.
local function on_moved(event)
  local pole = event.moved_entity
  if not (pole and pole.valid and lamp_name(pole.name)) then return end
  local lamp = storage.lamps[script.register_on_object_destroyed(pole)]
  if lamp and lamp.valid then
    lamp.teleport(pole.position)
  else
    place_lamp(pole)
  end
end

-- Remove every hidden lamp and place one under every lighted pole (new mod in a save, changed prototypes).
local function rebuild()
  lamp_of, is_lamp = {}, nil
  for _, lamp in pairs(storage.lamps or {}) do
    if lamp.valid then lamp.destroy() end
  end
  storage.lamps = {}
  local lamps, poles = {}, {}
  for lamp in pairs(lamp_names()) do
    lamps[#lamps + 1] = lamp
    poles[#poles + 1] = lamp:sub(1, -#SUFFIX - 1)
  end
  if not lamps[1] then return end
  for _, surface in pairs(game.surfaces) do
    for _, lamp in pairs(surface.find_entities_filtered({name = lamps})) do lamp.destroy() end
    for _, pole in pairs(surface.find_entities_filtered({name = poles})) do place_lamp(pole) end
  end
end

-- Lighted pole recipes unlocked by technologies that a force has already researched.
local function enable_researched_recipes()
  for _, force in pairs(game.forces) do
    for _, technology in pairs(force.technologies) do
      if technology.researched then
        for _, effect in pairs(technology.prototype.effects) do
          if effect.type == "unlock-recipe" and effect.recipe:sub(1, #PREFIX) == PREFIX then
            local recipe = force.recipes[effect.recipe]
            if recipe then recipe.enabled = true end
          end
        end
      end
    end
  end
end

local function register_dollies()
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_moved)
  end
end

local pole_filter = {{filter = "type", type = "electric-pole"}}
for _, id in pairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
}) do
  script.on_event(id, on_built, pole_filter)
end
script.on_event(defines.events.on_entity_cloned, on_cloned,
  {{filter = "type", type = "electric-pole"}, {filter = "type", type = "lamp"}})
script.on_event(defines.events.on_object_destroyed, on_destroyed)

script.on_init(function()
  storage.lamps = {}
  rebuild()
  register_dollies()
end)

script.on_load(register_dollies)

script.on_configuration_changed(function()
  rebuild()
  enable_researched_recipes()
end)
