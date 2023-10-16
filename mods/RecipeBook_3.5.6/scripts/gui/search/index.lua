local gui = require("__flib__.gui")
local table = require("__flib__.table")

local constants = require("constants")

local database = require("scripts.database")
local formatter = require("scripts.formatter")
local gui_util = require("scripts.gui.util")
local util = require("scripts.util")

--- @class SearchGuiRefs
--- @field window LuaGuiElement
--- @field titlebar SearchGuiTitlebarRefs
--- @field tabbed_pane LuaGuiElement
--- @field search_textfield LuaGuiElement
--- @field textual_results_pane LuaGuiElement
--- @field visual_results_flow LuaGuiElement
--- @field group_table LuaGuiElement
--- @field objects_frame LuaGuiElement
--- @field warning_frame LuaGuiElement
--- @field delete_favorites_button LuaGuiElement
--- @field delete_history_button LuaGuiElement
--- @field favorites_pane LuaGuiElement
--- @field history_pane LuaGuiElement

--- @class SearchGuiTitlebarRefs
--- @field flow LuaGuiElement
--- @field drag_handle LuaGuiElement
--- @field pin_button LuaGuiElement
--- @field settings_button LuaGuiElement

--- @class SearchGui
local Gui = {}

local actions = require("scripts.gui.search.actions")

function Gui:dispatch(msg, e)
  if type(msg) == "string" then
    actions[msg](self, msg, e)
  else
    actions[msg.action](self, msg, e)
  end
end

function Gui:destroy()
  if self.refs.window.valid then
    self.refs.window.destroy()
  end
  self.player_table.guis.search = nil
  self.player.set_shortcut_toggled("rb-search", false)
end

function Gui:open()
  local refs = self.refs
  refs.window.visible = true
  refs.window.bring_to_front()
  refs.tabbed_pane.selected_tab_index = 1
  refs.search_textfield.select_all()
  refs.search_textfield.focus()

  if not self.state.pinned then
    self.player.opened = refs.window
  end
  -- Workaround to prevent the search GUI from centering itself if the player doesn't manually recenter
  if self.player_table.settings.general.interface.search_gui_location ~= "center" then
    refs.window.auto_center = false
  end

  self.player.set_shortcut_toggled("rb-search", true)

  if self.state.search_type == "visual" and self.state.needs_visual_update then
    self:update_visual_contents()
  end
end

function Gui:close()
  local window = self.player_table.guis.search.refs.window
  window.visible = false

  local player = self.player
  player.set_shortcut_toggled("rb-search", false)
  if player.opened == window then
    player.opened = nil
  end
end

function Gui:toggle()
  if self.refs.window.visible then
    self:close()
  else
    self:open()
  end
end

function Gui:update_visual_contents()
  self.state.needs_visual_update = false

  local player_data = formatter.build_player_data(self.player, self.player_table)

  local show_fluid_temperatures = player_data.settings.general.search.show_fluid_temperatures
  local groups = {}

  for _, objects in pairs(
    { database.item, database.fluid }
    -- { database.recipe }
  ) do
    for name, object in pairs(objects) do
      -- Create / retrieve group and subgroup
      local group = object.group
      local group_table = groups[group.name]
      if not group_table then
        group_table = {
          button = {
            type = "sprite-button",
            name = group.name,
            style = "rb_filter_group_button_tab",
            sprite = "item-group/" .. group.name,
            tooltip = { "item-group-name." .. group.name },
            actions = {
              on_click = { gui = "search", action = "change_group", group = group.name },
            },
          },
          members = 0,
          scroll_pane = {
            type = "scroll-pane",
            name = group.name,
            style = "rb_filter_scroll_pane",
            vertical_scroll_policy = "always",
            visible = false,
          },
          subgroups = {},
        }
        groups[group.name] = group_table
      end
      local subgroup = object.subgroup
      local subgroup_table = group_table.subgroups[subgroup.name]
      if not subgroup_table then
        subgroup_table = { type = "table", style = "slot_table", column_count = 10 }
        group_table.subgroups[subgroup.name] = subgroup_table
        table.insert(group_table.scroll_pane, subgroup_table)
      end

      -- Check fluid temperature
      local matched = true
      local temperature_ident = object.temperature_ident
      if temperature_ident then
        local is_range = temperature_ident.min ~= temperature_ident.max
        if is_range then
          if show_fluid_temperatures ~= "all" then
            matched = false
          end
        else
          if show_fluid_temperatures == "off" then
            matched = false
          end
        end
      end

      if matched then
        local blueprint_result = object.place_result and { name = object.place_result.name } or nil
        local formatted = formatter(object, player_data, { blueprint_result = blueprint_result })
        if formatted then
          group_table.members = group_table.members + 1
          local style = "default"
          if formatted.disabled or formatted.hidden then
            style = "grey"
          elseif not formatted.researched then
            style = "red"
          end
          -- Create the button
          table.insert(subgroup_table, {
            type = "sprite-button",
            style = "flib_slot_button_" .. style,
            sprite = object.class .. "/" .. object.prototype_name,
            tooltip = formatted.tooltip,
            mouse_button_filter = { "left", "middle", "right" },
            tags = {
              blueprint_result = blueprint_result,
              context = { class = object.class, name = name },
            },
            actions = {
              on_click = { gui = "search", action = "open_object" },
            },
            temperature_ident and {
              type = "label",
              style = "rb_slot_label",
              caption = temperature_ident.short_string,
              ignored_by_interaction = true,
            } or nil,
            temperature_ident and temperature_ident.short_top_string and {
              type = "label",
              style = "rb_slot_label_top",
              caption = temperature_ident.short_top_string,
              ignored_by_interaction = true,
            } or nil,
          })
        end
      end
    end
  end

  local group_buttons = {}
  local group_scroll_panes = {}
  local first_group
  for group_name, group in pairs(groups) do
    if group.members > 0 then
      table.insert(group_buttons, group.button)
      table.insert(group_scroll_panes, group.scroll_pane)
      if not first_group then
        first_group = group_name
      end
    end
  end

  if
    #self.state.active_group == 0
    or not table.for_each(group_buttons, function(button)
      return button.name == self.state.active_group
    end)
  then
    self.state.active_group = first_group
  end

  local refs = self.refs

  refs.group_table.clear()
  gui.build(refs.group_table, group_buttons)

  refs.objects_frame.clear()
  gui.build(refs.objects_frame, group_scroll_panes)

  self:dispatch({ action = "change_group", group = self.state.active_group, ignore_last_button = true })
  self:dispatch("update_search_results")
