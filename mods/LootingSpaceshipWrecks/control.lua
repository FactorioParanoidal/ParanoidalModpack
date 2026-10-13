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

  -- Keep Beta 8's loot ranges, except for the removed nuclear fuel.
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
    ["bob-integrated-electronics"] = math.random(5, 35),
    ["radar"] = math.random(1, 3),
    ["burner-mining-drill"] = math.random(1, 3),
    ["bob-battery-3"] = math.random(2, 9),
    -- Paranoidal quality branch: supplies for the refinement workshop.
    ["repair-pack"] = math.random(100, 200),
    ["bob-basic-circuit-board"] = math.random(20, 40)
  })
  add_items(debris_items, {
    ["copper-plate"] = 20,
    ["iron-plate"] = 25
  })

  remote.call("freeplay", "set_created_items", created_items)
  remote.call("freeplay", "set_ship_items", ship_items)
  remote.call("freeplay", "set_debris_items", debris_items)
end)

-- Paranoidal: the crash-site wrecks start damaged, and the engine copies the health of a mined
-- entity to every product. Loot is restored to full health so it stacks with ordinary items.
local function repair_loot(event)
  local buffer = event.buffer
  if not (buffer and buffer.valid) then return end
  for i = 1, #buffer do
    local stack = buffer[i]
    if stack.valid_for_read and stack.health < 1 then stack.health = 1 end
  end
end

local wreck_filters = {}
for name in pairs(prototypes.entity) do
  if string.sub(name, 1, 20) == "crash-site-spaceship" then
    wreck_filters[#wreck_filters + 1] = {filter = "name", name = name}
  end
end
if #wreck_filters > 0 then
  script.on_event(defines.events.on_player_mined_entity, repair_loot, wreck_filters)
  script.on_event(defines.events.on_robot_mined_entity, repair_loot, wreck_filters)
end

-- Paranoidal: a selected small wreck is replaced by its simple-entity twin (data-final-fixes.lua),
-- so mining it plays the pickaxe animation and sound, like rocks and the AAI small wreck.
local salvage_twins = {}
for index = 1, 6 do
  local name = "crash-site-spaceship-wreck-small-" .. index
  if prototypes.entity[name] and prototypes.entity[name .. "-salvage"] then
    salvage_twins[name] = name .. "-salvage"
  end
end

if next(salvage_twins) then
  script.on_event(defines.events.on_selected_entity_changed, function(event)
    local player = game.get_player(event.player_index)
    local wreck = player and player.selected
    if not (wreck and wreck.valid) then return end
    local twin_name = salvage_twins[wreck.name]
    if not twin_name then return end

    local surface, position, health = wreck.surface, wreck.position, wreck.health
    wreck.destroy()
    local twin = surface.create_entity{name = twin_name, position = position, force = "neutral"}
    if twin then
      twin.health = health
      player.selected = twin
    end
  end)
end
