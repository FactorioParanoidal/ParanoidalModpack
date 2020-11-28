local Event = require("__stdlib__/stdlib/event/event")
local Gui = require("__stdlib__/stdlib/event/gui")
local UPConvert = require("converter")
local UPEntityUpgrade = require("upgrade-planner/entity-upgrade")
local UPGui = require("gui")
local UPUtility = require("utility")

local upgrade_planner_gui_events = {}

local function on_gui_closed(event)
  local player = game.players[event.player_index]
  local element = event.element
  if not element then return end
  if element.name == "upgrade_planner_config_frame" then
    UPGui.open_frame(player)
    return
  end
  if element.name == "upgrade_planner_export_frame" then
    element.destroy()
    UPGui.open_frame(player)
    return
  end
end

local function gui_save_changes(player)
  -- Saving changes consists in:
  --   1. copying config-tmp to config
  --   2. removing config-tmp

  if global["config-tmp"][player.name] then
    global.current_config[player.index] = {}
    for i = 1, #global["config-tmp"][player.name] do
      global.current_config[player.index][i] =
          {
            from = global["config-tmp"][player.name][i].from,
            to = global["config-tmp"][player.name][i].to,
          }
    end
  end
  if not global.storage then global.storage = {} end
  if not global.storage[player.index] then global.storage[player.index] = {} end
  local gui = player.gui.left.mod_gui_frame_flow.upgrade_planner_config_frame
  if not gui then return end
  local drop_down = gui.upgrade_planner_storage_flow.children[1]
  local name = drop_down.get_item(global.storage_index[player.index])
  global.storage[player.index][name] = global.current_config[player.index]
end

local function gui_set_rule(player, type, index, element)
  local items = game.item_prototypes
  local name = element.elem_value
  local frame = player.gui.left.mod_gui_frame_flow.upgrade_planner_config_frame
  local ruleset_grid = frame["upgrade_planner_ruleset_grid"]
  local storage_name = element.parent.parent.upgrade_planner_storage_flow
                           .children[1].get_item(
                               global.storage_index[player.index])
  local storage = global["config-tmp"][player.name]
  if not frame or not storage then return end
  if not name then
    ruleset_grid["upgrade_planner_" .. type .. "_" .. index].tooltip = ""
    storage[index][type] = ""
    gui_save_changes(player)
    return
  end
  local opposite = "from"
  if type == "from" then
    opposite = "to"
    for i = 1, #storage do
      if index ~= i and storage[i].from == name then
        player.print({"upgrade-planner.item-already-set"})
        UPGui.restore_config(player, storage_name)
        return
      end
    end
  end
  local related = storage[index][opposite]
  if related ~= "" then
    if related == name then
      player.print({"upgrade-planner.item-is-same"})
      UPGui.restore_config(player, storage_name)
      return
    end
    if UPUtility.get_type(name) ~= UPUtility.get_type(related) and
        (not UPUtility.is_exception(UPUtility.get_type(name),
                                    UPUtility.get_type(related))) then
      player.print({"upgrade-planner.item-not-same-type"})
      if storage[index][type] == "" then
        element.elem_value = nil
      elseif items[storage[index][type]] then
        element.elem_value = storage[index][type]
      else
        element.elem_value = nil
      end
      return
    end
  end
  storage[index][type] = name
  ruleset_grid["upgrade_planner_" .. type .. "_" .. index].tooltip =
      items[name].localised_name
  gui_save_changes(player)
end

local function on_gui_elem_changed(event)
  local element = event.element
  local player = game.players[event.player_index]
  if not string.find(element.name, "upgrade_planner_") then return end
  local type, index = string.match(element.name, "upgrade_planner_(%a+)_(%d+)")
  if type and index then
    if type == "from" or type == "to" then
      gui_set_rule(player, type, tonumber(index), element)
    end
  end
end

--- Switch selected storage
local function on_gui_selection_state_changed(event)
  local element = event.element
  local player = game.players[event.player_index]
  if not string.find(element.name, "upgrade_planner_") then return end
  if element.selected_index > 0 then
    global.storage_index[player.index] = element.selected_index
    local name = element.get_item(element.selected_index)
    UPGui.restore_config(player, name)
    global.current_config[player.index] = global.storage[player.index][name]
  end
end

local function oc_convert_ingame(event)
  local player = game.players[event.player_index]
  local stack = player.cursor_stack
  if (stack and stack.valid and stack.valid_for_read and stack.is_upgrade_item) then
    local config = UPConvert.from_upgrade_planner(stack)
    global.storage[player.index]["Imported storage"] = config
    local count = 0
    for k, _ in pairs(global.storage[player.index]) do count = count + 1 end
    global.storage_index[player.index] = count
    player.print({"upgrade-planner.import-sucessful"})
    UPGui.open_frame(player)
    UPGui.open_frame(player)
  else
    local config = global.current_config[player.index]
    if not config then return end

    if player.clean_cursor() then
      stack = player.cursor_stack
      UPConvert.to_upgrade_planner(stack, config, player)
    end
  end
