local guilib = require('__flib__.gui-beta')

local rqtech = require('scripts.rqtech')
local util = require('scripts.util')

local tech_button = require('.tech_button')
local templates = require('.templates')

local function build(player, window)
  local force = player.force
  local player_data = global.players[player.index]
  local tech_ingredients = player_data.tech_ingredients

  local gui_data = guilib.build(window, {
    {
      type = 'frame',
      style = 'rq_settings_window',
      direction = 'vertical',
      children = {
        {
          ref = {'titlebar'},
          type = 'flow',
          children = {
            templates.frame_title{'factorio-research-queue.settings-title'},
            templates.titlebar_drag_handle(),
          },
        },
        {
          type = 'flow',
          style = 'vertical_flow',
          style_mods = {
            vertical_spacing = 12,
          },
          direction = 'vertical',
          children = {
            {
              ref = {'researched_techs_checkbox'},
              type = 'checkbox',
              actions = {
                on_click = 'toggle_researched_filter',
              },
              caption = {'factorio-research-queue.researched-techs-checkbox'},
              state = false,
            },
            {
              ref = {'upgrade_techs_checkbox'},
              type = 'checkbox',
              actions = {
                on_click = 'toggle_upgrades_filter',
              },
              caption = {'factorio-research-queue.upgrade-techs-checkbox'},
              state = false,
            },
            {
              type = 'frame',
              style = 'rq_settings_section',
              direction = 'vertical',
              children = {
                {
                  type = 'label',
                  style = 'caption_label',
                  caption = {'factorio-research-queue.tech-ingredient-filter-table'},
                },
                {
                  type = 'scroll-pane',
                  style = 'rq_tech_ingredient_filter_table_scroll_box',
                  children = {
                    {
                      ref = {'tech_ingredient_filter', 'table'},
                      type = 'table',
                      column_count = 4,
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  })

  local items_gui_data = {}
  for _, tech_ingredient in ipairs(tech_ingredients) do
    local item_gui_data = guilib.build(gui_data.tech_ingredient_filter.table, {
      {
        ref = {'button'},
        type = 'sprite-button',
        actions = {
          on_click = { type = 'toggle_tech_ingredient_filter', tech_ingredient = tech_ingredient.name },
        },
        sprite = string.format('%s/%s', 'item', tech_ingredient.name),
        mouse_button_filter = {'left'},
      },
    })
    items_gui_data[tech_ingredient.name] = item_gui_data
  end
  gui_data.tech_ingredient_filter.items = items_gui_data

  gui_data.titlebar.drag_target = window

  return gui_data
end

return {
  build = build,
}
