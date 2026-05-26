local SearchGui = {}

---@param signal SignalID
---@return LocalisedString
local function get_signal_name(signal)
  if signal.name then
    if signal.type == "item" then
      return prototypes.item[signal.name].localised_name
    elseif signal.type == "fluid" then
      return prototypes.fluid[signal.name].localised_name
    elseif signal.type == "virtual" then
      return prototypes.virtual_signal[signal.name].localised_name
    end
  end
end

---@param surface_name string
---@param entity_groups EntityGroup[]
---@return GuiElemDef[]
function SearchGui.build_surface_category_results(surface_name, entity_groups)
  local gui_elements = {}
  for _, group in pairs(entity_groups) do
    local entity_name = group.entity_name
    local distance_info = {""}
    if group.distance then
      distance_info = {"", "\n[font=default-semibold][color=255, 230, 192]", {"search-gui.distance-tooltip"}, ":[/color][/font] ", util.format_number(math.ceil(group.distance), true), "m"}
    end
    local extra_info = {""}
    if group.recipe_list then
      extra_info = {""}
      local multiple_recipes = false
      local number_of_recipes = 0
      for _ in pairs(group.recipe_list) do number_of_recipes = number_of_recipes + 1 end

      if number_of_recipes > 1 then
        multiple_recipes = true
      end
      if number_of_recipes <= 10 then
        -- Localised strings must not have more than 20 parameters
        for name, recipe_info in pairs(group.recipe_list) do
          local string = "\n"
          if multiple_recipes then
            string = string .. "[font=default-bold]" .. recipe_info.count .. " × [/font]"
          end
          string = string .. "[recipe=" .. name .. "] "
          table.insert(extra_info, string)
          table.insert(extra_info, recipe_info.localised_name)
        end
      end
    end
    if group.item_count then
      extra_info = {"", "\n[font=default-semibold][color=255, 230, 192]", {"gui-train.add-item-count-condition"}, ":[/color][/font] ", util.format_number(math.floor(group.item_count), true)}
    end
    if group.fluid_count then
      extra_info = {"", "\n[font=default-semibold][color=255, 230, 192]", {"gui-train.add-fluid-count-condition"}, ":[/color][/font] ", util.format_number(math.floor(group.fluid_count), true)}
    end
    if group.module_count then
      extra_info = {"", "\n[font=default-semibold][color=255, 230, 192]", {"search-gui.module-count-tooltip"}, ":[/color][/font] ", util.format_number(math.floor(group.module_count), true)}
    end
    if group.request_count then
      extra_info = {"", "\n[font=default-semibold][color=255, 230, 192]", {"search-gui.request-count-tooltip"}, ":[/color][/font] ", util.format_number(math.floor(group.request_count), true)}
    end
    if group.signal_count then
      extra_info = {"", "\n[font=default-semibold][color=255, 230, 192]", {"search-gui.signal-count-tooltip"}, ":[/color][/font] ", util.format_number(math.floor(group.signal_count), true)}
    end
    local sprite = "entity/" .. entity_name
    if not helpers.is_valid_sprite_path(sprite) then
      sprite = "item/" .. entity_name
      if not helpers.is_valid_sprite_path(sprite) then
        sprite = "fluid/" .. entity_name
        if not helpers.is_valid_sprite_path(sprite) then
          sprite = "recipe/" .. entity_name
          if not helpers.is_valid_sprite_path(sprite) then
            sprite = "virtual-signal/" .. entity_name
            if not helpers.is_valid_sprite_path(sprite) then
              sprite = "utility/questionmark"
            end
          end
        end
      end
    end
    table.insert(gui_elements,
      {
        type = "sprite-button",
        sprite = sprite,
        tooltip = {"", "[font=default-bold]", group.localised_name, "[/font]", distance_info, extra_info, "\n", {"search-gui.result-tooltip"}},
        style = "slot_button",
        number = group.resource_count or group.count,
        tags = {position = group.avg_position, surface = surface_name, selection_boxes = group.selection_boxes, group_selection_box = group.selection_box},
        handler = {[defines.events.on_gui_click] = SearchGui.open_location_on_map}
      }
    )
  end
  return gui_elements
end

