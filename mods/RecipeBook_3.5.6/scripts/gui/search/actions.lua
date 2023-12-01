local gui = require("__flib__.gui")
local on_tick_n = require("__flib__.on-tick-n")
local table = require("__flib__.table")

local constants = require("constants")

local database = require("scripts.database")
local formatter = require("scripts.formatter")
local gui_util = require("scripts.gui.util")
local util = require("scripts.util")

local actions = {}

--- @param Gui SearchGui
--- @param e on_gui_click
function actions.reset_location(Gui, _, e)
  if e.button ~= defines.mouse_button_type.middle then
    return
  end

  if Gui.player_table.settings.general.interface.search_gui_location == "top_left" then
    local scale = Gui.player.display_scale
    Gui.refs.window.location = table.map(constants.search_gui_top_left_location, function(pos)
      return pos * scale
    end)
    Gui.refs.window.auto_center = false
  else
    Gui.refs.window.force_auto_center()
  end
end

--- @param Gui SearchGui
function actions.close(Gui, _, _)
  if not Gui.state.ignore_closed and not Gui.player_table.flags.technology_gui_open then
    Gui:close()
  end
end

--- @param Gui SearchGui
function actions.toggle_pinned(Gui, _, _)
  local player = Gui.player
  local refs = Gui.refs
  local state = Gui.state

  local pin_button = refs.titlebar.pin_button

  state.pinned = not state.pinned
  if state.pinned then
    pin_button.style = "flib_selected_frame_action_button"
    pin_button.sprite = "rb_pin_black"
    if player.opened == refs.window then
      state.ignore_closed = true
      player.opened = nil
      state.ignore_closed = false
    end
  else
    pin_button.style = "frame_action_button"
    pin_button.sprite = "rb_pin_white"
    player.opened = refs.window
  end
end

--- @param Gui SearchGui
function actions.toggle_settings(Gui, _, _)
  local state = Gui.state
  local player = Gui.player

  state.ignore_closed = true
  local SettingsGui = util.get_gui(Gui.player.index, "settings")
  if SettingsGui then
    SettingsGui:destroy()
  else
    SETTINGS_GUI.build(player, Gui.player_table)
  end
  state.ignore_closed = false
  local settings_button = Gui.refs.titlebar.settings_button
  if Gui.player_table.guis.settings then
    settings_button.style = "flib_selected_frame_action_button"
    settings_button.sprite = "rb_settings_black"
  else
    settings_button.style = "frame_action_button"
    settings_button.sprite = "rb_settings_white"
    if not state.pinned then
      player.opened = Gui.refs.window
    end
  end
end

--- @param Gui SearchGui
function actions.deselect_settings_button(Gui, _, _)
  local settings_button = Gui.refs.titlebar.settings_button
  settings_button.style = "frame_action_button"
  settings_button.sprite = "rb_settings_white"
  if not Gui.state.pinned and Gui.refs.window.visible then
    Gui.player.opened = Gui.refs.window
  end
end

--- @param Gui SearchGui
--- @param e on_gui_text_changed
function actions.update_search_query(Gui, _, e)
  local player_table = Gui.player_table
  local state = Gui.state
  local refs = Gui.refs

  local class_filter
  local query = string.lower(e.element.text)
  if string.find(query, "/") then
    -- The `_`s here are technically globals, but whatever
    _, _, class_filter, query = string.find(query, "^/(.-)/(.-)$")
    if class_filter then
      class_filter = string.lower(class_filter)
    end
    -- Check translations of each class filter
    local matched = false
    if class_filter then
      local gui_translations = player_table.translations.gui
      for _, class in pairs(constants.classes) do
        if class_filter == string.lower(gui_translations[class]) then
          matched = true
          class_filter = class
          break
        end
      end
    end
    -- Invalidate textfield
    if not class_filter or not query or not matched then
      class_filter = false
      query = nil
    end
  end
  -- Remove results update action if there is one
  if state.update_results_ident then
    on_tick_n.remove(state.update_results_ident)
    state.update_results_ident = nil
  end
  if query then
    -- Fuzzy search
    if player_table.settings.general.search.fuzzy_search then
      query = string.gsub(query, ".", "%1.*")
    end
    -- Input sanitization
    for pattern, replacement in pairs(constants.input_sanitizers) do
      query = string.gsub(query, pattern, replacement)
    end
    -- Save query
    state.search_query = query
    state.class_filter = class_filter
    -- Reset textfield style
    refs.search_textfield.style = "rb_search_textfield"
    if #query == 0 and not class_filter then
      -- Update immediately
      actions.update_search_results(Gui)
    else
      -- Update in a while
      state.update_results_ident = on_tick_n.add(
        game.tick + constants.search_timeout,
        { gui = "search", action = "update_search_results", player_index = e.player_index }
      )
    end
  else
    state.search_query = ""
    refs.search_textfield.style = "rb_search_invalid_textfield"
  end