end

function Gui:update_favorites()
  local favorites = self.player_table.favorites
  local refs = self.refs
  gui_util.update_list_box(
    refs.favorites_pane,
    favorites,
    formatter.build_player_data(self.player, self.player_table),
    pairs,
    { always_show = true }
  )
  refs.delete_favorites_button.enabled = next(favorites) and true or false
  for id, InfoGui in pairs(self.player_table.guis.info) do
    if not constants.ignored_info_ids[id] then
      local context = InfoGui:get_context()
      local to_state = favorites[context.class .. "." .. context.name]
      InfoGui:dispatch({ action = "update_header_button", button = "favorite_button", to_state = to_state })
    end
  end
end

function Gui:update_history()
  local refs = self.refs
  gui_util.update_list_box(
    refs.history_pane,
    self.player_table.global_history,
    formatter.build_player_data(self.player, self.player_table),
    ipairs,
    { always_show = true }
  )
  refs.delete_history_button.enabled = next(self.player_table.global_history) and true or false
end

function Gui:bring_to_front()
  self.refs.window.bring_to_front()
end

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function index.build(player, player_table)
  --- @type SearchGuiRefs
  local gui_type = player_table.settings.general.search.default_gui_type
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      name = "rb_search_window",
      style = "invisible_frame",
      visible = false,
      ref = { "window" },
      actions = {
        on_closed = { gui = "search", action = "close" },
      },
      -- Search frame
      {
        type = "frame",
        direction = "vertical",
        {
          type = "flow",
          style = "flib_titlebar_flow",
          ref = { "titlebar", "flow" },
          actions = {
            on_click = { gui = "search", action = "reset_location" },
          },
          {
            type = "label",
            style = "frame_title",
            caption = { "gui.rb-search-title" },
            ignored_by_interaction = true,
          },
          { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
          util.frame_action_button(
            "rb_pin",
            { "gui.rb-pin-instruction" },
            { "titlebar", "pin_button" },
            { gui = "search", action = "toggle_pinned" }
          ),
          util.frame_action_button(
            "rb_settings",
            { "gui.rb-settings-instruction" },
            { "titlebar", "settings_button" },
            { gui = "search", action = "toggle_settings" }
          ),
          util.frame_action_button(
            "utility/close",
            { "gui.close" },
            { "titlebar", "close_button" },
            { gui = "search", action = "close" }
          ),
        },
        {
          type = "frame",
          style = "inside_deep_frame_for_tabs",
          direction = "vertical",
          ref = { "tab_frame" },
          {
            type = "tabbed-pane",
            style = "tabbed_pane_with_no_side_padding",
            style_mods = { maximal_width = 426 },
            ref = { "tabbed_pane" },
            {
              tab = { type = "tab", caption = { "gui.search" } },
              content = {
                type = "frame",
                style = "rb_inside_deep_frame_under_tabs",
                direction = "vertical",
                {
                  type = "frame",
                  style = "rb_subheader_frame",
                  {
                    type = "textfield",
                    style = "flib_widthless_textfield",
                    style_mods = { horizontally_stretchable = true },
                    clear_and_focus_on_right_click = true,
                    ref = { "search_textfield" },
                    actions = {
                      on_text_changed = { gui = "search", action = "update_search_query" },
                    },
                  },
                  -- {
                  --   type = "sprite-button",
                  --   style = "tool_button",
                  --   tooltip = { "gui.rb-search-filters" },
                  --   sprite = "rb_filter",
                  --   actions = {
                  --     on_click = { gui = "search", action = "toggle_filters" },
                  --   },
                  -- },
                  {
                    type = "sprite-button",
                    style = "tool_button",
                    tooltip = { "gui.rb-change-search-type" },
                    sprite = "rb_swap",
                    actions = {
                      on_click = { gui = "search", action = "change_search_type" },
                    },
                  },
                },
                {
                  type = "scroll-pane",
                  style = "rb_search_results_scroll_pane",
                  ref = { "textual_results_pane" },
                  visible = gui_type == "textual",
                },
                {
                  type = "flow",
                  style_mods = { padding = 0, margin = 0, vertical_spacing = 0 },
                  direction = "vertical",
                  visible = gui_type == "visual",
                  ref = { "visual_results_flow" },
                  {
                    type = "table",
                    style = "filter_group_table",
                    style_mods = { width = 426 },
                    column_count = 6,
                    ref = { "group_table" },
                  },
                  {
                    type = "frame",
                    style = "rb_filter_frame",
                    {
                      type = "frame",
                      style = "deep_frame_in_shallow_frame",
                      style_mods = { natural_height = 40 * 15, natural_width = 40 * 10 },
                      ref = { "objects_frame" },
                    },
                    {
                      type = "frame",
                      style = "rb_warning_frame_in_shallow_frame",
                      style_mods = { height = 40 * 15, width = 40 * 10 },
                      ref = { "warning_frame" },
                      visible = false,
                      {
                        type = "flow",
                        style = "rb_warning_flow",
                        direction = "vertical",
                        { type = "label", style = "bold_label", caption = { "gui.rb-no-results" } },
                      },
                    },
                  },
                },
              },
            },
            {
              tab = { type = "tab", caption = { "gui.rb-favorites" } },
              content = {
                type = "frame",
                style = "rb_inside_deep_frame_under_tabs",
                direction = "vertical",
                {
                  type = "frame",
                  style = "subheader_frame",
                  { type = "empty-widget", style = "flib_horizontal_pusher" },
                  {
                    type = "sprite-button",
                    style = "tool_button_red",
                    sprite = "utility/trash",
                    tooltip = { "gui.rb-delete-favorites" },
                    ref = { "delete_favorites_button" },
                    actions = {
                      on_click = { gui = "search", action = "delete_favorites" },
                    },
                  },
                },
                { type = "scroll-pane", style = "rb_search_results_scroll_pane", ref = { "favorites_pane" } },
              },
            },
            {
              tab = { type = "tab", caption = { "gui.rb-history" } },
              content = {
                type = "frame",
                style = "rb_inside_deep_frame_under_tabs",
                direction = "vertical",
                {
                  type = "frame",
                  style = "subheader_frame",
                  { type = "empty-widget", style = "flib_horizontal_pusher" },
                  {
                    type = "sprite-button",
                    style = "tool_button_red",
                    sprite = "utility/trash",
                    tooltip = { "gui.rb-delete-history" },
                    ref = { "delete_history_button" },
                    actions = {
                      on_click = { gui = "search", action = "delete_history" },
                    },
                  },
                },
                { type = "scroll-pane", style = "rb_search_results_scroll_pane", ref = { "history_pane" } },
              },
            },
          },
        },
      },
    },
  })

  refs.titlebar.flow.drag_target = refs.window

  if player_table.settings.general.interface.search_gui_location == "top_left" then
    refs.window.location = table.map(constants.search_gui_top_left_location, function(pos)
      return pos * player.display_scale
    end)
  else
    refs.window.force_auto_center()
  end

  --- @class SearchGui
  local self = {
    player = player,
    player_table = player_table,
    state = {
      active_group = "",
      ignore_closed = false,
      needs_visual_update = true,
      search_query = "",
      search_type = gui_type,
      pinned = false,
    },
    refs = refs,
  }
  index.load(self)
  player_table.guis.search = self

  self:update_favorites()
  self:update_history()

  if gui_type == "visual" then
    self:update_visual_contents()
  end
end

function index.load(self)
  setmetatable(self, { __index = Gui })
end

return index
