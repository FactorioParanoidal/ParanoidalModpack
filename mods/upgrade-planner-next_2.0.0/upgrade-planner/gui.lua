local mod_gui = require("mod-gui")
local UPUtility = require("utility")
local UPGlobals = require("globals")

local upgrade_planner_gui = {}

local function restore_config(player, storage_name)
  local frame = player.gui.left.mod_gui_frame_flow.upgrade_planner_config_frame
  if not frame then return end
  if not global.storage[player.index] then return end
  local storage = global.storage[player.index][storage_name]
  if not storage and storage_name == "New storage" then storage = {} end
  if not storage then return end

  global["config-tmp"][player.name] = {}
  local items = game.item_prototypes
  local ruleset_grid = frame["upgrade_planner_ruleset_grid"]
  for i = 1, UPGlobals.MAX_CONFIG_SIZE do
    if i > #storage then
      global["config-tmp"][player.name][i] = {from = "", to = ""}
    else
      global["config-tmp"][player.name][i] =
          {from = storage[i].from, to = storage[i].to}
    end
    local from_name = UPUtility.get_config_item(player, i, "from")
    ruleset_grid["upgrade_planner_from_" .. i].elem_value = from_name
    if from_name and from_name ~= "" then
      ruleset_grid["upgrade_planner_from_" .. i].tooltip =
          items[from_name].localised_name
    else
      ruleset_grid["upgrade_planner_from_" .. i].tooltip = ""
    end
    local to_name = UPUtility.get_config_item(player, i, "to")
    ruleset_grid["upgrade_planner_to_" .. i].elem_value = to_name
    if to_name and to_name ~= "" then
      ruleset_grid["upgrade_planner_to_" .. i].tooltip =
          items[to_name].localised_name
    else
      ruleset_grid["upgrade_planner_to_" .. i].tooltip = ""
    end
  end
  global.current_config[player.index] = global["config-tmp"][player.name]
end

upgrade_planner_gui.init = function(player)
  local flow = mod_gui.get_button_flow(player)
  if not flow.upgrade_planner_config_button then
    local button = flow.add{
      type = "sprite-button",
      name = "upgrade_planner_config_button",
      style = mod_gui.button_style,
      sprite = "item/upgrade-builder",
      tooltip = {"upgrade-planner.button-tooltip"},
    }
    button.visible = true
  end
end

