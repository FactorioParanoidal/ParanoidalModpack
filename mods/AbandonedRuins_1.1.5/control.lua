local util = require("__AbandonedRuins__/utilities")
local spawning = require("__AbandonedRuins__/spawning")
---@type table<string, RuinSet>
local ruin_sets = {}
ruin_sets.base = require("__AbandonedRuins__/ruins/base_ruin_set")

local on_entity_force_changed_event = script.generate_event_name()

local function spawn_chances()
  local smallChance = settings.global["ruins-small-ruin-chance"].value
  local mediumChance = settings.global["ruins-medium-ruin-chance"].value
  local largeChance = settings.global["ruins-large-ruin-chance"].value
  local sumChance = smallChance + mediumChance + largeChance
  local totalChance = math.min(sumChance, 1)
  -- now compute cumulative distribution of conditional probabilities for
  -- spawn_type given a spawn occurs.
  local smallThreshold = smallChance / sumChance * totalChance
  local mediumThreshold = mediumChance / sumChance * totalChance + smallThreshold
  local largeThreshold = largeChance / sumChance * totalChance + mediumThreshold

  global.spawn_table = {small = smallThreshold, medium = mediumThreshold, large = largeThreshold}
end

local function init()
  util.set_enemy_force_cease_fire(util.get_enemy_force(), not settings.global["AbandonedRuins-enemy-not-cease-fire"].value)
  spawn_chances()
  if global.spawn_ruins == nil then
    global.spawn_ruins = true
  end
  global.ruin_queue = global.ruin_queue or {}
  if not global.excluded_surfaces then
    global.excluded_surfaces = {
      ["beltlayer"] = true,
      ["pipelayer"] = true,
      ["Factory floor"] = true, -- factorissimo
      ["ControlRoom"] = true -- mobile factory
    }
  end
end

script.on_init(init)
script.on_configuration_changed(init)
script.on_event(defines.events.on_runtime_mod_setting_changed, init)

script.on_event(defines.events.on_force_created,
  function()
    -- Sets up the diplomacy for all forces, not just the newly created one.
    util.set_enemy_force_diplomacy(util.get_enemy_force(), not settings.global["AbandonedRuins-enemy-not-cease-fire"].value)
  end
)

script.on_event(defines.events.on_tick,
  function(event)
    ---@type RuinQueueItem[]
    local ruins = global.ruin_queue[event.tick]
    if not ruins then return end
    for _, ruin in pairs(ruins) do
      spawning.spawn_random_ruin(ruin_sets[settings.global["AbandonedRuins-set"].value][ruin.size], util.ruin_half_sizes[ruin.size], ruin.center, ruin.surface)
    end
    global.ruin_queue[event.tick] = nil
  end
)

-- This delays ruin spawning to the next tick. This is done because on_chunk_generated may be called before other mods have a chance to do the remote call for the ruin set:  
-- ThisMod_onInit -> SomeOtherMod_generatesChunks -> ThisMod_onChunkGenerated (ruin is queued) -> RuinPack_onInit (ruin set remote call) -> ThisMod_OnTick (ruin set is used)
---@param tick uint
---@param ruin RuinQueueItem
local function queue_ruin(tick, ruin)
  local processing_tick = tick + 1
  if not global.ruin_queue[processing_tick] then
    global.ruin_queue[processing_tick] = {}
  end
  table.insert(global.ruin_queue[processing_tick], ruin)
end

---@param size number
---@param min_distance number
---@param center MapPosition
---@param surface LuaSurface
---@param tick uint
local function try_ruin_spawn(size, min_distance, center, surface, tick)
  min_distance = min_distance * util.ruin_min_distance_multiplier[size]
  if math.abs(center.x) < min_distance and math.abs(center.y) < min_distance then return end -- too close to spawn

  -- random variance so they aren't always chunk aligned
  local variance = -(util.ruin_half_sizes[size] * 0.75) + 12 -- 4 -> 9, 8 -> 6, 16 -> 0. Was previously 4 -> 10, 8 -> 5, 16 -> 0
  if variance > 0 then
    center.x = center.x + math.random(-variance, variance)
    center.y = center.y + math.random(-variance, variance)
  end

  queue_ruin(tick, {size = size, center = center, surface = surface})
end

script.on_event(defines.events.on_chunk_generated,
  function (e)
    if global.spawn_ruins == false then return end -- ruin spawning is disabled

    if util.str_contains_any_from_table(e.surface.name, global.excluded_surfaces) then return end

    local center = util.get_center_of_chunk(e.position)
    local min_distance = settings.global["ruins-min-distance-from-spawn"].value

    local spawn_type = math.random()
    if spawn_type <= global.spawn_table["small"] then
      try_ruin_spawn("small", min_distance, center, e.surface, e.tick)
    elseif spawn_type <= global.spawn_table["medium"] then
      try_ruin_spawn("medium", min_distance, center, e.surface, e.tick)
    elseif spawn_type <= global.spawn_table["large"] then
      try_ruin_spawn("large", min_distance, center, e.surface, e.tick)
    end
  end
)

