local util = require("utilities")
local spawning = require("spawning")
local ruin_sets = {}
ruin_sets.base = require("ruins/base_ruin_set")

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
  global.excluded_surfaces = global.excluded_surfaces or {}
  global.excluded_surfaces["beltlayer"] = true
  global.excluded_surfaces["pipelayer"] = true
  global.excluded_surfaces["Factory floor"] = true -- factorissimo
  global.excluded_surfaces["ControlRoom"] = true -- mobile factory
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
    local ruins = global.ruin_queue[event.tick]
    if not ruins then return end
    for _, ruin in pairs(ruins) do
      spawning.spawn_random_ruin(ruin_sets[settings.global["AbandonedRuins-set"].value][ruin.size], util.ruin_half_sizes[ruin.size], ruin.center, ruin.surface)
    end
    global.ruin_queue[event.tick] = nil
  end
)

local function queue_ruin(tick, ruin)
  local processing_tick = tick + 1
  if not global.ruin_queue[processing_tick] then
    global.ruin_queue[processing_tick] = {}
  end
  table.insert(global.ruin_queue[processing_tick], ruin)
end

local function check_ruin_spawn(size, min_distance, center, surface, tick)
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
      check_ruin_spawn("small", min_distance, center, e.surface, e.tick)
    elseif spawn_type <= global.spawn_table["medium"] then
      check_ruin_spawn("medium", min_distance, center, e.surface, e.tick)
    elseif spawn_type <= global.spawn_table["large"] then
      check_ruin_spawn("large", min_distance, center, e.surface, e.tick)
    end
  end
)

script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, function(event)
  if event.item ~= "AbandonedRuins-claim" then return end

  local claimants_force = game.get_player(event.player_index).force
  for _, entity in pairs(event.entities) do
    if entity.force.name == "neutral" then
      entity.force = claimants_force
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
  -- Set whether ruins should be spawned at all
  set_spawn_ruins = function(spawn_ruins)
    if type(spawn_ruins) ~= "boolean" then
      error("Remote call parameter to set_spawn_ruins for AbandonedRuins must be a boolean value.")
    end
    global.spawn_ruins = spawn_ruins
  end,

  -- Get whether ruins should be spawned at all
  get_spawn_ruins = function() return global.spawn_ruins end,

  -- Any surface whose name contains this string will not have ruins generated on it.
  exclude_surface = function(name)
    if type(name) ~= "string" then
      error("Remote call parameter to exclude_surface for AbandonedRuins must be a string value.")
    end
    global.excluded_surfaces[name] = true
  end,

  -- You excluded a surface at some earlier point but you don't want it excluded anymore.
  reinclude_surface = function(name)
    if type(name) ~= "string" then
      error("Remote call parameter to reinclude_surface for AbandonedRuins must be a string value.")
    end
    global.excluded_surfaces[name] = nil
  end,

  -- !! ALWAYS call this in on_load and on_init. !!
  -- !! The ruins sets are not save/loaded. !!
  -- small_ruins, medium_ruins and large_ruins are each arrays of ruins.
  -- The ruins should have the sizes given in util.ruin_half_sizes, e.g. ruins in the small_ruins array should be 8x8 tiles.
  -- See also: docs/ruin_sets.md
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
  get_ruin_set = function(name)
    return ruin_sets[name]
  end,

  -- !! The ruins sets are not save/loaded. !!
  -- returns {small = {<array of ruins>}, medium = {<array of ruins>}, large = {<array of ruins>}}
  get_current_ruin_set = function()
    return ruin_sets[settings.global["AbandonedRuins-set"].value]
  end
})
