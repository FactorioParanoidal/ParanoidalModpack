local gui = require("__FactorySearch__.scripts.flib-gui")

local Gui = {}

local function toggle_fab(elem, sprite, state)
  if state then
    elem.style = "fs_flib_selected_frame_action_button"
    elem.sprite = sprite .. "_black"
  else
    elem.style = "frame_action_button"
    elem.sprite = sprite .. "_white"
  end
end

local function get_signal_name(signal)
  if signal.name then
    if signal.type == "item" then
      return game.item_prototypes[signal.name].localised_name
    elseif signal.type == "fluid" then
      return game.fluid_prototypes[signal.name].localised_name
    elseif signal.type == "virtual" then
      return game.virtual_signal_prototypes[signal.name].localised_name
    end
  end
end


function Gui.build_surface_results(surface_name, surface_data)
  local gui_elements = {}
  for entity_name, entity_surface_data in pairs(surface_data) do
    for _, group in pairs(entity_surface_data) do
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
      local sprite = "item/" .. entity_name
      if not game.is_valid_sprite_path(sprite) then
        sprite = "fluid/" .. entity_name
        if not game.is_valid_sprite_path(sprite) then
          sprite = "entity/" .. entity_name
          if not game.is_valid_sprite_path(sprite) then
            sprite = "recipe/" .. entity_name
            if not game.is_valid_sprite_path(sprite) then
              sprite = "virtual-signal/" .. entity_name
              if not game.is_valid_sprite_path(sprite) then
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
          tooltip = { "", "[font=default-bold]", group.localised_name, "[/font]", distance_info, extra_info, "\n", {"search-gui.result-tooltip"} },
          style = "slot_button",
          number = group.resource_count or group.count,
          tags = { position = group.avg_position, surface = surface_name, selection_boxes = group.selection_boxes },
          actions = { on_click = { gui = "search", action = "open_location_in_map" } },
        }
      )
    end
  end
  return gui_elements
end

function Gui.build_surface_name(include_surface_name, surface_name)
  if include_surface_name then
    if surface_name == "nauvis" then
      -- Space Exploration capitilises all other planet names, so do Nauvis for consistency
      surface_name = "Nauvis"
    end
    return  {
      type = "label",
      caption = surface_name,
      style = "bold_label",
      style_mods = { font = "default-large-bold" }
    }
  else
    return {}
  end

end

function Gui.build_results(data, frame, check_result_found, include_surface_name)
  -- check_result_found defaults to true

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
      surface_contains_results = surface_contains_results or not not next(category_data)
    end
    result_found = result_found or surface_contains_results
    if not surface_contains_results then
      goto continue
    end
    gui.build(frame, {
      Gui.build_surface_name(include_surface_name, surface_name),
      {
        type = "frame",
        direction = "vertical",
        style = "slot_button_deep_frame",
        children = {
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.consumers)
          },
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.producers)
          },
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.storage)
          },
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.logistics)
          },          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.modules)
          },
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.entities)
          },
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.ground_items)
          },
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.requesters)
          },
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.signals)
          },
          {
            type = "table",
            column_count = 10,
            style = "logistics_slot_table",
            children = Gui.build_surface_results(surface_name, surface_data.map_tags)
          },
        }
      }
    })
    ::continue::
  end

  if not result_found and check_result_found ~= false then
    frame.clear()
    gui.build(frame, {
      {
        type = "label",
        style_mods = { font_color = {1, 0, 0, 1} },
        caption = {"search-gui.no-results"}
      }
    })
  end
end

function Gui.clear_results(frame)
  frame.clear()
  gui.build(frame, {
    {
      type = "label",
      caption = {"search-gui.explanation"},
    }
  })
end

function Gui.build_invalid_state(frame)
  frame.clear()
  gui.build(frame, {
    {
      type = "label",
      style_mods = { font_color = {1, 0, 0, 1} },
      caption = {"search-gui.incorrect-config"}
    }
  })
