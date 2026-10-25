-- The squad command tool and the selection of a squad.
--   select (drag or click):        pick the squad of the selected droids (or the nearest one);
--                                  empty ground deselects
--   alt-select (Shift + drag):     the picked squad attack-moves to the middle of the box
--   reverse-select (right drag):   pick up the selected droids
-- A picked squad is shown only to the picking player: a mark on every member, a label with
-- the squad number and size above one member, and a line to where the squad is going.
local shared = require("lib.shared")
local config = require("script.config")
local state = require("script.state")
local Squad = require("script.squad")
local util = require("script.util")

local is_droid = shared.is_droid
local rendering = rendering

local tools = {}

local LINE_COLOR = {r = 0.2, g = 0.9, b = 0.2, a = 0.6}
local TEXT_COLOR = {r = 0.6, g = 1, b = 0.6}

local function area_center(area)
  local lt, rb = area.left_top, area.right_bottom
  return {x = (lt.x + rb.x) / 2, y = (lt.y + rb.y) / 2}
end

local function flying_text(player, text)
  player.create_local_flying_text({text = text, create_at_cursor = true})
end

------------------------------------------------------------------------------------------
-- Selection visuals

local function clear_objects(selection)
  for _, object in pairs(selection.objects) do
    if object.valid then object.destroy() end
  end
  selection.objects = {}
end

local function draw(player, selection, squad)
  clear_objects(selection)
  local objects = selection.objects
  local players = {player}
  local leader
  for _, member in pairs(squad.members) do
    if member.valid then
      leader = leader or member
      objects[#objects + 1] = rendering.draw_sprite({
        sprite = shared.selection_sprite,
        target = member,
        surface = member.surface,
        players = players,
        x_scale = 0.5,
        y_scale = 0.5,
        render_layer = "selection-box",
      })
    end
  end
  if not leader then return end
  objects[#objects + 1] = rendering.draw_text({
    text = {"robotarmy-gui.squad-label", squad.id, squad.size},
    target = {entity = leader, offset = {0, -2.2}},
    surface = leader.surface,
    players = players,
    color = TEXT_COLOR,
    alignment = "center",
    scale = 1.2,
  })
  local destination = Squad.destination(squad)
  if destination and util.distance2(leader.position, destination) > 25 then
    objects[#objects + 1] = rendering.draw_line({
      from = leader,
      to = destination,
      surface = leader.surface,
      players = players,
      color = LINE_COLOR,
      width = 2,
      dash_length = 0.6,
      gap_length = 0.4,
    })
  end
end

function tools.deselect(player_index)
  local selection = storage.selection[player_index]
  if not selection then return end
  clear_objects(selection)
  storage.selection[player_index] = nil
end

function tools.select(player, squad)
  tools.deselect(player.index)
  local selection = {squad = squad.id, objects = {}}
  storage.selection[player.index] = selection
  draw(player, selection, squad)
end

--- Squad picked by a player, or nil (a squad that is gone deselects itself).
function tools.selected_squad(player_index)
  local selection = storage.selection[player_index]
  if not selection then return nil end
  local squad = storage.squads[selection.squad]
  if not squad or squad.size <= 0 then
    tools.deselect(player_index)
    return nil
  end
  return squad
end

--- Periodic redraw (members join and die, the squad moves on).
function tools.refresh()
  for player_index, selection in pairs(storage.selection) do
    local player = game.get_player(player_index)
    local squad = player and tools.selected_squad(player_index)
    if squad and player.force.index == squad.force_index then
      draw(player, selection, squad)
    else
      tools.deselect(player_index)
    end
  end
end

------------------------------------------------------------------------------------------
-- Tool actions

--- Squad most of the selected droids belong to, or the nearest squad to the click.
local function squad_from_event(fd, event)
  local counts, best, best_count = {}, nil, 0
  local unit_squad = storage.unit_squad
  for _, entity in pairs(event.entities) do
    local id = entity.valid and unit_squad[entity.unit_number]
    if id then
      local n = (counts[id] or 0) + 1
      counts[id] = n
      if n > best_count then
        best, best_count = id, n
      end
    end
  end
  local squad = best and storage.squads[best]
  if squad and squad.force_index == fd.force.index then return squad end
  return Squad.find_near(fd, event.surface.index, area_center(event.area), config.SQUAD_CHECK_RANGE)
end

local function on_select(player, event)
  local squad = squad_from_event(state.force_data(player.force), event)
  if squad then
    tools.select(player, squad)
    flying_text(player, {"robotarmy-gui.squad-label", squad.id, squad.size})
  else
    tools.deselect(player.index)
  end
end

--- Orders a squad to attack-move to a position (tool or GUI).
function tools.order_attack(squad, position)
  local group = Squad.ensure_group(squad)
  if not group then return false end
  squad.qrf = nil
  squad.hold = nil
  Squad.order_attack(squad, position)
  return true
end

local function on_command(player, event)
  local squad = tools.selected_squad(player.index)
  if not squad or squad.force_index ~= player.force.index then
    flying_text(player, {"robotarmy-gui.no-squad-selected"})
    return
  end
  if squad.surface_index ~= event.surface.index then
    flying_text(player, {"robotarmy-gui.other-surface"})
    return
  end
  tools.order_attack(squad, area_center(event.area))
  tools.refresh()
end

local function pick_up(player, event)
  local picked, full = 0, false
  for _, unit in pairs(event.entities) do
    if unit.valid and is_droid[unit.name] then
      local max_health = unit.max_health
      local stack = {
        name = unit.name,
        count = 1,
        quality = unit.quality.name,
        health = max_health > 0 and unit.health / max_health or 1,
      }
      if player.insert(stack) == 0 then
        full = true
        break
      end
      unit.destroy({raise_destroy = true})
      picked = picked + 1
    end
  end
  if full then
    flying_text(player, {"robotarmy-gui.pickup-no-space", picked})
  elseif picked > 0 then
    flying_text(player, {"robotarmy-gui.picked-up", picked})
  end
end

------------------------------------------------------------------------------------------

function tools.on_selected_area(event)
  if event.item ~= shared.tool then return end
  local player = game.get_player(event.player_index)
  if player then on_select(player, event) end
end

function tools.on_alt_selected_area(event)
  if event.item ~= shared.tool then return end
  local player = game.get_player(event.player_index)
  if player then on_command(player, event) end
end

function tools.on_reverse_selected_area(event)
  if event.item ~= shared.tool then return end
  local player = game.get_player(event.player_index)
  if player then pick_up(player, event) end
end

return tools
