local UI=require("ui")
local Goal=require("goal")
script.on_init(function() storage.native_players={}; storage.native_graphs={}; storage.ptt_goals={} end)
script.on_configuration_changed(function()
  UI.invalidate()
  storage.ptt_goals = storage.ptt_goals or {}
  -- Goals survive mod updates; a removed goal technology is dropped with a message.
  Goal.validate()
end)
script.on_event("ptt-toggle",function(e)
  local p=game.get_player(e.player_index)
  if UI.root(p) then UI.close(p) else UI.open(p) end
end)
script.on_event(defines.events.on_gui_click,UI.click)
script.on_event(defines.events.on_gui_text_changed,UI.changed)
script.on_event(defines.events.on_gui_checked_state_changed,UI.changed)
script.on_event(defines.events.on_string_translated,UI.translated)
script.on_event(defines.events.on_gui_closed,function(e)
  if e.element and e.element.valid and e.element.name=="ptt_native" then UI.close(game.get_player(e.player_index)) end
end)
script.on_event(defines.events.on_gui_opened,function(e)
  if e.gui_type~=defines.gui_type.research then return end
  local p=game.get_player(e.player_index)
  if p.mod_settings["ptt-replace-native"].value then p.opened=nil; UI.open(p) end
end)
script.on_event({defines.events.on_player_display_resolution_changed,defines.events.on_player_display_scale_changed},function(e)
  local p=game.get_player(e.player_index)
  if UI.root(p) then UI.close(p); UI.open(p) end
end)
script.on_event(defines.events.on_player_changed_force,function(e)
  local p=game.get_player(e.player_index)
  local was=UI.root(p)~=nil
  UI.close(p)
  storage.native_players[p.index]=nil
  if was then UI.open(p) end
end)
local function refresh(force)
  -- Defer GUI rebuild: add_research can raise these events within a click handler.
  for _,p in pairs(force.connected_players) do
    if UI.root(p) then UI.state(p).refresh_due=true end
  end
end
script.on_event(defines.events.on_research_finished,function(e)
  Goal.on_finished(e)
  refresh(e.research.force)
end)
script.on_event(defines.events.on_research_cancelled,function(e)
  Goal.on_cancelled(e)
  refresh(e.force)
end)
script.on_event(defines.events.on_research_reversed,function(e)
  Goal.fill(e.research.force)
  refresh(e.research.force)
end)
script.on_event(defines.events.on_research_started,function(e) refresh(e.research.force) end)
script.on_event({defines.events.on_research_queued,defines.events.on_research_moved},function(e) refresh(e.force) end)
script.on_nth_tick(15,function()
  UI.tick()
  for _,p in pairs(game.connected_players) do
    local s=storage.native_players and storage.native_players[p.index]
    if s and s.refresh_due then
      s.refresh_due=nil; UI.refresh(p); UI.panel(p)
    end
  end
end)
script.on_event(defines.events.on_player_left_game,function(e) UI.close(game.get_player(e.player_index)) end)
