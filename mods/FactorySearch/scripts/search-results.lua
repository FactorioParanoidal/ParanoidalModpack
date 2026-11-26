local SearchResults = {}

local group_gap_size = 20
local CELL, MAX_CELLS = 64, 64
local floor = math.floor
-- Search accumulators are append-only until their surface is finished, then sorted for display.
-- The index is derived, rebuilt from the saved group order after a reload, and never stored.
local indexes = setmetatable({}, {__mode = "k"})

local function cells(box)
  return floor(box.left_top.x / CELL), floor(box.left_top.y / CELL),
    floor(box.right_bottom.x / CELL), floor(box.right_bottom.y / CELL)
end

local function register(index, group, id, old_box)
  local x1, y1, x2, y2 = cells(group.selection_box)
  local ox1, oy1, ox2, oy2
  if old_box then
    ox1, oy1, ox2, oy2 = cells(old_box)
    if ox1 == x1 and oy1 == y1 and ox2 == x2 and oy2 == y2 then return end
    if (ox2 - ox1 + 1) * (oy2 - oy1 + 1) > MAX_CELLS then return end
  end
  local name = group.entity_name
  local kind = index[name]
  if not kind then
    kind = {rows = {}, large = {}, all = {}}
    index[name] = kind
  end
  if not old_box then kind.all[id] = group end
  if (x2 - x1 + 1) * (y2 - y1 + 1) > MAX_CELLS then
    kind.large[id] = group
    if old_box then
      for y = oy1, oy2 do
        local row = kind.rows[y]
        for x = ox1, ox2 do
          local bucket = row[x]
          bucket[id] = nil
          if not next(bucket) then row[x] = nil end
        end
        if not next(row) then kind.rows[y] = nil end
      end
    end
    return
  end
  for y = y1, y2 do
    local row = kind.rows[y]
    if not row then row = {}; kind.rows[y] = row end
    for x = x1, x2 do
      local bucket = row[x]
      if not bucket then bucket = {}; row[x] = bucket end
      bucket[id] = group
    end
  end
end

local function first_group(index, name, box)
  local kind = index[name]
  if not kind then return end
  local x1, y1, x2, y2 = cells(box)
  local best, found
  local function consider(bucket)
    for id, group in pairs(bucket) do
      if (not best or id < best) and math2d.bounding_box.collides_with(box, group.selection_box) then
        best, found = id, group
      end
    end
  end
  if (x2 - x1 + 1) * (y2 - y1 + 1) > MAX_CELLS then
    consider(kind.all)
  else
    consider(kind.large)
    for y = y1, y2 do
      local row = kind.rows[y]
      if row then
        for x = x1, x2 do if row[x] then consider(row[x]) end end
      end
    end
  end
  return found, best
end