script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, function(event)
  if event.item ~= "AbandonedRuins-claim" then return end

  local neutral_force = game.forces["neutral"]

  local claimants_force = game.get_player(event.player_index).force
  for _, entity in pairs(event.entities) do
    if entity.valid and entity.force == neutral_force then
      entity.force = claimants_force
      if entity.valid then
        script.raise_event(on_entity_force_changed_event, {entity = entity, force = neutral_force})
      end
    end
  end

  if event.name == defines.events.on_player_alt_selected_area then
    local remnants = event.surface.find_entities_filtered{area = event.area, type = {"corpse", "rail-remnants"}}
    for _, remnant in pairs(remnants) do
      remnant.destroy({raise_destroy = true})
    end
  end
end)

remote.add_interface("AbandonedRuins",
{
  get_on_entity_force_changed_event = function() return on_entity_force_changed_event end,
  -- The event contains:
  ---@class on_entity_force_changed_event_data:EventData
  ---@field entity LuaEntity The entity that had its force changed.
  ---@field force LuaForce The entity that had its force changed.
  -- The current force can be gotten from event.entity.
  -- This is raised after the force is changed.
  -- Mod event subscription explanation can be found lower in this file.

  -- Set whether ruins should be spawned at all
  ---@param spawn_ruins boolean
  set_spawn_ruins = function(spawn_ruins)
    assert(type(spawn_ruins) == "boolean",
      "Remote call parameter to set_spawn_ruins for AbandonedRuins must be a boolean value."
    )
    global.spawn_ruins = spawn_ruins
  end,

  -- Get whether ruins should be spawned at all
  ---@return boolean
  get_spawn_ruins = function() return global.spawn_ruins end,

  -- Any surface whose name contains this string will not have ruins generated on it.
  ---@param name string
  exclude_surface = function(name)
    assert(type(name) == "string",
      "Remote call parameter to exclude_surface for AbandonedRuins must be a string value."
    )
    global.excluded_surfaces[name] = true
  end,

  -- You excluded a surface at some earlier point but you don't want it excluded anymore.
  ---@param name string
  reinclude_surface = function(name)
    assert(type(name) == "string",
      "Remote call parameter to reinclude_surface for AbandonedRuins must be a string value."
    )
    global.excluded_surfaces[name] = nil
  end,

  -- !! ALWAYS call this in on_load and on_init. !!  
  -- !! The ruins sets are not save/loaded. !!  
  -- The ruins should have the sizes given in util.ruin_half_sizes, e.g. ruins in the small_ruins array should be 8x8 tiles.
  -- See also: docs/ruin_sets.md
  ---@param name string
  ---@param small_ruins Ruin[]
  ---@param medium_ruins Ruin[]
  ---@param large_ruins Ruin[]
  add_ruin_set = function(name, small_ruins, medium_ruins, large_ruins)
    assert(small_ruins and next(small_ruins))
    assert(medium_ruins and next(medium_ruins))
    assert(large_ruins and next(large_ruins))

    ruin_sets[name] = {}
    ruin_sets[name].small = small_ruins
    ruin_sets[name].medium = medium_ruins
    ruin_sets[name].large = large_ruins
  end,

  -- !! The ruins sets are not save/loaded. !!
  -- returns {small = {<array of ruins>}, medium = {<array of ruins>}, large = {<array of ruins>}}
  ---@param name string
  ---@return RuinSet
  get_ruin_set = function(name)
    return ruin_sets[name]
  end,

  -- !! The ruins sets are not save/loaded. !!
  -- returns {small = {<array of ruins>}, medium = {<array of ruins>}, large = {<array of ruins>}}
  ---@return RuinSet
  get_current_ruin_set = function()
    return ruin_sets[settings.global["AbandonedRuins-set"].value]
  end
})

--[[ How to: Subscribe to mod events
  Basics: Get the event id from a remote interface. Subscribe to the event in on_init and on_load.

  Example:

  script.on_load(function()
    if remote.interfaces["AbandonedRuins"] then
      script.on_event(remote.call("AbandonedRuins", "get_on_entity_force_changed_event"),
      ---@param event on_entity_force_changed_event_data
      function(event)
        -- An entity changed force, let's handle that
        local entity = event.entity
        local old_force = event.force
        local new_force = entity.force
        -- handle the force change
        game.print("old: " .. old_force.name .. " new: " .. new_force.name)
      end)
    end
  end)

  script.on_init(function()
    if remote.interfaces["AbandonedRuins"] then
      script.on_event(remote.call("AbandonedRuins", "get_on_entity_force_changed_event"),
      ---@param event on_entity_force_changed_event_data
      function(event)
        -- An entity changed force, let's handle that
        local entity = event.entity
        local old_force = event.force
        local new_force = entity.force
        -- handle the force change
        game.print("old: " .. old_force.name .. " new: " .. new_force.name)
      end)
    end
  end)

--]]
