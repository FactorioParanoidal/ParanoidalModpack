-- Ammunition cook-off. A store with ammunition, explosives or rocket fuel near a fire starts
-- popping: slowly at first, then faster and in bigger batches. Rockets, shells and grenades fly
-- out and burst around; every pop hurts the store. If the store is destroyed, the rest goes off at once.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.cook = M

-- MJ per item by ammo category; "fling" throws grenades around, "fire" lights flames.
local AMMO_POWER = {
  ["bullet"] = 0.5, ["shotgun-shell"] = 0.5, ["Schall-sniper-bullet"] = 0.5, ["autocannon-shell"] = 1,
  ["Bio_Turret_Ammo"] = 0.3, ["Bio_Cannon_Ammo"] = 2, ["cannon-shell"] = 3, ["cannon-H1-shell"] = 4,
  ["cannon-H2-shell"] = 5, ["rocket"] = 5, ["mirv-launcher"] = 8, ["artillery-shell"] = 25,
  ["artillery-shell-prototype"] = 25, ["flamethrower"] = 2,
}
local AMMO_FLING = {
  ["rocket"] = true, ["mirv-launcher"] = true, ["artillery-shell"] = true, ["artillery-shell-prototype"] = true,
  ["cannon-shell"] = true, ["cannon-H1-shell"] = true, ["cannon-H2-shell"] = true,
}
local NOT_EXPLOSIVE = {
  ["nano-ammo"] = true, ["bob-laser-rifle"] = true, ["flying-saucer-laser"] = true,
  ["humanoid_ammo_category"] = true, ["beam"] = true, ["laser"] = true, ["electric"] = true,
  ["melee"] = true, ["biological"] = true,
}
local NAMED = {
  ["grenade"] = { 3, "fling" }, ["cluster-grenade"] = { 6, "fling" }, ["cliff-explosives"] = { 6, "blast" },
  ["explosives"] = { 4, "blast" }, ["bob-explosive-rocket-warhead"] = { 4, "blast" },
  ["bob-alien-explosive-barrel"] = { 10, "blast" },
  ["solid-fuel"] = { 1.2, "fire" }, ["rocket-fuel"] = { 10, "fire" }, ["nuclear-fuel"] = { 10, "fire" },
}

local classes = {} -- item name -> {power, class} | false (prototype-derived)

function M.classify(name)
  local cached = classes[name]
  if cached ~= nil then return cached end
  local result = false
  local proto = prototypes.item[name]
  if NAMED[name] then
    result = NAMED[name]
  elseif proto and proto.type == "ammo" then
    local category = proto.ammo_category and proto.ammo_category.name
    if category and not NOT_EXPLOSIVE[category] then
      result = {
        AMMO_POWER[category] or 1,
        category == "flamethrower" and "fire" or (AMMO_FLING[category] and "fling" or "blast"),
      }
    end
  elseif proto and string.find(name, "explosive", 1, true) then
    result = { 3, "blast" }
  end
  classes[name] = result
  return result
end

---Explosive stacks of a store and their total power (MJ).
local function scan(entity)
  local list, total = {}, 0
  local inventories = C.CONTAINER_INVENTORIES[entity.type]
  if not inventories then return list, total end
  for _, inventory_name in ipairs(inventories) do
    local inventory = entity.get_inventory(defines.inventory[inventory_name])
    if inventory then
      for _, content in pairs(inventory.get_contents()) do
        local class = M.classify(content.name)
        if class then
          list[#list + 1] = {
            inventory = inventory, name = content.name, quality = content.quality,
            count = content.count, power = class[1], class = class[2],
          }
          total = total + class[1] * content.count
        end
      end
    end
  end
  return list, total
end

local function forget(id)
  local cook = storage.cook
  if not cook then return end
  cook[id] = nil
  if next(cook) == nil then storage.cook = nil end
end

