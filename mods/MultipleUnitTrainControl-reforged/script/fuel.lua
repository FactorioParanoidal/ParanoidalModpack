-- Shared fuel: in a train with at least one MU pair, locomotives linked to a pair even out their fuel
-- and their burnt results (empty batteries). Linked are all locomotives of a block that holds an MU
-- twin: the whole train in "advanced" mode, a run of locomotives without wagons in "basic" mode.
-- Only locomotives that burn the same fuel categories share with each other.
--
-- storage.linked: train id -> LuaTrain with at least one pair; storage.fuel_cursor: last balanced id.
-- Each linked train is balanced about once per CYCLE ticks; the handler runs every PERIOD ticks.
local catalog = require("script.catalog")
local planner = require("script.planner")

local M = {PERIOD = 60}
local CYCLE = 300

local signatures = {}
local function signature(locomotive)
  local key = signatures[locomotive.name]
  if not key then
    local categories = {}
    for category in pairs(locomotive.prototype.burner_prototype.fuel_categories) do
      categories[#categories + 1] = category
    end
    table.sort(categories)
    key = table.concat(categories, ",")
    signatures[locomotive.name] = key
  end
  return key
end

-- Evens out every item (name and quality) over the inventories. Items move only when the target
-- accepts them, so nothing is lost; a full target simply keeps less.
local function balance(inventories)
  local count = #inventories
  if count < 2 then return end
  local held, items = {}, {}
  for i, inventory in ipairs(inventories) do
    held[i] = {}
    for _, item in pairs(inventory.get_contents()) do
      local key = item.name .. "/" .. item.quality
      if not items[key] then
        items[key] = {name = item.name, quality = item.quality, total = 0}
        items[#items + 1] = key
      end
      held[i][key] = (held[i][key] or 0) + item.count
      items[key].total = items[key].total + item.count
    end
  end
  for _, key in ipairs(items) do
    local item = items[key]
    local share = math.floor(item.total / count)
    local extra = item.total - share * count
    -- the inventories that already hold the most keep the remainder
    local order = {}
    for i = 1, count do order[i] = i end
    table.sort(order, function(a, b)
      local held_a, held_b = held[a][key] or 0, held[b][key] or 0
      if held_a ~= held_b then return held_a > held_b end
      return a < b
    end)
    local want = {}
    for rank, i in ipairs(order) do want[i] = share + (rank <= extra and 1 or 0) end
    local donor = 1
    for receiver = 1, count do
      local need = want[receiver] - (held[receiver][key] or 0)
      while need > 0 do
        while donor <= count and (held[donor][key] or 0) <= want[donor] do donor = donor + 1 end
        if donor > count then break end
        local amount = math.min(need, held[donor][key] - want[donor])
        local moved = inventories[receiver].insert({name = item.name, quality = item.quality, count = amount})
        if moved == 0 then break end
        inventories[donor].remove({name = item.name, quality = item.quality, count = moved})
        held[donor][key] = held[donor][key] - moved
        held[receiver][key] = (held[receiver][key] or 0) + moved
        need = need - moved
        if moved < amount then break end
      end
    end
  end
end

function M.balance_train(train, mode)
  for _, block in ipairs(planner.blocks(train, mode)) do
    local linked = false
    for _, locomotive in ipairs(block) do
      if catalog.std(locomotive.name) then linked = true break end
    end
    if linked then
      local groups, order = {}, {}
      for _, locomotive in ipairs(block) do
        local burner = locomotive.burner
        if burner then
          local key = signature(locomotive)
          local group = groups[key]
          if not group then
            group = {fuel = {}, burnt = {}}
            groups[key] = group
            order[#order + 1] = group
          end
          group.fuel[#group.fuel + 1] = burner.inventory
          if burner.burnt_result_inventory and #burner.burnt_result_inventory > 0 then
            group.burnt[#group.burnt + 1] = burner.burnt_result_inventory
          end
        end
      end
      for _, group in ipairs(order) do
        balance(group.fuel)
        balance(group.burnt)
      end
    end
  end
end

function M.link(train)
  storage.linked[train.id] = train
end

function M.unlink(id)
  if id and storage.linked[id] then
    storage.linked[id] = nil
    if storage.fuel_cursor == id then storage.fuel_cursor = nil end
  end
end

-- on_nth_tick(PERIOD) handler; mode_of(force) gives the current MU mode of a force.
function M.tick(mode_of)
  local linked = storage.linked
  local total = table_size(linked)
  if total == 0 then return end
  local id = storage.fuel_cursor
  if id and not linked[id] then id = nil end
  for _ = 1, math.min(total, math.ceil(total * M.PERIOD / CYCLE)) do
    local train
    id, train = next(linked, id)
    if not id then id, train = next(linked) end
    if not id then break end
    if train.valid then
      local mode = mode_of(train.carriages[1].force)
      if mode ~= "off" then M.balance_train(train, mode) end
    else
      linked[id] = nil
    end
  end
  storage.fuel_cursor = id
end

return M
