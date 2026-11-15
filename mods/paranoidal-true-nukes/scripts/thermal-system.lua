local cache = require("entity-cache")
local hurt = cache.hurt

local function damage_entity(surface, distSq, ePos, fireballSq, initialDamage, v, force, cause, corpseMap, deathStatsForTrees, deathStatsForOther)
  local damage = math.min(fireballSq*initialDamage/distSq, cache.max_damage)
  if(v.type=="spider-leg") then
    return
  elseif(v.type=="tree" and not deathStatsForTrees) then
    -- efficient tree handling
    if(math.random(0, 100)<1) then
      surface.create_entity{name="fire-flame-on-tree", target = v, position=ePos}
    end
    local damage = math.random(damage/8, damage)/2
    local after = cache.after_resistance(v, "fire", damage)
    if(v.health<after) then
      local surface = v.surface
      local destPos = ePos
      if (deathStatsForTrees) then
        v.die();
      else
        v.destroy()
      end
      surface.create_entity{name="tree-01-stump",position=destPos}
    else
      v.health = v.health-after
    end
  else
    local damage = math.random(damage/2, damage*2)
    if(v.grid) then
      hurt(v, damage, force, "fire", cause)
      if(v.valid and(v.type == "unit" or v.type == "car" or v.type == "spider-vehicle")) then
        surface.create_entity{name="fire-sticker", position=ePos, target=v}
      end
    else
      local after = cache.after_resistance(v, "fire", damage)
      if(v.health>after) then
        v.health = v.health-after
      else
        if((not v.grid) and corpseMap[v.name] and not deathStatsForOther) then
          local corpseName = corpseMap[v.name]
          --local ghost
          --if(eProto.create_ghost_on_death or eProto.create_ghost_on_death == nil) then
          --  ghost = {inner_name = v.name, name = "entity-ghost", direction = v.direction, expires = true, force = v.force, position = v.position}
          --  if(v.type == "assembling-machine" and v.get_recipe()) then
          --    ghost.recipe = v.get_recipe().name
          --  end
          --end
          v.destroy{raise_destroy = true}
          surface.create_entity{name=corpseName, position=ePos}
          --if(eProto.create_ghost_on_death or eProto.create_ghost_on_death == nil) then
          --  surface.create_entity(ghost)
          --end
        else
          hurt(v, damage, force, "fire", cause)
        end
      end
    end
  end
end





-- Thermal wave over square cells of CELL tiles, at most CELLS_PER_TICK cells per tick (Paranoidal 9.0.0).
-- True Nukes did up to 100 cells (1 million tiles) per tick with the first slice in the detonation tick,
-- did the whole square at once below r 500, missed cells the circle entered without a corner inside,
-- and never finished when 2r was not a multiple of 100 (non-default range settings).
local CELL = 100
local CELLS_PER_TICK = 16
local SINGLE_AREA_MAX_R = 200

local function stats_flags(thermal_max_r)
  local deathStatsForTrees = settings.global["retain-death-statistics-for-trees"].value or (thermal_max_r < 2000 and settings.global["retain-death-statistics-for-trees-small"].value)
  local deathStatsForOther = settings.global["retain-death-statistics"].value or (thermal_max_r < 2000 and settings.global["retain-death-statistics-small"].value)
  return deathStatsForTrees, deathStatsForOther
end

-- damage everything with health in area a that lies in the ring fireball_r < d <= thermal_max_r
local function heat_area(surface, a, cx, cy, thermSq, fireballSq, initialDamage, force, cause, corpseMap, deathStatsForTrees, deathStatsForOther)
  local count = 0
  for _,v in pairs(cache.find_with_health(surface, a)) do
    count = count + 1
    if (v.valid) then
      local ePos = v.position
      local xdif = ePos.x-cx
      local ydif = ePos.y-cy
      local distSq = xdif*xdif + ydif*ydif
      if(distSq <= thermSq and distSq>fireballSq and cache.has_health(v)
        and ePos.x>=a[1][1] and ePos.x<a[2][1] and ePos.y>=a[1][2] and ePos.y<a[2][2]) then
        damage_entity(surface, distSq, ePos, fireballSq, initialDamage, v, force, cause, corpseMap, deathStatsForTrees, deathStatsForOther)
      end
    end
  end
  return count
end

