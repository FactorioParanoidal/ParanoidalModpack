local PTlib = require("lib.PTlib")
local cfg2 = require("config.config-2")
local PTrender = require("lib.PTrender")



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


local function add_PT(e)
  local entity = e.entity or e.created_entity
  if not entity or not entity.valid or not entity.name:match(cfg2.PT_ptrn) or entity.name:match(cfg2.PT_upper_ptrn) then return end
  local player
  if e.player_index then
    player = game.players[e.player_index]
  elseif e.created_entity and e.created_entity.last_user then
    player = e.created_entity.last_user
  end
  PTrender.add_rectangle(entity, player)
  local surface = entity.surface
  local position = entity.position
  position.y = position.y + 0.01
  local force = entity.force
  local chest = entity
  local tower = surface.create_entity({name = entity.name..cfg2.PT_upper_suffix, position = position, force = force}) -- force = "neutral"
  tower.destructible = false
end

local function remove_PT(e)
  local entity = e.entity
  if not entity or not entity.valid or not entity.name:match(cfg2.PT_ptrn) then return end
  PTrender.remove_rectangle(entity)
  local surface = entity.surface
  local position = entity.position
  local search_results = surface.find_entities_filtered{area = PTlib.box_area(position, 0.5), type = "radar"}
  -- PTlib.debugprint(" "..#search_results.." related entities removed.")
  for _, v in pairs(search_results) do
    -- PTlib.debugprint("  "..v.name)
    v.destroy()
  end
end

local function pickup_items(e)
  local radar = e.radar
  if not radar or not radar.valid or not radar.name:match(cfg2.PT_ptrn) then return end
  local surface = radar.surface
  local position = radar.position
  local pickupradius = tonumber(radar.name:match(cfg2.PT_upper_radius_ptrn))
  -- PTlib.debugprint("Tower " .. radar.unit_number .. " has radius " .. pickupradius)
  -- Look for chest
  local search_results = surface.find_entities_filtered{area = PTlib.box_area(position, 0.5), type = "container"}
  if #search_results < 1 then return end
  local inv = search_results[1].get_inventory(cfg2.idx_inv_chest)
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
  local itemproto = game.item_prototypes
  local item_cnt = {}
  local totalcnt = 0
  for _, enty in pairs(surface.find_entities_filtered{area = PTlib.box_area(position, pickupradius), type = "item-entity"}) do
    local stack = enty.stack
    local suc_insert = 0
    if filter_allow(unlimitedmode, filters, stack.name) then
      if stack.grid or stack.is_blueprint or stack.is_blueprint_book or stack.is_armor or stack.is_item_with_inventory or stack.is_item_with_entity_data or stack.is_deconstruction_item or stack.is_upgrade_item then
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
  for k, v in pairs(item_cnt) do
    PTlib.create_flying_text_item(surface, position, itemproto[k], v, inv)
    position.y = position.y + 0.5
    -- PTlib.debugprint("  Picked up " .. totalcnt .. " items.")
  end
end


local function configuration_changed()
  PTrender.update_legacy()
end

local function runtime_mod_setting_changed(e)
  if e.setting:match("^pickuptower%-") then PTrender.init() end
  if e.setting == "pickuptower-range-force-disable" and settings.global[e.setting].value then
    PTrender.clear_rendering()
  end
end

local function sector_scanned(e)
  pickup_items(e)
end

local function built_entity(e)
  add_PT(e)
end

local function mined_entity(e)
  remove_PT(e)
end

local function entity_died(e)
  remove_PT(e)
end

local function selected_entity_changed(e)
  local player = game.players[e.player_index]
  -- local last = e.last_entity
  PTrender.selection_changed(player)
end

local function player_cursor_stack_changed(e)
  local player = game.players[e.player_index]
  PTrender.cursor_changed(player)
end



script.on_configuration_changed(                                        configuration_changed)
script.on_event(defines.events.on_runtime_mod_setting_changed,          runtime_mod_setting_changed)
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
script.on_event(defines.events.on_player_cursor_stack_changed,          player_cursor_stack_changed)