end

local function oc_import_export(event)
  UPGui.import_export_config(event, event.element.name ==
                                 "upgrade_planner_import_config_open")
end

local function oc_import_config(event)
  local player = game.players[event.player_index]

  if not player.opened then return end
  local frame = player.opened
  if not (frame.name and frame.name == "upgrade_planner_export_frame") then
    return
  end
  local textbox = frame.children[1]
  if not textbox.type == "text-box" then return end
  local text = textbox.text
  local new_config = game.json_to_table(text)
  if new_config then
    for name, config in pairs(new_config) do
      if name == "New storage" then
        global.storage[player.index]["Imported storage"] = config
      else
        global.storage[player.index][name] = config
      end
    end
    player.print({"upgrade-planner.import-sucessful"})
    player.opened.destroy()
    local count = 0
    for k, _ in pairs(global.storage[player.index]) do count = count + 1 end
    global.storage_index[player.index] = count
    UPGui.open_frame(player)
  else
    player.print({"upgrade-planner.import-failed"})
  end
end

-----------------------------------------------
-- Storage handling
-----------------------------------------------
local function oc_storage_confirm(event)
  local player = game.players[event.player_index]
  local index = global.storage_index[player.index]
  local children = event.element.parent.children
  local new_name = children[4].text
  local length = string.len(new_name)
  if length < 1 then
    player.print({"upgrade-planner.storage-name-too-short"})
    return
  end
  for k = 4, 6 do children[k].visible = false end
  local items = children[1].items
  if index > #items then index = #items end
  local old_name = items[index]
  if old_name == "New storage" then children[1].add_item("New storage") end
  if not global.storage then global.storage = {} end
  if not global.storage[player.index] then global.storage[player.index] = {} end
  if global.storage[player.index][old_name] then
    global.storage[player.index][new_name] =
        global.storage[player.index][old_name]
  else
    global.storage[player.index][new_name] = {}
  end
  global.storage[player.index][old_name] = nil
  -- game.print(serpent.block(global.storage[player.index][new_name]))
  children[1].set_item(index, new_name)
  children[1].selected_index = 0
  children[1].selected_index = index
  global.storage_index[player.index] = index
  return
end

local function oc_storage_rename(event)
  local children = event.element.parent.children
  for k, child in pairs(children) do child.visible = true end
  children[4].text = children[1].get_item(children[1].selected_index)
  if children[4].text == "New storage" then children[4].text = "" end
end

local function oc_storage_cancel(event)
  local children = event.element.parent.children
  for k = 4, 6 do children[k].visible = false end
  children[4].text = children[1].get_item(children[1].selected_index)
end

local function oc_storage_delete(event)
  local player = game.players[event.player_index]
  local element = event.element
  local children = element.parent.children
  local dropdown = children[1]
  local index = dropdown.selected_index
  local name = dropdown.get_item(index)
  global.storage[player.index][name] = nil
  if name ~= "New storage" then dropdown.remove_item(index) end
  if index > 1 then index = index - 1 end
  dropdown.selected_index = 0
  dropdown.selected_index = index
  UPGui.restore_config(player, dropdown.get_item(index))
  global.storage_index[player.index] = index
  return
end

local function sc_default_bot(event)
  global.default_bot[event.player_index] = event.element.state
end

upgrade_planner_gui_events.register = function()
  Event.register(defines.events.on_mod_item_opened, function(event)
    if event.item.name == "upgrade-builder" then
      UPGui.open_frame_event(event)
    end
  end)

  Gui.on_click("upgrade_planner_export_config_open", oc_import_export)
  Gui.on_click("upgrade_planner_import_config_button", oc_import_config)
  Gui.on_click("upgrade_planner_import_config_open", oc_import_export)
  Gui.on_click("upgrade_planner_storage_cancel", oc_storage_cancel)
  Gui.on_click("upgrade_planner_storage_confirm", oc_storage_confirm)
  Gui.on_click("upgrade_planner_storage_delete", oc_storage_delete)
  Gui.on_click("upgrade_planner_storage_rename", oc_storage_rename)

  Gui.on_checked_state_changed("upgrade_planner_default_bot_checkbox",
                               sc_default_bot)

  Event.register("upgrade-planner", UPGui.open_frame_event)
  Gui.on_click("upgrade_planner_config_button", UPGui.open_frame_event)
  Gui.on_click("upgrade_planner_frame_close", UPGui.close_frame)
  Event.register(defines.events.on_gui_closed, on_gui_closed)

  Gui.on_click("upgrade_blueprint", UPEntityUpgrade.upgrade_blueprint)

  Gui.on_click("upgrade_planner_convert_ingame", oc_convert_ingame)

  -- TODO: Use stdlib functions: https://afforess.github.io/Factorio-Stdlib/modules/Event.Gui.html
  Event.register(defines.events.on_gui_selection_state_changed,
                 on_gui_selection_state_changed)
  Event.register(defines.events.on_gui_elem_changed, on_gui_elem_changed)
end

return upgrade_planner_gui_events
