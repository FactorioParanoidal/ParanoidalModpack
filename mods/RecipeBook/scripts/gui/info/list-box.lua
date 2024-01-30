local gui = require("__flib__.gui")

local constants = require("constants")
local database = require("scripts.database")
local formatter = require("scripts.formatter")

local list_box = {}

function list_box.build(parent, index, component, variables)
  return gui.build(parent, {
    {
      type = "flow",
      direction = "vertical",
      index = index,
      ref = { "root" },
      action = {
        on_click = { gui = "info", id = variables.gui_id, action = "set_as_active" },
      },
      {
        type = "flow",
        style_mods = { vertical_align = "center" },
        action = {
          on_click = { gui = "info", id = variables.gui_id, action = "set_as_active" },
        },
        { type = "label", style = "rb_list_box_label", ref = { "label" } },
        { type = "empty-widget", style = "flib_horizontal_pusher" },
        {
          type = "sprite-button",
          style = "mini_button_aligned_to_text_vertically_when_centered",
          tooltip = { "gui.rb-open-list-in-new-window" },
          sprite = "rb_export_black",
          ref = { "open_list_button" },
          -- NOTE: Actions are set in the update function
        },
        {
          type = "sprite-button",
          style = "mini_button_aligned_to_text_vertically_when_centered",
          ref = { "expand_collapse_button" },
          -- NOTE: Sprite, tooltip, and action are set in the update function
        },
      },
      {
        type = "frame",
        style = "deep_frame_in_shallow_frame",
        {
          type = "scroll-pane",
          style = "rb_list_box_scroll_pane",
          ref = { "scroll_pane" },
        },
      },
    },
  })
end

function list_box.default_state(settings)
  return { collapsed = settings.default_state == "collapsed" }
end

function list_box.update(component, refs, context_data, player_data, settings, variables)
  -- Scroll pane
  local scroll = refs.scroll_pane
  local children = scroll.children

  -- Settings and variables
  local always_show = component.always_show
  local context = variables.context
  local query = variables.search_query

  local search_type = player_data.settings.general.search.search_type

  -- Add items
  local i = 0 -- The "added" index
  local iterator = component.use_pairs and pairs or ipairs
  local objects = settings.default_state ~= "hidden" and context_data[component.source] or {}
  for _, obj in iterator(objects) do
    local translation = player_data.translations[obj.class][obj.name]
    -- Match against search string
    local matched
    if search_type == "both" then
      matched = string.find(string.lower(obj.name), query) or string.find(string.lower(translation), query)
    elseif search_type == "internal" then
      matched = string.find(string.lower(obj.name), query)
    elseif search_type == "localised" then
      matched = string.find(string.lower(translation), query)
    end

    if matched then
      local obj_data = database[obj.class][obj.name]
      local blueprint_result
      if context.class == "recipe" and component.source == "made_in" and obj_data.blueprintable then
        blueprint_result = { name = obj.name, recipe = context.name }
      elseif context.class == "entity" and component.source == "can_craft" and context_data.blueprintable then
        blueprint_result = { name = context.name, recipe = obj.name }
      end
      local info = formatter(obj_data, player_data, {
        always_show = always_show,
        amount_ident = obj.amount_ident,
        blueprint_result = blueprint_result,
        rocket_parts_required = obj_data.rocket_parts_required,
      })

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
            { blueprint_result = blueprint_result, context = { class = obj.class, name = obj.name } }
          )
        else
          gui.add(scroll, {
            type = "button",
            style = style,
            caption = info.caption,
            tooltip = info.tooltip,
            enabled = info.num_interactions > 0,
            mouse_button_filter = { "left", "middle" },
            tags = {
              blueprint_result = blueprint_result,
              context = { class = obj.class, name = obj.name },
            },
            actions = {
              on_click = { gui = "info", id = variables.gui_id, action = "navigate_to" },
            },
          })
        end
      end
    end
  end
  -- Destroy extraneous items
  for j = i + 1, #children do
    children[j].destroy()
  end

  -- Set listbox properties
  if i > 0 then
    refs.root.visible = true
    local translations = player_data.translations.gui

    -- Update label caption
    refs.label.caption = formatter.expand_string(
      translations.list_box_label,
      translations[component.source] or component.source,
      i
    )

    -- Update open list button
    if i > 1 then
      refs.open_list_button.visible = true
      gui.set_action(refs.open_list_button, "on_click", {
        gui = "info",
        id = variables.gui_id,
        action = "open_list",
        context = variables.context,
        source = component.source,
      })
    else
      refs.open_list_button.visible = false
    end

    -- Update expand/collapse button and height
    gui.set_action(refs.expand_collapse_button, "on_click", {
      gui = "info",
      id = variables.gui_id,
      action = "toggle_collapsed",
      context = variables.context,
      component_index = variables.component_index,
    })
    if variables.component_state.collapsed then
      refs.expand_collapse_button.sprite = "rb_collapsed"
      scroll.style.maximal_height = 1
      refs.expand_collapse_button.tooltip = { "gui.rb-expand" }
    else
      refs.expand_collapse_button.sprite = "rb_expanded"
      scroll.style.maximal_height = (settings.max_rows or constants.default_max_rows) * 28
      refs.expand_collapse_button.tooltip = { "gui.rb-collapse" }
    end
  else
    refs.root.visible = false
  end

  return i > 0
end

return list_box
