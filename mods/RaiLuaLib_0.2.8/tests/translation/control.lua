-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRANSLATION LIBRARY CONTROL TESTS

local event = require("__RaiLuaLib__.lualib.event")
local translation = require("__RaiLuaLib__.lualib.translation")

local mod_gui = require("mod-gui")

-- build LOTS of data to really stress the translation engine
local function build_data()
  local translation_data = {}
  local function generic_setup(key)
    local data = {}
    local i = 0
    for name,prototype in pairs(game[key.."_prototypes"]) do
      i = i + 1
      data[i] = {localised=prototype.localised_name, internal=name}
    end
    return data
  end
  translation_data.achievement = generic_setup("achievement")
  translation_data.entity = generic_setup("entity")
  translation_data.equipment = generic_setup("equipment")
  translation_data.fluid = generic_setup("fluid")
  translation_data.item = generic_setup("item")
  translation_data.recipe = generic_setup("recipe")
  translation_data.technology = generic_setup("technology")
  translation_data.tile = generic_setup("tile")
  global.__lualib.translation.build_data = translation_data
end

local function translate_whole(player)
  for name,t in pairs(global.__lualib.translation.build_data) do
    translation.start(player, name, t)
  end
end

local function translate_for_all_players()
  for _,player in ipairs(game.connected_players) do
    translate_whole(player)
  end
end

event.on_init(function()
  global.players = {}
  for i,p in pairs(game.players) do
    global.players[i] = {dictionary={}}
  end
  build_data()
  translate_for_all_players()
  event.register(translation.retranslate_all_event, translate_for_all_players)
end)

event.on_load(function()
  event.register(translation.retranslate_all_event, translate_for_all_players)
end)

event.on_configuration_changed(function()
  build_data()
  translate_for_all_players()
end)

event.on_player_created(function(e)
  global.players[e.player_index] = {dictionary={}}

  -- create test buttons
  local player = game.get_player(e.player_index)
  local button_flow = mod_gui.get_button_flow(player)
  button_flow.add{type="button", name="translation_cancel_recipe", style=mod_gui.button_style, caption="Cancel Recipe"}
  button_flow.add{type="button", name="translation_cancel_all", style=mod_gui.button_style, caption="Cancel All"}
  button_flow.add{type="button", name="translation_start_recipe", style=mod_gui.button_style, caption="Start Recipe"}
  button_flow.add{type="button", name="translation_start_all", style=mod_gui.button_style, caption="Start All"}
end)

event.on_player_joined_game(function(e)
  translate_whole(game.get_player(e.player_index))
end)

event.register(translation.finish_event, function(e)
  game.print("[color=255,200,150]finished translation of dictionary: "..e.dictionary_name.."[/color]")
  global.players[e.player_index].dictionary[e.dictionary_name] = {
    lookup = e.lookup,
    searchable = e.searchable,
    translations = e.translations
  }
end)

-- test button handlers

event.on_gui_click(function(e)
  translation.cancel(game.get_player(e.player_index), "recipe")
end, "translation_cancel_recipe")

event.on_gui_click(function(e)
  translation.cancel_all_for_player(game.get_player(e.player_index))
end, "translation_cancel_all")

event.on_gui_click(function(e)
  translation.start(game.get_player(e.player_index), "recipe", global.__lualib.translation.build_data.recipe)
end, "translation_start_recipe")

event.on_gui_click(function(e)
  translate_whole(game.get_player(e.player_index))
end, "translation_start_all")