end

--- @param Gui SearchGui
function actions.update_search_results(Gui, _, _)
  local player = Gui.player
  local player_table = Gui.player_table
  local state = Gui.state
  local refs = Gui.refs

  -- Data
  local player_data = formatter.build_player_data(player, player_table)
  local show_fluid_temperatures = player_table.settings.general.search.show_fluid_temperatures
  local search_type = player_table.settings.general.search.search_type
  local class_filter = state.class_filter
  local query = state.search_query

  if state.search_type == "textual" then
    -- Update results based on query
    local i = 0
    local pane = refs.textual_results_pane
    local children = pane.children
    local max = constants.search_results_limit
    if class_filter ~= false and (class_filter or #query >= 2) then
      for class in pairs(constants.pages) do
        if not class_filter or class_filter == class then
          for internal, translation in pairs(player_table.translations[class]) do
            -- Match against search string
            local matched
            if search_type == "both" then
              matched = string.find(string.lower(internal), query) or string.find(string.lower(translation), query)
            elseif search_type == "internal" then
              matched = string.find(string.lower(internal), query)
            elseif search_type == "localised" then
              matched = string.find(string.lower(translation), query)
            end

            if matched then
              local obj_data = database[class][internal]

              -- Check temperature settings
              local passed = true
              if obj_data.class == "fluid" then
                local temperature_ident = obj_data.temperature_ident
                if temperature_ident then
                  local is_range = temperature_ident.min ~= temperature_ident.max
                  if is_range then
                    if show_fluid_temperatures ~= "all" then
                      passed = false
                    end
                  else
                    if show_fluid_temperatures == "off" then
                      passed = false
                    end
                  end
                end
              end

              if passed then
                local blueprint_result = class == "entity" and obj_data.blueprintable and { name = internal } or nil
                local info = formatter(obj_data, player_data, { blueprint_result = blueprint_result })
                if info then
                  i = i + 1
                  local style = info.researched and "rb_list_box_item" or "rb_unresearched_list_box_item"
                  local item = children[i]
                  if item then
                    item.style = style
                    item.caption = info.caption
                    item.tooltip = info.tooltip
                    item.enabled = info.num_interactions > 0
                    gui.update_tags(
                      item,
                      { blueprint_result = blueprint_result, context = { class = class, name = internal } }
                    )
                  else
                    gui.add(pane, {
                      type = "button",
                      style = style,
                      caption = info.caption,
                      tooltip = info.tooltip,
                      enabled = info.num_interactions > 0,
                      mouse_button_filter = { "left", "middle" },
                      tags = {
                        blueprint_result = blueprint_result,
                        context = { class = class, name = internal },
                      },
                      actions = {
                        on_click = { gui = "search", action = "open_object" },
                      },
                    })
                    if i >= max then
                      break
                    end
                  end
                end
              end
            end
          end
        end
        if i >= max then
          break
        end
      end
    end
    -- Destroy extraneous items
    for j = i + 1, #children do
      children[j].destroy()
    end
  elseif state.search_type == "visual" then
    refs.objects_frame.visible = true
    refs.warning_frame.visible = false

    --- @type LuaGuiElement
    local group_table = refs.group_table

    for _, group_scroll in pairs(refs.objects_frame.children) do
      local group_has_results = false
      for _, subgroup_table in pairs(group_scroll.children) do
        local visible_count = 0
        for _, obj_button in pairs(subgroup_table.children) do
          local context = gui.get_tags(obj_button).context

          local matched
          -- Match against class filter
          if not class_filter or class_filter == context.class then
            local translation = player_data.translations[context.class][context.name]
            -- Match against search string
            if search_type == "both" then
              matched = string.find(string.lower(context.name), query) or string.find(string.lower(translation), query)
            elseif search_type == "internal" then
              matched = string.find(string.lower(context.name), query)
            elseif search_type == "localised" then
              matched = string.find(string.lower(translation), query)
            end
          end

          if matched then
            obj_button.visible = true
            visible_count = visible_count + 1
          else
            obj_button.visible = false
          end
        end

        if visible_count > 0 then
          group_has_results = true
          subgroup_table.visible = true
        else
          subgroup_table.visible = false
        end
      end

      local group_name = group_scroll.name
      local group_button = group_table[group_name]
      if group_has_results then
        group_button.style = "rb_filter_group_button_tab"
        group_button.enabled = state.active_group ~= group_scroll.name
        if state.active_group == group_name then
          group_scroll.visible = true
        else
          group_scroll.visible = false
        end
      else
        group_scroll.visible = false
        group_button.style = "rb_disabled_filter_group_button_tab"
        group_button.enabled = false
        if state.active_group == group_name then
          local matched = false
          for _, group_button in pairs(group_table.children) do
            if group_button.enabled then
              matched = true
              actions.change_group(Gui, { group = group_button.name, ignore_last_button = true })
              break
            end
          end
          if not matched then
            refs.objects_frame.visible = false
            refs.warning_frame.visible = true
          end
        end
      end
    end
  end
end

--- @param Gui SearchGui
--- @param e on_gui_click
function actions.open_object(Gui, _, e)
  local context = gui_util.navigate_to(e)
  if context then
    local attach = Gui.player_table.settings.general.interface.attach_search_results
    local sticky = attach and e.button == defines.mouse_button_type.left
    local id = sticky and Gui.state.id and Gui.player_table.guis.info[Gui.state.id] and Gui.state.id or nil
    local parent = sticky and Gui.refs.window or nil
    OPEN_PAGE(Gui.player, Gui.player_table, context, { id = id, parent = parent })
    if sticky and not id then
      Gui.state.id = Gui.player_table.guis.info._active_id
    end
    if not sticky and Gui.player_table.settings.general.interface.close_search_gui_after_selection then
      actions.close(Gui)
    end
  end
end

--- @param Gui SearchGui
function actions.change_search_type(Gui)
  local state = Gui.state
  local refs = Gui.refs
  if state.search_type == "textual" then
    state.search_type = "visual"
    refs.textual_results_pane.visible = false
    refs.visual_results_flow.visible = true
    if state.needs_visual_update then
      state.needs_visual_update = false
      Gui:update_visual_contents()
    end
  elseif state.search_type == "visual" then
    state.search_type = "textual"
    refs.textual_results_pane.visible = true
    refs.visual_results_flow.visible = false
  end
  actions.update_search_results(Gui)
end

--- @param Gui SearchGui
--- @param msg table
function actions.change_group(Gui, msg)
  local last_group = Gui.state.active_group

  if not msg.ignore_last_button then
    Gui.refs.group_table[last_group].enabled = true
  end
  Gui.refs.objects_frame[last_group].visible = false

  local new_group = msg.group
  Gui.refs.group_table[new_group].enabled = false
  Gui.refs.objects_frame[new_group].visible = true

  Gui.state.active_group = msg.group
end

--- @param Gui SearchGui
function actions.update_favorites(Gui, _, _)
  Gui:update_favorites()
end

--- @param Gui SearchGui
function actions.update_history(Gui, _, _)
  Gui:update_history()
end

--- @param Gui SearchGui
function actions.delete_favorites(Gui, _, _)
  Gui.player_table.favorites = {}
  Gui:update_favorites()
end

--- @param Gui SearchGui
function actions.delete_history(Gui, _, _)
  Gui.player_table.global_history = {}
  Gui:update_history()
end

return actions
