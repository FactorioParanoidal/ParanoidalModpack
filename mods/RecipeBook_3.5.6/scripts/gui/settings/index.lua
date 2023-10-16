local gui = require("__flib__.gui")
local table = require("__flib__.table")

local constants = require("constants")

local database = require("scripts.database")
local util = require("scripts.util")

--- @class SettingsGui
local Gui = {}

local actions = require("scripts.gui.settings.actions")

function Gui:dispatch(msg, e)
  if type(msg) == "string" then
    actions[msg](self, msg, e)
  else
    actions[msg.action](self, msg, e)
  end
end

function Gui:destroy()
  self.player_table.guis.settings.refs.window.destroy()
  self.player_table.guis.settings = nil
end

function Gui:update_contents(tab)
  local refs = self.refs
  local state = self.state

  local query = state.search_query

  local translations = self.player_table.translations
  local gui_translations = translations.gui
  local actual_settings = self.player_table.settings

  -- For simplicity's sake, since there's not _that much_ going on here, we will just destroy and recreate things
  -- instead of updating them.

  -- GENERAL

  if not tab or tab == "general" then
    local general_pane = refs.general.pane
    general_pane.clear()
    for category, settings in pairs(constants.general_settings) do
      local actual_category_settings = actual_settings.general[category]
      local children = {}
      for setting_name, setting_ident in pairs(settings) do
        local caption = gui_translations[setting_name] or setting_name
        if string.find(string.lower(caption), query) then
          local converted_setting_name = string.gsub(setting_name, "_", "-")
          local tooltip = ""
          if setting_ident.has_tooltip then
            tooltip = { "gui.rb-" .. converted_setting_name .. "-description" }
            caption = caption .. " [img=info]"
          end
          local enabled = true
          if setting_ident.dependencies then
            for _, dependency in pairs(setting_ident.dependencies) do
              if actual_settings.general[dependency.category][dependency.name] ~= dependency.value then
                enabled = false
                break
              end
            end
          end
          if setting_ident.type == "bool" then
            children[#children + 1] = {
              type = "checkbox",
              caption = caption,
              tooltip = tooltip,
              state = actual_category_settings[setting_name],
              enabled = enabled,
              actions = enabled and {
                on_click = {
                  gui = "settings",
                  action = "change_general_setting",
                  type = setting_ident.type,
                  category = category,
                  name = setting_name,
                },
              } or nil,
            }
          elseif setting_ident.type == "enum" then
            children[#children + 1] = {
              type = "flow",
              style_mods = { vertical_align = "center" },
              { type = "label", caption = caption, tooltip = tooltip },
              { type = "empty-widget", style = "flib_horizontal_pusher" },
              {
                type = "drop-down",
                items = table.map(setting_ident.options, function(option_name)
                  return { "gui.rb-" .. converted_setting_name .. "-" .. string.gsub(option_name, "_", "-") }
                end),
                selected_index = table.find(setting_ident.options, actual_category_settings[setting_name]),
                enabled = enabled,
                actions = enabled and {
                  on_selection_state_changed = {
                    gui = "settings",
                    action = "change_general_setting",
                    type = setting_ident.type,
                    category = category,
                    name = setting_name,
                  },
                } or nil,
              },
            }
          end
        end
      end

      if #children > 0 then
        gui.build(general_pane, {
          {
            type = "frame",
            style = "bordered_frame",
            direction = "vertical",
            caption = gui_translations[category] or category,
            children = children,
          },
        })
      end
    end
  end

  -- CATEGORIES

  if not tab or tab == "categories" then
    local categories_frame = refs.categories.frame
    categories_frame.clear()
    local selected_class = constants.category_classes[state.selected_category]
    local class_settings = actual_settings.categories[selected_class]
    local class_translations = translations[selected_class]
    local children = {}
    for category_name in pairs(database[selected_class]) do
      local category_translation = class_translations[category_name] or category_name
      if string.find(string.lower(category_translation), query) then
        local img_type = constants.class_to_type[selected_class]
        if img_type then
          category_translation = "[img=" .. img_type .. "/" .. category_name .. "]  " .. category_translation
        end
        children[#children + 1] = {
          type = "checkbox",
          caption = category_translation,
          state = class_settings[category_name],
          actions = {
            on_checked_state_changed = {
              gui = "settings",
              action = "change_category_setting",
              class = selected_class,
              name = category_name,
            },
          },
        }
      end
    end

    if #children > 0 then
      gui.build(categories_frame, children)
    end
  end

  -- PAGES

  if not tab or tab == "pages" then
    local pages_pane = refs.pages.pane
    pages_pane.clear()
    local selected_page = constants.pages_arr[state.selected_page]
    local page_settings = actual_settings.pages[selected_page]
    local children = {}
    for component_name, component_settings in pairs(page_settings) do
      local component_children = {}

      component_children[1] = {
        type = "flow",
        style_mods = { vertical_align = "center" },
        { type = "label", caption = gui_translations.default_state },
        { type = "empty-widget", style = "flib_horizontal_pusher" },
        {
          type = "drop-down",
          items = table.map(constants.component_states, function(option_name)
            return { "gui.rb-" .. string.gsub(option_name, "_", "-") }
          end),
          selected_index = table.find(constants.component_states, component_settings.default_state),
          actions = {
            on_selection_state_changed = {
              gui = "settings",
              action = "change_default_state",
              class = selected_page,
              component = component_name,
            },
          },
        },
      }

      if component_settings.max_rows then
        component_children[#component_children + 1] = {
          type = "flow",
          style_mods = { vertical_align = "center" },
          { type = "label", caption = gui_translations.max_rows },
          { type = "empty-widget", style = "flib_horizontal_pusher" },
          {
            type = "textfield",
            style_mods = { width = 50, horizontal_align = "center" },
            numeric = true,
            lose_focus_on_confirm = true,
            clear_and_focus_on_right_click = true,
            text = tostring(component_settings.max_rows),
            actions = {
              on_confirmed = {
                gui = "settings",
                action = "change_max_rows",
                class = selected_page,
                component = component_name,
              },
            },
          },
        }
      end

      if component_settings.rows then
        for row_name, row_state in pairs(component_settings.rows) do
          component_children[#component_children + 1] = {
            type = "checkbox",
            caption = gui_translations[row_name],
            state = row_state,
            actions = {
              on_checked_state_changed = {
                gui = "settings",
                action = "change_row_visible",
                class = selected_page,
                component = component_name,
                row = row_name,
              },
            },
          }
        end
      end

      children[#children + 1] = {
        type = "frame",
        style = "bordered_frame",
        style_mods = { minimal_width = 300, horizontally_stretchable = true },
        direction = "vertical",
        caption = gui_translations[component_name] or component_name,
        children = component_children,
      }
    end

    gui.build(pages_pane, children)
  end
