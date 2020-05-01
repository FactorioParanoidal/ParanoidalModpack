local idx_inv_chest = defines.inventory.chest
local PT_ptrn = "^Schall%-pickup%-tower%-"
local PT_radius_ptrn = "%a+%-%a(%d+)"
local PT_upper_ptrn = "%-upper$"
local PT_upper_suffix = "-upper"
local PT_upper_radius_ptrn = "%a+%-%a(%d+)%-.+"
local PT_rect_color = {r=0.1, g=0.5, b=0.1, a=0.05}
local PT_mod_name = "SchallPickupTower"



local function contain_negative(t, k)
  return t[k] and t[k] < 0
end

local function filter_allow(unlimitedmode, t, k)
  return unlimitedmode or contain_negative(t, k)
end

local function filter_update(unlimitedmode, t, k, chg)
  if not unlimitedmode then
    t[k] = t[k] + chg
  end
end


local function clear_rendering()
  rendering.clear(PT_mod_name)
  -- game.print("Removed all render objects")
end

local function remove_rectangle(enty)
  if settings.global["Schall-pickup-tower-range-force-disable"].value then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_ids(PT_mod_name)
  local target
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if not target.entity then
        -- game.print("No target uid : " .. id .. ", removed.")
        rendering.destroy(id)
      end
      if target.entity == enty then
        -- game.print("Match uid : " .. id .. ", removed.")
        rendering.destroy(id)
      end
    end
  end
end

local function match_players(players, player, remove)
  if not players then return false, {} end
  for k, v in pairs(players) do
    if v == player then
      if remove then table.remove(players, k) end
      return true, players
    end
  end
  return false, players
end

local function hide_rectangle(enty, player)
  if settings.global["Schall-pickup-tower-range-force-disable"].value then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_ids(PT_mod_name)
  local target
  local match
  local players
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if not target.entity then
        -- game.print("No target uid : " .. id .. ", removed.")
        rendering.destroy(id)
      end
      if target.entity == enty then
        -- game.print("Match uid : " .. id .. ", checking...")
        if rendering.get_visible(id) then
          match, players = match_players(rendering.get_players(id), player, true)
          if match then
            -- game.print("Match uid : " .. id .. ", hid " .. player.name .. ".")
            rendering.set_players(id, players)
          end
          -- if next(players) == nil then
          if #players == 0 then
            -- game.print("Match uid : " .. id .. ", now invisible.")
            rendering.set_visible(id, false)
          end
        else
          -- game.print("Match uid : " .. id .. ", already invisible.")
        end
      end
    end
  end
end

local function add_rectangle(enty, player, radius)
  if settings.global["Schall-pickup-tower-range-force-disable"].value then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_ids(PT_mod_name)
  local offset = {{-radius, -radius}, { radius,  radius}}
  local target
  local found = false
  local match
  local players
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if not target.entity then
        -- game.print("No target uid : " .. id .. ", removed.")
        rendering.destroy(id)
      end
      if target.entity == enty then
        -- Existing rect found, no need to create new
        found = true
        if rendering.get_visible(id) then
          match, players = match_players(rendering.get_players(id), player, false)
          players = rendering.get_players(id)
          if match then
            -- game.print("Match uid : " .. id .. ", already has " .. player.name .. ".")
          else
            -- game.print("Match uid : " .. id .. ", inserted " .. player.name .. ".")
            table.insert(players, player)
            rendering.set_players(id, players)
          end
        else
          -- game.print("Match uid : " .. id .. ", now visible.")
          rendering.set_players(id, {player})
          rendering.set_visible(id, true)
        end
      end
    end
  end
  if not found then
    -- No rect found, create new
    local id = rendering.draw_rectangle{color=PT_rect_color, filled=true, left_top=enty, right_bottom=enty, left_top_offset=offset[1], right_bottom_offset=offset[2], surface=enty.surface, players={player}, draw_on_ground=true}
    -- game.print("Create new uid : " .. id .. ", for " .. player.name .. ".")
    -- player.print("Rect type: \"" .. rendering.get_type(uid) .. "\"  uid : " .. id)
  end
end


local function built_entity(e)
  local entity = e.entity or e.created_entity
  if not entity or not entity.valid or not entity.name:match(PT_ptrn) or entity.name:match(PT_upper_ptrn) then return end
  local surface = entity.surface
  local position = entity.position
  position.y = position.y + 0.01
  local force = entity.force
  local chest = entity
  local tower = surface.create_entity({name = entity.name..PT_upper_suffix, position = position, force = force}) -- force = "neutral"
  tower.destructible = false
end


