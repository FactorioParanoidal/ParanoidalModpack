local gui = require("__flib__.gui")
local table = require("__flib__.table")

local constants = require("constants")

local database = require("scripts.database")
local formatter = require("scripts.formatter")
local player_data = require("scripts.player-data")
local util = require("scripts.util")

local components = {
  list_box = require("scripts.gui.info.list-box"),
  table = require("scripts.gui.info.table"),
}

local function tool_button(sprite, tooltip, ref, action, style_mods)
  return {
    type = "sprite-button",
    style = "tool_button",
    style_mods = style_mods,
    sprite = sprite,
    tooltip = tooltip,
    mouse_button_filter = { "left" },
    ref = ref,
    actions = {
      on_click = action,
    },
  }
end

--- @class InfoGui
local Gui = {}

local actions = require("scripts.gui.info.actions")

function Gui:dispatch(msg, e)
  -- Mark this GUI as the active one whenever we do anything
  self.player_table.guis.info._active_id = self.id

  if type(msg) == "string" then
    actions[msg](self, msg, e)
  else
    actions[msg.action](self, msg, e)
  end
end

function Gui:destroy()
  self.refs.window.destroy()
  self.player_table.guis.info[self.id] = nil
  if self.state.docked and not self.state.search_info then
    self.player_table.guis.info._relative_id = nil
  end
end

function Gui:get_context()
  local history = self.state.history
  return history[history._index]
end

