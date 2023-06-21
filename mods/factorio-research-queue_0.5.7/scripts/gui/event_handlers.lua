local queue = require('scripts.queue')
local rqtech = require('scripts.rqtech')

local actions = require('.actions')

local event_handlers = {}

function event_handlers.close_window(player, event)
  actions.close_window(player)
end

function event_handlers.enqueue(player, action, event)
  local pos = action.pos
  local tech_id = action.tech
  local force = player.force
  local tech = rqtech.from_id(force, tech_id)
  queue[({
    last = 'enqueue_tail',
    second = 'enqueue_before_head',
    first = 'enqueue_head',
  })[pos]](force, tech)
  queue.update(force)
  for _, player in pairs(force.players) do
    if global.players[player.index] ~= nil then
      actions.update_queue(player, tech)
      actions.update_techs(player)
    end
  end
end

function event_handlers.dequeue(player, action, event)
  local tech_id = action.tech
  local force = player.force
  local tech = rqtech.from_id(force, tech_id)
  queue.dequeue(force, tech)
  queue.update(force)
  for _, player in pairs(force.players) do
    if global.players[player.index] ~= nil then
      actions.update_queue(player)
      actions.update_techs(player)
    end
  end
end

function event_handlers.queue_shift(player, action, event)
  local dir = action.dir
  local tech_id = action.tech
  local force = player.force
  local tech = rqtech.from_id(force, tech_id)
  queue[({
    up = {
      [false] = 'shift_earlier',
      [true] = 'shift_before_earliest',
    },
    down = {
      [false] = 'shift_later',
      [true] = 'shift_latest',
    },
  })[dir][event.shift]](force, tech)
  queue.update(force)
  for _, player in pairs(force.players) do
    if global.players[player.index] ~= nil then
      actions.update_queue(player)
    end
  end
end

function event_handlers.clear_queue(player, event)
  local force = player.force
  queue.clear(force)
  queue.update(force)
  for _, player in pairs(force.players) do
    if global.players[player.index] ~= nil then
      actions.update_queue(player)
      actions.update_techs(player)
    end
  end
end

function event_handlers.toggle_queue_pause(player, event)
  local force = player.force
  queue.toggle_paused(force)
  queue.update(force, 4) -- pause toggle
  for _, player in pairs(force.players) do
    if global.players[player.index] ~= nil then
      actions.update_queue(player)
      actions.update_techs(player)
    end
  end
end

function event_handlers.update_search(player, event)
  actions.update_search(player)
  actions.update_techs(player)
end

function event_handlers.toggle_search(player, event)
  actions.toggle_search(player)
end

function event_handlers.toggle_researched_filter(player, event)
  actions.toggle_researched_filter(player)
  actions.update_techs(player)
end

function event_handlers.toggle_upgrades_filter(player, event)
  actions.toggle_upgrades_filter(player)
  actions.update_techs(player)
end

function event_handlers.toggle_tech_ingredient_filter(player, action, event)
  local tech_ingredient_name = action.tech_ingredient
  local tech_ingredient = game.item_prototypes[tech_ingredient_name]
  actions.toggle_tech_ingredient_filter(player, tech_ingredient)
  actions.update_techs(player)
end

function event_handlers.on_click_tech_button(player, action, event)
  local tech_id = action.tech
  local force = player.force
  local tech = rqtech.from_id(force, tech_id)
  if event.button == defines.mouse_button_type.left then
    if not event.shift and not event.control and not event.alt then
      if not rqtech.is_researched(tech) then
        queue.enqueue_tail(force, tech)
        queue.update(force)
        for _, player in pairs(force.players) do
          if global.players[player.index] ~= nil then
            actions.update_queue(player, tech)
            actions.update_techs(player)
          end
        end
      end
    elseif event.shift and not event.control and not event.alt then
      if not rqtech.is_researched(tech) then
        queue.enqueue_before_head(force, tech)
        queue.update(force)
        for _, player in pairs(force.players) do
          if global.players[player.index] ~= nil then
            actions.update_queue(player, tech)
            actions.update_techs(player)
          end
        end
      end
    elseif not event.shift and not event.control and event.alt then
      player.open_technology_gui(tech.tech.name)
    end
  elseif event.button == defines.mouse_button_type.right then
    if not event.shift and not event.control and not event.alt then
      if not rqtech.is_researched(tech) then
        queue.dequeue(force, tech)
        queue.update(force)
        for _, player in pairs(force.players) do
          if global.players[player.index] ~= nil then
            actions.update_queue(player)
            actions.update_techs(player)
          end
        end
      end
    end
  end
end

function event_handlers.research_current(player, event)
  local force = player.force
  if force.current_research ~= nil then
    force.research_progress = 1
  end
end

function event_handlers.refresh_gui(player, event)
  local player = game.players[event.player_index]
  actions.update_search(player)
  actions.update_queue(player)
  actions.update_techs(player)
end

return event_handlers
