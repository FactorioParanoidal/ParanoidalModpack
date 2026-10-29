-- Decides which locomotives of a train form MU pairs. Pure function of the train: no writes.
--
-- A pair is one locomotive facing the train front and one facing back, of the same base type
-- (and the same quality when quality changes power), inside one block. In "basic" mode a block is a
-- run of locomotives without wagons between them, in "advanced" mode the whole train is one block.
-- Locomotives that already are MU twins are paired first, so a stable train is never touched again.
local catalog = require("script.catalog")

local M = {}

function M.blocks(train, mode)
  local blocks, current = {}, nil
  for _, carriage in ipairs(train.carriages) do
    if carriage.type == "locomotive" then
      if not current then
        current = {}
        blocks[#blocks + 1] = current
      end
      current[#current + 1] = carriage
    elseif mode == "basic" then
      current = nil
    end
  end
  return blocks
end

-- Twins first, otherwise the order of the train.
local function twins_first(list)
  local sorted = {}
  for _, locomotive in ipairs(list) do
    if catalog.std(locomotive.name) then sorted[#sorted + 1] = locomotive end
  end
  for _, locomotive in ipairs(list) do
    if not catalog.std(locomotive.name) then sorted[#sorted + 1] = locomotive end
  end
  return sorted
end

local function reason(single, singles)
  local other_type = false
  for _, other in ipairs(singles) do
    if other.front ~= single.front then
      if other.std == single.std then
        if other.key ~= single.key then return "quality" end
        if other.block ~= single.block then return "apart" end
      else
        other_type = true
      end
    end
  end
  return other_type and "type" or nil
end

-- Returns {
--   replace = array of {entity, name}: locomotives whose prototype must change,
--   labels  = unit_number -> {kind = "pair", bonus} | {kind = "single", reason},
--   linked  = true when the train has at least one pair,
-- }
function M.plan(train, mode)
  local replace, labels, linked = {}, {}, false
  if mode == "off" then
    for _, carriage in ipairs(train.carriages) do
      local std = carriage.type == "locomotive" and catalog.std(carriage.name)
      if std then replace[#replace + 1] = {entity = carriage, name = std} end
    end
    return {replace = replace, labels = labels, linked = false}
  end

  local singles, faces = {}, {}
  for block_index, block in ipairs(M.blocks(train, mode)) do
    local buckets, order = {}, {}
    for _, locomotive in ipairs(block) do
      local std = catalog.base(locomotive.name)
      if std then
        local key = catalog.quality_matters(std) and (std .. "/" .. locomotive.quality.name) or std
        local bucket = buckets[key]
        if not bucket then
          bucket = {std = std, key = key, front = {}, back = {}}
          buckets[key] = bucket
          order[#order + 1] = bucket
        end
        local front = locomotive.is_headed_to_trains_front
        local side = front and bucket.front or bucket.back
        side[#side + 1] = locomotive
        faces[front] = true
      end
    end
    for _, bucket in ipairs(order) do
      local pairs_count = math.min(#bucket.front, #bucket.back)
      for _, front in ipairs({true, false}) do
        for index, locomotive in ipairs(twins_first(front and bucket.front or bucket.back)) do
          local paired = index <= pairs_count
          local name = paired and catalog.mu(bucket.std) or bucket.std
          if locomotive.name ~= name then replace[#replace + 1] = {entity = locomotive, name = name} end
          if paired then
            labels[locomotive.unit_number] = {kind = "pair", bonus = catalog.bonus(bucket.std)}
            linked = true
          else
            singles[#singles + 1] = {entity = locomotive, std = bucket.std, key = bucket.key,
                                     front = front, block = block_index}
          end
        end
      end
    end
  end

  -- A locomotive without a pair is marked only in a train that drives both ways.
  if faces[true] and faces[false] then
    for _, single in ipairs(singles) do
      labels[single.entity.unit_number] = {kind = "single", reason = reason(single, singles)}
    end
  end
  return {replace = replace, labels = labels, linked = linked}
end

return M
