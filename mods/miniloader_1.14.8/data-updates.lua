-- boblogistics does some late changes in the data-updates phase, so we need to react to them here

local function update(prefix)
  local loader = data.raw["loader-1x1"][prefix .. "miniloader-loader"]
  local loader_item = data.raw["item"][prefix .. "miniloader"]
  local filter_loader = data.raw["loader-1x1"][prefix .. "filter-miniloader-loader"]
  local filter_loader_item = data.raw["item"][prefix .. "filter-miniloader"]
  prefix = string.gsub(prefix, "^ub%-", "")
  local base_underground = data.raw["underground-belt"][prefix .. "underground-belt"]
  local base_underground_item = data.raw["item"][prefix .. "underground-belt"]

  if loader then loader.speed = base_underground.speed end
  if loader_item then loader_item.subgroup = base_underground_item.subgroup end
  if filter_loader then filter_loader.speed = base_underground.speed end
  if filter_loader_item then filter_loader_item.subgroup = base_underground_item.subgroup end
end

update("basic-")
update("")
update("fast-")
update("express-")

if data.raw["item"]["turbo-miniloader"] then
  update("turbo-")
end
if data.raw["item"]["ultimate-miniloader"] then
  update("ultimate-")
end

-- catch belt speed changes made by other mods in data stage
for name, ug in pairs(data.raw["underground-belt"]) do
  local prefix = name:match("(.*)%-underground%-belt")
  local miniloader = prefix and data.raw["loader-1x1"][prefix .. "-miniloader"]
  if miniloader then
    miniloader.speed = ug.speed
  end
end
