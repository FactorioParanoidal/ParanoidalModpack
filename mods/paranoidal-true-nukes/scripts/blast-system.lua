local cache = require("entity-cache")
local hurt = cache.hurt

-- 2.x rail entity types (1.1 had only straight-rail and curved-rail); all take a tenth of the blast
local reduced_types = {
  ["straight-rail"] = true, ["curved-rail-a"] = true, ["curved-rail-b"] = true, ["half-diagonal-rail"] = true,
  ["legacy-straight-rail"] = true, ["legacy-curved-rail"] = true,
  ["elevated-straight-rail"] = true, ["elevated-curved-rail-a"] = true, ["elevated-curved-rail-b"] = true,
  ["elevated-half-diagonal-rail"] = true, ["rail-ramp"] = true, ["rail-support"] = true,
  ["transport-belt"] = true, ["land-mine"] = true
}

local function fire_damage_entity(surface, entity, force, cause, killPlanes)
  if (entity.valid and entity.position and (killPlanes or entity.type ~= "car")) then
    if cache.has_health(entity) then
      -- For thermobarics, with the blast wave carrying the fire
      local type = entity.type
      if (type == "unit" or type == "car" or type == "spider-vehicle") then
        surface.create_entity{name="fire-sticker", position=entity.position, target=entity}
        hurt(entity, 20, force, "fire", cause)
        if(entity.valid)then
          hurt(entity, 40, force, "physical", cause)
        end
        if(entity.valid and entity.type == "car" and entity.prototype.get_max_health(entity.quality) >= 1000) then
          hurt(entity, 80, force, "fire", cause)
        end
      elseif (type ~= "tree" and type ~= "spider-leg") then
        hurt(entity, 100, force, "fire", cause)
      end
    end
  end
end


local function damage_entity(surface, distSq, ePos, power, fire, damage_init, blast_min_damage, entity, force, cause, corpseMap,  deathStatsForTrees, deathStatsForOther)
  -- do blast damage - reduced for rails, belts, land mines and flying vehicles, as this makes some sense, and trees in order to leave some alive
  local damage = math.min(power/distSq*damage_init+blast_min_damage, cache.max_damage)
  local t = entity.type
  if(t=="spider-leg") then
    return
  elseif(t=="tree") then
    if(fire) then
      surface.create_entity{name="fire-flame-on-tree", target = entity, position=ePos}
    end
    damage = math.random(damage/8, damage)/2

    damage = cache.after_resistance(entity, "explosion", damage)
    -- If a tree is destroyed, don't bother doing particle effects, just destroy it - huge performance savings
    if (entity.health<damage) then
      if (deathStatsForTrees) then
        hurt(entity, damage, force, "explosion", cause)
      else
        entity.destroy()
      end
      surface.create_entity{name="tree-01-stump",position=ePos}
    else
      entity.health = entity.health-damage
      if entity.tree_stage_index_max ~= entity.tree_stage_index then
        local damage_level = (1-entity.health/entity.prototype.get_max_health()) * (entity.tree_stage_index_max - entity.tree_stage_index)
        entity.tree_stage_index = math.max(math.ceil(damage_level) + entity.tree_stage_index, 1)
      end
    end
    return
  else
    if reduced_types[t] then
      damage = damage/10
    elseif(t=="car" or t=="spider-vehicle") then
      if cache.is_flying(entity) then
        damage = damage/2
      end
    end
    damage = math.random(damage/2, damage*2)
    local calcDamage = cache.after_resistance(entity, "explosion", damage)
    if((not entity.grid) and entity.health>calcDamage) then
      entity.health = entity.health-calcDamage
    else
      if((not entity.grid) and corpseMap[entity.name] and not deathStatsForOther) then
        local corpseName = corpseMap[entity.name]
        --local ghost
        --if(eProto.create_ghost_on_death or eProto.create_ghost_on_death == nil) then
        --  ghost = {inner_name = entity.name, name = "entity-ghost", direction = entity.direction, expires = true, force = entity.force, position = entity.position}
        --  if(t == "assembling-machine" and entity.get_recipe()) then
        --    ghost.recipe = entity.get_recipe().name
        --  end
        --end
        entity.destroy{raise_destroy = true}
        surface.create_entity{name=corpseName, position=ePos}
        --if(eProto.create_ghost_on_death or eProto.create_ghost_on_death == nil) then
        --  surface.create_entity(ghost)
        --end
      else
        hurt(entity, damage, force, "explosion", cause)
      end
    end
  end
end