---@param include_surface_name boolean?
---@param surface_name string
---@return GuiElemDef
function SearchGui.build_surface_name(include_surface_name, surface_name)
  if include_surface_name then
    local surface = game.get_surface(surface_name)
    local display_name
    -- Capitalize first letter
    if not surface then
      display_name = surface_name:gsub("^%l", string.upper)
    elseif surface.platform then
      display_name = surface.platform.name
    elseif surface.planet then
      display_name = surface.planet.prototype.localised_name
    elseif surface.localised_name then
      display_name = surface.localised_name
    else
      display_name = surface_name:gsub("^%l", string.upper)
    end
    return  {
      type = "label",
      caption = display_name,
      style = "bold_label",
      style_mods = {font = "default-large-bold"}
    }
  else
    return {}
  end
end

---@param string LocalisedString
---@param count number
---@return GuiElemDef
local function count_label(string, count)
  return {
    type = "label",
    caption = {"", "[font=default-semibold]", string, ":[/font] ", util.format_number(math.floor(count), true)},
    style = "bold_label",
    tooltip = nil,
    --style_mods = {font = "default-bold"
  }
end

---@param surface_statistics SurfaceStatistics
---@param surface_name_included boolean?
---@return GuiElemDef
function SearchGui.build_surface_count(surface_statistics, surface_name_included)
  local labels = {}
  --[[if next(surface_statistics) then
    table.insert(labels, {
      type = "label",
      caption = "Totals",
      style = "bold_label",
      -- Less margin top
      style_mods = {top_margin = -8}  -- TODO don't reduce top margin when no planet name
    })
  end]]
  if surface_statistics.consumers_count then
    table.insert(labels, count_label({"search-gui.total-consumers"}, surface_statistics.consumers_count))
  end
  if surface_statistics.producers_count then
    table.insert(labels, count_label({"search-gui.total-producers"}, surface_statistics.producers_count))
  end
  if surface_statistics.item_count then
    table.insert(labels, count_label({"search-gui.total-items"}, surface_statistics.item_count))
  end
  if surface_statistics.fluid_count then
    table.insert(labels, count_label({"search-gui.total-fluids"}, surface_statistics.fluid_count))
  end
  if surface_statistics.module_count then
    table.insert(labels, count_label({"search-gui.total-modules"}, surface_statistics.module_count))
  end
  if surface_statistics.entity_count then
    table.insert(labels, count_label({"search-gui.total-entities"}, surface_statistics.entity_count))
  end
  if surface_statistics.resource_count then
    table.insert(labels, count_label({"search-gui.total-resources"}, surface_statistics.resource_count))
  end
  if surface_statistics.ground_count then
    table.insert(labels, count_label({"search-gui.total-ground"}, surface_statistics.ground_count))
  end
  if surface_statistics.request_count then
    table.insert(labels, count_label({"search-gui.total-requested"}, surface_statistics.request_count))
  end
  if surface_statistics.signal_count then
    table.insert(labels, count_label({"search-gui.total-signals"}, surface_statistics.signal_count))
  end
  if surface_statistics.tag_count then
    table.insert(labels, count_label({"search-gui.total-tags"}, surface_statistics.tag_count))
  end
  local flow = {
    type = "flow",
    direction = "vertical",
    --style = "bold_label",
    --tooltip = nil,
    style_mods = {
      vertical_spacing = -4,
      top_margin = surface_name_included and -8 or 0,  -- Don't place too high if there isn't a surface name
    },
    children = labels,
  }
  return flow
end

---@param data table<SurfaceName, SurfaceData>
---@param statistics table<SurfaceName, SurfaceStatistics>
---@param frame LuaGuiElement
---@param check_result_found? boolean Default: true
---@param include_surface_name? boolean Whether to show the surface name when there's only one surface in `data`
function SearchGui.build_results(data, statistics, frame, check_result_found, include_surface_name)
  if not (frame and frame.valid) then return end

  frame.clear()

  local surface_count = 0
  for _, _ in pairs(data) do
    surface_count = surface_count + 1
  end

  if surface_count > 1 then
    include_surface_name = true
  end

  local result_found = false
  for surface_name, surface_data in pairs(data) do
    local surface_contains_results = false
    for _, category_data in pairs(surface_data) do
      -- TODO surface_statistics check here?
      surface_contains_results = surface_contains_results or table_size(category_data) > 0
    end
    result_found = result_found or surface_contains_results
    if not surface_contains_results then
      goto continue
    end

    gui.add(frame, {
      SearchGui.build_surface_name(include_surface_name, surface_name),
      SearchGui.build_surface_count(statistics[surface_name], include_surface_name),
      {
        type = "frame",
        direction = "vertical",
        style = "slot_button_deep_frame",
        children = {
          {
            type = "table",
            column_count = 10,
            style = "slot_table",  --       padding = 0, TODO 2.0
            children = SearchGui.build_surface_category_results(surface_name, surface_data.consumers)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.producers)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.storage)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.logistics)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.modules)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.entities)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.ground_items)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.requesters)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.signals)
          },
          {
            type = "table",
            column_count = 10,
            style = "slot_table",
            children = SearchGui.build_surface_category_results(surface_name, surface_data.map_tags)
          },
        }
      }
    })
    ::continue::
  end

  if not result_found and check_result_found ~= false then
    frame.clear()
    gui.add(frame, {
      {
        type = "label",
        style_mods = {font_color = {1, 0, 0, 1}},
        caption = {"search-gui.no-results"}
      }
    })
  end
