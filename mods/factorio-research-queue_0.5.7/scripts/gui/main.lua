local guilib = require('__flib__.gui-beta')

local rqtech = require('scripts.rqtech')
local util = require('scripts.util')

local tech_button = require('.tech_button')
local templates = require('.templates')

local function build_tech_item_ingredients_flow(player, container, tech)
  local ingredients_flow_size = (64+8*2+8-8) * player.display_scale
  local ingredient_width = 16 * player.display_scale
  local ingredients = {}
  for _, ingredient in ipairs(tech.tech.research_unit_ingredients) do
    table.insert(ingredients, {
      type = 'sprite',
      style = 'rq_tech_list_item_ingredient',
      sprite = string.format('%s/%s', ingredient.type, ingredient.name),
    })
  end
  local ingredients_spacing = nil
  if #ingredients >= 2 then
    ingredients_spacing =
      math.floor((ingredients_flow_size - #ingredients*ingredient_width) /
        (#ingredients - 1)) /
        player.display_scale
    if ingredients_spacing > 0 then
      ingredients_spacing = 0
    end
  end
  local gui_data = guilib.build(container, {
    {
      type = 'flow',
      style = 'horizontal_flow',
      style_mods = {
        horizontal_spacing = ingredients_spacing,
      },
      direction = 'horizontal',
      children = ingredients,
    },
  })
end

local function build_tech_item(player, container, tech, index)
  local gui_data = guilib.build(container, {
    {
      ref = {'item'},
      type = 'flow',
      style = 'rq_tech_list_item',
      direction = 'vertical',
      index = index,
      children = {
        {
          ref = {'tech_button_container'},
          type = 'flow',
          direction = 'vertical',
        },
        {
          ref = {'ingredients_bar'},
          type = 'frame',
          direction = 'horizontal',
        },
        {
          ref = {'tool_bar'},
          type = 'frame',
          direction = 'horizontal',
          children = {
            templates.tool_button{
              style = 'rq_tech_list_item_tool_button',
              actions = {
                on_click = { type = 'enqueue', pos = 'last', tech = tech.id },
              },
              sprite = 'rq-enqueue-last-black',
              tooltip = {'factorio-research-queue.enqueue-last-button-tooltip', tech.tech.localised_name},
            },
            templates.tool_button{
              style = 'rq_tech_list_item_tool_button',
              actions = {
                on_click = { type = 'enqueue', pos = 'second', tech = tech.id },
              },
              sprite = 'rq-enqueue-second-black',
              tooltip = {'factorio-research-queue.enqueue-second-button-tooltip', tech.tech.localised_name},
            },
            templates.tool_button{
              style = 'rq_tech_list_item_tool_button',
              actions = {
                on_click = { type = 'enqueue', pos = 'first', tech = tech.id },
              },
              sprite = 'rq-enqueue-first-black',
              tooltip = {'factorio-research-queue.enqueue-first-button-tooltip', tech.tech.localised_name},
            },
          },
        },
      },
    },
  })
  gui_data.tech_button = tech_button.build(
    player,
    gui_data.tech_button_container,
    tech,
    'tech_list')
  gui_data.ingredients_bar_flow = build_tech_item_ingredients_flow(
    player,
    gui_data.ingredients_bar,
    tech)
  return gui_data
end

local function build(player, window)
  local force = player.force
  local player_data = global.players[player.index]
  local tech_ingredients = player_data.tech_ingredients

  local gui_data = guilib.build(window, {
    {
      type = 'frame',
      style = 'rq_main_window',
      direction = 'vertical',
      children = {
        {
          ref = {'titlebar'},
          type = 'flow',
          children = {
            templates.frame_title{'factorio-research-queue.window-title'},
            templates.titlebar_drag_handle(),
            {
              ref = {'search'},
              type = 'textfield',
              actions = {
                on_text_changed = 'update_search',
              },
              clear_and_focus_on_right_click = true,
              tooltip = {'factorio-research-queue.search-tooltip'},
              elem_mods = {
                visible = false,
              },
            },
            templates.frame_action_button{
              ref = {'search_toggle_button'},
              actions = {
                on_click = 'toggle_search',
              },
              sprite = 'utility/search_white',
              hovered_sprite = 'utility/search_black',
              clicked_sprite = 'utility/search_black',
              tooltip = {'factorio-research-queue.search-tooltip'},
            },
            templates.frame_action_button{
              ref = {'queue_pause_toggle_button'},
              actions = {
                on_click = 'toggle_queue_pause',
              },
            },
            templates.frame_action_button{
              ref = {'queue_clear_button'},
              style = 'rq_frame_action_button_red',
              actions = {
                on_click = 'clear_queue',
              },
              sprite = 'utility/trash_white',
              hovered_sprite = 'utility/trash',
              clicked_sprite = 'utility/trash',
              tooltip = {'factorio-research-queue.clear-tooltip'},
            },
            templates.frame_action_button{
              actions = {
                on_click = 'research_current',
              },
              sprite = 'rq-enqueue-first-white',
              tooltip = '[[color=red]Cheat[/color]] Research current technology',
              elem_mods = {
                visible = __rq_debug,
              },
            },
            templates.frame_action_button{
              actions = {
                on_click = 'refresh_gui',
              },
              sprite = 'rq-refresh',
              tooltip = '[[color=purple]Debug[/color]] Refresh data',
              elem_mods = {
                visible = __rq_debug,
              },
            },
            templates.frame_action_button{
              actions = {
                on_click = 'close_window',
              },
              sprite = 'utility/close_white',
              hovered_sprite = 'utility/close_black',
              clicked_sprite = 'utility/close_black',
              tooltip = {'factorio-research-queue.close-tooltip'},
            },
          },
        },
        {
          type = 'flow',
          style = 'horizontal_flow',
          style_mods = {
            horizontal_spacing = 12,
          },
          direction = 'horizontal',
          children = {
            {
              type = 'flow',
              style = 'vertical_flow',
              style_mods = {
                vertical_spacing = 8,
              },
              direction = 'vertical',
              children = {
                {
                  ref = {'queue', 'head'},
                  type = 'frame',
                  style = 'rq_tech_queue_head_frame',
                  children = {
                    {
                      ref = {'queue', 'pause_button_container'},
                      type = 'flow',
                      style = 'rq_tech_queue_item_paused',
                      children = {
                        {
                          type = 'sprite-button',
                          style = 'rq_tech_queue_item_paused_unpause_button',
                          actions = {
                            on_click = 'toggle_queue_pause',
                          },
                          sprite = 'rq-play-black',
                          tooltip = {'factorio-research-queue.queue-play-button-tooltip'},
                          mouse_button_filter = {'left'},
                        },
                      },
                    },
                    {
                      ref = {'queue', 'head_item_container'},
                      type = 'flow',
                    },
                  },
                },
                {
                  ref = {'queue', 'list'},
                  type = 'scroll-pane',
                  style = 'rq_tech_queue_list_box',
                  vertical_scroll_policy = 'always',
                },
              },
            },
            {
              type = 'scroll-pane',
              style = 'rq_tech_list_list_box',
              vertical_scroll_policy = 'always',
              children = {
                {
                  ref = {'techs', 'table'},
                  type = 'table',
                  style = 'rq_tech_list_table',
                  column_count = 7,
                },
              },
            },
          },
        },
      },
    },
  })

  gui_data.titlebar.drag_target = window

  local techs_list = {}
  local techs_set = {}
  for tech in rqtech.iter(force) do
    if not tech.tech.prototype.hidden then
      table.insert(techs_list, tech)
      techs_set[tech.id] = true
    end
  end
  util.sort_by_key(techs_list, function(tech)
    local ingredients = {}
    for i, tech_ingredient in ipairs(tech_ingredients) do
      local has = false
      for _, ingredient in ipairs(tech.tech.research_unit_ingredients) do
        if tech_ingredient.name == ingredient.name then
          has = true
          break
        end
      end
      ingredients[#tech_ingredients+1-i] = has
    end
    return {
      ingredients,
      tech.research_unit_count,
      tech.tech.order,
      tech.tech.name,
      tech.level,
    }
  end)
  do
    local topo_set = {}
    local topo_list = {}
    local function add(tech)
      if topo_set[tech.id] then return end
      if not techs_set[tech.id] then return end
      for _, dep in pairs(tech.prerequisites) do
        add(dep)
      end
      table.insert(topo_list, tech)
      topo_set[tech.id] = true
    end
    for _, tech in ipairs(techs_list) do
      add(tech)
    end
    tech_list = topo_list
  end
  local items_gui_data = {}
  for _, tech in ipairs(techs_list) do
    local item_gui_data = build_tech_item(player, gui_data.techs.table, tech)
    items_gui_data[tech.id] = item_gui_data
  end
  gui_data.techs.items = items_gui_data

  return gui_data
end

return {
  build = build,
  build_tech_item = build_tech_item,
  build_tech_item_ingredients_flow = build_tech_item_ingredients_flow,
}
