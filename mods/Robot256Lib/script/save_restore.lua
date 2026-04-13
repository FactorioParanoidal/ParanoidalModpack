--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Robot256's Library
 * File: save_restore.lua
 * Description: Functions for converting between inventory, burner, and grid objects and native Lua table structures.
 *   Functions handle items in arrays of SimpleItemStack tables, with the extra "data" field to store blueprints etc.
 *   Functions include nil checking for both objects and arrays.
 *   Functions to insert items into objects return list of stacks representing the items that could not be inserted.
 -]]

require("util")

local __saveGridStacks__ = nil
local __saveGrid__ = nil

local exportable = {["blueprint"]=true,
                    ["blueprint-book"]=true,
                    ["upgrade-planner"]=true,
                    ["deconstruction-planner"]=true,
                    ["item-with-tags"]=true}
                    
local function mergeStackLists(stacks1, stacks2)
  if not stacks2 then
    return stacks1
  end
  if not stacks1 then
    return stacks2
  end
  for _,s in pairs(stacks2) do
    if not s.count then s.count = 1 end
    if s.data or s.health or s.durability or s.ammo then
      table.insert(stacks1, s)
    else
      local found = false
      for _,t in pairs(stacks1) do
        if not t.count then t.count = 1 end
        if (s.name == t.name) and (s.quality == t.quality) and not (t.ammo or t.data or t.durability) then
          t.count = t.count + s.count
          found = true
          break
        end
      end
      if not found then
        table.insert(stacks1, s)
      end
    end
  end
  return stacks1
end


local function itemsToStacks(items)
  local stacks = {}
  if items then
    for name, count in pairs(items) do
      table.insert(stacks, {name=name, count=count})
    end
    if #stacks == 0 then stacks = nil end
    return stacks
  end
end


