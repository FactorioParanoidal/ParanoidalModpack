local constants = require("lua/constants")
local utils = require("lua/utilities")
local ruinsets = require("lua/ruinsets")
local spawning = require("lua/spawning")
local surfaces = require("lua/surfaces")
local queue = require("lua/queue")

---@type number
local spawn_tick = settings.global[constants.SPAWN_TICK_SECONDS_KEY].value

local on_entity_force_changed_event = script.generate_event_name()

local function update_debug_log()
  debug_log = settings.global[constants.ENABLE_DEBUG_LOG_KEY].value
  debug_on_tick = settings.global[constants.ENABLE_DEBUG_ON_TICK_KEY].value
  utils.output_message(string.format("Ruins: debug log is now: debug=%s,on_tick=%s", debug_log, debug_on_tick))
end

local function init()
  if debug_log then log("[init]: CALLED!") end
  if game then
    log("[init]: Initializing enemy force' cease fire ...")
    utils.set_enemy_force_cease_fire(utils.get_enemy_force(), not settings.global["ruins-enemy-not-cease-fire"].value)
  else
    log("[init]: Cannot intitialize enemy force' cease fire, this is normal during on_load event.")
  end

  -- Initialize spawn changes array (isn't stored in save-game)
  if debug_log then log("[init]: Invoking spawning.init() ...") end
  spawning.init()

  -- Update debug flags
  if debug_log then log("[init]: Invoking update_debug_log() ...") end
  update_debug_log()

  ---@type boolean
  storage.spawn_ruins = storage.spawn_ruins or true

  if debug_log then log("[init]: EXIT!") end
end

script.on_init(init)
script.on_load(init)
script.on_configuration_changed(init)
script.on_event(defines.events.on_player_created, update_debug_log)
script.on_event(defines.events.on_runtime_mod_setting_changed, init)

script.on_event(defines.events.on_force_created, function()
  -- Sets up the diplomacy for all forces, not just the newly created one.
  utils.set_enemy_force_diplomacy(utils.get_enemy_force(), not settings.global["ruins-enemy-not-cease-fire"].value)
end)

script.on_nth_tick(spawn_tick, function(event)
  if debug_on_tick then log(string.format("[on_tick]: event.tick=%d - CALLED!", event.tick)) end

  ---@type RuinQueueItem[] All currently queued ruin-queue items
  local queue_items = queue.get_ruins()

  ---@type string
  local ruinset_name = settings.global[constants.CURRENT_RUIN_SET_KEY].value

  if debug_on_tick then log(string.format("[on_tick]: queue_items[]='%s',ruinset_name='%s'", type(queue_items), ruinset_name)) end

  if table_size(queue_items) == 0 then
    if debug_on_tick then log(string.format("[on_tick]: event.tick=%d has no ruins to spawn - EXIT!", event.tick)) end
    return
  elseif ruinset_name == nil or ruinset_name == "" then
    if debug_on_tick then log("[on_tick]: No current ruin-set configured - EXIT!") end
    return
  end

  local _ruinsets = ruinsets.get(ruinset_name)
  if debug_on_tick then log(string.format("[on_tick]: runinset_name='%s' has %d ruin(s) registered.", ruinset_name, table_size(_ruinsets))) end
  if table_size(_ruinsets) == 0 then
    log(string.format("[on_tick]: ruinset_name='%s' has no ruins registed but is configured as ruin-set. - EXIT!", ruinset_name))
    return
  end

  if debug_on_tick then log(string.format("[on_tick]: Spawning %d random ruin sets ...", table_size(queue_items))) end

  ---@type RuinQueueItem Individual ruin-queue item
  for _, queue_item in pairs(queue_items) do
    if debug_on_tick then log(string.format("[on_tick]: Spawning queue_item.size='%s',queue_item.center='%s',queue_item.surface='%s' ...", queue_item.size, tostring(queue_item.center), tostring(queue_item.surface))) end
    if not utils.ruin_half_sizes[queue_item.size] then
      error(string.format("queue_item.size='%s' is not registered in ruin_half_sizes table. Have you forgotten to invoke `utils.register_ruin_set()`?", queue_item.size))
    end

    if not spawning.allow_spawning_on(queue_item.surface, ruinset_name) then
      if debug_on_tick then log(string.format("[on_tick]: ruinset_name='%s' is not allowed to spawn on surface='%s' - SKIPPED!", ruinset_name, queue_item.surface.name)) end
    elseif spawning.exclusive_ruinset[queue_item.surface.name] == nil or ruinset_name == spawning.exclusive_ruinset[queue_item.surface.name] then
      -- Get ruins
      if debug_on_tick then log(string.format("[on_tick]: Getting ruins for ruinset_name='%s',queue_item.size='%s' ...", ruinset_name, queue_item.size)) end
      local ruins = _ruinsets[queue_item.size]

      if debug_on_tick then log(string.format("[on_tick]: ruins[]='%s'", type(ruins))) end
      if type(ruins) == "table" and table_size(ruins) > 0 then
        -- The ruin-set is either marked as non-exclusive or it surface and ruin-set name are matching
        if debug_on_tick then log(string.format("[on_tick]: Invoking spawning.spawn_random_ruin() with ruins()=%d,ruinset_name='%s',queue_item.size='%s' ...", #ruins, ruinset_name, queue_item.size)) end
        spawning.spawn_random_ruin(ruins, utils.ruin_half_sizes[queue_item.size], queue_item.center, queue_item.surface)
      end
    end
  end

  if debug_on_tick then log("[on_tick]: Resetting queue ...") end
  queue.reset_ruins()

  if debug_on_tick then log("[on_tick]: EXIT!") end
end)

script.on_event(defines.events.on_chunk_generated, function (event)
  if debug_log then log(string.format("[on_chunk_generated]: event.surface.name='%s' - CALLED!", event.surface.name)) end
  if storage.spawn_ruins == false then
    if debug_log then log("[on_chunk_generated]: Spawning ruins is disabled by configuration - EXIT!") end
    return
  elseif event.surface.name == constants.DEBUG_SURFACE_NAME then
    if debug_log then log(string.format("[on_chunk_generated]: Debug surface '%s' must spawn ruins on their own, not through randomness - EXIT!", event.surface.name)) end
    return
  elseif event.surface.generate_with_lab_tiles == true then
    if debug_log then log(string.format("[on_chunk_generated]: event.surface.name='%s' is a lab, no spawning here - EXIT!", event.surface.name)) end
    return
  elseif settings.global[constants.CURRENT_RUIN_SET_KEY].value == constants.NONE then
    if debug_log then log("[on_chunk_generated]: No ruin-set selected by player - EXIT!") end
    return
  elseif utils.str_contains_any_from_table(event.surface.name, surfaces.get_all_excluded()) then
    if debug_log then log(string.format("[on_chunk_generated]: event.surface.name='%s' is excluded - EXIT!", event.surface.name)) end
    return
  end

  local center       = utils.get_center_of_chunk(event.position)
  local min_distance = settings.global["ruins-min-distance-from-spawn"].value
  local spawn_chance = math.random()
  if debug_log then log(string.format("[on_chunk_generated]: center.x=%d,center.y=%d,min_distance=%d,spawn_chance=%.2f", center.x, center.y, min_distance, spawn_chance)) end

  for _, size in pairs(spawning.ruin_sizes) do
    if debug_log then log(string.format("[on_chunk_generated]: spawn_chance=%.2f,size[%s]='%s'", spawn_chance, type(size), size)) end
    if spawn_chance <= spawning.get_spawn_chance(size) then
      if debug_log then log(string.format("[on_chunk_generated]: Trying to spawn ruin of size='%s' at event.surface='%s' ...", size, event.surface)) end
      spawning.try_ruin_spawn(size, min_distance, center, event.surface)

      if debug_log then log("[on_chunk_generated]: Ruin was attempted to spawn - BREAK!") end
      break
    end
  end

  if debug_log then log("[on_chunk_generated]: EXIT!") end
end)

script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, function(event)
  if debug_log then log(string.format("[on_player_selected_area]: event.item='%s',event.entities()=%d - CALLED!", event.item, table_size(event.entities))) end
  if event.item ~= "ruins-claim-tool" then
    if debug_log then log(string.format("[on_player_selected_area]: event.item='%s' is not ruin claim - EXIT!", event.item)) end
    return
  elseif table_size(event.entities) == 0 then
    if debug_log then log("[on_player_selected_area]: No entities selected - EXIT!") end
    return
  end

  ---@type LuaForce
  local neutral_force = game.forces.neutral
  ---@type LuaForce
  local claimants_force = game.get_player(event.player_index).force
  if debug_log then log(string.format("[on_player_selected_area]: neutral_force='%s',claimants_force='%s'", tostring(neutral_force), tostring(claimants_force))) end

  for _, entity in pairs(event.entities) do
    if debug_log then log(string.format("[on_player_selected_area]:entity.valid='%s',entity.force='%s'", entity.valid, tostring(entity.force))) end
    if entity.valid and entity.force == neutral_force then
      if debug_log then log(string.format("[on_player_selected_area]:Setting entity.force='%s' ...", tostring(claimants_force))) end
      entity.force = claimants_force

      if debug_log then log(string.format("[on_player_selected_area]:entity.valid='%s'", tostring(entity.valid))) end
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

  if debug_log then log("[on_player_selected_area]: EXIT!") end
end)

script.on_event(defines.events.on_pre_surface_deleted, function(event)
  if debug_log then log(string.format("[on_pre_surface_deleted]: event.surface_index=%d - CALLED!", event.surface_index)) end

  local surface = game.surfaces[event.surface_index] or nil
  if debug_log then log(string.format("[on_pre_surface_deleted]: surface[]='%s'", type(surface))) end

  if surface ~= nil and surfaces.is_excluded(surface.name) then
    if debug_log then log(string.format("[on_pre_surface_deleted]: Invoking surfaces.reinclude(%s) ...", surface.name)) end
    surfaces.reinclude(surface.name)
  end

  if debug_log then log("[on_pre_surface_deleted]: EXIT!") end
end)