-- process cells of one thermal wave from its saved cell index; true when the wave is done
local function thermal_step(therm, corpseMap)
  local surface = game.surfaces[therm.surface_index]
  if not surface then return true end
  local position, R = therm.position, therm.thermal_max_r
  local thermSq = R*R
  local fireballSq = therm.fireball_r*therm.fireball_r
  local deathStatsForTrees, deathStatsForOther = stats_flags(R)
  local x0, y0 = position.x - R, position.y - R
  local n = math.ceil(2*R/CELL)
  local done = 0
  while therm.iy < n and done < CELLS_PER_TICK do
    local ax, ay = x0 + therm.ix*CELL, y0 + therm.iy*CELL
    local bx, by = math.min(ax + CELL, position.x + R), math.min(ay + CELL, position.y + R)
    -- the nearest point of the cell to the centre decides whether the circle reaches it
    local nx = math.max(ax, math.min(position.x, bx)) - position.x
    local ny = math.max(ay, math.min(position.y, by)) - position.y
    if nx*nx + ny*ny < thermSq then
      heat_area(surface, {{ax, ay}, {bx, by}}, position.x, position.y, thermSq, fireballSq, therm.initialDamage, therm.force, therm.cause, corpseMap, deathStatsForTrees, deathStatsForOther)
      done = done + 1
    end
    therm.ix = therm.ix + 1
    if therm.ix >= n then
      therm.ix = 0
      therm.iy = therm.iy + 1
    end
  end
  return therm.iy >= n
end

local function atomic_thermal_blast(surface_index, position, force, cause, thermal_max_r, initialDamage, fireball_r, corpseMap)
  if not storage.thermalBlasts then
    storage.thermalBlasts = {}
  end
  if thermal_max_r < SINGLE_AREA_MAX_R then
    -- small waves: one area at once, as before
    local surface = game.surfaces[surface_index]
    local deathStatsForTrees, deathStatsForOther = stats_flags(thermal_max_r)
    heat_area(surface, {{position.x-thermal_max_r, position.y-thermal_max_r}, {position.x+thermal_max_r, position.y+thermal_max_r}},
      position.x, position.y, thermal_max_r*thermal_max_r, fireball_r*fireball_r, initialDamage, force, cause, corpseMap, deathStatsForTrees, deathStatsForOther)
    return
  end
  -- larger waves start next tick: the detonation tick already carries the fireball and the crater
  storage.thermalNextId = (storage.thermalNextId or 0) + 1
  storage.thermalBlasts[storage.thermalNextId] = {surface_index=surface_index, position=position, force=force, cause=cause,
    thermal_max_r=thermal_max_r, initialDamage=initialDamage, fireball_r=fireball_r, ix=0, iy=0}
end

local function atomic_thermal_blast_move_along(corpseMap)
  for i,therm in pairs(storage.thermalBlasts) do
    if therm.ix == nil or thermal_step(therm, corpseMap) then
      storage.thermalBlasts[i]=nil
    end
  end
end

local function chunk_loaded(chunkLoaderStruct, surface_index, originPos, x, y, chunkPosAndArea, killPlanes, force, cause, corpseMap)
  local cx = originPos.x
  local cy = originPos.y
  local thermSq = chunkLoaderStruct.thermal_max_r*chunkLoaderStruct.thermal_max_r;
  local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
  local init_thermal = chunkLoaderStruct.init_thermal
  local surface = game.surfaces[surface_index]
  local count = 0
  for _,v in pairs(cache.find_with_health(surface, chunkPosAndArea.area)) do
    count = count + 1
    if (v.valid) then
      local ePos = v.position
      local xdif = ePos.x-cx
      local ydif = ePos.y-cy
      local distSq = xdif*xdif + ydif*ydif
      if(distSq <= thermSq and distSq>fireballSq and cache.has_health(v)
        and ePos.x>=x and ePos.x<x+32 and ePos.y>=y and ePos.y<y+32 and (killPlanes or v.type ~= "car")) then
        damage_entity(surface, distSq, ePos, fireballSq, init_thermal, v, force, cause, corpseMap, false, false)
      end
    end
  end
  return count
end


return {
  atomic_thermal_blast = atomic_thermal_blast,
  atomic_thermal_blast_move_along = atomic_thermal_blast_move_along,
  chunk_loaded = chunk_loaded
}
