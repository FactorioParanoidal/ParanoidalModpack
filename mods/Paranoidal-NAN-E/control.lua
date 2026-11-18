-- НЯН-Я (NAN-E). Handlers are registered here, with filters where the game has them.
local shared = require("shared")
local state = require("script.state")
local speech = require("script.speech")
local chatter = require("script.chatter")
local memory = require("script.memory")
local abilities = require("script.abilities")
local errands = require("script.errands")
local nanny = require("script.nanny")
local gui = require("script.gui")

-- The modules talk to each other through these (they load in an order that cannot require back).
memory.spawn_husk = nanny.spawn_husk
speech.on_said = gui.on_said
memory.on_changed = gui.on_memory_changed
nanny.on_first_meeting = function(player)
  gui.open(player, "nanny")
end
gui.on_action = function(player, action)
  local data = nanny.get(player.index)
  if action == "call" then
    nanny.call(player)
  elseif action == "quiet" then
    nanny.toggle_quiet(player)
  elseif action == "talk" and data and data.status == "active" then
    chatter.talk(data, player)
  end
end

-- Events of other mods: paranoidal-rain's lightning strikes, paranoidal-ruins' new ruins. Their ids come through
-- remote calls, so they are registered in on_init and on_load alike.
local register_foreign_events = function()
  local rain = remote.interfaces["paranoidal-rain"]
  if rain and rain.get_events then
    local events = remote.call("paranoidal-rain", "get_events")
    if events and events.on_lightning_strike then
      script.on_event(events.on_lightning_strike, abilities.on_strike)
    end
  end
  local ruins = remote.interfaces["AbandonedRuins"]
  if ruins and ruins.get_on_ruin_spawned_event then
    local id = remote.call("AbandonedRuins", "get_on_ruin_spawned_event")
    if id then
      script.on_event(id, memory.on_ruin_spawned)
    end
  end
end

script.on_init(function()
  storage.nan_e = state.new_storage()
  state.s = storage.nan_e
  register_foreign_events()
  for _, player in pairs(game.players) do
    gui.update_button(player)
  end
end)

script.on_load(function()
  state.s = storage.nan_e
  register_foreign_events()
end)

script.on_configuration_changed(function()
  storage.nan_e = storage.nan_e or state.new_storage()
  state.s = storage.nan_e
  state.fill(state.s)
  if not prototypes.entity["bnl-old-expedition"] and state.s.axiom6.state == "searching" then
    state.s.axiom6.state = "none"
  end
  for _, player in pairs(game.players) do
    gui.close(player)
    gui.update_button(player)
  end
end)

-- A new nanny placed, and start-bnl's distress beacon (if the game has it).
local built_filters = {{filter = "name", name = shared.husk}}
local beacon = prototypes.entity["bnl-distress-beacon"] and "bnl-distress-beacon"
if beacon then
  built_filters[2] = {filter = "name", name = beacon, mode = "or"}
end
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  if entity.name == shared.husk then
    nanny.on_built(event)
  elseif entity.name == beacon then
    memory.on_beacon_built(event)
  end
end, built_filters)
for _, id in pairs{defines.events.on_robot_built_entity, defines.events.script_raised_built, defines.events.script_raised_revive} do
  script.on_event(id, nanny.on_built, {{filter = "name", name = shared.husk}})
end

script.on_event(defines.events.on_entity_died, nanny.on_unit_died, {{filter = "name", name = shared.unit}})
script.on_event(defines.events.on_entity_damaged, abilities.on_damaged,
  {{filter = "type", type = "character"}, {filter = "name", name = shared.unit, mode = "or"}})
script.on_event(defines.events.on_player_repaired_entity, nanny.on_player_repaired)
script.on_event(defines.events.on_player_mined_entity, memory.on_player_mined,
  {{filter = "type", type = "simple-entity"}, {filter = "type", type = "simple-entity-with-owner", mode = "or"},
   {filter = "type", type = "container", mode = "or"}})
script.on_event(defines.events.on_gui_opened, memory.on_gui_opened)
script.on_event(defines.events.on_chunk_generated, memory.on_chunk_generated)