end


function Gui.add_loading_results(frame)
  gui.add(frame,
    {
      type = "label",
      caption = {"search-gui.searching"},
      tooltip = {"search-gui.searching-tooltip", {"", "[font=default-semibold]", {"mod-setting-name.fs-non-blocking-search"}, "[/font]"}}
    }
  )
end

function Gui.build_loading_results(frame)
  frame.clear()
  Gui.add_loading_results(frame)
end

function Gui.build(player)
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      name = "fs_frame",
      direction = "vertical",
      visible = true,
      ref = { "frame" },
      style_mods = { maximal_height = 800 },
      actions = {
        on_closed = { gui = "search", action = "close" },
      },
      children = {
        {
          type = "flow",
          style = "fs_flib_titlebar_flow",
          ref = { "titlebar_flow" },
          actions = {
            on_click = { gui = "search", action = "recenter" },  -- TODO What is this?
          },
          children = {
            {
              type = "label",
              style = "frame_title",
              caption = { "mod-name.FactorySearch" },
              ignored_by_interaction = true,
            },
            { type = "empty-widget", style = "fs_flib_titlebar_drag_handle", ignored_by_interaction = true },
            {
              type = "sprite-button",
              style = "frame_action_button",
              sprite = "fs_flib_pin_white",
              hovered_sprite = "fs_flib_pin_black",
              clicked_sprite = "fs_flib_pin_black",
              mouse_button_filter = { "left" },
              tooltip = { "search-gui.keep-open" },
              ref = { "pin_button" },
              actions = {
                on_click = { gui = "search", action = "toggle_pin"},
              }
            },
            {
              type = "sprite-button",
              style = "close_button",
              sprite = "utility/close_white",
              hovered_sprite = "utility/close_black",
              clicked_sprite = "utility/close_black",
              mouse_button_filter = { "left" },
              tooltip = { "gui.close-instruction" },
              ref = { "close_button" },
              actions = {
                on_click = { gui = "search", action = "close" },
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
                  style_mods = { vertical_align = "center", horizontally_stretchable = true, horizontal_spacing = 12 },
                  children = {
                    {
                      type = "label",
                      style = "subheader_caption_label",
                      ref = { "subheader_title" },
                    },
                    {
                      type = "empty-widget",
                      style_mods = { horizontally_stretchable = true, horizontally_squashable = true }
                    },
                    {
                      type = "checkbox",
                      state = true,
                      caption = { "search-gui.all-surfaces" },
                      visible = global.multiple_surfaces,
                      ref = { "all_surfaces" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "sprite-button",
                      style = "tool_button",
                      sprite = "utility/refresh",
                      tooltip = { "gui.refresh" },
                      mouse_button_filter = { "left" },
                      actions = {
                        on_click = { gui = "search", action = "refresh" },
                      },
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
                  style_mods = { padding = 12, right_padding = 6 },
                  children = {
                    {
                      type = "choose-elem-button",
                      style = "slot_button_in_shallow_frame",
                      elem_type = "signal",
                      mouse_button_filter = {"left"},
                      ref = { "item_select" },
                      style_mods = {
                        width = 84,
                        height = 84,
                      },
                      actions = {
                        on_elem_changed = { gui = "search", action = "item_selected" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = true,
                      caption = {"search-gui.consumers-name"},
                      tooltip = {"search-gui.consumers-tooltip", "[entity=assembling-machine-2][entity=chemical-plant][entity=steel-furnace][entity=burner-mining-drill][entity=boiler][entity=gun-turret]"},
                      ref = { "include_consumers" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = true,
                      caption = {"search-gui.producers-name"},
                      tooltip = {"search-gui.producers-tooltip", "[entity=assembling-machine-2][entity=chemical-plant][entity=steel-furnace][entity=electric-mining-drill][entity=pumpjack]"},
                      ref = { "include_machines" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.storage-name"},
                      tooltip = {"search-gui.storage-tooltip", "[entity=steel-chest][entity=logistic-chest-storage][entity=storage-tank][entity=car][entity=spidertron][entity=cargo-wagon][entity=roboport]"},
                      ref = { "include_inventories" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.logistics-name"},
                      tooltip = {"search-gui.logistics-tooltip", "[entity=fast-transport-belt][entity=fast-underground-belt][entity=fast-splitter][entity=pipe][entity=fast-inserter][entity=logistic-robot]"},
                      ref = { "include_logistics" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.modules-name"},
                      tooltip = {"search-gui.modules-tooltip", "[entity=assembling-machine-2][entity=steel-furnace][entity=electric-mining-drill][entity=beacon][entity=lab][entity=rocket-silo]"},
                      ref = { "include_modules" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.entities-name"},
                      tooltip = {"search-gui.entities-tooltip"},
                      ref = { "include_entities" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.ground-items-name"},
                      tooltip = {"search-gui.ground-items-tooltip"},
                      ref = { "include_ground_items" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.requesters-name"},
                      tooltip = {"search-gui.requesters-tooltip", "[entity=logistic-chest-requester][entity=logistic-chest-buffer]"},
                      ref = { "include_requesters" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.signals-name"},
                      tooltip = {"search-gui.signals-tooltip", "[entity=decider-combinator][entity=arithmetic-combinator][entity=constant-combinator][entity=roboport][entity=train-stop][entity=rail-signal][entity=rail-chain-signal][entity=accumulator][entity=stone-wall]"},
                      ref = { "include_signals" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    {
                      type = "checkbox",
                      state = false,
                      caption = {"search-gui.map-tags-name"},
                      tooltip = {"search-gui.map-tags-tooltip"},
                      ref = { "include_map_tags" },
                      actions = {
                        on_checked_state_changed = { gui = "search", action = "checkbox_toggled" }
                      }
                    },
                    --[[{
                      type = "sprite-button",
                      style = "slot_sized_button",
                      sprite = "utility/search_icon",
                      mouse_button_filter = {"left"},
                      ref = { "search" },
                      actions = {
                        on_click = { gui = "search", action = "search" }
                      }
                    },]]
                  },
                },
                {
                  type = "scroll-pane",
                  style = "naked_scroll_pane",
                  horizontal_scroll_policy = "never",
                  vertical_scroll_policy = "auto-and-reserve-space",
                  style_mods = { top_padding = 12, bottom_padding = 12, left_padding = 6 },
                  children = {
                    {
                      type = "flow",
                      ref = { "result_flow" },
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
            },
          }
        },
      }
    }
  })

  local player_data = {}
  refs.titlebar_flow.drag_target = refs.frame
  refs.frame.force_auto_center()
  player_data.refs = refs
  global.players[player.index] = player_data
  return player_data
end

function Gui.open(player, player_data)
  if not player_data or not player_data.refs.frame.valid then
    player_data = Gui.build(player)
  end
  local refs = player_data.refs
  if not player_data.pinned then
    player.opened = refs.frame
  end
  refs.frame.visible = true
  refs.frame.bring_to_front()
  player.set_shortcut_toggled("search-factory", true)
end

function Gui.destroy(player, player_data)
  local main_frame = player_data.refs.frame
  if main_frame then
    main_frame.destroy()
  end
  global.players[player.index] = nil
  Gui.after_close(player)
end

function Gui.close(player, player_data)
  if player_data.ignore_close then
    -- Set when the pin button is pressed just before changing player.opened
    player_data.ignore_close = false
  else
    local refs = player_data.refs
    refs.frame.visible = false
    if player.opened == refs.frame then
      player.opened = nil
    end
    --Gui.destroy(player, player_data)
    Gui.after_close(player)
  end
end

function Gui.after_close(player)
  player.set_shortcut_toggled("search-factory", false)
  if player.mod_settings["fs-clear-highlights-with-gui"].value then
    ResultLocation.clear_markers(player)
  end
end

function Gui.toggle(player, player_data)
  if player_data and player_data.refs.frame.valid and player_data.refs.frame.visible then
    Gui.close(player, player_data)
  else
    Gui.open(player, player_data)
  end
end

local function generate_state(refs)
  return {
    consumers = refs.include_consumers.state,
    producers = refs.include_machines.state,
    storage = refs.include_inventories.state,
    logistics = refs.include_logistics.state,
    modules = refs.include_modules.state,
    requesters = refs.include_requesters.state,
    ground_items = refs.include_ground_items.state,
    entities = refs.include_entities.state,
    signals = refs.include_signals.state,
    map_tags = refs.include_map_tags.state
  }
end

local function is_valid_state(state)  -- TODO rename
  local some_checked = false
  for _, checked in pairs(state) do
    some_checked = some_checked or checked
  end
  return some_checked
end

function Gui.start_search(player, player_data)
  local refs = player_data.refs
  local elem_button = refs.item_select
  local item = elem_button.elem_value
  if item then
    local force = player.force
    local state = generate_state(refs)
    local state_valid = is_valid_state(state)
    local data
    if state_valid then
      data = Search.find_machines(item, force, state, player, not refs.all_surfaces.state)
      refs.subheader_title.caption = get_signal_name(item) or ""
      if data.non_blocking_search then
        Gui.build_loading_results(refs.result_flow)
      else
        Gui.build_results(data, refs.result_flow)
      end
    else
      Gui.build_invalid_state(refs.result_flow)
      global.current_searches[player.index] = nil
    end
  else
    Gui.clear_results(refs.result_flow)
    refs.subheader_title.caption = ""
    ResultLocation.clear_markers(player)
    global.current_searches[player.index] = nil
  end
end

gui.hook_events(
  function(event)
    local action = gui.read_action(event)
    if action then
      local player = game.get_player(event.player_index)
      local player_data = global.players[event.player_index]

      local msg = action.action
      if msg == "item_selected" then  -- on_gui_elem_changed
        Gui.start_search(player, player_data)
      elseif msg == "checkbox_toggled" then  -- on_gui_checked_state_changed
        Gui.start_search(player, player_data)
      elseif msg == "close" then  -- on_gui_click
        Gui.close(player, player_data)
        --Gui.destroy(player, player_data)
      elseif msg == "toggle_pin" then
        player_data.pinned = not player_data.pinned
        toggle_fab(player_data.refs.pin_button, "fs_flib_pin", player_data.pinned)
        if player_data.pinned then
          player_data.ignore_close = true
          player.opened = nil
          player_data.refs.close_button.tooltip = { "gui.close" }
        else
          player.opened = player_data.refs.frame
          player_data.refs.frame.force_auto_center()
          player_data.refs.close_button.tooltip = { "gui.close-instruction" }
        end
      elseif msg == "open_location_in_map" then
        local button = event.element
        local tags = button.tags.FactorySearch
        local mouse_button = event.button
        if mouse_button == defines.mouse_button_type.left then
          ResultLocation.open(player, tags)
        elseif mouse_button == defines.mouse_button_type.right then
          ResultLocation.highlight(player, tags)
        end

        local highlighted_button = player_data.refs.highlighted_button
        if highlighted_button and highlighted_button.valid then
          highlighted_button.style = "slot_button"
        end
        button.style = "yellow_slot_button"
        player_data.refs.highlighted_button = button
      elseif msg == "refresh" then
        Gui.start_search(player, player_data)
      elseif msg == "checkbox_toggled" then
        Gui.start_search(player, player_data)
      end
    end
  end
)

event.on_gui_closed(
  function(event)
    if event.element and event.element.name == "fs_frame" then
      local player = game.get_player(event.player_index)
      Gui.close(player, global.players[event.player_index])
    end
  end
)

return Gui