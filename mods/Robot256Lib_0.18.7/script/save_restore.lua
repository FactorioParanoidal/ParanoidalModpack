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
        if s.name == t.name and not (t.ammo or t.data or t.durability) then
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
          local s = {name=stack.name, count = stack.count}
          if stack.prototype.magazine_size then
            if stack.ammo < stack.prototype.magazine_size then
              s.ammo = stack.ammo
            end
          end
          if stack.prototype.durability then
            if stack.durability < stack.prototype.durability then
              s.durability = stack.durability
            end
          end
          if stack.health < 1 then
            s.health = stack.health
          end
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
  local proto = game.item_prototypes[stack.name]
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
          d = target.insert({name=stack.name, count=stack_limit})
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
    surface.spill_item_stack(position, stack)
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
              if estring == "0eNqrrgUAAXUA+Q==" then
                es.import_stack(stack.data)
                break
              end
            elseif es.is_upgrade_item then
              local estring = es.export_stack()
              -- Compare export string to empty upgrade planner
              if estring == "0eNqrViotSC9KTEmNL8hJzMtLLVKyqlYqTi0pycxLL1ayyivNydFRyixJzVWygqnUhanUUSpLLSrOzM9TsjI3NjC0NDMyNDY3q60FABK2HN8=" then
                es.import_stack(stack.data)
                break
              end
            elseif es.is_deconstruction_item then
              local estring = es.export_stack()
              -- Compare export string to empty deconstruction planner
              if estring == "0eNpljsEKwjAQRP9lzxFaCy3mZ0JIphJMN5JdhVLy77aoF70NbxjmbRQRCovWR9BU2N2zZ0Ylu5FANfFVjgzWpKubU1ZUt5QIsp0hrYA4z9HVEm7iCueV7OyzYC9Txv/igIKM992HN0NJsZD90Tl9dQw9UWUnZKeh6y/juR+msbUXMiNFlg==" then
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
      saved.currently_burning = burner.currently_burning.name
      saved.remaining_burning_fuel = burner.remaining_burning_fuel
    end
    if burner.inventory and burner.inventory.valid then
      saved.inventory = itemsToStacks(burner.inventory.get_contents())
    end
    if burner.burnt_result_inventory and burner.burnt_result_inventory.valid then
      saved.burnt_result_inventory = itemsToStacks(burner.burnt_result_inventory.get_contents())
    end
    return saved
  end
end

local function restoreBurner(target, saved)
  if target and target.valid and saved then
    -- Only restore burner heat if the fuel prototype still exists and is valid in this burner.
    if (saved.currently_burning and 
        game.item_prototypes[saved.currently_burning] and 
        target.inventory.can_insert({name=saved.currently_burning, count=1})) then
      target.currently_burning = game.item_prototypes[saved.currently_burning]
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
      local item = {name=v.name,position=v.position}
      local burner = saveBurner(v.burner)
      local energy, shield
      if v.energy > 0 then
        energy = v.energy
      end
      if v.shield > 0 then
        shield = v.shield
      end
      table.insert(gridContents, {item=item,
                                  energy=energy,
                                  shield=shield,
                                  burner=burner})
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
      if game.equipment_prototypes[v.item.name] then
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
      items = mergeStackLists(items, {{name=v.item.name, count=1}})
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
  local proxies = target.surface.find_entities_filtered{
            name = "item-request-proxy",
            force = target.force,
            position = target.position
          }
  for _, proxy in pairs(proxies) do
    if proxy.proxy_target == target and proxy.valid then
      local items = {}
      for k,v in pairs(proxy.item_requests) do
        items[k] = v
      end
      return items
    else
      return nil
    end
  end
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