end

local index = {}

local function subpage_set(name, action, include_tooltip, include_bordered_frame, initial_items)
  return {
    tab = {
      type = "tab",
      style_mods = { padding = { 7, 10, 8, 10 } },
      caption = { "", { "gui.rb-" .. name }, include_tooltip and " [img=info]" or nil },
      tooltip = include_tooltip and { "gui.rb-" .. name .. "-description" } or nil,
    },
    content = {
      type = "flow",
      style_mods = { horizontal_spacing = 12, padding = { 8, 0, 12, 12 } },
      {
        type = "list-box",
        style = "list_box_in_shallow_frame",
        style_mods = { height = 28 * constants.settings_gui_rows, width = 150 },
        items = initial_items,
        selected_index = 1,
        actions = {
          on_selection_state_changed = { gui = "settings", action = action },
        },
      },
      {
        type = "frame",
        style = "flib_shallow_frame_in_shallow_frame",
        style_mods = { height = 28 * constants.settings_gui_rows },
        {
          type = "scroll-pane",
          style = "flib_naked_scroll_pane",
          style_mods = { padding = 4, vertically_stretchable = true },
          vertical_scroll_policy = "always",
          ref = { name, "pane" },
          include_bordered_frame and {
            type = "frame",
            style = "bordered_frame",
            style_mods = { minimal_width = 300, horizontally_stretchable = true, vertically_stretchable = true },
            direction = "vertical",
            ref = { name, "frame" },
          } or nil,
        },
      },
    },
  }
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
function index.build(player, player_table)
  local gui_translations = player_table.translations.gui

  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      name = "rb_settings_window",
      direction = "vertical",
      ref = { "window" },
      actions = {
        on_closed = { gui = "settings", action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar", "flow" },
        actions = {
          on_click = { gui = "settings", action = "reset_location" },
        },
        { type = "label", style = "frame_title", caption = { "gui.rb-settings" }, ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
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
            on_text_changed = { gui = "settings", action = "update_search_query" },
          },
        },
        util.frame_action_button(
          "utility/search",
          { "gui.rb-search-instruction" },
          { "titlebar", "search_button" },
          { gui = "settings", action = "toggle_search" }
        ),
        util.frame_action_button(
          "utility/close",
          { "gui.close" },
          { "titlebar", "close_button" },
          { gui = "settings", action = "close" }
        ),
      },
      {
        type = "frame",
        style = "inside_deep_frame_for_tabs",
        direction = "vertical",
        {
          type = "tabbed-pane",
          style = "flib_tabbed_pane_with_no_padding",
          {
            tab = { type = "tab", caption = { "gui.rb-general" } },
            content = {
              type = "flow",
              style_mods = { padding = 4 },
              direction = "vertical",
              ref = { "general", "pane" },
            },
          },
          subpage_set(
            "categories",
            "change_category",
            true,
            true,
            table.map(constants.category_classes, function(class)
              return gui_translations[class] or class
            end)
          ),
          subpage_set(
            "pages",
            "change_page",
            false,
            false,
            table.map(constants.pages_arr, function(class)
              return gui_translations[class] or class
            end)
          ),
        },
      },
    },
  })

  refs.window.force_auto_center()
  refs.titlebar.flow.drag_target = refs.window
  player.opened = refs.window

  --- @type SettingsGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    state = {
      search_opened = false,
      search_query = "",
      selected_category = 1,
      selected_page = 1,
    },
  }
  index.load(self)
  player_table.guis.settings = self

  self:update_contents()
end

function index.load(self)
  setmetatable(self, { __index = Gui })
end

return index