local function move_blast(i,blast,pastEHits, corpseMap)
  local deathStatsForTrees = settings.global["retain-death-statistics-for-trees"].value or (blast.max < 2000 and settings.global["retain-death-statistics-for-trees-small"].value)
  local deathStatsForOther = settings.global["retain-death-statistics"].value or (blast.max < 2000 and settings.global["retain-death-statistics-small"].value)

  -- Compute the number of regions we move the blast in
  local regNum = 8
  if(blast.r<=500 or not blast.doItts) then
    regNum = 8
  elseif(blast.r<=1000) then
    regNum = 24
  elseif(blast.r<=2000) then
    regNum = 48
  elseif(blast.r<=4000) then
    regNum = 96
  else
    regNum = 192
  end
  -- Do we need to wait a while (we might need to if the simulated blast is going faster than expected)
  blast.ittframe = blast.ittframe+1
  if(blast.itt > regNum and blast.ittframe >=8) then
    blast.r = blast.r + blast.speed
    blast.ittframe = 1
    blast.itt = 1
  elseif (blast.itt > regNum) then
    return
  end

  local surface = game.surfaces[blast["s"]]
  local center = blast["pos"]
  local sideOffset = blast.speed*1.5
  local extraSpace = blast.speed

  local eHits = pastEHits

  local area = {{}, {}}

  -- Some hard-coded regions for small blasts
  local regions = {
    {{center.x-blast.r/2-sideOffset, center.y+(blast.r-extraSpace)*0.86603-0.5}, {center.x+blast.r/2+sideOffset, center.y+blast.r+1}},
    {{center.x-blast.r/2-sideOffset, center.y-blast.r}, {center.x+blast.r/2+sideOffset, center.y-(blast.r-extraSpace)*0.86603+0.5}},
    {{center.x+(blast.r-extraSpace)*0.86603-0.5, center.y-blast.r/2-sideOffset}, {center.x+blast.r+1, center.y+blast.r/2+sideOffset}},
    {{center.x-blast.r, center.y-blast.r/2-sideOffset}, {center.x-(blast.r-extraSpace)*0.86603+0.5, center.y+blast.r/2+sideOffset}},

    {{center.x-(blast.r-extraSpace)*0.86603-0.5, center.y+blast.r/2-extraSpace/2-0.5}, {center.x-blast.r/2+extraSpace/2+0.5, center.y+(blast.r-extraSpace)*0.86603+0.5}},
    {{center.x+blast.r/2-extraSpace/2-0.5, center.y+blast.r/2-extraSpace/2-0.5}, {center.x+(blast.r-extraSpace)*0.86603+0.5, center.y+(blast.r-extraSpace)*0.86603+0.5}},
    {{center.x-(blast.r-extraSpace)*0.86603-0.5, center.y-(blast.r-extraSpace)*0.86603-0.5}, {center.x-blast.r/2+extraSpace/2+0.5, center.y-blast.r/2+extraSpace/2+0.5}},
    {{center.x+blast.r/2-extraSpace/2-0.5, center.y-(blast.r-extraSpace)*0.86603-0.5}, {center.x+(blast.r-extraSpace)*0.86603+0.5, center.y-blast.r/2+extraSpace/2+0.5}}
  }

  if(blast.r<=500 or not blast.doItts) then
    area = regions[blast.itt]
  else
    -- otherwise compute the regions for large area blast-waves
    local reg = blast.itt % (regNum/4)
    local currentQuadrant = (math.floor(blast.itt/(regNum/4)))%4
    local angleUnit = 2*3.14159/regNum
    local angleRelative = math.min(angleUnit*(reg+1), angleUnit*(regNum/4-reg-1))
    local angleStart = angleUnit*((regNum/4)*currentQuadrant+reg)
    local overstep = math.sqrt( (blast.r*math.sin(angleRelative))^2+2*blast.r*blast.speed+blast.speed*blast.speed)-blast.r*math.sin(angleRelative)+2;



    if(currentQuadrant==0) then
      if(reg<regNum/8) then
        area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r)*math.sin(angleStart)},
          {center.x + (blast.r)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)+overstep}}
      elseif(reg==regNum/8) then
        area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart)},
          {center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}}
      else
        area = {{center.x + (blast.r)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart)},
          {center.x + (blast.r-blast.speed)*math.cos(angleStart)+overstep, center.y + (blast.r)*math.sin(angleStart+angleUnit)}}
      end
    elseif(currentQuadrant==1) then
      if(reg<regNum/8) then
        area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit)-overstep, center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)},
          {center.x + (blast.r)*math.cos(angleStart), center.y + (blast.r)*math.sin(angleStart)}}
      elseif(reg==regNum/8) then
        area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)},
          {center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart)}}
      else
        area = {{center.x + (blast.r)*math.cos(angleStart+angleUnit), center.y + (blast.r)*math.sin(angleStart+angleUnit)},
          {center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart)+overstep}}
      end
    elseif(currentQuadrant==2) then
      if(reg<regNum/8) then
        area = {{center.x + (blast.r)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)-overstep},
          {center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r)*math.sin(angleStart)}}
      elseif(reg==regNum/8) then
        area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)},
          {center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart)}}
      else
        area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart)-overstep, center.y + (blast.r)*math.sin(angleStart+angleUnit)},
          {center.x + (blast.r)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart)}}
      end
    else
      if(reg<regNum/8) then
        area = {{center.x + (blast.r)*math.cos(angleStart), center.y + (blast.r)*math.sin(angleStart)},
          {center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit)+overstep, center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}}
      elseif(reg==regNum/8) then
        area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart)},
          {center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}}
      else
        area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart)-overstep},
          {center.x + (blast.r)*math.cos(angleStart+angleUnit), center.y + (blast.r)*math.sin(angleStart+angleUnit)}}
      end
    end
  end

  local entities = cache.find_with_health(surface, area)
  eHits = eHits + #entities
  --game.players[1].print(math.floor(blast.itt/6) .. " {" .. area[1][1] .. ", " .. area[1][2] .. "}, {" .. area[2][1] .. ", " .. area[2][2] .. "}")
  local blastInnerSq = (blast.r - blast.speed)*(blast.r - blast.speed)
  local blastSq = blast.r*blast.r
  local cx = center.x
  local cy = center.y
  for _,entity in pairs(entities) do
    if (entity.valid and entity.position) then
      local ePos = entity.position
      local xdif = ePos.x-cx
      local ydif = ePos.y-cy
      local distSq = xdif*xdif + ydif*ydif
      if(distSq <= blastSq and distSq>blastInnerSq and entity.valid and cache.has_health(entity)
        and ePos.x>=area[1][1] and ePos.x<area[2][1] and ePos.y>=area[1][2] and ePos.y<area[2][2]) then

        damage_entity(surface, distSq, ePos, blast.pow, blast.fire, blast.damage_init, blast.blast_min_damage, entity, blast.force, blast.cause, corpseMap, deathStatsForTrees, deathStatsForOther)
        if blast.fire then
          fire_damage_entity(surface, entity, blast.force, blast.cause, true)
        end
      end
    end
  end

  -- For thermobarics, start all the required fires
  if(blast.fire) then
    local area = regions[blast.itt]
    local tiles = surface.find_tiles_filtered{area=area}
    for _,tile in pairs(tiles) do
      local xdif = tile.position.x-center.x
      local ydif = tile.position.y-center.y
      local distSq = xdif*xdif + ydif*ydif
      -- 9.0.0: a quarter of the tiles get a fire (True Nukes lit every tile: 31 thousand fires for the large charge)
      if(distSq > (blast.r - blast.speed)*(blast.r - blast.speed) and distSq <= blast.r*blast.r and math.random() < 0.25) then
        if (blast.r <= blast.fire_rad) then
          local chance = math.random(0, blast.fire_rad)
          if(chance*chance>distSq) then
            surface.create_entity{name="fire-flame",position=tile.position}
          else
            surface.create_entity{name="thermobaric-wave-fire",position=tile.position}
          end
        else
          local chanceWave = math.random(blast.fire_rad, blast.max)
          if(chanceWave*chanceWave>distSq) then
            surface.create_entity{name="thermobaric-wave-fire",position=tile.position}
          end
        end
      end
    end
  end
  local hasEnded = false
  -- We want to do more regions this frame if the ones we have covered contain very few entities (such as if they are unloaded)
  if(blast.itt == regNum and blast.ittframe>=8) then
    blast.r = blast.r + blast.speed
    blast.itt = 1
    blast.ittframe = 1
  elseif blast.itt ~= regNum then
    blast.itt = blast.itt+1
    if((not blast.doItts) or eHits<4000) then
      hasEnded = move_blast(i, blast,eHits, corpseMap)
    end
  end
  if(blast.r>blast.max and not hasEnded) then
    storage.blastWaves[i] = nil
    return true
  end
  return hasEnded
end



local function chunk_loaded(chunkLoaderStruct, surface_index, originPos, chunkPosAndArea, x, y, killPlanes, blastSq, force, cause, corpseMap)
  local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
  local cx = originPos.x
  local cy = originPos.y
  local init_blast = chunkLoaderStruct.init_blast
  local blast_min_damage = chunkLoaderStruct.blast_min_damage
  local count = 0
  for _,entity in pairs(cache.find_with_health(game.surfaces[surface_index], chunkPosAndArea.area)) do
    count = count + 1
    if (entity.valid and entity.position) then
      local ePos = entity.position
      local xdif = ePos.x-cx
      local ydif = ePos.y-cy
      local distSq = xdif*xdif + ydif*ydif
      if(distSq <= blastSq and cache.has_health(entity)
        and ePos.x>=x and ePos.x<x+32 and ePos.y>=y and ePos.y<y+32 and (killPlanes or entity.type ~= "car")) then
        damage_entity(game.surfaces[surface_index], distSq, ePos, fireballSq, false, init_blast, blast_min_damage, entity, force, cause, corpseMap, false, false)
      end
    end
  end
  return count
end

return {
  move_blast = move_blast,
  chunk_loaded = chunk_loaded
}
