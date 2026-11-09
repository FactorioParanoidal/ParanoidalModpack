-- Test-only remote interface used by the FUnit scenario.
--
-- This file is required only when the funit mod is active. It is inert in
-- normal play and exposes a few internal helpers that cannot be reached through
-- regular game events in a headless test.
local Public = {}

local function stage()
  return Muluna.funit
end

remote.add_interface("muluna_funit", {
  get_storage = function()
    return storage
  end,

  get_constants = function()
    return prototypes.mod_data["muluna-constants"].data
  end,

  get_telescope_data = function(unit_number)
    return storage.telescopes and storage.telescopes[unit_number]
  end,

  update_telescope = function(unit_number)
    local telescope = storage.telescopes and storage.telescopes[unit_number]
    if telescope then
      Muluna.update_telescope_daytime(telescope)
    end
  end,

  get_telescope_signals = function(unit_number)
    local telescope = storage.telescopes and storage.telescopes[unit_number]
    if not telescope then return nil end
    local combinator = telescope["constant-combinator"]
    if not combinator or not combinator.valid then return nil end
    return stage().get_telescope_combinator_signals(combinator.surface, combinator.force, telescope)
  end,

  get_telescope_combinator_stats = function()
    return stage().get_telescope_combinator_stats()
  end,

  set_telescope_asteroid_signals = function(unit_number, state)
    return stage().set_telescope_asteroid_signals(unit_number, state)
  end,

  get_telescope_probability = function(pollution, quality_level)
    return Muluna.get_telescope_probability(pollution, { level = quality_level or 0 })
  end,

  get_telescope_min_pollution = function(quality_level)
    return Muluna.get_telescope_min_pollution({ level = quality_level or 0 })
  end,

  get_telescope_max_pollution = function(quality_level)
    return Muluna.get_telescope_max_pollution({ level = quality_level or 0 })
  end,

  get_state_integer = function(state)
    return stage().get_state_integer(state)
  end,

  get_time_to_next_asteroid_check = function(unit_number)
    local telescope = storage.telescopes and storage.telescopes[unit_number]
    if not telescope then return nil end
    return stage().get_time_to_next_asteroid_check(telescope)
  end,

  short_update_roboport = function(unit_number)
    local entry = storage.burner_roboports and storage.burner_roboports[unit_number]
    local refueler = entry and entry.refueler
    if refueler and refueler.valid then
      stage().short_update_roboport(refueler)
    end
  end,

  set_cheat_mode = function(force_name)
    return stage().set_cheat_mode(game.forces[force_name or "player"])
  end,

  get_burner_roboport_data = function(unit_number)
    return storage.burner_roboports and storage.burner_roboports[unit_number]
  end,

  get_nav_scan_area = function(unit_number)
    local beacon = storage.nav_beacons and storage.nav_beacons[unit_number]
    if not beacon or not beacon.valid then return nil end
    return stage().get_nav_scan_area(beacon)
  end,

  set_nav_beacon_enabled = function(unit_number, enabled)
    local settings = storage.nav_beacons_other and storage.nav_beacons_other[unit_number]
    local beacon = storage.nav_beacons and storage.nav_beacons[unit_number]
    if not settings or not beacon or not beacon.valid then return false end
    settings.gui = settings.gui or {}
    settings.gui.enabled = enabled
    Muluna.update_nav_beacon_status(beacon)
    return true
  end,

  get_nav_energy_cost = function(unit_number)
    local beacon = storage.nav_beacons and storage.nav_beacons[unit_number]
    if not beacon or not beacon.valid then return nil end
    return stage().get_nav_energy_cost(beacon)
  end,

  get_nav_energy_cost_stats = function()
    return stage().get_nav_energy_cost_stats()
  end,

  reset_nav_energy_cost_cache = function()
    stage().reset_nav_energy_cost_cache()
  end,

  -- The update tick only reaches this branch through a player in remote view,
  -- which the headless FUnit scenario cannot create. Run the same per-player
  -- handler against a stub that records alert calls.
  -- Controller changes cannot be raised for a real player in the headless
  -- scenario. Drive the production tracking function with a stub that is only
  -- given a remove_alert method when the change actually removes the alert, so
  -- a function is never written into storage.
  probe_nav_beacon_controller_change = function(old_type, new_type)
    local removed = 0
    local stub = { controller_type = new_type }
    if new_type ~= defines.controllers.remote then
      function stub.remove_alert(_)
        removed = removed + 1
      end
    end
    local ok, err = pcall(stage().apply_controller_change, 9999, stub, old_type)
    return {
      ok = ok,
      error = err,
      removed = removed,
      tracked = storage.nav_beacon_players[9999] ~= nil,
    }
  end,

  -- A save migration can remove players before on_configuration_changed has
  -- initialized storage.nav_beacon_players. Clear the real table, invoke the
  -- registered on_player_removed handler, and restore the table so the test
  -- covers the exact event path without leaving storage behind.
  probe_nav_beacon_player_removal = function(player_index)
    local saved = storage.nav_beacon_players
    storage.nav_beacon_players = nil
    local handler = script.get_event_handler(defines.events.on_player_removed)
    local ok, err = pcall(handler, {
      name = defines.events.on_player_removed,
      tick = game.tick,
      player_index = player_index,
    })
    storage.nav_beacon_players = saved
    return { ok = ok, error = err }
  end,

  probe_nav_beacon_player = function(surface_name, options)
    local surface
    for _, candidate in pairs(game.surfaces) do
      if candidate.name == surface_name then
        surface = candidate
        break
      end
    end
    if not surface then
      return { ok = false, error = "no surface named " .. tostring(surface_name) }
    end

    options = options or {}
    local calls = { added = 0, removed = 0 }
    local player = {
      surface = surface,
      force = game.forces[options.force or "player"],
      position = { x = 0, y = 0 },
      controller_type = defines.controllers.remote,
      mod_settings = { ["nav-beacon-display-alert"] = { value = options.display_alert ~= false } },
    }
    function player.add_custom_alert(entity, icon, message)
      calls.added = calls.added + 1
      calls.alert_entity = entity.unit_number
      calls.alert_message = message and message[1]
    end
    function player.remove_alert(_)
      calls.removed = calls.removed + 1
    end

    local ok, err = pcall(stage().update_player_nav_beacon, player)
    return {
      ok = ok,
      error = err,
      added = calls.added,
      removed = calls.removed,
      alert_entity = calls.alert_entity,
      alert_message = calls.alert_message,
    }
  end,

  -- The update tick only reaches this branch through a player in remote view,
  -- which the headless FUnit scenario cannot create. Invalidate the supplied
  -- probe entity, store it as the beacon, and call the same handler to exercise
  -- the stale-storage path.
  handle_invalid_nav_surface = function(unit_number, probe)
    if probe and probe.valid then
      probe.destroy({ raise_destroy = false })
    end
    if probe then
      storage.nav_beacons[unit_number] = probe
    end
    return stage().handle_invalid_nav_surface(unit_number)
  end,

  -- Player build events cannot be raised from script, so the FUnit suite calls
  -- the production build handler directly to exercise blueprint-tag handling.
  build_nav_beacon = function(entity, tags)
    stage().build_nav_beacon(entity, tags)
  end,

  get_heat_assembling_machine_data = function(unit_number)
    return storage.heat_assembling_machines and storage.heat_assembling_machines[unit_number]
  end,

  get_compound_blueprint_tags = function(unit_number)
    return stage().capture_compound_blueprint_tags(unit_number)
  end,

  get_compound_retry_state = function()
    return stage().get_compound_retry_state()
  end,

  -- The headless scenario cannot save and reload a map, so a test can apply the
  -- same state sync that on_load performs after a fresh control-stage load.
  apply_compound_load_state = function()
    return stage().apply_compound_load_state()
  end,

  -- Overturn one entry of a child index, or remove it when parent is nil, so a
  -- test can reproduce an older save (no index) or a stale index.
  set_compound_child_index = function(table_name, child_unit_number, parent_unit_number)
    local index = storage[table_name]
    if not index then
      if parent_unit_number == nil then return false end
      index = {}
      storage[table_name] = index
    end
    index[child_unit_number] = parent_unit_number
    return true
  end,

  -- Queue a wire whose other endpoint will never exist, so the retry timer
  -- starts and then drains a tick after it runs.
  queue_test_pending_wire = function(parent_unit_number)
    return stage().queue_test_pending_wire(parent_unit_number)
  end,

  transform_compound_offset = function(offset, direction, flip_horizontal, flip_vertical)
    return stage().transform_compound_offset(offset, direction, flip_horizontal, flip_vertical)
  end,

  get_walking_controller_branch = function(input_method)
    return stage().is_game_controller_input(input_method)
  end,

  -- The per-tick particle step needs a player, which the headless scenario has
  -- none of. Expose the direction averaging so its shape (and the fact that it
  -- copies the shared direction vector instead of mutating it) stays tested.
  get_walking_step_movement = function(direction_name, previous)
    return stage().get_walking_step_movement(direction_name, previous)
  end,

  -- The headless scenario has no player, so on_gui_opened/on_gui_click cannot
  -- be raised with a real GUI. Build the frame against a stub root that records
  -- each element definition and enforces the engine's checkbox state type.
  build_entity_gui = function(entity, selected)
    local recorded = {}
    local function make_element()
      local element = { style = {} }
      function element.add(definition)
        if definition.state ~= nil and type(definition.state) ~= "boolean" then
          error("GUI checkbox state must be a boolean, got " .. type(definition.state))
        end
        recorded[#recorded + 1] = {
          type = definition.type,
          name = definition.name,
          state = definition.state,
        }
        return make_element()
      end
      return element
    end
    local root = make_element()
    local ok, err = pcall(stage().build_entity_gui, { gui = { relative = root } }, entity, selected)
    return { ok = ok, error = err, elements = recorded }
  end,

  handle_gui_click = function(element_name, opened)
    local player = { opened = opened }
    local ok, err = pcall(stage().handle_gui_click, player, { name = element_name })
    return { ok = ok, error = err, opened = player.opened }
  end,
})

return Public
