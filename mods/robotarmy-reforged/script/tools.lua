-- The squad command tool and the selection of a squad.
--   select (drag or click):        pick the squad of the selected droids (or the nearest one);
--                                  empty ground deselects
--   alt-select (Shift + drag):     the picked squad attack-moves to the middle of the box
--   reverse-select (right drag):   pick up the selected droids
--   alt-reverse-select (Shift + right drag): merge the squads of the selected droids into one
--   while a player sets the rally point of a droid assembler (button in its panel), a click with
--   the tool sets it instead of picking a squad
-- A picked squad is shown only to the picking player: a mark on every member, a label with
-- the squad number and size above one member, and a line to where the squad is going
-- (the label and the line also on the map).
local shared = require("lib.shared")
local config = require("script.config")
local state = require("script.state")
local Squad = require("script.squad")
local util = require("script.util")
local droids = require("script.droids")
local spawners = require("script.spawners")

local is_droid = droids.is_droid
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
  local label = {"robotarmy-gui.squad-label", squad.id, squad.size}
  objects[#objects + 1] = rendering.draw_text({
    text = label,
    target = {entity = leader, offset = {0, -2.2}},
    surface = leader.surface,
    players = players,
    color = TEXT_COLOR,
    alignment = "center",
    scale = 1.2,
  })
  -- map view: the label at the squad and the line (redrawn with the marks every GUI period)
  local at = leader.position
  objects[#objects + 1] = rendering.draw_text({
    text = label,
    target = {at.x, at.y - 3},
    surface = leader.surface,
    players = players,
    color = TEXT_COLOR,
    alignment = "center",
    scale = 3,
    render_mode = "chart",
  })
  local destination = Squad.destination(squad)
  if destination and util.distance2(at, destination) > 25 then
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
    objects[#objects + 1] = rendering.draw_line({
      from = at,
      to = destination,
      surface = leader.surface,
      players = players,
      color = LINE_COLOR,
      width = 3,
      dash_length = 2,
      gap_length = 1,
      render_mode = "chart",
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

------------------------------------------------------------------------------------------
-- Rally point of a droid assembler

--- The panel button: the next click with the tool sets the rally point of the assembler.
function tools.start_rally_pick(player, unit_number)
  storage.rally_pick[player.index] = unit_number
  if player.clear_cursor() then
    player.cursor_stack.set_stack({name = shared.tool})
  end
  player.opened = nil
  flying_text(player, {"robotarmy-gui.rally-pick", shared.rally_range})
end

--- The tool left the cursor: no more rally point picking.
function tools.on_cursor_changed(event)
  if not storage.rally_pick[event.player_index] then return end
  local player = game.get_player(event.player_index)
  local stack = player and player.cursor_stack
  if not (stack and stack.valid_for_read and stack.name == shared.tool) then
    storage.rally_pick[event.player_index] = nil
  end
end

local function set_rally(player, event, unit_number)
  storage.rally_pick[player.index] = nil
  local record = storage.spawners[unit_number]
  if not (record and record.entity.valid and record.entity.force.index == player.force.index) then return end
  if record.entity.surface_index ~= event.surface.index then
    flying_text(player, {"robotarmy-gui.other-surface"})
    return
  end
  if spawners.set_rally(record, area_center(event.area)) then
    flying_text(player, {"robotarmy-gui.rally-set"})
  else
    flying_text(player, {"robotarmy-gui.rally-too-far", shared.rally_range})
  end
end

local function on_select(player, event)
  local rally = storage.rally_pick[player.index]
  if rally then
    set_rally(player, event, rally)
    return
  end
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
  local picked, full, veterans = 0, false, 0
  for _, unit in pairs(event.entities) do
    if unit.valid and is_droid[unit.name] and (droids.rank[unit.name] or 0) > 0 then
      veterans = veterans + 1 -- the rank would be lost: only a drop pod carries veterans
    elseif unit.valid and is_droid[unit.name] then
      local max_health = unit.max_health
      local stack = {
        name = droids.kind[unit.name],
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
  elseif veterans > 0 then
    flying_text(player, {"robotarmy-gui.pickup-veterans", picked, veterans})
  elseif picked > 0 then
    flying_text(player, {"robotarmy-gui.picked-up", picked})
  end
end

--- Merges the squads of the selected droids (garrisons excluded) into the biggest one.
local function merge_selected(player, event)
  local fd = state.force_data(player.force)
  local ids, list = {}, {}
  local unit_squad = storage.unit_squad
  for _, entity in pairs(event.entities) do
    local id = entity.valid and unit_squad[entity.unit_number]
    local squad = id and not ids[id] and storage.squads[id]
    if squad then
      ids[id] = true
      if squad.force_index == fd.force.index and not squad.station and squad.mode ~= Squad.MODE.guard then
        list[#list + 1] = squad
      end
    end
  end
  if #list < 2 then
    flying_text(player, {"robotarmy-gui.merge-nothing"})
    return
  end
  table.sort(list, function(a, b) return a.size > b.size end)
  local into = list[1]
  local merged = 1
  for i = 2, #list do
    local other = list[i]
    if not other.deleted and other.surface_index == into.surface_index then
      into = Squad.merge(into, other) or into
      merged = merged + 1
    end
  end
  if merged < 2 then
    flying_text(player, {"robotarmy-gui.merge-nothing"})
    return
  end
  into.order.dirty = true
  tools.select(player, into)
  flying_text(player, {"robotarmy-gui.merged", merged, into.id, into.size})
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

function tools.on_alt_reverse_selected_area(event)
  if event.item ~= shared.tool then return end
  local player = game.get_player(event.player_index)
  if player then merge_selected(player, event) end
end

return tools
