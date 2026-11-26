-- Pickup tower: a passive provider chest with a hidden radar on top. The radar draws power and
-- finishes one sector scan per interval; on_sector_scanned moves ground items around the chest into it.
--
-- storage.towers[chest unit] = {chest, radar, radar_unit, tier, radius, x, y}
-- storage.by_radar[radar unit] = chest unit
-- storage.views[player index].by_unit[chest unit] = render object  -- ranges while a tower is in the cursor
-- storage.hover[player index] = render object      -- range of the hovered tower
local S = require("shared")

local MAX_ITEMS = 1000      -- ground items looked at per pickup; the rest wait for the next one
local TEXT_KINDS = 6        -- item kinds listed in the pickup text
local TEXT_REACH = 32       -- the text is shown to players within radius + this many tiles
local RANGE_COLOR = {r = 0.125, g = 0.05, b = 0.05, a = 0.05}

local CHEST_INV = defines.inventory.chest
local RED, GREEN = defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green
local ENTITY_TARGET = defines.target_type.entity

local TOWER, RADAR = {}, {}
local tower_filter, all_filter = {}, {}
for tier in ipairs(S.tiers) do
  TOWER[S.tower(tier)] = tier
  RADAR[S.radar(tier)] = tier
  tower_filter[#tower_filter + 1] = {filter = "name", name = S.tower(tier)}
  all_filter[#all_filter + 1] = {filter = "name", name = S.tower(tier)}
  all_filter[#all_filter + 1] = {filter = "name", name = S.radar(tier)}
end

-- Item types whose stacks carry data (grids, inventories, blueprints, tags): moved whole into an empty slot.
local DATA_TYPES = {
  ["armor"] = true, ["blueprint"] = true, ["blueprint-book"] = true, ["deconstruction-item"] = true,
  ["upgrade-item"] = true, ["item-with-inventory"] = true, ["item-with-entity-data"] = true,
  ["item-with-tags"] = true, ["selection-tool"] = true, ["copy-paste-tool"] = true, ["spidertron-remote"] = true,
}
local carries_data = setmetatable({}, {__index = function(t, name)
  local proto = prototypes.item[name]
  local v = proto ~= nil and (DATA_TYPES[proto.type] or proto.equipment_grid ~= nil) or false
  t[name] = v
  return v
end})

local show_cache = {}  -- player index -> per-user setting value
local function shows(player)
  local v = show_cache[player.index]
  if v == nil then
    v = player.mod_settings[S.show_setting].value
    show_cache[player.index] = v
  end
  return v
end

---------------------------------------------------------------------------------------------------
-- Range rectangles

local function draw_range(rec, player)
  local r = rec.radius
  return rendering.draw_rectangle{
    color = RANGE_COLOR, filled = true, draw_on_ground = true,
    left_top = {entity = rec.chest, offset = {-r, -r}},
    right_bottom = {entity = rec.chest, offset = {r, r}},
    surface = rec.chest.surface, players = {player},
  }
end

local function hide_view(index)
  local view = storage.views[index]
  if not view then return end
  -- Older saves kept a plain list. Its entity anchors still expire normally.
  for _, obj in pairs(view.by_unit or view) do obj.destroy() end
  storage.views[index] = nil
end

local function hide_hover(index)
  local obj = storage.hover[index]
  if obj then
    obj.destroy()
    storage.hover[index] = nil
  end
end

local function show_view(player)
  hide_view(player.index)
  local by_unit = {}
  local force, surface = player.force, player.surface
  for unit, rec in pairs(storage.towers) do
    local chest = rec.chest
    if chest.valid and chest.surface == surface and chest.force == force then
      by_unit[unit] = draw_range(rec, player)
    end
  end
  storage.views[player.index] = {by_unit = by_unit}
end

local function in_cursor(player)
  local stack = player.cursor_stack
  if stack and stack.valid_for_read then return TOWER[stack.name] ~= nil end
  local ghost = player.cursor_ghost
  if ghost then
    local name = ghost.name
    if type(name) ~= "string" then name = name.name end
    return TOWER[name] ~= nil
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Registry

local retry_radars
local retry_live = false

local function sync_retry()
  local want = storage.radar_retry and next(storage.radar_retry) ~= nil or false
  if want ~= retry_live then
    retry_live = want
    script.on_nth_tick(60, want and retry_radars or nil)
  end
end

local function remove_retry(rec)
  if storage.radar_retry then storage.radar_retry[rec.chest_unit] = nil end
  if storage.radar_retry_cursor == rec.chest_unit then storage.radar_retry_cursor = nil end
  sync_retry()
end

local function place_radar(rec)
  local chest = rec.chest
  local pos = chest.position
  rec.x, rec.y = pos.x, pos.y
  local radar = chest.surface.create_entity{
    name = S.radar(rec.tier), position = {pos.x, pos.y + 0.01}, force = chest.force,
    create_build_effect_smoke = false,
  }
  if not (radar and radar.valid) then
    rec.radar, rec.radar_unit = nil, nil
    storage.radar_retry = storage.radar_retry or {}
    storage.radar_retry[rec.chest_unit] = rec
    if not rec.radar_warned then
      log("Pickup Tower: radar creation failed for tower " .. rec.chest_unit .. "; retry scheduled")
      rec.radar_warned = true
    end
    sync_retry()
    return false
  end
  radar.destructible = false
  rec.radar, rec.radar_unit = radar, radar.unit_number
  rec.radar_warned = nil
  storage.by_radar[rec.radar_unit] = rec.chest_unit
  script.register_on_object_destroyed(radar)
  remove_retry(rec)
  return true
end

local function add_tower(chest)
  local unit = chest.unit_number
  if storage.towers[unit] then return end
  local tier = TOWER[chest.name]
  local rec = {
    chest = chest, chest_unit = unit, tier = tier,
    radius = S.tiers[tier].radius * chest.quality.range_multiplier,
  }
  storage.towers[unit] = rec
  script.register_on_object_destroyed(chest)
  place_radar(rec)

  local force, surface = chest.force, chest.surface
  for index, view in pairs(storage.views) do
    local player = game.get_player(index)
    if player and player.connected and player.force == force and player.surface == surface then
      if view.by_unit then view.by_unit[unit] = draw_range(rec, player)
      else show_view(player) end -- Upgrade a legacy view on demand.
    end
  end
end

local function drop_radar(rec)
  if rec.radar_unit then storage.by_radar[rec.radar_unit] = nil end
  if rec.radar and rec.radar.valid then rec.radar.destroy() end
  rec.radar, rec.radar_unit = nil, nil
end

local function remove_tower(unit)
  local rec = storage.towers[unit]
  if not rec then return end
  storage.towers[unit] = nil
  for _, view in pairs(storage.views) do
    local by_unit = view.by_unit
    local obj = by_unit and by_unit[unit]
    if obj then
      obj.destroy()
      by_unit[unit] = nil
    end
  end
  remove_retry(rec)
  drop_radar(rec)
end

-- Failure-only work: one pending tower per second, round-robin until it recovers.
retry_radars = function()
  local queue = storage.radar_retry
  if not queue then sync_retry(); return end
  local key = next(queue, storage.radar_retry_cursor)
  if not key then key = next(queue) end
  if key then
    storage.radar_retry_cursor = key
    local rec = queue[key]
    if storage.towers[key] ~= rec then
      remove_retry(rec)
    elseif not rec.chest.valid then
      remove_tower(key)
    else
      place_radar(rec)
    end
  end
  sync_retry()
end

local function follow_chest(rec)
  local pos = rec.chest.position
  if pos.x ~= rec.x or pos.y ~= rec.y then
    rec.x, rec.y = pos.x, pos.y
    if rec.radar and rec.radar.valid then rec.radar.teleport({pos.x, pos.y + 0.01}) end
  end
end

-- Full rebuild: every placed tower gets a fresh record and radar; stray radars are removed.
local function rebuild()
  storage.towers, storage.by_radar = {}, {}
  storage.radar_retry, storage.radar_retry_cursor = {}, nil
  sync_retry()
  for index in pairs(storage.views) do hide_view(index) end
  for index in pairs(storage.hover) do hide_hover(index) end
  local towers, radars = {}, {}
  for name in pairs(TOWER) do towers[#towers + 1] = name end
  for name in pairs(RADAR) do radars[#radars + 1] = name end
  for _, surface in pairs(game.surfaces) do
    for _, radar in pairs(surface.find_entities_filtered{name = radars}) do radar.destroy() end
    for _, chest in pairs(surface.find_entities_filtered{name = towers}) do add_tower(chest) end
  end
end

local function init_storage()
  storage.towers = storage.towers or {}
  storage.by_radar = storage.by_radar or {}
  storage.radar_retry = storage.radar_retry or {}
  storage.views = storage.views or {}
  storage.hover = storage.hover or {}
end

---------------------------------------------------------------------------------------------------
-- Pickup

-- Wired chest: only items with a negative network sum (its own contents included) are taken, up to that sum.
local function allowance(chest)
  local signals = chest.get_signals(RED, GREEN)
  if not signals then return nil end
  local allow = {}
  for i = 1, #signals do
    local s = signals[i]
    local id = s.signal
    if (id.type == nil or id.type == "item") and id.name then
      allow[id.name] = (allow[id.name] or 0) - s.count
    end
  end
  return allow
end

local function announce(rec, pos, got, kinds, more)
  local players = rec.chest.force.connected_players
  if #players == 0 then return end
  local parts = {}
  for i = 1, kinds do
    local g = got[i]
    if g.quality == "normal" then
      parts[i] = "+" .. g.count .. " [item=" .. g.name .. "]"
    else
      parts[i] = "+" .. g.count .. " [item=" .. g.name .. ",quality=" .. g.quality .. "]"
    end
  end
  if more then parts[#parts + 1] = "…" end
  local text = table.concat(parts, " ")
  local surface = rec.chest.surface
  local reach = rec.radius + TEXT_REACH
  reach = reach * reach
  for _, player in pairs(players) do
    if player.surface == surface then
      local p = player.position
      local dx, dy = p.x - pos.x, p.y - pos.y
      if dx * dx + dy * dy <= reach then
        player.create_local_flying_text{text = text, position = pos, surface = surface}
      end
    end
  end
end

local function pickup(rec)
  local chest = rec.chest
  local inv = chest.get_inventory(CHEST_INV)
  if inv.is_full() then return end
  follow_chest(rec)
  local x, y, r = rec.x, rec.y, rec.radius
  local items = chest.surface.find_entities_filtered{
    area = {{x - r, y - r}, {x + r, y + r}}, type = "item-entity", limit = MAX_ITEMS,
  }
  if not items[1] then return end

  local allow = allowance(chest)
  local bar = inv.supports_bar() and inv.get_bar() or #inv + 1
  local blocked = {}           -- name -> quality -> true: did not fit during this pickup
  local index, got = {}, {}    -- name .. quality -> entry of got
  local kinds, more = 0, false

  for i = 1, #items do
    local ent = items[i]
    local stack = ent.stack
    if stack.valid_for_read then
      local name = stack.name
      local left = allow and allow[name]
      if not allow or (left and left > 0) then
        local quality = stack.quality.name
        local b = blocked[name]
        if not (b and b[quality]) then
          local count = stack.count
          local want = (left and left < count) and left or count
          local moved = 0
          local native_transfer = false
          if carries_data[name] then
            if want == count then
              local slot, slot_index = inv.find_empty_stack()
              if slot and slot_index < bar and slot.set_stack(stack) then moved = count end
            end
          elseif want == count then
            native_transfer = true
            moved = inv.transfer_from_stack(stack)
          else
            stack.count = want
            moved = inv.insert(stack)
            stack.count = count
          end

          if moved > 0 then
            -- A full native move may already invalidate the ground entity/stack.
            if moved >= count then
              if ent.valid then ent.destroy() end
            elseif not native_transfer then
              stack.count = count - moved
            end
            if allow then allow[name] = left - moved end
            local key = name .. "|" .. quality
            local g = index[key]
            if g then
              g.count = g.count + moved
            elseif kinds < TEXT_KINDS then
              kinds = kinds + 1
              g = {name = name, quality = quality, count = moved}
              got[kinds], index[key] = g, g
            else
              more = true
            end
          end
          if moved < want then
            if not b then b = {}; blocked[name] = b end
            b[quality] = true
            if inv.is_full() then break end
          end
        end
      end
    end
  end

  if kinds > 0 then announce(rec, {x = x, y = y}, got, kinds, more) end
end

---------------------------------------------------------------------------------------------------
-- Events

local function on_built(e)
  local entity = e.entity or e.destination
  if entity and entity.valid and TOWER[entity.name] then add_tower(entity) end
end

local function on_removed(e)
  local entity = e.entity
  if entity and entity.valid then remove_tower(entity.unit_number) end
end

local function on_cloned(e)
  local entity = e.destination
  if not (entity and entity.valid) then return end
  if RADAR[entity.name] then
    if not storage.by_radar[entity.unit_number] then entity.destroy() end
  elseif TOWER[entity.name] then
    add_tower(entity)
  end
end

local function on_moved(entity)
  if not (entity and entity.valid and TOWER[entity.name]) then return end
  local rec = storage.towers[entity.unit_number]
  if rec then follow_chest(rec) end
end

local function on_destroyed(e)
  if e.type ~= ENTITY_TARGET then return end
  local id = e.useful_id
  if storage.towers[id] then
    remove_tower(id)
    return
  end
  local unit = storage.by_radar[id]
  if not unit then return end
  storage.by_radar[id] = nil
  local rec = storage.towers[unit]
  if rec and rec.radar_unit == id then
    rec.radar, rec.radar_unit = nil, nil
    if rec.chest.valid then place_radar(rec) else remove_tower(unit) end
  end
end

local function on_scanned(e)
  local radar = e.radar
  if not (radar and radar.valid) then return end
  local unit = storage.by_radar[radar.unit_number]
  local rec = unit and storage.towers[unit]
  if not rec then
    radar.destroy()
  elseif not rec.chest.valid then
    remove_tower(unit)
  else
    pickup(rec)
  end
end

local function update_hover(player)
  local index = player.index
  hide_hover(index)
  if not player.connected or storage.views[index] or not shows(player) then return end
  local selected = player.selected
  if not selected then return end
  local name = selected.name
  local unit
  if TOWER[name] then
    unit = selected.unit_number
  elseif RADAR[name] then
    unit = storage.by_radar[selected.unit_number]
  else
    return
  end
  local rec = unit and storage.towers[unit]
  if rec and rec.chest.valid and rec.chest.surface == player.surface then
    storage.hover[index] = draw_range(rec, player)
  end
end

local function update_view(player, refresh)
  local index = player.index
  local view = storage.views[index]
  if player.connected and shows(player) and in_cursor(player) then
    if refresh or not view or not view.by_unit then
      hide_hover(index)
      show_view(player)
    end
  elseif view or refresh then
    hide_view(index)
    update_hover(player)
  end
end

local function on_cursor(e)
  local player = game.get_player(e.player_index)
  if player then update_view(player, false) end
end

local function on_selected(e)
  local player = game.get_player(e.player_index)
  if player then update_hover(player) end
end

local function refresh_player(e)
  local player = game.get_player(e.player_index)
  if player then update_view(player, true) end
end

local function clear_player(e)
  hide_view(e.player_index)
  hide_hover(e.player_index)
  show_cache[e.player_index] = nil
end

local function on_setting(e)
  if e.setting ~= S.show_setting or not e.player_index then return end
  show_cache[e.player_index] = nil
  refresh_player(e)
end

local function rebuild_and_refresh()
  rebuild()
  for _, player in pairs(game.connected_players) do update_view(player, true) end
end

-- Even Pickier Dollies: the tower chest may be moved, the hidden radar may not.
local function dollies(blacklist)
  local api = remote.interfaces["PickerDollies"]
  if not api then return end
  if api.dolly_moved_entity_id then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), function(e) on_moved(e.moved_entity) end)
  end
  if blacklist and api.add_blacklist_name then
    for name in pairs(RADAR) do remote.call("PickerDollies", "add_blacklist_name", name) end
  end
end

for _, id in ipairs({"on_built_entity", "on_robot_built_entity", "script_raised_built", "script_raised_revive",
    "on_space_platform_built_entity"}) do
  script.on_event(defines.events[id], on_built, tower_filter)
end
for _, id in ipairs({"on_player_mined_entity", "on_robot_mined_entity", "on_space_platform_mined_entity",
    "on_entity_died", "script_raised_destroy"}) do
  script.on_event(defines.events[id], on_removed, tower_filter)
end
script.on_event(defines.events.on_entity_cloned, on_cloned, all_filter)
script.on_event(defines.events.script_raised_teleported, function(e) on_moved(e.entity) end, tower_filter)
script.on_event(defines.events.on_object_destroyed, on_destroyed)
script.on_event(defines.events.on_sector_scanned, on_scanned, (function()
  local f = {}
  for name in pairs(RADAR) do f[#f + 1] = {filter = "name", name = name} end
  return f
end)())
script.on_event(defines.events.on_player_cursor_stack_changed, on_cursor)
script.on_event(defines.events.on_selected_entity_changed, on_selected)
script.on_event({defines.events.on_player_changed_surface, defines.events.on_player_changed_force,
    defines.events.on_player_joined_game}, refresh_player)
script.on_event({defines.events.on_player_left_game, defines.events.on_player_removed}, clear_player)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_setting)
script.on_event(defines.events.on_forces_merged, rebuild_and_refresh)

script.on_init(function()
  init_storage()
  rebuild_and_refresh()
  dollies(true)
end)

script.on_load(function()
  dollies(false)
  sync_retry()
end)

script.on_configuration_changed(function()
  init_storage()
  rebuild_and_refresh()
  dollies(true)
end)