function Gui:update_contents(options)
  options = options or {}
  local new_context = options.new_context
  local refresh = options.refresh

  local state = self.state
  local refs = self.refs

  -- HISTORY

  -- Add new history if needed
  local history = state.history
  if new_context then
    -- Remove all entries after this
    for i = history._index + 1, #history do
      history[i] = nil
    end
    -- Insert new entry
    local new_index = #history + 1
    history[new_index] = new_context
    history._index = new_index
    -- Limit the length
    local max_size = constants.session_history_size
    if new_index > max_size then
      history._index = max_size
      for _ = max_size + 1, new_index do
        table.remove(history, 1)
      end
    end
  end

  local context = new_context or history[history._index]
  if not refresh then
    player_data.update_global_history(self.player_table.global_history, context)
    local SearchGui = util.get_gui(self.player.index, "search")
    if SearchGui then
      SearchGui:dispatch("update_history")
    end
  end

  -- COMMON DATA

  local obj_data = database[context.class][context.name]

  local player_data = formatter.build_player_data(self.player, self.player_table)
  local gui_translations = player_data.translations.gui

  -- TECH LEVEL

  if not refresh and obj_data.research_unit_count_formula then
    state.selected_tech_level = player_data.force.technologies[context.name].level
  end

  -- TITLEBAR

  -- Nav buttons

  -- Generate tooltips
  local history_index = history._index
  local history_len = #history
  local entries = {}
  for i, history_context in ipairs(history) do
    local obj_data = database[history_context.class][history_context.name]
    local info = formatter(obj_data, player_data, { always_show = true, label_only = true })
    local caption = info.caption
    if not info.researched then
      caption = formatter.rich_text("color", "unresearched", caption)
    end
    entries[history_len - (i - 1)] = formatter.rich_text(
      "font",
      "default-semibold",
      formatter.rich_text("color", history_index == i and "green" or "invisible", ">")
    ) .. "   " .. caption
  end
  local entries = table.concat(entries, "\n")
  local base_tooltip = formatter.rich_text(
    "font",
    "default-bold",
    formatter.rich_text("color", "heading", gui_translations.session_history)
  ) .. "\n" .. entries

  -- Apply button properties
  local nav_backward_button = refs.titlebar.nav_backward_button
  if history._index == 1 then
    nav_backward_button.enabled = false
    nav_backward_button.sprite = "rb_nav_backward_disabled"
  else
    nav_backward_button.enabled = true
    nav_backward_button.sprite = "rb_nav_backward_white"
  end
  nav_backward_button.tooltip = base_tooltip
    .. formatter.control(gui_translations.click, gui_translations.go_backward)
    .. formatter.control(gui_translations.shift_click, gui_translations.go_to_the_back)

  local nav_forward_button = refs.titlebar.nav_forward_button
  if history._index == #history then
    nav_forward_button.enabled = false
    nav_forward_button.sprite = "rb_nav_forward_disabled"
  else
    nav_forward_button.enabled = true
    nav_forward_button.sprite = "rb_nav_forward_white"
  end
  nav_forward_button.tooltip = base_tooltip
    .. formatter.control(gui_translations.click, gui_translations.go_forward)
    .. formatter.control(gui_translations.shift_click, gui_translations.go_to_the_front)

  -- Label
  local label = refs.titlebar.label
  label.caption = gui_translations[context.class]

  -- Reset search when moving pages
  if not options.refresh and state.search_opened then
    state.search_opened = false
    local search_button = refs.titlebar.search_button
    local search_textfield = refs.titlebar.search_textfield
    search_button.sprite = "utility/search_white"
    search_button.style = "frame_action_button"
    search_textfield.visible = false

    if state.search_query ~= "" then
      -- Reset query
      search_textfield.text = ""
      state.search_query = ""
    end
  end

  -- HEADER

  -- List navigation
  -- List nav is kind of weird because it doesn't respect your settings, but making it respect the settings would be
  -- too much work
  local list_context = context.list
  if list_context then
    local source = list_context.context
    local source_data = database[source.class][source.name]
    local list = source_data[list_context.source]
    local list_len = #list
    local index = list_context.index

    local list_refs = refs.header.list_nav
    list_refs.flow.visible = true

    -- Labels
    local source_info = formatter(source_data, player_data, { always_show = true })
    local source_label = list_refs.source_label

    source_label.caption = formatter.rich_text("color", "heading", source_info.caption)
      .. "  -  "
      .. gui_translations[list_context.source]
    local position_label = list_refs.position_label
    position_label.caption = " (" .. index .. " / " .. list_len .. ")"

    -- Buttons
    for delta, button in pairs({ [-1] = list_refs.back_button, [1] = list_refs.forward_button }) do
      local new_index = index + delta
      if new_index < 1 then
        new_index = list_len
      elseif new_index > list_len then
        new_index = 1
      end
      local ident = list[new_index]
      gui.set_action(button, "on_click", {
        gui = "info",
        id = self.id,
        action = "navigate_to_plain",
        context = {
          class = ident.class,
          name = ident.name,
          list = {
            context = source,
            index = new_index,
            source = list_context.source,
          },
        },
      })
    end

    refs.header.line.visible = true
  else
    refs.header.list_nav.flow.visible = false
    refs.header.line.visible = false
  end

  -- Label
  local title_info = formatter(obj_data, player_data, { always_show = true, is_label = true })
  local label = refs.header.label
  label.caption = title_info.caption
  label.tooltip = title_info.tooltip
  label.style = title_info.researched and "rb_toolbar_label" or "rb_unresearched_toolbar_label"

  -- Buttons
  if context.class == "technology" then
    refs.header.open_in_tech_window_button.visible = true
  else
    refs.header.open_in_tech_window_button.visible = false
  end
  if context.class == "fluid" and obj_data.temperature_ident then
    local base_fluid_button = refs.header.go_to_base_fluid_button
    base_fluid_button.visible = true
    gui.set_action(base_fluid_button, "on_click", {
      gui = "info",
      id = self.id,
      action = "navigate_to_plain",
      context = obj_data.base_fluid,
    })
  else
    refs.header.go_to_base_fluid_button.visible = false
  end
  if context.class == "recipe" then
    local button = refs.header.quick_ref_button
    button.visible = true
    local is_selected = self.player_table.guis.quick_ref[context.name]
    button.style = is_selected and "flib_selected_tool_button" or "tool_button"
    button.tooltip = { "gui.rb-" .. (is_selected and "close" or "open") .. "-quick-ref-window" }
  else
    refs.header.quick_ref_button.visible = false
  end
  local favorite_button = refs.header.favorite_button
  if self.player_table.favorites[context.class .. "." .. context.name] then
    favorite_button.style = "flib_selected_tool_button"
    favorite_button.tooltip = { "gui.rb-remove-from-favorites" }
  else
    favorite_button.style = "tool_button"
    favorite_button.tooltip = { "gui.rb-add-to-favorites" }
  end

  -- PAGE

  local pane = refs.page_scroll_pane
  local page_refs = refs.page_components

  local page_settings = self.player_table.settings.pages[context.class]

  local i = 0
  local visible = false
  local component_variables = {
    context = context,
    gui_id = self.id,
    search_query = state.search_query,
    selected_tech_level = state.selected_tech_level,
  }
  -- Add or update relevant components
  for _, component_ident in pairs(constants.pages[context.class]) do
    i = i + 1

    local component = components[component_ident.type]
    local component_refs = page_refs[i]
    if not component_refs or component_refs.type ~= component_ident.type then
      -- Destroy old elements
      if component_refs then
        component_refs.root.destroy()
      end
      -- Create new elements
      component_refs = component.build(pane, i, component_ident, component_variables)
      component_refs.type = component_ident.type
      page_refs[i] = component_refs
    end

    local component_settings = page_settings[component_ident.label or component_ident.source]

    if not refresh then
      state.components[i] = component.default_state(component_settings)
    end

    component_variables.component_index = i
    component_variables.component_state = state.components[i]

    local comp_visible =
      component.update(component_ident, component_refs, obj_data, player_data, component_settings, component_variables)

    visible = visible or comp_visible
  end
  -- Destroy extraneous components
  for j = i + 1, #page_refs do
    page_refs[j].root.destroy()
    page_refs[j] = nil
  end

  -- Show error frame if nothing is visible
  if not visible and not state.warning_shown then
    state.warning_shown = true
    pane.visible = false
    refs.page_frame.style = "rb_inside_warning_frame"
    refs.page_frame.style.vertically_stretchable = state.docked and state.search_info
    refs.warning_flow.visible = true
    if state.search_query == "" then
      refs.warning_text.caption = { "gui.rb-no-content-warning" }
    else
      refs.warning_text.caption = { "gui.rb-no-results" }
    end
  elseif visible and state.warning_shown then
    state.warning_shown = false
    pane.visible = true
    refs.page_frame.style = "inside_shallow_frame"
    refs.page_frame.style.vertically_stretchable = state.docked and state.search_info
    refs.warning_flow.visible = false
  end
