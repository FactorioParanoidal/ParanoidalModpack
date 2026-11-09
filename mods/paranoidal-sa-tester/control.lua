-- Tester panel of the Space Age branch: /sa-test, Ctrl+Shift+T or the shortcut button.
local common = require("scripts.common")
local catalog = require("scripts.catalog")
local actions = require("scripts.actions")
local gui = require("scripts.gui")

local function set_shortcut(player)
  player.set_shortcut_available(common.SHORTCUT, common.enabled())
  player.set_shortcut_toggled(common.SHORTCUT, gui.is_open(player))
end

local function setup_all()
  common.init_storage()
  for _, player in pairs(game.players) do
    common.pdata(player)
    set_shortcut(player)
  end
end

script.on_init(setup_all)

script.on_configuration_changed(function()
  catalog.reset()
  common.init_storage()
  -- The window layout may differ after an update: close open windows, they reopen with the new layout.
  for _, player in pairs(game.players) do
    if gui.is_open(player) then gui.close(player) end
    common.pdata(player).refs = {}
    set_shortcut(player)
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  local player = game.get_player(e.player_index)
  if player then
    common.pdata(player)
    set_shortcut(player)
  end
end)

script.on_event(defines.events.on_player_removed, function(e)
  if storage.players then storage.players[e.player_index] = nil end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting ~= common.SETTING then return end
  for _, player in pairs(game.players) do
    if not common.enabled() and gui.is_open(player) then gui.close(player) end
    set_shortcut(player)
  end
end)

local function toggle(player_index, tab)
  local player = game.get_player(player_index)
  if not player then return end
  if not common.enabled() then
    common.say(player, {"pst.disabled"})
    return
  end
  gui.toggle(player, tab)
end

script.on_event(common.INPUT, function(e) toggle(e.player_index) end)

script.on_event(defines.events.on_lua_shortcut, function(e)
  if e.prototype_name == common.SHORTCUT then toggle(e.player_index) end
end)

commands.add_command("sa-test", {"pst.command-help"}, function(cmd)
  if not cmd.player_index then return end
  local tab = cmd.parameter and cmd.parameter:match("^%s*(%S+)") or nil
  local valid
  for _, key in ipairs(gui.TABS) do
    if key == tab then valid = key end
  end
  local player = game.get_player(cmd.player_index)
  if valid and player and gui.is_open(player) then
    gui.open(player, valid)
  else
    toggle(cmd.player_index, valid)
  end
end)

script.on_event(defines.events.on_gui_click, gui.on_click)
script.on_event(defines.events.on_gui_checked_state_changed, gui.on_checked)
script.on_event(defines.events.on_gui_elem_changed, gui.on_elem_changed)
script.on_event(defines.events.on_gui_selection_state_changed, gui.on_selection)
script.on_event(defines.events.on_gui_text_changed, gui.on_text)
script.on_event(defines.events.on_gui_selected_tab_changed, gui.on_tab)
script.on_event(defines.events.on_gui_closed, gui.on_closed)
script.on_event(defines.events.on_gui_location_changed, gui.on_location)

script.on_event(defines.events.on_selected_entity_changed, function(e)
  local player = game.get_player(e.player_index)
  if player and gui.is_open(player) then gui.on_selected_entity(player) end
end)

local function refresh_player(e)
  local player = game.get_player(e.player_index)
  if player and gui.is_open(player) then gui.refresh(player) end
end
script.on_event(defines.events.on_player_changed_surface, refresh_player)
script.on_event(defines.events.on_player_controller_changed, refresh_player)

-- A new body (respawn, editor exit) gets the character modes that are on.
local function reapply(e)
  local player = game.get_player(e.player_index)
  if player and player.character then actions.reapply_modes(player) end
end
script.on_event(defines.events.on_player_respawned, reapply)
script.on_event(defines.events.on_player_toggled_map_editor, reapply)

-- Keep open windows in step with research done by anyone (labs, triggers, other players): mark, update once a second
-- ("research everything" finishes a thousand technologies in one tick).
script.on_event(defines.events.on_research_finished, function()
  storage.refresh_pending = true
end)

script.on_nth_tick(60, function()
  if storage.refresh_pending then
    storage.refresh_pending = nil
    gui.refresh_all()
  end
  gui.tick()
end)

-- Remote interface: the same actions as the window, for test scenarios and other tools.
remote.add_interface("paranoidal-sa-tester", {
  open = function(player_index, tab)
    local player = game.get_player(player_index)
    if player then gui.open(player, tab) end
    return player ~= nil and gui.is_open(player)
  end,
  close = function(player_index)
    local player = game.get_player(player_index)
    if player then gui.close(player) end
  end,
  is_open = function(player_index)
    local player = game.get_player(player_index)
    return player ~= nil and gui.is_open(player)
  end,
  -- Run an action by name; returns ok and the message (LocalisedString).
  run = function(player_index, name, args)
    local player = game.get_player(player_index)
    if not player then return false, "no player" end
    local ok, message = actions.run(player, name, args)
    if gui.is_open(player) then gui.refresh(player) end
    return ok, message
  end,
  -- Act as a click on an element with these tags (modifiers: right, shift, confirmed).
  click = function(player_index, tags, mods)
    local player = game.get_player(player_index)
    if not player then return false, "no player" end
    return gui.act(player, tags, mods)
  end,
  -- Player choices the window keeps (tech, recipe, item, fluid, tile, quality, count, platform).
  set_choice = function(player_index, key, value)
    local player = game.get_player(player_index)
    if not player then return end
    common.pdata(player)[key] = value
    if gui.is_open(player) then gui.refresh(player) end
  end,
  get_choice = function(player_index, key)
    local player = game.get_player(player_index)
    return player and common.pdata(player)[key]
  end,
  -- Act as the player using a window control (tests): see gui.simulate.
  ui = function(player_index, name, value, nth, mods)
    local player = game.get_player(player_index)
    return player ~= nil and gui.simulate(player, name, value, nth, mods)
  end,
  select_tab = function(player_index, index)
    local player = game.get_player(player_index)
    local refs = player and common.pdata(player).refs
    if refs and refs.tabs and refs.tabs.valid then
      refs.tabs.selected_tab_index = index
      common.pdata(player).tab = index
      gui.refresh(player)
    end
  end,
  elements = function(player_index)
    local player = game.get_player(player_index)
    return player and gui.action_elements(player) or {}
  end,
  actions = function()
    local names = {}
    for name in pairs(actions.by_name) do names[#names + 1] = name end
    table.sort(names)
    return names
  end,
  catalog = function()
    local out = {milestones = catalog.milestones(), discoveries = {}, locations = {}}
    for _, entry in ipairs(catalog.discoveries()) do
      local kit = catalog.kit(entry.tech)
      out.discoveries[#out.discoveries + 1] = {tech = entry.tech, location = entry.location, techs = kit.techs,
        buildings = #kit.buildings, materials = #kit.materials, packs = #kit.packs, fluids = #kit.fluids,
        pack_names = kit.packs, fluid_names = kit.fluids}
    end
    for _, loc in ipairs(catalog.locations(false)) do out.locations[#out.locations + 1] = loc.name end
    return out
  end,
})