local function open_frame(player)
  local flow = mod_gui.get_frame_flow(player)

  local frame = flow.upgrade_planner_config_frame

  if frame then
    frame.destroy()
    global["config-tmp"][player.name] = nil
    return
  end

  global.current_config[player.index] = global.current_config[player.index] or
                                            {}
  global["config-tmp"][player.name] = {}

  for i = 1, UPGlobals.MAX_CONFIG_SIZE do
    if i > #global.current_config[player.index] then
      global["config-tmp"][player.name][i] = {from = "", to = ""}
    else
      global["config-tmp"][player.name][i] =
          {
            from = global.current_config[player.index][i].from,
            to = global.current_config[player.index][i].to,
          }
    end
  end

  -- Now we can build the GUI.
  frame = flow.add{
    type = "frame",
    caption = {"upgrade-planner.config-frame-title"},
    name = "upgrade_planner_config_frame",
    direction = "vertical",
  }
  if not global.storage_index then global.storage_index = {} end
  if not global.storage_index[player.index] then
    global.storage_index[player.index] = 1
  end
  local storage_flow = frame.add{
    type = "table",
    name = "upgrade_planner_storage_flow",
    column_count = 3,
  }
  -- storage_flow.style.horizontal_spacing = 2
  local drop_down = storage_flow.add{
    type = "drop-down",
    name = "upgrade_planner_drop_down",
  }
  -- drop_down.style.minimal_height = 50
  drop_down.style.minimal_width = 164
  drop_down.style.maximal_width = 0
  if not global.storage then global.storage = {} end
  if not global.storage[player.index] then global.storage[player.index] = {} end
  for key, _ in pairs(global.storage[player.index]) do drop_down.add_item(key) end
  if not global.storage[player.index]["New storage"] then
    drop_down.add_item("New storage")
  end
  local options = drop_down.items
  local index = math.min(global.storage_index[player.index], #options)
  index = math.max(index, 1)
  drop_down.selected_index = index
  global.storage_index[player.index] = index
  local storage_to_restore = drop_down.get_item(drop_down.selected_index)
  local rename_button = storage_flow.add{
    type = "sprite-button",
    name = "upgrade_planner_storage_rename",
    sprite = "utility/rename_icon_normal",
    tooltip = {"upgrade-planner.rename-button-tooltip"},
  }
  rename_button.style = "slot_button"
  rename_button.style.maximal_width = 24
  rename_button.style.minimal_width = 24
  rename_button.style.maximal_height = 24
  rename_button.style.minimal_height = 24
  local remove_button = storage_flow.add{
    type = "sprite-button",
    name = "upgrade_planner_storage_delete",
    sprite = "utility/remove",
    tooltip = {"upgrade-planner.delete-storage-button-tooltip"},
  }
  remove_button.style = "red_slot_button"
  remove_button.style.maximal_width = 24
  remove_button.style.minimal_width = 24
  remove_button.style.maximal_height = 24
  remove_button.style.minimal_height = 24
  local rename_field = storage_flow.add{
    type = "textfield",
    name = "upgrade_planner_storage_rename_textfield",
    text = drop_down.get_item(drop_down.selected_index),
  }
  rename_field.visible = false
  local confirm_button = storage_flow.add{
    type = "sprite-button",
    name = "upgrade_planner_storage_confirm",
    sprite = "utility/confirm_slot",
    tooltip = {"upgrade-planner.confirm-storage-name"},
  }
  confirm_button.style = "green_slot_button"
  confirm_button.style.maximal_width = 24
  confirm_button.style.minimal_width = 24
  confirm_button.style.maximal_height = 24
  confirm_button.style.minimal_height = 24
  confirm_button.visible = false
  local cancel_button = storage_flow.add{
    type = "sprite-button",
    name = "upgrade_planner_storage_cancel",
    sprite = "utility/set_bar_slot",
    tooltip = {"upgrade-planner.cancel-storage-name"},
  }
  cancel_button.style = "red_slot_button"
  cancel_button.style.maximal_width = 24
  cancel_button.style.minimal_width = 24
  cancel_button.style.maximal_height = 24
  cancel_button.style.minimal_height = 24
  cancel_button.visible = false
  local ruleset_grid = frame.add{
    type = "table",
    column_count = (UPGlobals.MAX_CONFIG_SIZE / 6 - UPGlobals.MAX_CONFIG_SIZE %
        6) * 3,
    name = "upgrade_planner_ruleset_grid",
    style = "slot_table",
  }

  for i = 1, UPGlobals.MAX_CONFIG_SIZE / 6 do
    ruleset_grid.add{
      type = "label",
      caption = {"upgrade-planner.config-header-1"},
    }
    ruleset_grid.add{
      type = "label",
      caption = {"upgrade-planner.config-header-2"},
    }
    ruleset_grid.add{type = "label"}
  end

  local items = game.item_prototypes
  for i = 1, UPGlobals.MAX_CONFIG_SIZE do
    local tooltip = nil
    local from = UPUtility.get_config_item(player, i, "from")
    if from then
      -- sprite = "item/"..UPUtility.get_config_item(player, i, "from")
      tooltip = items[from].localised_name
    end
    local choose_elem_button_from = ruleset_grid.add{
      type = "choose-elem-button",
      name = "upgrade_planner_from_" .. i,
      style = "slot_button",
      -- sprite = sprite,
      elem_type = "item",
      tooltip = tooltip,
    }
    choose_elem_button_from.elem_value = from
    tooltip = nil
    local to = UPUtility.get_config_item(player, i, "to")
    if to then
      -- sprite = "item/"..UPUtility.get_config_item(player, i, "to")
      tooltip = items[to].localised_name
    end
    local choose_elem_button_to = ruleset_grid.add{
      type = "choose-elem-button",
      name = "upgrade_planner_to_" .. i,
      -- style = "slot_button",
      -- sprite = sprite,
      elem_type = "item",
      tooltip = tooltip,
    }
    choose_elem_button_to.elem_value = to
    ruleset_grid.add{type = "label"}
  end

  frame.add{
    type = "checkbox",
    name = "upgrade_planner_default_bot_checkbox",
    state = global.default_bot[player.index] or false,
    caption = {"upgrade-planner.default-bot-upgrade-caption"},
    tooltip = {"upgrade-planner.default-bot-upgrade-tooltip"},
  }

  local button_grid = frame.add{type = "table", column_count = 5}
  button_grid.add{
    type = "sprite-button",
    name = "upgrade_blueprint",
    sprite = "item/blueprint",
    tooltip = {"upgrade-planner.config-button-upgrade-blueprint"},
    style = mod_gui.button_style,
  }
  button_grid.add{
    type = "sprite-button",
    name = "upgrade_planner_import_config_open",
    sprite = "utility/import_slot",
    tooltip = {"upgrade-planner.config-button-import-config"},
    style = mod_gui.button_style,
  }
  button_grid.add{
    type = "sprite-button",
    name = "upgrade_planner_export_config_open",
    sprite = "utility/export_slot",
    tooltip = {"upgrade-planner.config-button-export-config"},
    style = mod_gui.button_style,
  }
  button_grid.add{
    type = "sprite-button",
    name = "upgrade_planner_convert_ingame",
    sprite = "item/upgrade-planner",
    tooltip = {"upgrade-planner.config-button-export-config"},
    style = mod_gui.button_style,
  }
  button_grid.add{
    type = "button",
    caption = {"gui.close"},
    name = "upgrade_planner_frame_close",
    style = mod_gui.button_style,
  }
  restore_config(player, storage_to_restore)
end

upgrade_planner_gui.open_frame_event = function(event)
  local player = game.players[event.player_index]
  open_frame(player)
end

upgrade_planner_gui.open_frame = open_frame

upgrade_planner_gui.close_frame = function(event)
  local player = game.players[event.player_index]
  local element = event.element
  while element.type ~= "frame" do element = element.parent end

  if element.name == "upgrade_planner_config_frame" then
    local ieframe = player.gui.left.mod_gui_frame_flow
                        .upgrade_planner_export_frame
    if ieframe then ieframe.destroy() end
  else
    open_frame(player)
  end

  element.destroy()
end

upgrade_planner_gui.import_export_config =
    function(event, import)
      local player = game.players[event.player_index]
      local caption = {"upgrade-planner.export-config"}

      if import then caption = {"upgrade-planner.import-config"} end

      player.opened = nil
      local gui = player.gui.left.mod_gui_frame_flow
      local frame = gui.add{
        type = "frame",
        caption = caption,
        name = "upgrade_planner_export_frame",
        direction = "vertical",
      }
      local textfield = frame.add{type = "text-box"}
      textfield.word_wrap = true
      textfield.read_only = not import
      textfield.style.minimal_width = 500
      textfield.style.minimal_height = 200
      textfield.style.maximal_height = 500
      if not import then
        textfield.text = game.table_to_json(global.storage[player.index])
      end
      local flow = frame.add{type = "flow"}
      if import then
        flow.add{
          type = "button",
          caption = {"upgrade-planner.import-button"},
          name = "upgrade_planner_import_config_button",
          style = mod_gui.button_style,
        }
      end
      flow.add{
        type = "button",
        caption = {"gui.close"},
        name = "upgrade_planner_frame_close",
        style = mod_gui.button_style,
      }
      frame.visible = true
      player.opened = frame
      open_frame(player)
    end

upgrade_planner_gui.restore_config = restore_config

return upgrade_planner_gui