---------------------------------------------------------------
-- Insert Stack Structure into Inventory.
-- Arguments:  source -> LuaInventory to save contents of
-- Returns:    stacks -> Dictionary [slot#] -> SimpleItemStack with extra optional field "data" storing blueprint export string
---------------------------------------------------------------
local function saveInventoryStacks(source)
  if source and source.valid and not source.is_empty() then
    local stacks = {}
    for slot = 1, #source do
      local stack = source[slot]
      if stack and stack.valid_for_read then
        if exportable[stack.name] then
          table.insert(stacks, {name=stack.name, count=1, data=stack.export_stack()})
        else
          local s = {name=stack.name, count=stack.count, quality=stack.quality}
          if stack.is_ammo then
            if stack.ammo < stack.prototype.magazine_size then
              s.ammo = stack.ammo
            end
          end
          if stack.is_tool then
            if stack.durability < stack.prototype.get_durability(stack.quality) then
              s.durability = stack.durability
            end
          end
          if stack.health < 1 then
            s.health = stack.health
          end
          
          -- TODO: Spoilage
          -- Merge with existing stacks to avoid duplicates
          mergeStackLists(stacks, {s})
          
          -- Can't restore equipment to an item's grid, have to unpack it to the inventory
          if stack.grid and stack.grid.valid then
            local equipStacks, fuelStacks = __saveGridStacks__(__saveGrid__(stack.grid))
            mergeStackLists(stacks, equipStacks)
            mergeStackLists(stacks, fuelStacks)
          end
          
        end
      end
    end
    return stacks
  end
end

---------------------------------------------------------------
-- Insert Stack Structure into Inventory.
-- Arguments:  target -> LuaInventory to insert items into
--             stack -> SimpleItemStack with extra optional field "data" storing blueprint export string.
--             stack_limit (optional) -> integer maximum number of items to insert from the given stack.
-- Returns:    remainder -> SimpleItemStack with extra field "data", representing all the items that could not be inserted at this time.
---------------------------------------------------------------
local function insertStack(target, stack, stack_limit)
  local proto = prototypes.item[stack.name]
  if not stack.count then stack.count = 1 end
  local remainder = table.deepcopy(stack)
  if proto then
    if target.can_insert(stack) then
      if stack.data then
        -- Insert bp item, find ItemStack, import data string
        for i = 1, #target do
          if not target[i].valid_for_read then
            -- this stack is empty, set it to blueprint
            target[i].set_stack(stack)
            target[i].import_stack(stack.data)
            return nil  -- no remainders after insertion
          end
        end
      else
        -- Handle normal item, break into chunks if need be, correct for oversized stacks
        if not stack_limit then
          stack_limit = math.huge
        end
        local d = 0
        if stack.count > stack_limit then
          -- This time we limit ourselves to part of the given stack.
          -- TODO: Handle Spoilage
          d = target.insert({name=stack.name, count=stack_limit, quality=stack.quality})
        else
          -- Only the last part gets assigned ammo and durability ratings of the original stack
          d = target.insert(stack)
        end
        remainder.count = stack.count - d
        if remainder.count == 0 then
          return nil  -- All items inserted, no remainder
        else
          return remainder  -- Not all items inserted, return remainder with original ammo/durability ratings
        end
      end
    else
      -- Can't insert this stack, entire thing is remainder.
      return remainder
    end
  else
    -- Prototype for this item was removed from the game, don't give a remainder.
    return nil
  end
end

---------------------------------------------------------------
-- Spill Stack Structure onto ground.
-- Arguments:  target -> LuaInventory to insert items into
--             stack -> SimpleItemStack with extra optional field "data" storing blueprint export string.
--             stack_limit (optional) -> integer maximum number of items to insert from the given stack.
-- Returns:    remainder -> SimpleItemStack with extra field "data", representing all the items that could not be inserted at this time.
---------------------------------------------------------------
local function spillStack(stack, surface, position)
  if stack then
    surface.spill_item_stack{position=position, stack=stack, allow_belts=false}
    if stack.data then
      -- This is a bp item, find it on the surface and restore data
      for _,entity in pairs(surface.find_entities_filtered{name="item-on-ground",position=position,radius=1000}) do
        -- Check if these are the droids we are looking for
        if entity.stack.valid_for_read then
          local es = entity.stack
          if es.name == stack.name then
            -- TODO: Handle detection of empty deconstruction_planner, upgrade_planner, item_with_tags
            if es.is_blueprint and not es.is_blueprint_setup() then
              -- New empty blueprint, let's import into it
              es.import_stack(stack.data)
              break
            elseif es.is_blueprint_book then
              local estring = es.export_stack()
              -- Compare export string to empty blueprint book
              if estring == "0eNqrVkrKKU0tKMrMK4lPys/PVrKqVsosSc1VskJI6IIldJQSk0syy1LjM/NSUiuUrAx0lMpSi4oz8/OUrIwsDE3MLY3MDc3MzS0tjWprAVWnHQo=" then
                es.import_stack(stack.data)
                break
              end
            elseif es.is_upgrade_item then
              local estring = es.export_stack()
              -- Compare export string to empty upgrade planner
              if estring == "0eNo1yk0KgCAQBtC7fGtbKNGklwmhQQSbxJ824t1b+dZvoOdQ/M1XTl6EC9xA5daihAonPSWF2PiBW3NbU+HjUuMrcObUO1lD+iCy1sz5A4aSHcM=" then
                es.import_stack(stack.data)
                break
              end
            elseif es.is_deconstruction_item then
              local estring = es.export_stack()
              -- Compare export string to empty deconstruction planner
              if estring == "0eNpdy8EKgCAMANB/2dkOSmTuZyJshGAz3Owi/XtdunR98DpsFAuL1hY1FV7OvDJTBewgpJp4F0BuORtISgfgLwxfMHBRlVcA3WxHH5y3k/chuPt+ALDXI9s=" then
                es.import_stack(stack.data)
                break
              end
            elseif es.is_item_with_tags  then
              if not es.tags or table_size(es.tags) == 0 then
                es.import_stack(stack.data)
                break
              end
            end
          end
        end
      end
    end
  end
end

local function spillStacks(stacks, surface, position)
  if stacks then
    for _,s in pairs(stacks) do
      spillStack(s, surface, position)
    end
  end
end


---------------------------------------------------------------
-- Restore Inventory Stack List to Inventory.
-- Arguments:  target -> LuaInventory to insert items into
--             stacks -> List of SimpleItemStack with extra optional field "data" storing blueprint export string.
-- Returns:    remainders -> List of SimpleItemStacks representing all the items that could not be inserted at this time.
---------------------------------------------------------------
local function insertInventoryStacks(target, stacks)
  local remainders = {}
  if target and target.valid and stacks then
    for _,stack in pairs(stacks) do
      local r = insertStack(target, stack)
      if r then 
        table.insert(remainders, r)
      end
    end
  elseif stacks then
    -- If inventory invalid, return entire contents
    return stacks
  end
  if #remainders > 0 then
    return remainders
  else
    return nil
  end
end


local function saveBurner(burner)
  if burner and burner.valid then
    local saved = {heat = burner.heat}
    if burner.currently_burning then
      saved.currently_burning = burner.currently_burning
      saved.remaining_burning_fuel = burner.remaining_burning_fuel
      saved.heat = burner.heat
    end
    if burner.inventory and burner.inventory.valid then
      saved.inventory = burner.inventory.get_contents()
    end
    if burner.burnt_result_inventory and burner.burnt_result_inventory.valid then
      saved.burnt_result_inventory = burner.burnt_result_inventory.get_contents()
    end
    return saved
  end
end

local function restoreBurner(target, saved)
  if target and target.valid and saved then
    -- Only restore burner heat if the fuel prototype still exists and is valid in this burner.
    if (saved.currently_burning and 
        prototypes.item[saved.currently_burning] and 
        target.inventory.can_insert({name=saved.currently_burning, count=1})) then
      target.currently_burning = prototypes.item[saved.currently_burning]
      target.remaining_burning_fuel = saved.remaining_burning_fuel
      target.heat = saved.heat
    end
    local r1 = insertInventoryStacks(target.inventory, saved.inventory)
    local r2 = insertInventoryStacks(target.burnt_result_inventory, saved.burnt_result_inventory)
    return mergeStackLists(r1, r2)
  elseif saved then
    -- Return entire contents if target invalid
    local r = mergeStackLists({}, saved.burnt_result_inventory)
    r = mergeStackLists(r, saved.inventory)
    return r
  end
end


local function saveGrid(grid)
  if grid and grid.valid then
    local gridContents = {}
    for _,v in pairs(grid.equipment) do
      local item = {
        name = v.name,
        position = v.position,
        quality = v.quality
      }
      if item.name == "equipment-ghost" then
        item.name = v.ghost_name
        item.ghost = true
      end
      local burner = saveBurner(v.burner)
      local energy, shield, to_be_removed
      if v.energy > 0 then
        energy = v.energy
      end
      if v.shield > 0 then
        shield = v.shield
      end
      if v.to_be_removed then
        to_be_removed = v.to_be_removed
      end
      table.insert(gridContents, {item=item,
                                  energy=energy,
                                  shield=shield,
                                  burner=burner,
                                  to_be_removed=to_be_removed})
    end
    return gridContents
  else
    return nil
  end
end

__saveGrid__ = saveGrid

local function restoreGrid(grid, savedGrid)
  local r_stacks = {}
  if grid and grid.valid and savedGrid then
    -- Insert as much as possible into this grid, return items not inserted as remainder stacks
    for _,v in pairs(savedGrid) do
      if prototypes.equipment[v.item.name] then
        local e = grid.put(v.item)
        if e then
          if v.energy then
            e.energy = v.energy
          end
          if v.shield and v.shield > 0 then
            e.shield = v.shield
          end
          if v.burner then
            local r1 = restoreBurner(e.burner,v.burner)
            r_stacks = mergeStackLists(r_stacks, r1)
          end
          if v.to_be_removed then
            grid.order_removal(e)
          end
        else
          r_stacks = mergeStackLists(r_stacks, {{name=v.item.name, count=1}})
          if v.burner then
            r_stacks = mergeStackLists(r_stacks, v.burner.inventory)
            r_stacks = mergeStackLists(r_stacks, v.burner.burnt_result_inventory)
          end
        end
      end
    end
    if #r_stacks > 0 then
      return r_stacks
    end
  elseif savedGrid then
    -- If grid is invalid but we have saved items, return the whole grid as a remainder
    local e,f = __saveGridStacks__(savedGrid)
    r_stacks = mergeStackLists(r_stacks, e)
    r_stacks = mergeStackLists(r_stacks, f)
    return r_stacks
  end
end


local function removeStackFromSavedGrid(savedGrid, stack)
  if savedGrid and stack then
    if not stack.count then stack.count = 1 end
    for i,e in pairs(savedGrid) do
      if e.item.name == stack.name then
        savedGrid[i] = nil
        stack.count = stack.count - 1
      elseif e.burner then
        if e.burner.inventory then
          for k,s in pairs(e.burner.inventory) do
            if s.name == stack.name then
              if s.count <= stack.count then
                stack.count = stack.count - s.count
                e.burner.inventory[k] = nil
              else
                s.count = s.count - stack.count
                stack.count = 0
              end
            end
          end
        end
      end
      if stack.count == 0 then
        return
      end
    end
  end
end


---------------------------------------------------------------
-- Convert Grid Contents to SimpleItemStack array.
-- Arguments:  grid -> table result of saveGrid()
--             dest (optional) -> SimpleItemStack array to insert stacks into
-- Returns:    stacks -> List of SimpleItemStacks or reference to dest
---------------------------------------------------------------
local function saveGridStacks(savedGrid)
-- Count item numbers so we can add stacks of equipment and fuel properly
  local items = {}
  local fuel_items = {}
  if savedGrid then
    for _,v in pairs(savedGrid) do
      if v.burner then
        fuel_items = mergeStackLists(fuel_items, v.burner.inventory)
        fuel_items = mergeStackLists(fuel_items, v.burner.burnt_result_inventory)
      end
      items = mergeStackLists(items, {{name=v.item.name, count=1, quality=v.item.quality}})
    end
    return items, fuel_items
  end
end

__saveGridStacks__ = saveGridStacks


local function saveFilters(source)
  local filters = nil
  if source and source.valid then
    if source.is_filtered() then
      filters = {}
      for f = 1, #source do
        filters[f] = source.get_filter(f)
      end
    end
    if source.supports_bar() and source.get_bar() <= #source then
      filters = filters or {}
      filters.bar = source.get_bar()
    end
  end
  return filters
end

local function restoreFilters(target, filters)
  if target and target.valid and filters then
    if target.supports_filters() then
      for f = 1, #target do
        target.set_filter(f, filters[f])
      end
    end
    if target.supports_bar() then
      if not filters.bar then
        target.set_bar()
      else
        target.set_bar(filters.bar)  -- if filters.bar is nil, will clear bar setting
      end
    end
  end
end


local function saveItemRequestProxy(target)
  -- Search for item_request_proxy ghosts targeting this entity
  -- There can be more than one, but there isn't usually
  local proxies = target.surface.find_entities_filtered{
            name = "item-request-proxy",
            force = target.force,
            position = target.position
          }
  
  -- Merge the requests from all the proxies targeting this entity
  local insert_plan = {}
  local removal_plan = {}
  for _, proxy in pairs(proxies) do
    if proxy.proxy_target == target then
      local ip = proxy.insert_plan
      if ip then
        for _,plan in pairs(ip) do
          insert_plan[#insert_plan+1] = plan
        end
      end
      local rp = proxy.removal_plan
      if rp then
        for _,plan in pairs(rp) do
          removal_plan[#removal_plan+1] = plan
        end
      end
    end
  end
  return insert_plan, removal_plan
end

return {
    saveBurner = saveBurner,
    restoreBurner = restoreBurner,
    saveGrid = saveGrid,
    restoreGrid = restoreGrid,
    saveGridStacks = saveGridStacks,
    removeStackFromSavedGrid = removeStackFromSavedGrid,
    saveInventoryStacks = saveInventoryStacks,
    insertStack = insertStack,
    insertInventoryStacks = insertInventoryStacks,
    mergeStackLists = mergeStackLists,
    itemsToStacks = itemsToStacks,
    spillStack = spillStack,
    spillStacks = spillStacks,
    saveFilters = saveFilters,
    restoreFilters = restoreFilters,
    saveItemRequestProxy = saveItemRequestProxy,
  }
