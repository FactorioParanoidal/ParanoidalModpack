local primitive_tint = {r = 170, g = 130, b = 1, a = 255}

local function tinted_icon(path)
  return {{icon = path, icon_size = 64, tint = primitive_tint}}
end

local function tint_sprites(node)
  if type(node) ~= "table" then
    return
  end
  if node.filename or node.filenames then
    node.tint = primitive_tint
    return
  end
  for _, child in pairs(node) do
    tint_sprites(child)
  end
end

local stop = table.deepcopy(data.raw["train-stop"]["train-stop"])
stop.name = "train-stop-scrap"
stop.localised_description = {"entity-description.train-stop-scrap"}
stop.icons = tinted_icon("__base__/graphics/icons/train-stop.png")
stop.icon = nil
stop.minable = {mining_time = 1, result = "train-stop-scrap"}
stop.max_health = 250
stop.next_upgrade = "train-stop"
stop.fast_replaceable_group = data.raw["train-stop"]["train-stop"].fast_replaceable_group
stop.color = {r = 0.95, g = 0.85, b = 0.1, a = 0.5}
for _, direction in pairs({"north", "east", "south", "west"}) do
  local animation = stop.animations[direction].layers[1]
  animation.filename = "__JunkTrain3__/graphics/train/hr-train-stop-bottom.png"
  animation.width = 140
  animation.height = 291
  animation.scale = 0.5

  local overlay = stop.rail_overlay_animations[direction]
  overlay.filename = "__JunkTrain3__/graphics/train/hr-train-stop-ground.png"
  overlay.width = 386
  overlay.height = 377
  overlay.scale = 0.5
end

local signal = table.deepcopy(data.raw["rail-signal"]["rail-signal"])
signal.name = "rail-signal-scrap"
signal.localised_description = {"entity-description.rail-signal-scrap"}
signal.icons = tinted_icon("__base__/graphics/icons/rail-signal.png")
signal.icon = nil
signal.minable = {mining_time = 0.5, result = "rail-signal-scrap"}
signal.max_health = 100
signal.next_upgrade = "rail-signal"
signal.fast_replaceable_group = data.raw["rail-signal"]["rail-signal"].fast_replaceable_group
tint_sprites(signal.animation)

local chain_signal = table.deepcopy(data.raw["rail-chain-signal"]["rail-chain-signal"])
chain_signal.name = "rail-chain-signal-scrap"
chain_signal.localised_description = {"entity-description.rail-chain-signal-scrap"}
chain_signal.icons = tinted_icon("__base__/graphics/icons/rail-chain-signal.png")
chain_signal.icon = nil
chain_signal.minable = {mining_time = 0.5, result = "rail-chain-signal-scrap"}
chain_signal.max_health = 100
chain_signal.next_upgrade = "rail-chain-signal"
chain_signal.fast_replaceable_group = data.raw["rail-chain-signal"]["rail-chain-signal"].fast_replaceable_group
tint_sprites(chain_signal.animation)

data:extend({stop, signal, chain_signal})
