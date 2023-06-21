local guilib = require('__flib__.gui-beta')
local translationlib = require('__flib__.translation')
local eventlib = require('__flib__.event')

local rqtech = require('scripts.rqtech')
local queue = require('scripts.queue')
local util = require('scripts.util')

local main_gui = require('.main')
local settings_gui = require('.settings')
local tech_button = require('.tech_button')
local templates = require('.templates')

local actions = {}

function actions.init(player)
  local force = player.force
  local player_data = global.players[player.index]

  local tech_ingredients = {}
  for _, item in pairs(game.get_filtered_item_prototypes{{filter='tool'}}) do
    local is_tech_ingredient = (function()
      for _, tech in pairs(force.technologies) do
        if tech.enabled then
          for _, ingredient in pairs(tech.research_unit_ingredients) do
            if ingredient.type == 'item' and ingredient.name == item.name then
              return true
            end
          end
        end
      end
      return false
    end)()
    if is_tech_ingredient then
      table.insert(tech_ingredients, item)
    end
  end
  table.sort(tech_ingredients, function(a, b) return a.order < b.order end)
  player_data.tech_ingredients = tech_ingredients

  local filter_data = {
    researched = false,
    upgrades = false,
    ingredients = {},
    search_terms = {},
  }
  player_data.filter = filter_data

  player_data.translations = {}
  do
    local requests = {}

    for _, tech in pairs(force.technologies) do
      if not tech.prototype.hidden then
        local function add_request(localised_string)
          local key = translationlib.serialise_localised_string(localised_string)
          local request = {
            dictionary = tech.name,
            internal = key,
            localised = localised_string,
          }
          table.insert(requests, request)
        end

        add_request(tech.localised_name)
        add_request(tech.localised_description)
        for _, effect in ipairs(tech.effects) do
          if effect.type == 'nothing' then
            add_request(effect.effect_description)
          elseif effect.type == 'give-item' then
            local item = game.item_prototypes[effect.item]
            add_request(item.localised_name)
            -- add_request(item.localised_description)
          elseif effect.type == 'unlock-recipe' then
            local recipe = game.recipe_prototypes[effect.recipe]
            add_request(recipe.localised_name)
            -- add_request(recipe.localised_description)
          elseif effect.type == 'gun-speed' then
            local ammo_category = game.ammo_category_prototypes[effect.ammo_category]
            add_request(ammo_category.localised_name)
            -- add_request(ammo_category.localised_description)
          elseif effect.type == 'turret-attack' then
            local entity = game.entity_prototypes[effect.turret_id]
            add_request(entity.localised_name)
            -- add_request(entity.localised_description)
          else
            add_request{'modifier-description.'..effect.type, effect.modifier}
          end
        end
      end
    end

    translationlib.add_requests(player.index, requests)
    actions.register_translation_handler()
  end

  local gui_data = guilib.build(player.gui.screen, {
    {
      ref = {'window'},
      type = 'frame',
      style = 'outer_frame',
      actions = {
        on_closed = 'close_window',
      },
      elem_mods = {
        visible = false,
      },
    },
  })
  gui_data.window.force_auto_center()

  gui_data.main = main_gui.build(player, gui_data.window)
  gui_data.settings = settings_gui.build(player, gui_data.window)

  player_data.gui = gui_data

  actions.auto_select_tech_ingredients(player)
  actions.update_techs(player)
  actions.update_queue(player)
end

