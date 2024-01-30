local gui = require("__flib__.gui")
local table = require("__flib__.table")

local database = require("scripts.database")
local formatter = require("scripts.formatter")

local table_comp = {}

function table_comp.build(parent, index, component, variables)
  local has_label = (component.label or component.source) and true or false
  return gui.build(parent, {
    {
      type = "flow",
      style_mods = not has_label and { top_margin = 4 } or nil,
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
        visible = has_label,
        { type = "label", style = "rb_list_box_label", ref = { "label" } },
        { type = "empty-widget", style = "flib_horizontal_pusher" },
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
        action = {
          on_click = { gui = "info", id = variables.gui_id, action = "set_as_active" },
        },
        ref = { "deep_frame" },
        {
          type = "table",
          style = "rb_info_table",
          column_count = 2,
          ref = { "table" },
          -- Dummy elements so the first row doesn't get used
          { type = "empty-widget" },
          { type = "empty-widget" },
        },
      },
    },
  })
end

function table_comp.default_state(settings)
  return { collapsed = settings.default_state == "collapsed" }
end

function table_comp.update(component, refs, object_data, player_data, settings, variables)
  local tbl = refs.table
  local children = tbl.children

  local gui_translations = player_data.translations.gui

  local search_query = variables.search_query

  local i = 2
  local is_shown = settings.default_state ~= "hidden"
  local row_settings = settings.rows
  local source_tbl = is_shown and (component.source and object_data[component.source] or component.rows) or {}
  for _, row in ipairs(source_tbl) do
    local row_name = row.label or row.source
    local value = row.value or object_data[row.source]
    if value and (not row_settings or row_settings[row_name]) then
      local caption = gui_translations[row_name] or row_name
      if string.find(string.lower(caption), search_query) then
        -- Label
        i = i + 1
        local label_label = children[i]
        if not label_label or not label_label.valid then
          label_label = tbl.add({
            type = "label",
            style = "rb_table_label",
            index = i,
          })
        end
        local tooltip = row.label_tooltip
        if tooltip then
          caption = caption .. " [img=info]"
          tooltip = gui_translations[row.label_tooltip]
        else
          tooltip = ""
        end
        label_label.caption = caption
        label_label.tooltip = tooltip

        -- Value
        if row.type == "plain" then
          local fmt = row.formatter
          if fmt then
            value = formatter[fmt](value, gui_translations)
          end
          i = i + 1
          local value_label = children[i]
          if not value_label or not value_label.valid or value_label.type ~= "label" then
            if value_label and value_label.valid then
              value_label.destroy()
            end
            value_label = tbl.add({ type = "label", index = i })
          end
          value_label.caption = value
        elseif row.type == "goto" then
          i = i + 1
          local button = children[i]
          if not button or not button.valid or button.type ~= "button" then
            if button and button.valid then
              button.destroy()
            end
            button = tbl.add({
              type = "button",
              style = "rb_table_button",
              mouse_button_filter = { "left", "middle" },
              index = i,
            })
          end
          local source_data = database[value.class][value.name]
          local options = table.shallow_copy(row.options or {})
          options.label_only = true
          options.amount_ident = value.amount_ident
          options.blueprint_result = value.class == "entity" and source_data.blueprintable and { name = value.name }
            or nil
          local info = formatter(source_data, player_data, options)
          if info then
            button.caption = info.caption
            button.tooltip = info.tooltip
            gui.set_action(button, "on_click", { gui = "info", id = variables.gui_id, action = "navigate_to" })
            gui.update_tags(
              button,
              { context = { class = value.class, name = value.name }, blueprint_result = options.blueprint_result }
            )
          else
            -- Don't actually show this row
            -- This is an ugly way to do it, but whatever
            button.destroy()
            label_label.destroy()
            i = i - 2
          end
        elseif row.type == "tech_level_selector" then
          i = i + 1
          local flow = children[i]
          if not flow or not flow.valid or flow.type ~= "flow" then
            if flow and flow.valid then
              flow.destroy()
            end
            flow = gui.build(tbl, {
              {
                type = "flow",
                style_mods = { vertical_align = "center" },
                index = i,
                ref = { "flow" },
                {
                  type = "sprite-button",
                  style = "mini_button_aligned_to_text_vertically_when_centered",
                  sprite = "rb_minus_black",
                  mouse_button_filter = { "left" },
                  actions = {
                    on_click = { gui = "info", id = variables.gui_id, action = "change_tech_level", delta = -1 },
                  },
                },
                { type = "label", name = "tech_level_label" },
                {
                  type = "sprite-button",
                  style = "mini_button_aligned_to_text_vertically_when_centered",
                  sprite = "rb_plus_black",
                  mouse_button_filter = { "left" },
                  actions = {
                    on_click = { gui = "info", id = variables.gui_id, action = "change_tech_level", delta = 1 },
                  },
                },
              },
            }).flow
          end
          flow.tech_level_label.caption = formatter.number(variables.selected_tech_level)
        elseif row.type == "tech_level_research_unit_count" then
          i = i + 1
          local value_label = children[i]
          if not value_label or value_label.type ~= "label" then
            if value_label then
              value_label.destroy()
            end
            value_label = tbl.add({ type = "label", index = i })
          end
          local tech_level = variables.selected_tech_level
          value_label.caption =
            formatter[row.formatter](game.evaluate_expression(value, { L = tech_level, l = tech_level }))
        end
      end
    end
  end
  for j = i + 1, #children do
    children[j].destroy()
  end

  if i > 3 then
    refs.root.visible = true

    local label_source = component.source or component.label
    if label_source then
      if component.hide_count then
        refs.label.caption = gui_translations[label_source] or label_source
      else
        refs.label.caption = formatter.expand_string(
          gui_translations.list_box_label,
          gui_translations[label_source] or label_source,
          i / 2 - 1
        )
      end
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
      refs.deep_frame.style.maximal_height = 1
      refs.expand_collapse_button.sprite = "rb_collapsed"
      refs.expand_collapse_button.tooltip = { "gui.rb-expand" }
    else
      refs.deep_frame.style.maximal_height = 0
      refs.expand_collapse_button.sprite = "rb_expanded"
      refs.expand_collapse_button.tooltip = { "gui.rb-collapse" }
    end
  else
    refs.root.visible = false
  end

  return i > 3
end

return table_comp
