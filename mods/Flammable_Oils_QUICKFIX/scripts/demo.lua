-- Test scene: remote.call("flammable_oils", "demo", game.player)
-- Builds five stations east of the player (refuses if the player's buildings are there) and fires
-- them one after another: fuse -> overheating tank with ammunition -> catastrophe; a tank that is
-- drained in time; toxic and fire accidents of chemical plants; an ammunition store; a ruin trap.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.demo = M

local OBSTACLES = { "tree", "simple-entity", "cliff", "fish", "item-entity" }

local function gps(surface, pos)
  return string.format("[gps=%d,%d,%s]", math.floor(pos.x), math.floor(pos.y), surface.name)
end

local function say(player, key, pos, ...)
  if not player.valid then return end
  local message = { "", { "flo-demo." .. key, ... } }
  if pos then
    message[#message + 1] = " "
    message[#message + 1] = gps(player.surface, pos)
  end
  player.print(message)
end

-- Clear obstacles and fill water in a rectangle [x1, x2) x [y1, y2).
local function prepare(surface, x1, y1, x2, y2)
  for _, e in pairs(surface.find_entities_filtered { area = { { x1, y1 }, { x2, y2 } }, type = OBSTACLES }) do
    if e.valid then e.destroy() end
  end
  local tiles = {}
  for x = x1, x2 - 1 do
    for y = y1, y2 - 1 do
      if surface.get_tile(x, y).collides_with("water_tile") then tiles[#tiles + 1] = { name = "landfill", position = { x, y } } end
    end
  end
  if #tiles > 0 then surface.set_tiles(tiles) end
end

local function place(surface, name, x, y, force)
  if not prototypes.entity[name] then return nil end
  return surface.create_entity { name = name, position = { x, y }, force = force }
end

local function fill(entity, fluid, amount)
  if entity and entity.valid and prototypes.fluid[fluid] then entity.insert_fluid { name = fluid, amount = amount } end
end

local function stock(entity, items)
  if not (entity and entity.valid) then return end
  for _, it in ipairs(items) do
    if prototypes.item[it[1]] then entity.insert { name = it[1], count = it[2] } end
  end
end

-- First chemistry recipe (by name) of the machine whose fluids are toxic / flammable.
local function find_recipe(machine, want_toxic)
  local categories = machine.prototype.crafting_categories or {}
  local names = {}
  for name, recipe in pairs(prototypes.recipe) do
    if categories[recipe.category] then
      local flam, tox = FO.fluids.recipe_hazards(recipe)
      if (want_toxic and tox) or (not want_toxic and flam and not tox) then names[#names + 1] = name end
    end
  end
  table.sort(names)
  for _, name in ipairs(names) do
    if pcall(machine.set_recipe, name) and machine.get_recipe() then return name end
  end
end

local function later(seconds, step, data)
  data.kind = "demo"
  data.step = step
  FO.sched.schedule(seconds * 60, data)
end

local steps = {}

function steps.fuse(task)
  local pipes = task.pipes
  local first, second = pipes[#pipes], pipes[#pipes - 1]
  if second and second.valid then FO.fuse.ignite(second, 1, { "flo-cause.fuse" }) end
  if first and first.valid then first.damage(100000, "neutral", "fire") end
end

function steps.ignite(task)
  if task.tank.valid then FO.tanks.ignite(task.tank, { "flo-cause.heat" }) end
end

function steps.drain(task)
  if task.tank.valid then
    task.tank.clear_fluid_inside()
    say(task.player, "drained", task.tank.position)
  end
end

function steps.cook(task)
  if task.chest.valid then FO.cook.start(task.chest) end
end

function steps.chem(task)
  for _, plant in ipairs(task.plants) do
    if plant.valid then plant.damage(100000, "neutral", "fire") end
  end
end

FO.sched.register("demo", function(task)
  local step = steps[task.step]
  if step then step(task) end
end)

function M.start(player)
  if not (player and player.valid) then return end
  local surface, force = player.surface, player.force
  local px, py = math.floor(player.position.x), math.floor(player.position.y)

  surface.request_to_generate_chunks({ px + 100, py }, 4)
  surface.force_generate_chunk_requests()

  -- never blow up the player's base
  local zone = { { px + 25, py - 60 }, { px + 175, py + 60 } }
  for _, e in pairs(surface.find_entities_filtered { area = zone, force = force }) do
    if e.valid and e.type ~= "character" then
      say(player, "busy", e.position)
      return
    end
  end
  say(player, "start")

  -- 1. pipeline -> tank with ammunition next to it
  local tx, ty = px + 90, py - 30
  prepare(surface, tx - 45, ty - 6, tx + 8, ty + 8)
  local tank = place(surface, "storage-tank", tx + 0.5, ty + 0.5, force)
  local pipes = {}
  for i = 0, 39 do pipes[#pipes + 1] = place(surface, "pipe", tx - 1.5 - i, ty - 0.5, force) end
  fill(tank, "light-oil", 25000)
  for _, pipe in ipairs(pipes) do fill(pipe, "light-oil", 100) end
  stock(place(surface, "wooden-chest", tx + 0.5, ty + 3.5, force), { { "firearm-magazine", 200 }, { "piercing-rounds-magazine", 100 } })
  stock(place(surface, "wooden-chest", tx + 1.5, ty + 3.5, force), { { "rocket", 50 }, { "explosive-rocket", 30 }, { "grenade", 50 } })
  say(player, "fuse", { x = tx - 40, y = ty })
  later(3, "fuse", { pipes = pipes })

  -- 2. burning tank that will be drained in time
  local sx, sy = px + 90, py + 30
  prepare(surface, sx - 3, sy - 3, sx + 5, sy + 5)
  local saved = place(surface, "storage-tank", sx + 0.5, sy + 0.5, force)
  fill(saved, "petroleum-gas", 20000)
  say(player, "saved", { x = sx, y = sy })
  if saved then
    later(5, "ignite", { tank = saved })
    later(40, "drain", { tank = saved, player = player })
  end

  -- 3. chemical accidents: toxic and fire
  local cx, cy = px + 50, py + 30
  prepare(surface, cx - 3, cy - 3, cx + 12, cy + 4)
  local plants = {}
  for i, toxic in ipairs({ true, false }) do
    local plant = place(surface, "chemical-plant", cx + 0.5 + (i - 1) * 8, cy + 0.5, force)
    if plant then
      if find_recipe(plant, toxic) then
        plants[#plants + 1] = plant
      else
        say(player, toxic and "no-toxic" or "no-fire")
      end
    end
  end
  say(player, "chem", { x = cx + 4, y = cy })
  later(12, "chem", { plants = plants })

  -- 4. ammunition store
  local ax, ay = px + 40, py
  prepare(surface, ax - 2, ay - 2, ax + 3, ay + 3)
  local store = place(surface, "steel-chest", ax + 0.5, ay + 0.5, force) -- survives more pops
  stock(store, { { "firearm-magazine", 200 }, { "rocket", 40 }, { "grenade", 40 }, { "explosives", 50 } })
  say(player, "cook", { x = ax, y = ay })
  if store then later(8, "cook", { chest = store }) end

  -- 5. ruin trap: neutral tank and pipeline, armed until somebody walks up
  local rx, ry = px + 150, py
  prepare(surface, rx - 3, ry - 3, rx + 20, ry + 5)
  local trap_tank = place(surface, "storage-tank", rx + 0.5, ry + 0.5, "neutral")
  fill(trap_tank, "crude-oil", 20000)
  for i = 0, 14 do fill(place(surface, "pipe", rx + 2.5 + i, ry + 1.5, "neutral"), "crude-oil", 80) end
  storage.traps = storage.traps or {}
  table.insert(storage.traps, { surface = surface, x = rx + 8, y = ry, half = 12 })
  FO.traps.sync()
  say(player, "trap", { x = rx + 8, y = ry }, 12 + C.TRAP_MARGIN)
end

return M