function actions.deinit(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  gui_data.window.destroy()

  player_data.gui = nil
end

function actions.open_window(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  if not gui_data.window.valid then
    actions.init(player)
    gui_data = player_data.gui
  end

  gui_data.window.visible = true
  player.opened = gui_data.window
  player.set_shortcut_toggled('factorio-research-queue', true)
  if gui_data.main.search.visible then
    gui_data.main.search.focus()
    gui_data.main.search.select_all()
  end
  if util.can_pause_game(player) then
    game.tick_paused = true
  end

  actions.update_search(player)
  actions.update_queue(player)
  actions.update_techs(player)
end

function actions.close_window(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  if gui_data.window.valid then
    gui_data.window.visible = false
    if player.opened == gui_data.window then
      player.opened = nil
    end
    player_data.closed_tick = game.tick
    if util.can_pause_game(player) then
      game.tick_paused = false
    end
  end
  player.set_shortcut_toggled('factorio-research-queue', false)
end

function actions.toggle_window(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  if gui_data.window.valid and gui_data.window.visible then
    actions.close_window(player)
  else
    actions.open_window(player)
  end
end

function actions.update_all(player)
  actions.update_queue(player)
  actions.update_techs(player)
  actions.update_progressbars(player)
end

function actions.update_techs(player, translations_changed)
  local force = player.force
  local player_data = global.players[player.index]
  local gui_data = player_data.gui
  local filter_data = player_data.filter
  local tech_ingredients = player_data.tech_ingredients

  if not gui_data.window.valid then return end

  gui_data.settings.researched_techs_checkbox.state = filter_data.researched
  gui_data.settings.upgrade_techs_checkbox.state = filter_data.upgrades
  for _, tech_ingredient in ipairs(tech_ingredients) do
    local button = gui_data.settings.tech_ingredient_filter.items[tech_ingredient.name].button
    local enabled = filter_data.ingredients[tech_ingredient.name]
    button.style = 'rq_tech_ingredient_filter_button_'..(enabled and 'enabled' or 'disabled')
    button.tooltip = {
      'factorio-research-queue.tech-ingredient-filter-button-'..(enabled and 'enabled' or 'disabled'),
      tech_ingredient.localised_name,
    }
  end

  local function is_tech_visible(tech)
    if tech.tech.prototype.hidden or not tech.tech.enabled then
      return false
    end

    if not filter_data.researched and rqtech.is_researched(tech) then
      return false
    end

    if tech.tech.upgrade or tech.infinite then
      -- only include upgrade techs if they have a "significant" dependency
      local has_significant_dependency = (function()
        for _, dependency in pairs(tech.prerequisites) do
          local is_significant_dependency = (function()
            -- significant if initially available research
            if #tech.prerequisites == 0 and tech.level and tech.level < 2 then
              return true
            end

            -- significant if not an upgrade or infinite
            if not (dependency.tech.upgrade or dependency.infinite) then
              return true
            end

            -- is an upgrade
            -- significant if not in the same group
            if tech.upgrade_group ~= dependency.upgrade_group then
              return true
            end

            -- is an upgrade and in the same group
            -- significant if researched
            if rqtech.is_researched(dependency) then
              return true
            end

            -- is an upgrade, in the same group, and not researched
            -- significant if in the queue
            if queue.in_queue(force, dependency) then
              return true
            end

            return false
          end)()
          if is_significant_dependency then return true end
        end
        return false
      end)()
      if not has_significant_dependency then
        -- if upgrades are hidden
        if not filter_data.upgrades then
          -- hide
          return false
        end

        -- upgrades are not hidden
        -- if the tech is infinite, still hide
        if tech.infinite then
          return false
        end
      end
    end

    local ingredients_filter = filter_data.ingredients
    for _, ingredient in pairs(tech.tech.research_unit_ingredients) do
      if not ingredients_filter[ingredient.name] then
        return false
      end
    end

    local search_terms = filter_data.search_terms
    local search_matches = (function()
      if #search_terms == 0 then
        return true
      end

      local strings = player_data.translations[tech.tech.name] or {}

      if next(strings) == nil then
        -- nothing translated yet, just call it a match
        return true
      end

      for _, s in pairs(strings) do
        if util.fuzzy_search(s, search_terms) then
          return true
        end
      end

      return false
    end)()
    if not search_matches then
      return false
    end

    return true
  end

  local function update_item(item_gui_data, tech)
    local researchable = queue.is_researchable(force, tech)
    local queued = queue.in_queue(force, tech)
    local queued_head = not queue.is_paused(force) and queue.is_head(force, tech)
    local researched = rqtech.is_researched(tech)
    local available = (function()
      for _, prereq in pairs(tech.prerequisites) do
        if not rqtech.is_researched(prereq) then
          return false
        end
      end
      return true
    end)()
    local style_prefix =
      'rq_tech_list_item' ..
        (queued_head and '_queued_head' or
        queued and '_queued' or
        researched and '_researched' or
        available and '_available' or
        '_unavailable')

    item_gui_data.ingredients_bar.style = style_prefix..'_ingredients_bar'
    item_gui_data.tool_bar.style = style_prefix..'_tool_bar'
    for _, button in pairs(item_gui_data.tool_bar.children) do
      button.enabled = researchable
    end
    actions.update_tech_button(
      player,
      item_gui_data.tech_button,
      tech,
      style_prefix..'_tech_button',
      translations_changed)
  end

  local items_gui_data = gui_data.main.techs.items
  local upgrade_items_gui_data = gui_data.main.techs.upgrade_items or {}

  for tech_id, item_gui_data in pairs(upgrade_items_gui_data) do
    item_gui_data.item.destroy()
    items_gui_data[tech_id] = nil
  end
  upgrade_items_gui_data = {}
  gui_data.main.techs.upgrade_items = upgrade_items_gui_data

  for tech in rqtech.iter(force) do
    if not tech.tech.prototype.hidden then
      local item_gui_data = items_gui_data[tech.id]

      local visible = is_tech_visible(tech)
      if visible then
        update_item(item_gui_data, tech)
        item_gui_data.item.visible = true
      else
        item_gui_data.item.visible = false
      end

      local index = item_gui_data.item.get_index_in_parent() + 1

      while true do
        if
          not (visible or rqtech.is_researched(tech)) or
          not tech.infinite or
          tech.level + 1 > tech.tech.prototype.max_level
        then
          break
        end
        local next_level_tech = rqtech.new(tech.tech, tech.level + 1)
        tech = next_level_tech
        visible = is_tech_visible(tech)
        if visible then
          local item_gui_data = main_gui.build_tech_item(
            player,
            gui_data.main.techs.table,
            tech,
            index)

          update_item(item_gui_data, tech)

          index = item_gui_data.item.get_index_in_parent() + 1

          items_gui_data[tech.id] = item_gui_data
          upgrade_items_gui_data[tech.id] = item_gui_data
        end
      end
    end
  end
end

function actions.update_tech_list_ingredients(player)
  local force = player.force
  local player_data = global.players[player.index]
  local gui_data = player_data.gui
  local items_gui_data = gui_data.main.techs.items
  for tech_id, item_gui_data in pairs(items_gui_data) do
    local tech = rqtech.from_id(force, tech_id)
    item_gui_data.ingredients_bar.clear()
    item_gui_data.ingredients_bar_flow = main_gui.build_tech_item_ingredients_flow(
      player,
      item_gui_data.ingredients_bar,
      tech)
  end
end

function actions.update_queue(player, new_tech)
  local force = player.force
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  local is_head = true
  do
    local queue_pause_toggle_button = gui_data.main.queue_pause_toggle_button
    local pause_button_container = gui_data.main.queue.pause_button_container
    local head_item_container = gui_data.main.queue.head_item_container
    if queue.is_paused(force) then
      queue_pause_toggle_button.style = 'rq_frame_action_button_green'
      queue_pause_toggle_button.sprite = 'rq-play-white'
      queue_pause_toggle_button.hovered_sprite = 'rq-play-black'
      queue_pause_toggle_button.clicked_sprite = 'rq-play-black'
      queue_pause_toggle_button.tooltip = {'factorio-research-queue.queue-play-button-tooltip'}

      pause_button_container.visible = true
      head_item_container.visible = false

      is_head = false
    else
      queue_pause_toggle_button.style = 'rq_frame_action_button_red'
      queue_pause_toggle_button.sprite = 'rq-pause-white'
      queue_pause_toggle_button.hovered_sprite = 'rq-pause-black'
      queue_pause_toggle_button.clicked_sprite = 'rq-pause-black'
      queue_pause_toggle_button.tooltip = {'factorio-research-queue.queue-pause-button-tooltip'}

      pause_button_container.visible = false
      head_item_container.visible = true
    end
  end

  gui_data.main.queue.head_item_container.clear()
  gui_data.main.queue.list.clear()
  local new_tech_element = nil
  local items_gui_data = {}
  for tech in queue.iter(force) do
    local shift_up_enabled = queue.can_shift_earlier(force, tech)
    local shift_down_enabled = queue.can_shift_later(force, tech)
    local container = gui_data.main.queue[is_head and 'head_item_container' or 'list']
    local item_gui_data = guilib.build(container, {
      {
        ref = {'item'},
        type = 'frame',
        style = 'rq_tech_queue_item',
        direction = 'horizontal',
        children = {
          {
            type = 'flow',
            style = 'rq_tech_queue_item_inner_flow',
            direction = 'vertical',
            children = {
              {
                ref = {'tech_button_container'},
                type = 'flow',
              },
              {
                ref = {'etc_label'},
                type = 'label',
                style = 'rq_etc_label',
                caption = '[img=quantity-time][img=infinity]',
                tooltip = {'factorio-research-queue.etc-label-tooltip'},
              },
            },
          },
          {
            type = 'flow',
            style = 'rq_tech_queue_item_buttons',
            direction = 'vertical',
            children = {
              {
                type = 'button',
                style = 'rq_tech_queue_item_shift_up_button',
                actions = {
                  on_click = { type = 'queue_shift', dir = 'up', tech = tech.id },
                },
                tooltip =
                  shift_up_enabled and
                    {'factorio-research-queue.shift-up-button-tooltip', tech.tech.localised_name} or
                    nil,
                enabled = shift_up_enabled,
                mouse_button_filter = {'left'},
              },
              {
                type = 'empty-widget',
                style = 'flib_vertical_pusher',
              },
              templates.tool_button{
                style = 'rq_tech_queue_item_close_button',
                actions = {
                  on_click = { type = 'dequeue', tech = tech.id },
                },
                sprite = 'utility/close_black',
                tooltip = {'factorio-research-queue.dequeue-button-tooltip', tech.tech.localised_name},
              },
              {
                type = 'empty-widget',
                style = 'flib_vertical_pusher',
              },
              {
                type = 'button',
                style = 'rq_tech_queue_item_shift_down_button',
                actions = {
                  on_click = { type = 'queue_shift', dir = 'down', tech = tech.id },
                },
                tooltip =
                  shift_down_enabled and
                    {'factorio-research-queue.shift-down-button-tooltip', tech.tech.localised_name} or
                    nil,
                enabled = shift_down_enabled,
                mouse_button_filter = {'left'},
              },
            },
          },
        },
      },
    })

    local tech_button_gui_data = tech_button.build(
      player,
      item_gui_data.tech_button_container,
      tech,
      'tech_queue')
    actions.update_tech_button(
      player,
      tech_button_gui_data,
      tech,
      'rq_tech_queue'..(is_head and '_head' or '')..'_item_tech_button')
    item_gui_data.tech_button = tech_button_gui_data

    items_gui_data[tech.id] = item_gui_data

    if new_tech ~= nil and new_tech.id == tech.id then
      if is_head then
        new_tech_element = 'head'
      else
        new_tech_element = item_gui_data.item
      end
    end

    is_head = false
  end
  gui_data.main.queue.items = items_gui_data

  if new_tech_element ~= nil then
    if new_tech_element == 'head' then
      gui_data.main.queue.list.scroll_to_top()
    else
      gui_data.main.queue.list.scroll_to_element(new_tech_element, 'top-third')
    end
  end

  actions.update_etcs(player)
end

function actions.update_etcs(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui
  local force = player.force

  if not gui_data.window.valid then return end

  local speed = player_data.last_research_speed_estimate or 0
  local etc = 0
  local tech_ingredient_totals = {}
  for tech in queue.iter(force) do
    local etc_label = gui_data.main.queue.items[tech.id].etc_label

    local progress = rqtech.progress(tech)

    local etc_text = ''
    if speed == 0 then
      etc_text = etc_text..'[img=infinity]'
    else
      etc = etc +
        (1-progress) *
        (tech.tech.research_unit_energy/60) *
        tech.research_unit_count /
        speed
      etc_text = etc_text..util.format_duration(etc)
    end
    etc_label.caption = etc_text

    for _, ingredient in ipairs(tech.tech.research_unit_ingredients) do
      tech_ingredient_totals[ingredient.name] =
        (tech_ingredient_totals[ingredient.name] or 0) +
        (1-progress) *
        tech.research_unit_count *
        ingredient.amount
    end

    local tech_ingredient_totals_text = '[font=count-font]'
    for _, ingredient in ipairs(player_data.tech_ingredients) do
      amount = tech_ingredient_totals[ingredient.name]
      if amount ~= nil and amount ~= 0 then
        tech_ingredient_totals_text = tech_ingredient_totals_text ..
          string.format(
            '[img=%s/%s]%d ',
            'item',
            ingredient.name,
            amount)
      end
    end
    tech_ingredient_totals_text = tech_ingredient_totals_text..'[/font]'
    etc_label.tooltip = {'',
      {'factorio-research-queue.etc-label-tooltip', etc_text},
      '\n',
      {'factorio-research-queue.tech-ingredient-totals-tooltip',
        tech_ingredient_totals_text}}
  end
end

function actions.update_progressbars(player)
  local force = player.force
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  for tech_id, item_gui_data in pairs(gui_data.main.techs.items) do
    local tech = rqtech.from_id(force, tech_id)

    if item_gui_data.item.visible then
      actions.update_tech_button_progressbar(
        player,
        item_gui_data.tech_button,
        tech)
    end
  end

  for tech_id, item_gui_data in pairs(gui_data.main.queue.items or {}) do
    local tech = rqtech.from_id(force, tech_id)
    actions.update_tech_button_progressbar(
      player,
      item_gui_data.tech_button,
      tech)
  end
end

function actions.update_tech_button(
  player,
  gui_data,
  tech,
  style,
  translations_changed
)
  gui_data.button.style = style
  if translations_changed then
    tech_button.update_tech_button_tooltip(player, gui_data, tech)
  end
  actions.update_tech_button_progressbar(player, gui_data, tech)
end

function actions.update_tech_button_progressbar(player, gui_data, tech)
  local researched = rqtech.is_researched(tech)
  local progress
  if researched then
    progress = 0
  else
    progress = rqtech.progress(tech)
  end

  gui_data.progressbar.value = progress
  gui_data.progressbar.visible = progress > 0
end

function actions.update_search(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui
  local filter_data = player_data.filter

  if not gui_data.window.valid then return end

  local search_text = gui_data.main.search.text
  filter_data.search_terms = util.prepare_search_terms(search_text)
end

function actions.focus_search(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  if not gui_data.window.valid then return end

  if gui_data.window.visible then
    local search = gui_data.main.search
    local search_toggle_button = gui_data.main.search_toggle_button
    if not search.visible then
      search_toggle_button.style = 'flib_selected_frame_action_button'
      search.visible = true
    end
    search.focus()
    search.select_all()
  end
end

function actions.toggle_search(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  if not gui_data.window.valid then return end

  if gui_data.window.visible then
    local search = gui_data.main.search
    local search_toggle_button = gui_data.main.search_toggle_button
    if not search.visible then
      search_toggle_button.style = 'flib_selected_frame_action_button'
      search.visible = true
      search.focus()
      search.select_all()
    else
      search_toggle_button.style = 'frame_action_button'
      search.visible = false
      search.text = ''
      actions.update_search(player)
      actions.update_techs(player)
    end
  end
end

function actions.toggle_researched_filter(player)
  local player_data = global.players[player.index]
  local filter_data = player_data.filter

  local enabled = filter_data.researched
  enabled = not enabled
  filter_data.researched = enabled
end

function actions.toggle_upgrades_filter(player)
  local player_data = global.players[player.index]
  local filter_data = player_data.filter

  local enabled = filter_data.upgrades
  enabled = not enabled
  filter_data.upgrades = enabled
end

function actions.auto_select_tech_ingredients(player)
  local force = player.force
  local player_data = global.players[player.index]
  local filter_data = player_data.filter
  local tech_ingredients = player_data.tech_ingredients

  for _, tech_ingredient in ipairs(tech_ingredients) do
    filter_data.ingredients[tech_ingredient.name] =
      util.is_item_available(force, tech_ingredient.name)
  end
end

function actions.toggle_tech_ingredient_filter(player, tech_ingredient)
  local player_data = global.players[player.index]
  local filter_data = player_data.filter

  local enabled = filter_data.ingredients[tech_ingredient.name]
  enabled = not enabled
  filter_data.ingredients[tech_ingredient.name] = enabled
end

function actions.on_technology_gui_opened(player)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  if gui_data.window.valid and player_data.closed_tick == game.tick then
    -- if the window was closed in the same tick that the tech gui was opened,
    -- keep the window visible in the background
    -- when the tech gui is closed, the window will be officially opened and
    -- made the opened gui of the player
    gui_data.window.visible = true
  end
end

function actions.on_technology_gui_closed(player)
  local force = player.force
  local player_data = global.players[player.index]
  local gui_data = player_data.gui

  queue.set_paused(force, force.current_research == nil)
  queue.update(force, 3) -- vanilla UI closed

  for _, player in pairs(force.players) do
    local player_data = global.players[player.index]
    if player_data ~= nil then
      local gui_data = player_data.gui
      if gui_data.window.valid and gui_data.window.visible then
        actions.update_queue(player, tech)
      end
    end
  end

  if gui_data.window.valid and gui_data.window.visible then
    -- after the tech gui is closed, if the window was still visible, make it
    -- the official opened gui of the player
    actions.open_window(player)
  end
end

function actions.on_research_started(force, tech, last_tech)
  tech = rqtech.new(tech, 'current')
  if not queue.is_head(force, tech, true) then
    --queue.set_paused(force, false)
    --queue.enqueue_head(force, tech)
    queue.update(force, 2) -- research started
    for _, player in pairs(force.players) do
      local player_data = global.players[player.index]
      if player_data ~= nil then
        local gui_data = player_data.gui
        if gui_data.window.valid and gui_data.window.visible then
          actions.update_queue(player, tech)
        end
      end
    end
  end
end

function actions.on_research_finished(force, tech)
  tech = rqtech.new(tech, 'previous')
  queue.update(force, 1) -- research finished
  for _, player in pairs(force.players) do
    local player_data = global.players[player.index]
    if player_data ~= nil then
      local gui_data = player_data.gui
      local filter_data = player_data.filter
      local tech_ingredients = player_data.tech_ingredients

      if settings.get_player_settings(player)['rq-notifications'].value then
        player.print{'factorio-research-queue.notification', tech.tech.name}
      end

      for _, tech_ingredient in ipairs(tech_ingredients) do
        if not filter_data.ingredients[tech_ingredient.name] then
          local newly_available = (function()
            for _, effect in pairs(tech.tech.effects) do
              if effect.type == 'unlock-recipe' then
                if util.is_item_available(force, tech_ingredient.name, effect.recipe) then
                  return true
                end
              end
            end
            return false
          end)()
          if newly_available then
            filter_data.ingredients[tech_ingredient.name] = true
          end
        end
      end

      if gui_data.window.valid and gui_data.window.visible then
        actions.update_queue(player)
        actions.update_techs(player)
      end
    end
  end
end

function actions.on_research_speed_estimate(force, speed)
  for _, player in pairs(force.players) do
    local player_data = global.players[player.index]
    if player_data ~= nil then
      local gui_data = player_data.gui

      player_data.last_research_speed_estimate = speed

      if gui_data.window.valid and gui_data.window.visible then
        actions.update_etcs(player)
        actions.update_progressbars(player)
      end
    end
  end
end

local function on_tick_translation_handler(event)
  if translationlib.translating_players_count() > 0 then
    translationlib.iterate_batch(event)
  else
    eventlib.on_tick(nil)
  end
end

function actions.register_translation_handler()
  if translationlib.translating_players_count() > 0 then
    eventlib.on_tick(on_tick_translation_handler)
  end
end

function actions.on_string_translated(player, event)
  local player_data = global.players[player.index]
  local gui_data = player_data.gui
  local translation_data = player_data.translations

  local sort_data, finished = translationlib.process_result(event)

  if sort_data then
    if event.translated then
      for tech_name, keys in pairs(sort_data) do
        for _, key in ipairs(keys) do
          local result = event.result
          if translation_data[tech_name] == nil then
            translation_data[tech_name] = {}
          end
          translation_data[tech_name][key] = result
        end
      end
    end

    if finished then
      if gui_data.window.valid and gui_data.window.visible then
        actions.update_techs(player, true)
      end
    end
  end
end

return actions
