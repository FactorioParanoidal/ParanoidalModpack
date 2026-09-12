local function add_items(collection, items)
  for name, count in pairs(items) do
    if prototypes.item[name] then
      collection[name] = (collection[name] or 0) + count
    else
      log("LootingSpaceshipWrecks: optional starting loot unavailable: " .. name)
    end
  end
end

script.on_init(function()
  if not settings.global["lootingspaceshipwrecks-bonus-start-items"].value then return end

  local freeplay = remote.interfaces.freeplay
  if not (freeplay and freeplay.get_created_items and freeplay.set_created_items
    and freeplay.get_ship_items and freeplay.set_ship_items
    and freeplay.get_debris_items and freeplay.set_debris_items) then return end

  local created_items = remote.call("freeplay", "get_created_items")
  local ship_items = remote.call("freeplay", "get_ship_items")
  local debris_items = remote.call("freeplay", "get_debris_items")

  -- Keep Beta 8's random call order as well as its ranges.
  add_items(created_items, {
    ["firearm-magazine"] = math.random(5, 19),
    ["repair-pack"] = math.random(2, 9),
    ["bob-titanium-bearing-ball"] = 2,
    ["intelligent-io"] = 1
  })
  add_items(ship_items, {
    ["salvaged-assembling-machine"] = math.random(2, 3),
    ["salvaged-lab"] = 1,
    ["copper-plate"] = math.random(50, 150),
    ["inserter"] = math.random(15, 75),
    ["long-handed-inserter"] = math.random(5, 35),
    ["fast-inserter"] = math.random(5, 35),
    ["bob-basic-transport-belt"] = math.random(50, 150),
    ["medium-electric-pole"] = math.random(5, 35),
    ["big-electric-pole"] = math.random(2, 9),
    ["steel-chest"] = math.random(1, 2),
    ["assembling-machine-2"] = 1,
    ["pipe-to-ground"] = math.random(5, 15),
    ["bob-basic-splitter"] = math.random(5, 15),
    ["bob-basic-underground-belt"] = 10,
    ["angels-slag"] = math.random(5, 35),
    ["angels-stone-crushed"] = math.random(5, 35),
    ["stone"] = math.random(5, 35),
    ["wood"] = math.random(5, 35),
    ["battery"] = math.random(2, 19),
    ["nuclear-fuel"] = math.random(1, 3),
    ["bob-integrated-electronics"] = math.random(5, 35),
    ["radar"] = math.random(1, 3),
    ["burner-mining-drill"] = math.random(1, 3),
    ["bob-battery-3"] = math.random(2, 9)
  })
  add_items(debris_items, {
    ["copper-plate"] = 20,
    ["iron-plate"] = 25
  })

  remote.call("freeplay", "set_created_items", created_items)
  remote.call("freeplay", "set_ship_items", ship_items)
  remote.call("freeplay", "set_debris_items", debris_items)
end)