script.on_event(defines.events.on_gui_click, gui.on_click)
script.on_event(defines.events.on_gui_closed, gui.on_closed)
script.on_event(shared.input, function(event)
  local player = game.get_player(event.player_index)
  if player then
    gui.toggle(player)
  end
end)
script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= shared.shortcut then return end
  local player = game.get_player(event.player_index)
  if player then
    gui.toggle(player)
  end
end)

local refresh_button = function(event)
  local player = game.get_player(event.player_index)
  if player then
    gui.update_button(player)
  end
end
script.on_event(defines.events.on_player_created, refresh_button)
script.on_event(defines.events.on_player_joined_game, refresh_button)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == shared.settings.button and event.player_index then
    refresh_button(event)
  end
end)
script.on_event(defines.events.on_player_removed, function(event)
  nanny.remove(event.player_index)
  state.s.gui[event.player_index] = nil
end)

-- The engineer died: a word when he is back.
script.on_event(defines.events.on_player_died, function(event)
  local data = nanny.get(event.player_index)
  if data then
    data.died = true
  end
end)
script.on_event(defines.events.on_player_respawned, function(event)
  local data = nanny.get(event.player_index)
  local player = game.get_player(event.player_index)
  if data and data.died and player and data.status == "active" then
    data.died = nil
    chatter.occasion(data, player, "died", {"nan-e.died-" .. math.random(2)}, "stern", 10 * 3600)
  end
end)

-- A research done: now and then a gold star.
script.on_event(defines.events.on_research_finished, function(event)
  local research = event.research
  if event.by_script or math.random() > 0.15 then return end
  for _, player in pairs(research.force.connected_players) do
    local data = nanny.get(player.index)
    if data and data.status == "active" then
      chatter.occasion(data, player, "research",
        {"nan-e.research-" .. math.random(2), "[technology=" .. research.name .. "]"}, "happy", 10 * 3600)
    end
  end
end)

script.on_nth_tick(30, nanny.update)
script.on_nth_tick(60, function(event)
  nanny.poll_husks(event)
  memory.poll(event)
  memory.poll_tags()
  memory.poll_players()
  gui.on_second()
end)
script.on_nth_tick(300, memory.poll_axiom6)

-- For other mods and the autotest.
remote.add_interface("nan-e",
{
  get_memory_stage_event = memory.get_memory_stage_event,
  -- {status, task, has_unit, has_husk, journal, fragments, solved, decrypting}
  status = function(player_index)
    local player = game.get_player(player_index)
    local data = nanny.get(player_index)
    if not player then return nil end
    local f = memory.force_data(player.force)
    return
    {
      status = data and data.status or "none",
      task = data and data.task and data.task.kind or nil,
      unit = data and data.unit and data.unit.valid and data.unit or nil,
      husk = data and data.husk and data.husk.valid and data.husk or nil,
      journal = data and #data.journal or 0,
      last_line = data and data.journal[#data.journal] and data.journal[#data.journal][2] or nil,
      fragments = f.count,
      solved = memory.solved_count(player.force),
      decrypting = f.decrypting ~= nil,
      scan = data and data.scan or nil,
      lamp = data and data.lamp and data.lamp.valid or false,
      rod = data and data.rod and data.rod.valid and data.rod or nil,
      trail = data and #data.trail.objects or 0,
      camp = f.camp,
      epilogue = f.epilogue
    }
  end,
  axiom6 = function()
    local a6 = state.s.axiom6
    return {state = a6.state, position = a6.position, husk = a6.husk and a6.husk.valid and a6.husk or nil}
  end,
  ruins = function()
    return {count = #state.s.ruins.list, seeded = state.s.ruins.seeded}
  end,
  open = function(player_index, page)
    local player = game.get_player(player_index)
    if player then
      gui.open(player, page)
    end
  end,
  decrypt = function(player_index)
    local player = game.get_player(player_index)
    return player and memory.start_decrypt(player) or false
  end,
  answer = function(player_index, q, option)
    local player = game.get_player(player_index)
    return player and memory.answer(player, q, option) or nil
  end,
  errand = function(player_index, kind)
    local player = game.get_player(player_index)
    local data = nanny.get(player_index)
    return player and data and data.status == "active" and errands.force_start(data, player, kind) or false
  end,
  talk = function(player_index)
    local player = game.get_player(player_index)
    local data = nanny.get(player_index)
    return player and data and data.status == "active" and chatter.talk(data, player) or false
  end
})
