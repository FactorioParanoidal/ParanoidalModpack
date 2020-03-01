local idx_inv_chest = defines.inventory.chest



local function built_entity(e)
  local entity = e.created_entity
  if not entity.name:match("^Schall%-pickup%-tower%-") then return end
  local surface = entity.surface
  local position = entity.position
  position.y = position.y + 0.01
  local force = entity.force
  local chest = entity
  local tower = surface.create_entity({name = entity.name.."-upper", position = position, force = force}) -- force = "neutral"
  tower.destructible = false
end


local function mined_entity(e)
  local entity = e.entity
  if not entity.name:match("^Schall%-pickup%-tower%-") then return end
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
  if not radar.name:match("^Schall%-pickup%-tower%-") then return end
  local surface = radar.surface
  local position = radar.position
  local pickupradius = tonumber(radar.name:match("%a+%-%a(%d+)%-.+"))
  -- log("Tower " .. radar.unit_number .. " has radius " .. pickupradius)
  -- Look for chest
  local area = {{position.x-0.5, position.y-0.5}, {position.x+0.5, position.y+0.5}}
  local search_results = surface.find_entities_filtered{area = area, type = "container"}
  if #search_results < 1 then return end
  local inv = search_results[1].get_inventory(idx_inv_chest)
  local i = #inv
  -- Search for items on ground
  area = {{position.x-pickupradius, position.y-pickupradius}, {position.x+pickupradius, position.y+pickupradius}}
  local itemproto = game.item_prototypes
  local item_cnt = {}
  local totalcnt = 0
  for _, enty in pairs(surface.find_entities_filtered{area=area, type="item-entity"}) do
    local stack = enty.stack
    local suc_insert = 0
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
      stack.clear()
    end
  end
  for k,v in pairs(item_cnt) do
    surface.create_entity{name = "flying-text", position = position, text = {"description.Schall-flying-text-item",itemproto[k].localised_name,"+",v,inv.get_item_count(itemproto[k].name)}}
    position.y = position.y + 0.5
    -- log("  Picked up " .. totalcnt .. " items.")
  end
end



script.on_event(defines.events.on_sector_scanned,                       sector_scanned)
script.on_event({defines.events.on_built_entity,
                 defines.events.on_robot_built_entity},                 built_entity)
script.on_event({defines.events.on_player_mined_entity,
                 defines.events.on_robot_mined_entity},                 mined_entity)
script.on_event(defines.events.on_entity_died,                          entity_died)