local function fling(surface, from)
  if not prototypes.entity["grenade"] then return end
  local angle = math.random() * 2 * math.pi
  local distance = 4 + math.random() * 10
  surface.create_entity {
    name = "grenade",
    position = from,
    target = { x = from.x + math.cos(angle) * distance, y = from.y + math.sin(angle) * distance },
    speed = 0.25,
    force = "neutral",
  }
end

function M.start(entity)
  if not entity.valid then return end
  local id = entity.unit_number
  if not id or (storage.cook and storage.cook[id]) then return end
  if not FO.core.check_cooldown(id) then return end
  if FO.protection.entity(entity) then return end
  local _, total = scan(entity)
  if total < 1 then return end
  storage.cook = storage.cook or {}
  storage.cook[id] = { entity = entity, pops = 0, interval = C.COOK_START_INTERVAL }
  FO.alerts.cookoff(entity)
  FO.sched.schedule(C.COOK_START_INTERVAL, { kind = "cook", id = id })
end

local function shrapnel(surface, pos, radius, damage, damage_type, entity)
  FO.fx.damage_area(surface, pos, radius, damage, "neutral", damage_type, entity)
  if entity.valid then entity.damage(damage, "neutral", "explosion") end
end

local function pop(task)
  local st = storage.cook and storage.cook[task.id]
  if not st then return end
  local entity = st.entity
  if not entity.valid then
    forget(task.id)
    return
  end

  local list = scan(entity)
  if #list == 0 or FO.protection.entity(entity) then -- emptied or now covered by a fire safety turret
    forget(task.id)
    return
  end
  local pick = list[math.random(#list)]
  local batch = math.min(pick.count, 1 + math.floor(st.pops / 5))
  local removed = pick.inventory.remove { name = pick.name, count = batch, quality = pick.quality }
  if removed == 0 then
    forget(task.id)
    return
  end
  st.pops = st.pops + 1

  local energy = pick.power * removed
  local surface = entity.surface
  local pos = FO.fx.random_point(entity.bounding_box, 0.2)
  if pick.class == "fire" then
    surface.create_entity { name = "oil-fire-flame", position = pos, force = "neutral" }
    surface.create_entity { name = "explosion", position = pos }
  else
    local name = energy >= 10 and "big-explosion" or (energy >= 2 and "medium-explosion" or "explosion")
    surface.create_entity { name = name, position = pos }
  end
  if pick.class == "fling" then
    for _ = 1, math.min(removed, 3) do fling(surface, pos) end
  end
  FO.fx.pollute(surface, pos, energy * 10)

  local damage = 6 * energy + 10
  FO.core.guarded(shrapnel, surface, pos, 2 + math.min(4, energy / 5), damage,
    pick.class == "fire" and "fire" or "explosion", entity)
  if not entity.valid then -- destroyed by its own ammunition
    forget(task.id)
    return
  end

  if st.pops == C.COOK_ACHIEVEMENT then FO.ach.near("flo-cookoff", surface, pos, 100) end
  st.interval = math.max(C.COOK_MIN_INTERVAL, math.floor(st.interval * C.COOK_ACCEL))
  FO.sched.schedule(st.interval, task)
end

FO.sched.register("cook", pop)

---A store with ammunition destroyed by fire/explosion: everything left goes off at once.
function M.on_died(entity, event)
  local id = entity.unit_number
  if id then forget(id) end
  if FO.protection.entity(entity) then return end
  local list, total = scan(entity)
  if total < 1 then return end

  local fire, fling_count = 0, 0
  for _, stack in ipairs(list) do
    if stack.class == "fire" then fire = fire + stack.power * stack.count end
    if stack.class == "fling" then fling_count = fling_count + stack.count end
  end
  local surface, pos = entity.surface, entity.position
  for _ = 1, math.min(10, fling_count) do fling(surface, pos) end

  local energy = math.min(total, 100000)
  local rec = FO.core.record(entity, {
    energy = energy,
    amount = total,
    fraction = 1,
    damage_type = fire * 2 > total and "fire" or "explosion",
  })
  rec.neighbours = nil
  rec.cause = FO.core.cause_of(event)
  FO.core.dispatch(rec, entity)
end

return M
