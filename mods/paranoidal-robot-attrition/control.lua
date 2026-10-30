local shared = require("shared")
local hooks = require("scripts.hooks")
local attrition = require("scripts.attrition")
local crash = require("scripts.crash")
local panel = require("scripts.panel")
local reliability = require("scripts.reliability")
local selection = require("scripts.select")
local stats = require("scripts.stats")

-- Built-in features use the same extension points as other features would.
hooks.select = selection.pick
hooks.spare[#hooks.spare + 1] = reliability.spare

-- Raised for every crashing robot before it dies: {robot, force, surface_index, busy, wreck, detonated, ignited}.
local on_robot_crashed = script.generate_event_name()
crash.event_id = on_robot_crashed

local function init_storage()
  storage.risk = storage.risk or {}                             -- [force index][surface index] = risk
  storage.crashes = storage.crashes or {}                       -- [force index] = crashed robots
  storage.recent = storage.recent or {}                         -- [force index][minute slot] = {minute, crashes}
  storage.alerts = storage.alerts or {}                         -- [force index][surface index] = tick of the last alert
  storage.surface_multiplier = storage.surface_multiplier or {} -- [surface index] = multiplier (remote)
  storage.panels = storage.panels or {}                         -- [player index] = {entity, frame, body}
  storage.force_enabled = storage.force_enabled or {}           -- [force index] = true/false (remote)
end

-- Drops data of forces, surfaces and players that no longer exist.
local function prune()
  for _, by_force in pairs({storage.risk, storage.crashes, storage.recent, storage.alerts, storage.force_enabled}) do
    for force_index in pairs(by_force) do
      if not game.forces[force_index] then by_force[force_index] = nil end
    end
  end
  for surface_index in pairs(storage.surface_multiplier) do
    if not game.surfaces[surface_index] then storage.surface_multiplier[surface_index] = nil end
  end
  for _, by_force in pairs({storage.risk, storage.alerts}) do
    for _, by_surface in pairs(by_force) do
      for surface_index in pairs(by_surface) do
        if not game.surfaces[surface_index] then by_surface[surface_index] = nil end
      end
    end
  end
  for player_index in pairs(storage.panels) do panel.close(player_index) end
end

script.on_init(init_storage)
script.on_configuration_changed(function()
  init_storage()
  prune()
end)

script.on_nth_tick(shared.interval, function()
  attrition.scan()
  if next(storage.panels) then panel.refresh_all() end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  if event.entity and event.entity.valid and event.entity.type == "roboport" then
    panel.open(player, event.entity)
  elseif storage.panels[event.player_index] then
    panel.close(event.player_index)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if storage.panels[event.player_index] then panel.close(event.player_index) end
end)

script.on_event(defines.events.on_player_removed, function(event)
  storage.panels[event.player_index] = nil
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == shared.setting_panel and event.player_index and storage.panels[event.player_index] then
    panel.close(event.player_index)
  end
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  storage.surface_multiplier[event.surface_index] = nil
  for _, by_force in pairs({storage.risk, storage.alerts}) do
    for _, by_surface in pairs(by_force) do by_surface[event.surface_index] = nil end
  end
end)

script.on_event(defines.events.on_forces_merged, function(event)
  local source, destination = event.source_index, event.destination.index
  storage.crashes[destination] = (storage.crashes[destination] or 0) + (storage.crashes[source] or 0)
  for _, by_force in pairs({storage.risk, storage.crashes, storage.recent, storage.alerts, storage.force_enabled}) do
    by_force[source] = nil
  end
end)

local function surface_index(surface)
  local s = game.get_surface(surface)
  if not s then error("unknown surface: " .. tostring(surface)) end
  return s.index
end

remote.add_interface("paranoidal-robot-attrition", {
  -- {on_robot_crashed = id} for script.on_event.
  get_event_ids = function() return {on_robot_crashed = on_robot_crashed} end,
  -- Robots of a force crashed since the mod was added (force name or index).
  get_crash_count = function(force)
    local f = game.forces[force]
    return f and stats.total(f.index) or 0
  end,
  -- {total, last_hour} crashed robots of a force (force name or index).
  get_force_summary = function(force)
    local f = game.forces[force]
    if not f then return nil end
    return {total = stats.total(f.index), last_hour = stats.last_hour(f.index)}
  end,
  -- Crash rate multiplier of a surface (name or index) on top of the map setting; nil resets it to 1, 0 disables.
  set_surface_multiplier = function(surface, multiplier)
    if multiplier ~= nil and (type(multiplier) ~= "number" or multiplier < 0) then
      error("multiplier must be a number >= 0 or nil")
    end
    storage.surface_multiplier[surface_index(surface)] = multiplier
  end,
  -- Whether a force (name or index) is checked: true always, false never, nil back to the default (forces with
  -- players).
  set_force_enabled = function(force, enabled)
    local f = game.forces[force]
    if not f then error("unknown force: " .. tostring(force)) end
    if enabled ~= nil and type(enabled) ~= "boolean" then error("enabled must be a boolean or nil") end
    storage.force_enabled[f.index] = enabled
  end,
  get_surface_multiplier = function(surface)
    return storage.surface_multiplier[surface_index(surface)] or 1
  end,
})