local function mined_entity(e)
  local entity = e.entity
  if not entity or not entity.valid or not entity.name:match(PT_ptrn) then return end
  remove_rectangle(entity)
  local surface = entity.surface
  local position = entity.position
  local area = {{position.x-0.5, position.y-0.5}, {position.x+0.5, position.y+0.5}}
  local search_results = surface.find_entities_filtered{area = area, type = "radar"}
  -- log(" "..#search_results.." related entities removed.")
  for _,v in pairs(search_results) do
    -- log("  "..v.name)
    v.destroy()
  end
end


local function entity_died(e)
  local entity = e.entity
  mined_entity(e)
end


local function sector_scanned(e)
  local radar = e.radar
  if not radar or not radar.valid or not radar.name:match(PT_ptrn) then return end
  local surface = radar.surface
  local position = radar.position
  local pickupradius = tonumber(radar.name:match(PT_upper_radius_ptrn))
  -- log("Tower " .. radar.unit_number .. " has radius " .. pickupradius)
  -- Look for chest
  local area = {{position.x-0.5, position.y-0.5}, {position.x+0.5, position.y+0.5}}
  local search_results = surface.find_entities_filtered{area = area, type = "container"}
  if #search_results < 1 then return end
  local inv = search_results[1].get_inventory(idx_inv_chest)
  local i = #inv
  -- Use signals to determine limited mode and filters
  local signals = search_results[1].get_merged_signals(defines.circuit_connector_id.container)
  local unlimitedmode = true
  local filters = {}
  if signals then
    unlimitedmode = false
    for _, v in pairs(signals) do
      filters[v.signal.name] = v.count
    end
  end
  -- Search for items on ground
  area = {{position.x-pickupradius, position.y-pickupradius}, {position.x+pickupradius, position.y+pickupradius}}
  local itemproto = game.item_prototypes
  local item_cnt = {}
  local totalcnt = 0
  for _, enty in pairs(surface.find_entities_filtered{area=area, type="item-entity"}) do
    local stack = enty.stack
    local suc_insert = 0
    if filter_allow(unlimitedmode, filters, stack.name) then
      if stack.grid or stack.is_blueprint or stack.is_blueprint_book or stack.is_armor or stack.is_item_with_inventory or stack.is_item_with_entity_data or stack.is_deconstruction_item then
        while i > 0 and inv[i].valid_for_read do i = i-1 end
        -- if i > 1 then suc_insert = inv[i].set_stack(stack) end
        if i > 1 and inv[i].set_stack(stack) then suc_insert = 1 end
      elseif stack.durability then
        suc_insert = inv.insert({name=stack.name, durability=stack.durability})
      elseif stack.type=="ammo" then
        suc_insert = inv.insert({name=stack.name, ammo=stack.ammo})
      else
        suc_insert = inv.insert(stack)
      end
      if suc_insert > 0 then
        totalcnt = totalcnt + suc_insert
        item_cnt[stack.name] = (item_cnt[stack.name] or 0) + suc_insert
        filter_update(unlimitedmode, filters, stack.name, suc_insert)
        stack.clear()
      end
    end
  end
  for k,v in pairs(item_cnt) do
    surface.create_entity{name = "flying-text", position = position, text = {"description.Schall-flying-text-item",itemproto[k].localised_name,"+",v,inv.get_item_count(itemproto[k].name)}}
    position.y = position.y + 0.5
    -- log("  Picked up " .. totalcnt .. " items.")
  end
end


local function selected_entity_changed(e)
  if settings.global["Schall-pickup-tower-range-force-disable"].value then return end
  local player = game.players[e.player_index]
  local last = e.last_entity
  if last and last.valid and last.name:match(PT_ptrn) and not last.name:match(PT_upper_ptrn) then
    hide_rectangle(last, player)
  end
  if not player.mod_settings["Schall-pickup-tower-range-show"].value then return end
  local selection = player.selected
  if selection and selection.valid and selection.name:match(PT_ptrn) and not selection.name:match(PT_upper_ptrn) then
    local pickupradius = tonumber(selection.name:match(PT_radius_ptrn))
    -- player.print("Tower found : " .. selection.name .. "  Radius: " .. pickupradius)
    add_rectangle(selection, player, pickupradius)
  end
end


local function runtime_mod_setting_changed(e)
  if e.setting == "Schall-pickup-tower-range-force-disable" and settings.global[e.setting].value then
    clear_rendering()
  end
end



script.on_event(defines.events.on_sector_scanned,                       sector_scanned)
script.on_event({defines.events.on_built_entity,
                 defines.events.on_robot_built_entity,
                 defines.events.script_raised_built,
                 defines.events.script_raised_revive},                  built_entity)
script.on_event({defines.events.on_player_mined_entity,
                 defines.events.on_robot_mined_entity},                 mined_entity)
script.on_event({defines.events.on_entity_died,
                 defines.events.script_raised_destroy},                 entity_died)
script.on_event(defines.events.on_selected_entity_changed,              selected_entity_changed)
script.on_event(defines.events.on_runtime_mod_setting_changed,          runtime_mod_setting_changed)