---@param entity LuaEntity
---@param entity_groups EntityGroup[]
---@return EntityGroup
function SearchResults.add_entity(entity, entity_groups)
  -- Group entities
  -- Group contains count, avg_position, selection_box, entity_name, selection_boxes
  local entity_name = entity.name
  local entity_position = entity.position
  local entity_selection_box = entity.selection_box
  local index = indexes[entity_groups]
  if not index then
    index = {}
    for id, group in ipairs(entity_groups) do register(index, group, id) end
    indexes[entity_groups] = index
  end
  local assigned_group, id = first_group(index, entity_name, entity_selection_box)
  if assigned_group then
      local group = assigned_group
      local old_box = group.selection_box
      local count = group.count
      local new_count = count + 1
      group.avg_position = {
        x = (group.avg_position.x * count + entity_position.x) / new_count,
        y = (group.avg_position.y * count + entity_position.y) / new_count,
      }
      group.selection_box = {
        left_top = {
          x = math.min(group.selection_box.left_top.x + group_gap_size, entity_selection_box.left_top.x) - group_gap_size,
          y = math.min(group.selection_box.left_top.y + group_gap_size, entity_selection_box.left_top.y) - group_gap_size,
        },
        right_bottom = {
          x = math.max(group.selection_box.right_bottom.x - group_gap_size, entity_selection_box.right_bottom.x) + group_gap_size,
          y = math.max(group.selection_box.right_bottom.y - group_gap_size, entity_selection_box.right_bottom.y) + group_gap_size,
        },
      }
      group.count = new_count
      table.insert(group.selection_boxes, entity_selection_box)
      register(index, group, id, old_box)
  else
    -- Create new group
    assigned_group = {
      count = 1,
      avg_position = entity_position,
      selection_box = {
        left_top = {
          x = entity_selection_box.left_top.x - group_gap_size,
          y = entity_selection_box.left_top.y - group_gap_size,
        },
        right_bottom = {
          x = entity_selection_box.right_bottom.x + group_gap_size,
          y = entity_selection_box.right_bottom.y + group_gap_size,
        }
      },
      entity_name = entity_name,
      selection_boxes = {[1] = entity_selection_box},
      localised_name = entity.localised_name,
    }
    table.insert(entity_groups, assigned_group)
    register(index, assigned_group, #entity_groups)
  end
  return assigned_group
end

local add_entity = SearchResults.add_entity

---@param entity LuaEntity
---@param entity_groups EntityGroup[]
---@param recipe LuaRecipe|LuaRecipePrototype
function SearchResults.add_entity_product(entity, entity_groups, recipe)
  local group = add_entity(entity, entity_groups)
  local group_recipe_list = group.recipe_list or {}
  recipe_name_info = group_recipe_list[recipe.name] or {localised_name = recipe.localised_name, count = 0}
  recipe_name_info.count = recipe_name_info.count + 1
  group_recipe_list[recipe.name] = recipe_name_info
  group.recipe_list = group_recipe_list
end

---@param entity LuaEntity
---@param entity_groups EntityGroup[]
---@param item_count number
function SearchResults.add_entity_storage(entity, entity_groups, item_count)
  local group = add_entity(entity, entity_groups)
  local group_item_count = group.item_count or 0
  group.item_count = group_item_count + item_count
end

---@param entity LuaEntity
---@param entity_groups EntityGroup[]
---@param fluid_count number
function SearchResults.add_entity_storage_fluid(entity, entity_groups, fluid_count)
  local group = add_entity(entity, entity_groups)
  local group_fluid_count = group.fluid_count or 0
  group.fluid_count = group_fluid_count + fluid_count
end

---@param entity LuaEntity
---@param entity_groups EntityGroup[]
---@param module_count number
function SearchResults.add_entity_module(entity, entity_groups, module_count)
  local group = add_entity(entity, entity_groups)
  local group_module_count = group.module_count or 0
  group.module_count = group_module_count + module_count
end

---@param entity LuaEntity
---@param entity_groups EntityGroup[]
---@param request_count number
function SearchResults.add_entity_request(entity, entity_groups, request_count)
  local group = add_entity(entity, entity_groups)
  local group_request_count = group.request_count or 0
  group.request_count = group_request_count + request_count
end

---@param entity LuaEntity
---@param entity_groups EntityGroup[]
---@param signal_count number
function SearchResults.add_entity_signal(entity, entity_groups, signal_count)
  local group = add_entity(entity, entity_groups)
  local group_signal_count = group.signal_count or 0
  group.signal_count = group_signal_count + signal_count
end

---@param entity LuaEntity
---@param entity_groups EntityGroup[]
---@return number
function SearchResults.add_entity_resource(entity, entity_groups)
  local resource_count
  if entity.initial_amount then
    resource_count = entity.amount / 3000  -- Calculate yield from amount
  else
    resource_count = entity.amount
  end

  local group = add_entity(entity, entity_groups)
  local group_resource_count = group.resource_count or 0
  group.resource_count = group_resource_count + resource_count
  return resource_count
end

---@param tag LuaCustomChartTag
---@param entity_groups EntityGroup[]
function SearchResults.add_tag(tag, entity_groups)
  -- An alternative to add_entity*, for map tags
  -- Tag groups always have size 1
  local tag_position = tag.position
  local tag_box_size = 8
  local selection_box = {
    left_top = {
      x = tag_position.x - tag_box_size,
      y = tag_position.y - tag_box_size,
    },
    right_bottom = {
      x = tag_position.x + tag_box_size,
      y = tag_position.y + tag_box_size,
    }
  }

  ---@type LocalisedString
  local localised_name = tag.text
  if localised_name == "" then localised_name = { "search-gui.default-map-tag-name" } end

  ---@type EntityGroup
  local group = {
    count = 1,
    avg_position = tag_position,
    entity_name = tag.icon.name,
    selection_boxes = {
      [1] = selection_box
    },
    selection_box = selection_box,
    localised_name = localised_name,
  }
  table.insert(entity_groups, group)
end

---@param category SurfaceStatisticsCategoryName
---@param amount number
---@param surface_statistics SurfaceStatistics
function SearchResults.add_surface_statistics(category, amount, surface_statistics)
  surface_statistics[category] = surface_statistics[category] or 0
  surface_statistics[category] = surface_statistics[category] + amount
end

return SearchResults