end

---@param frame LuaGuiElement
function SearchGui.clear_results(frame)
  frame.clear()
  gui.add(frame, {
    {
      type = "label",
      caption = {"search-gui.explanation"},
    }
  })
end

---@param frame LuaGuiElement
function SearchGui.build_invalid_state(frame)
  frame.clear()
  gui.add(frame, {
    {
      type = "label",
      style_mods = {font_color = {1, 0, 0, 1}},
      caption = {"search-gui.incorrect-config"}
    }
  })
end

---@param refs SearchGuiRefs
---@param progress? double
function SearchGui.show_search_progress(refs, progress)
  refs.searching_label.visible = true
  refs.search_progressbar.visible = progress ~= nil
  
  if progress ~= nil then
    refs.search_progressbar.value = progress
    refs.search_progressbar.tooltip = {'', math.floor(progress * 100), '%'}
  end
end

---@param refs SearchGuiRefs
function SearchGui.hide_search_progress(refs)
  refs.searching_label.visible = false
  refs.search_progressbar.visible = false
end

---@param refs SearchGuiRefs
---@param progress? double
function SearchGui.build_loading_results(refs, progress)
  refs.result_flow.clear()
  SearchGui.show_search_progress(refs, progress)
end

---@param player LuaPlayer
---@return PlayerData
function SearchGui.build(player)
  local refs = gui.add(player.gui.screen, {
    {
      type = "frame",
      name = "fs_frame",
      direction = "vertical",
      visible = true,
      ref = {"frame"},
      style_mods = {maximal_height = 800},
      handler = {
        [defines.events.on_gui_closed] = SearchGui.close,  -- TODO check that this works
      },
      children = {
        {
          type = "flow",
          style = "fs_flib_titlebar_flow",
          drag_target = "frame",
          children = {
            {
              type = "label",
              style = "frame_title",
              caption = {"mod-name.FactorySearch"},
              ignored_by_interaction = true,
            },
            {type = "empty-widget", style = "fs_flib_titlebar_drag_handle", ignored_by_interaction = true},
            {
              type = "sprite-button",
              style = "frame_action_button",
              sprite = "fs_flib_pin_white",
              mouse_button_filter = {"left"},
              tooltip = {"search-gui.keep-open"},
              ref = {"pin_button"},
              handler = {
                [defines.events.on_gui_click] = SearchGui.toggle_pin,
              }
            },
            {
              type = "sprite-button",
              style = "close_button",
              sprite = "utility/close",
              mouse_button_filter = {"left"},
              tooltip = {"gui.close-instruction"},
              ref = {"close_button"},
              handler = {
                [defines.events.on_gui_click] = SearchGui.close,
              },
            },
          },
        },
        {
          type = "frame",
          style = "inside_shallow_frame",
          direction = "vertical",
          children = {
            {
              type = "frame",
              style = "subheader_frame",
              direction = "horizontal",
              children = {
                {
                  type = "flow",
                  style = "horizontal_flow",
                  style_mods = {vertical_align = "center", horizontally_stretchable = true, horizontal_spacing = 12},
                  children = {
                    {
                      type = "label",
                      style = "subheader_caption_label",
                      ref = {"subheader_title"},
                    },
                    {
                      type = "empty-widget",
                      style_mods = {horizontally_stretchable = true, horizontally_squashable = true}
                    },
                    {
                      type = "label",
                      caption = {"", {"gui-explore-mods.sort-by"}, ":"},
                      style_mods = {right_padding = -8}
                    },
                    {
                      type = "drop-down",
                      items = {{"description.name"}, {"search-gui.distance"}, {"gui-logistic.count"}},
                      selected_index = 1,
                      mouse_button_filter = {"left"},
                      ref = {"sort_results_dropdown"},
                      handler = {[defines.events.on_gui_selection_state_changed] = SearchGui.sort_results_dropdown_changed},
                    },
                    {
                      type = "sprite-button",
                      style = "tool_button",
                      sprite = "utility/refresh",
                      tooltip = {"gui.refresh"},
                      mouse_button_filter = {"left"},
                      handler = {[defines.events.on_gui_click] = SearchGui.start_search_immediate},
                    },
                  }
                }
              }
            },
            {
              type = "flow",
              direction = "horizontal",
              children = {
                {
                  type = "flow",
                  direction = "vertical",
                  style_mods = {padding = 12, right_padding = 6},
                  children = {
                    {
                      type = "choose-elem-button",
                      style = "slot_button_in_shallow_frame",
                      elem_type = "signal",
                      mouse_button_filter = {"left"},
                      ref = {"item_select"},
                      style_mods = {
                        width = 84,
                        height = 84,
                      },
                      handler = {[defines.events.on_gui_elem_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = true,
                      caption = {"search-gui.all-qualities"},
                      visible = script.feature_flags.quality,
                      ref = {"all_qualities"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = true,
                      caption = {"search-gui.all-surfaces"},
                      visible = storage.multiple_surfaces,
                      ref = {"all_surfaces"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "line",
                      visible = script.feature_flags.quality or storage.multiple_surfaces,
                    },
                    {
                      type = "checkbox",
                      state = true,
                      caption = {"search-gui.consumers-name"},
                      tooltip = {"search-gui.consumers-tooltip", "[entity=assembling-machine-2][entity=chemical-plant][entity=steel-furnace][entity=burner-mining-drill][entity=boiler][entity=gun-turret]"},
                      ref = {"include_consumers"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = true,
                      caption = {"search-gui.producers-name"},
                      tooltip = {"search-gui.producers-tooltip", "[entity=assembling-machine-2][entity=chemical-plant][entity=steel-furnace][entity=electric-mining-drill][entity=pumpjack]"},
                      ref = {"include_machines"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.storage-name"},
                      tooltip = {"search-gui.storage-tooltip", "[entity=steel-chest][entity=storage-chest][entity=storage-tank][entity=car][entity=spidertron][entity=cargo-wagon][entity=roboport]"},
                      ref = {"include_inventories"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.logistics-name"},
                      tooltip = {"search-gui.logistics-tooltip", "[entity=fast-transport-belt][entity=fast-underground-belt][entity=fast-splitter][entity=pipe][entity=fast-inserter][entity=logistic-robot]"},
                      ref = {"include_logistics"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.modules-name"},
                      tooltip = {"search-gui.modules-tooltip", "[entity=assembling-machine-2][entity=steel-furnace][entity=electric-mining-drill][entity=beacon][entity=lab][entity=rocket-silo]"},
                      ref = {"include_modules"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.entities-name"},
                      tooltip = {"search-gui.entities-tooltip"},
                      ref = {"include_entities"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.ground-items-name"},
                      tooltip = {"search-gui.ground-items-tooltip"},
                      ref = {"include_ground_items"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.requesters-name"},
                      tooltip = {"search-gui.requesters-tooltip", "[entity=requester-chest][entity=buffer-chest]"},
                      ref = {"include_requesters"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.signals-name"},
                      tooltip = {"search-gui.signals-tooltip"},
                      ref = {"include_signals"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.map-tags-name"},
                      tooltip = {"search-gui.map-tags-tooltip"},
                      ref = {"include_map_tags"},
                      handler = {[defines.events.on_gui_checked_state_changed] = SearchGui.start_search}
                    },
                    --[[{
                      type = "sprite-button",
                      style = "slot_sized_button",
                      sprite = "utility/search_icon",
                      mouse_button_filter = {"left"},
                      ref = {"search"},
                      actions = {
                        on_click = {gui = "search", action = "search"}
                      }
                    },]]
                  },
                },
                {
                  type = "scroll-pane",
                  style = "naked_scroll_pane",
                  horizontal_scroll_policy = "never",
                  vertical_scroll_policy = "auto-and-reserve-space",
                  style_mods = {top_padding = 12, bottom_padding = 12, left_padding = 6},
                  children = {
                    {
                      type = "flow",
                      direction = "vertical",
                      children = {
                        {
                          type = "flow",
                          direction = "vertical",
                          children = {
                            {
                              type = "label",
                              ref = { "searching_label" },
                              visible = false,
                              caption = {"search-gui.searching"},
                              tooltip = {"search-gui.searching-tooltip", {"", "[font=default-semibold]", {"mod-setting-name.fs-non-blocking-search"}, "[/font]"}}
                            },
                            {
                              type = "progressbar",
                              ref = { "search_progressbar" },
                              visible = false,
                              value = 0
                            }
                          }
                        },
                        {
                          type = "flow",
                          ref = {"result_flow"},
                          direction = "vertical",
                          children = {
                            {
                              type = "label",
                              caption = {"search-gui.explanation"},
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
          }
        },
      }
    }
  })
  ---@cast refs SearchGuiRefs
  refs.frame.force_auto_center()
  local player_data = {refs = refs, sort_results_by = "name"}
  storage.players[player.index] = player_data
  return player_data
end

---@param player LuaPlayer
---@param player_data PlayerData
function SearchGui.open(player, player_data)
  if not player_data or not player_data.refs.frame.valid then
    player_data = SearchGui.build(player)
  end
  local refs = player_data.refs
  if not player_data.pinned then
    player.opened = refs.frame
  end
  refs.frame.visible = true
  refs.frame.bring_to_front()
  player.set_shortcut_toggled("search-factory", true)
end

---@param player LuaPlayer
---@param player_data PlayerData
function SearchGui.destroy(player, player_data)
  local main_frame = player_data.refs.frame
  if main_frame then
    main_frame.destroy()
  end
  storage.players[player.index] = nil
  SearchGui.after_close(player)
end

---@param player LuaPlayer
---@param player_data PlayerData
function SearchGui.close(player, player_data)
  if player_data.ignore_close then
    -- Set when the pin button is pressed just before changing player.opened
    player_data.ignore_close = false
  else
    local refs = player_data.refs
    refs.frame.visible = false
    if player.opened == refs.frame then
      player.opened = nil
    end
    --SearchGui.destroy(player, player_data)
    SearchGui.after_close(player)
  end
end

---@param player LuaPlayer
---@param player_data PlayerData
function SearchGui.toggle_pin(player, player_data)
  player_data.pinned = not player_data.pinned
  player_data.refs.pin_button.toggled = player_data.pinned
  if player_data.pinned then
    player_data.ignore_close = true
    player.opened = nil
    player_data.refs.close_button.tooltip = {"gui.close"}
  else
    player.opened = player_data.refs.frame
    player_data.refs.frame.force_auto_center()
    player_data.refs.close_button.tooltip = {"gui.close-instruction"}
  end
end

---@param player LuaPlayer
function SearchGui.after_close(player)
  player.set_shortcut_toggled("search-factory", false)
  if player.mod_settings["fs-clear-highlights-with-gui"].value then
    ResultLocation.clear_markers(player)
  end
end

---@param player LuaPlayer
---@param player_data PlayerData
function SearchGui.toggle(player, player_data)
  if player_data and player_data.refs.frame.valid and player_data.refs.frame.visible then
    SearchGui.close(player, player_data)
  else
    SearchGui.open(player, player_data)
  end
end

---@param player LuaPlayer
---@param player_data PlayerData
---@param element LuaGuiElement sprite-button
---@param mouse_button defines.mouse_button_type
function SearchGui.open_location_on_map(player, player_data, element, mouse_button)
  local tags = element.tags  --[[@as ResultLocationData]]
  if mouse_button == defines.mouse_button_type.left then
    ResultLocation.open(player, tags)
  elseif mouse_button == defines.mouse_button_type.right then
    ResultLocation.highlight(player, tags)
  end

  local highlighted_button = player_data.refs.highlighted_button
  if highlighted_button and highlighted_button.valid then
    highlighted_button.style = "slot_button"
  end
  element.style = "yellow_slot_button"
  player_data.refs.highlighted_button = element
end

---@param refs SearchGuiRefs
---@return SearchGuiState
local function generate_state(refs)
  return {
    all_qualities = refs.all_qualities.visible and refs.all_qualities.state or false,
    all_surfaces = refs.all_surfaces.visible and refs.all_surfaces.state or false,
    consumers = refs.include_consumers.state,
    producers = refs.include_machines.state,
    storage = refs.include_inventories.state,
    logistics = refs.include_logistics.state,
    modules = refs.include_modules.state,
    requesters = refs.include_requesters.state,
    ground_items = refs.include_ground_items.state,
    entities = refs.include_entities.state,
    signals = refs.include_signals.state,
    map_tags = refs.include_map_tags.state,
  }
end

---@param state SearchGuiState
---@return boolean
local function is_valid_state(state)
  local are_any_checked = false
  for name, checked in pairs(state) do
    if name ~= "all_qualities" and name ~= "all_surfaces" then
      are_any_checked = are_any_checked or checked
    end
  end
  return are_any_checked
end

---@param player LuaPlayer
---@param player_data PlayerData
---@param immediate boolean?
function SearchGui.start_search(player, player_data, _, _, immediate)
  local refs = player_data.refs
  local elem_button = refs.item_select
  local item = elem_button.elem_value --[[@as SignalID]]
  if item then
    local force = player.force --[[@as LuaForce]]
    local state = generate_state(refs)
    local state_valid = is_valid_state(state)
    if state_valid then
      if state.all_qualities then
        item.quality = "any"
      end
      refs.sort_results_dropdown.enabled = false
      search_started = Search.find_machines(item, force, state, player, immediate)
      refs.subheader_title.caption = get_signal_name(item) or ""
      if search_started then
        if storage.current_searches[player.index].blocking then
          SearchGui.build_loading_results(refs, nil)
        else
          SearchGui.build_loading_results(refs, 0)
        end
      else
        SearchGui.build_results({}, {}, refs.result_flow)
      end
    else
      SearchGui.build_invalid_state(refs.result_flow)
      storage.current_searches[player.index] = nil
    end
  else
    SearchGui.clear_results(refs.result_flow)
    refs.subheader_title.caption = ""
    ResultLocation.clear_markers(player)
    storage.current_searches[player.index] = nil
  end
end

---@param player LuaPlayer
---@param player_data PlayerData
function SearchGui.start_search_immediate(player, player_data)
  SearchGui.start_search(player, player_data, nil, nil, true)
end

---@param player LuaPlayer
---@param player_data PlayerData
function SearchGui.sort_results_dropdown_changed(player, player_data)
  local dropdown = player_data.refs.sort_results_dropdown
  local sort_results_by_options = {"count", "distance", "name"}
  player_data.sort_results_by = sort_results_by_options[dropdown.selected_index]
end

gui.add_handlers(SearchGui,
  function(event, handler)
    local player = game.get_player(event.player_index)  ---@cast player -?
    local player_data = storage.players[event.player_index]
    local element = event.element
    local mouse_button = event.button
    handler(player, player_data, element, mouse_button)
  end
)

--[[event.on_gui_closed(  -- TODO covered by frame element handler?
  function(event)
    if event.element and event.element.name == "fs_frame" then
      local player = game.get_player(event.player_index)
      SearchGui.close(player, storage.players[event.player_index])
    end
  end
)]]

return SearchGui