end

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param context Context
--- @param options table?
function index.build(player, player_table, context, options)
  options = options or {}

  local id = player_table.guis.info._next_id
  player_table.guis.info._next_id = id + 1
  local root_elem = options.parent or player.gui.screen
  local search_info = root_elem.name == "rb_search_window" or root_elem.name == "rb_visual_search_window"
  local relative = options.parent and not search_info
  local refs = gui.build(root_elem, {
    {
      type = "frame",
      style_mods = { minimal_width = 430, maximal_width = 600 },
      direction = "vertical",
      ref = { "window" },
      anchor = options.anchor,
      actions = {
        on_click = { gui = "info", id = id, action = "set_as_active" },
        on_closed = { gui = "info", id = id, action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar", "flow" },
        actions = {
          on_click = not relative and {
            gui = search_info and "search" or "info",
            id = not search_info and id or nil,
            action = "reset_location",
          } or nil,
        },
        util.frame_action_button(
          "rb_nav_backward",
          nil,
          { "titlebar", "nav_backward_button" },
          { gui = "info", id = id, action = "navigate", delta = -1 }
        ),
        util.frame_action_button(
          "rb_nav_forward",
          nil,
          { "titlebar", "nav_forward_button" },
          { gui = "info", id = id, action = "navigate", delta = 1 }
        ),
        {
          type = "label",
          style = "frame_title",
          style_mods = { left_margin = 4 },
          ignored_by_interaction = true,
          ref = { "titlebar", "label" },
        },
        {
          type = "empty-widget",
          style = relative and "flib_horizontal_pusher" or "flib_titlebar_drag_handle",
          ignored_by_interaction = true,
        },
        {
          type = "textfield",
          style_mods = {
            top_margin = -3,
            right_padding = 3,
            width = 120,
          },
          clear_and_focus_on_right_click = true,
          visible = false,
          ref = { "titlebar", "search_textfield" },
          actions = {
            on_text_changed = { gui = "info", id = id, action = "update_search_query" },
          },
        },
        util.frame_action_button(
          "utility/search",
          { "gui.rb-search-instruction" },
          { "titlebar", "search_button" },
          { gui = "info", id = id, action = "toggle_search" }
        ),
        options.parent and util.frame_action_button(
          "rb_detach",
          { "gui.rb-detach-instruction" },
          nil,
          { gui = "info", id = id, action = "detach_window" }
        ) or {},
        util.frame_action_button(
          "utility/close",
          { "gui.close" },
          { "titlebar", "close_button" },
          { gui = "info", id = id, action = "close" }
        ),
      },
      {
        type = "frame",
        style = "inside_shallow_frame",
        style_mods = { vertically_stretchable = search_info },
        direction = "vertical",
        ref = { "page_frame" },
        action = {
          on_click = { gui = "info", id = id, action = "set_as_active" },
        },
        {
          type = "frame",
          style = "rb_subheader_frame",
          direction = "vertical",
          {
            type = "flow",
            style_mods = { vertical_align = "center" },
            visible = false,
            ref = { "header", "list_nav", "flow" },
            action = {
              on_click = { gui = "info", id = id, action = "set_as_active" },
            },
            tool_button(
              "rb_list_nav_backward_black",
              { "gui.rb-go-backward" },
              { "header", "list_nav", "back_button" },
              nil,
              { padding = 3 }
            ),
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            {
              type = "label",
              style = "bold_label",
              style_mods = { horizontally_squashable = true },
              ref = { "header", "list_nav", "source_label" },
            },
            {
              type = "label",
              style = "bold_label",
              style_mods = { font_color = constants.colors.info.tbl },
              ref = { "header", "list_nav", "position_label" },
            },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            tool_button(
              "rb_list_nav_forward_black",
              { "gui.rb-go-forward" },
              { "header", "list_nav", "forward_button" },
              nil,
              { padding = 3 }
            ),
          },
          {
            type = "line",
            style = "rb_dark_line",
            direction = "horizontal",
            visible = false,
            ref = { "header", "line" },
          },
          {
            type = "flow",
            style_mods = { vertical_align = "center" },
            { type = "label", style = "rb_toolbar_label", ref = { "header", "label" } },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            __DebugAdapter and tool_button(nil, "Print", nil, { gui = "info", id = id, action = "print_object" }) or {},
            tool_button(
              "rb_technology_gui_black",
              { "gui.rb-open-in-technology-window" },
              { "header", "open_in_tech_window_button" },
              { gui = "info", id = id, action = "open_in_tech_window" }
            ),
            tool_button(
              "rb_fluid_black",
              { "gui.rb-view-base-fluid" },
              { "header", "go_to_base_fluid_button" },
              { gui = "info", id = id, action = "go_to_base_fluid" }
            ),
            tool_button(
              "rb_clipboard_black",
              { "gui.rb-toggle-quick-ref-window" },
              { "header", "quick_ref_button" },
              { gui = "info", id = id, action = "toggle_quick_ref" }
            ),
            tool_button(
              "rb_favorite_black",
              { "gui.rb-add-to-favorites" },
              { "header", "favorite_button" },
              { gui = "info", id = id, action = "toggle_favorite" }
            ),
          },
        },
        {
          type = "scroll-pane",
          style = "rb_page_scroll_pane",
          style_mods = { maximal_height = 900 },
          ref = { "page_scroll_pane" },
          action = {
            on_click = { gui = "info", id = id, action = "set_as_active" },
          },
        },
        {
          type = "flow",
          style = "rb_warning_flow",
          direction = "vertical",
          visible = false,
          ref = { "warning_flow" },
          {
            type = "label",
            style = "bold_label",
            caption = { "gui.rb-no-content-warning" },
            ref = { "warning_text" },
          },
        },
      },
    },
  })

  if options.parent then
    refs.root = root_elem
  else
    refs.root = refs.window
    refs.root.force_auto_center()
  end

  if not options.parent or search_info then
    refs.titlebar.flow.drag_target = refs.root
  end

  refs.page_components = {}

  --- @class InfoGui
  local self = {
    id = id,
    player = player,
    player_table = player_table,
    refs = refs,
    state = {
      components = {},
      docked = options.parent and true or false,
      history = { _index = 0 },
      search_info = search_info,
      search_opened = false,
      search_query = "",
      selected_tech_level = 0,
      warning_shown = false,
    },
  }
  index.load(self)

  player_table.guis.info[id] = self
  player_table.guis.info._active_id = id

  if options.anchor then
    player_table.guis.info._relative_id = id
  end

  self:update_contents({ new_context = context })
end

function index.load(self)
  setmetatable(self, { __index = Gui })
end

--- Find all info GUIs that are viewing the given context.
--- @param player_table PlayerTable
--- @param context Context
--- @return table<number, InfoGui>
function index.find_open_context(player_table, context)
  local open = {}
  for id, Gui in pairs(player_table.guis.info) do
    if not constants.ignored_info_ids[id] then
      local state = Gui.state
      local opened_context = state.history[state.history._index]
      if opened_context and opened_context.class == context.class and opened_context.name == context.name then
        open[id] = Gui
      end
    end
  end
  return open
end

-- function root.update_all(player, player_table)
--   for id in pairs(player_table.guis.info) do
--     if not constants.ignored_info_ids[id] then
--       root.update_contents(player, player_table, id, { refresh = true })
--     end
--   end
-- end

-- function root.bring_all_to_front(player_table)
--   for id, gui_data in pairs(player_table.guis.info) do
--     if not constants.ignored_info_ids[id] then
--       if gui_data.state.docked then
--         if gui_data.state.search_info then
--           gui_data.refs.root.bring_to_front()
--         end
--       else
--         gui_data.refs.window.bring_to_front()
--       end
--     end
--   end
-- end

return index
