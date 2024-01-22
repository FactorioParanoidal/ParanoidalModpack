local function damage_entity(surface, distSq, ePos, fireballSq, initialDamage, v, force, cause, corpseMap, deathStatsForTrees, deathStatsForOther)
  local damage = fireballSq*initialDamage/distSq
  local eProto = v.prototype
  if(v.type=="spider-leg") then
    return
  elseif(v.type=="tree" and not deathStatsForTrees) then
    -- efficient tree handling
    if(math.random(0, 100)<1) then
      surface.create_entity{name="fire-flame-on-tree", target = v, position=ePos}
    end
    local damage = math.random(damage/8, damage)/2
    if((((not eProto.resistances) or not eProto.resistances.fire) and v.health<damage) or
      (eProto.resistances and eProto.resistances.fire and v.health<(damage-eProto.resistances.fire.decrease)*(1-eProto.resistances.fire.percent))) then
      local surface = v.surface
      local destPos = ePos
      if (deathStatsForTrees) then
        v.die();
      else
        v.destroy()
      end
      surface.create_entity{name="tree-01-stump",position=destPos}
    else
      if((not eProto.resistances) or not eProto.resistances.fire) then
        v.health = v.health-damage
      else
        v.health = v.health-(damage-eProto.resistances.fire.decrease)*(1-eProto.resistances.fire.percent)
      end
    end
  else
    local damage = math.random(damage/2, damage*2)
    if(v.grid) then
      if(cause and cause.valid) then
        v.damage(damage, force, "fire", cause)
      else
        v.damage(damage, force, "fire")
      end
      if(v.valid and(v.type == "unit" or v.type == "car" or v.type == "spider-vehicle")) then
        local fireShield = nil
        for _,e in pairs(v.grid.equipment) do
          if(e.name=="fire-shield-equipment" and e.energy>=1000000) then
            fireShield = e;
            break;
          end
        end
        if fireShield then
          fireShield.energy = fireShield.energy-1000000
        else
          surface.create_entity{name="fire-sticker", position=ePos, target=v}
        end
      end
    else
      if(((not eProto.resistances) or not eProto.resistances.fire) and v.health>damage) then
        v.health = v.health-damage
      elseif(eProto.resistances and eProto.resistances.fire and v.health>(damage-eProto.resistances.fire.decrease)*(1-eProto.resistances.fire.percent)) then
        v.health = v.health-(damage-eProto.resistances.fire.decrease)*(1-eProto.resistances.fire.percent)
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
          if(cause and cause.valid) then
            v.damage(damage, force, "fire", cause)
          else
            v.damage(damage, force, "fire")
          end
        end
      end
    end
  end
end





local function atomic_thermal_blast_internal(surface_index, position, force, cause, thermal_max_r, initialDamage, fireball_r, initial_x, initial_y, corpseMap)
  local deathStatsForTrees = settings.global["retain-death-statistics-for-trees"].value or (thermal_max_r < 2000 and settings.global["retain-death-statistics-for-trees-small"].value)
  local deathStatsForOther = settings.global["retain-death-statistics"].value or (thermal_max_r < 2000 and settings.global["retain-death-statistics-small"].value)
  -- do thermal heat-wave damage
  local thermSq = thermal_max_r*thermal_max_r;
  local fireballSq = fireball_r*fireball_r;
  local surface = game.surfaces[surface_index]
  local areas = {}
  local y = -1;
  local x = -1;
  if(thermal_max_r<500) then
    areas = {{{position.x-thermal_max_r, position.y-thermal_max_r}, {position.x+thermal_max_r, position.y+thermal_max_r}}}
  else
    local i = 0;
    y = initial_y;
    x = initial_x;
    local distSq1
    local distSq2
    local distSq3
    local distSq4
    while(y+100<=position.y+thermal_max_r) do
      initial_x = position.x-thermal_max_r;
      while(x+100<=position.x +thermal_max_r) do
        distSq1 = (x-position.x)*(x-position.x)        +(y-position.y)*(y-position.y)
        distSq2 = (x+100-position.x)*(x+100-position.x)+(y-position.y)*(y-position.y)
        distSq3 = (x-position.x)*(x-position.x)        +(y+100-position.y)*(y+100-position.y)
        distSq4 = (x+100-position.x)*(x+100-position.x)+(y+100-position.y)*(y+100-position.y)
        if(distSq1<thermSq or distSq2<thermSq or distSq3<thermSq or distSq4<thermSq) then
          i = i+1;
          table.insert(areas, {{x, y}, {x+100, y+100}});
        end
        x = x+100
      end
      if(x ~= position.x +thermal_max_r) then
        if(distSq1<thermSq or distSq2<thermSq or distSq3<thermSq or distSq4<thermSq) then
          i = i+1;
          table.insert(areas, {{x, y}, {position.x +thermal_max_r, y+100}});
        end
      end
      y = y+100
      x = initial_x;
      if(i>=100) then
        break;
      end
    end
    if(i<100 and y ~= position.y +thermal_max_r) then
      distSq1 = distSq1 or ((x-position.x)*(x-position.x)        +(y-position.y)*(y-position.y))
      distSq2 = distSq2 or ((x+100-position.x)*(x+100-position.x)+(y-position.y)*(y-position.y))
      distSq3 = distSq3 or ((x-position.x)*(x-position.x)        +(y+100-position.y)*(y+100-position.y))
      distSq4 = distSq4 or ((x+100-position.x)*(x+100-position.x)+(y+100-position.y)*(y+100-position.y))
      while(x+100<=position.x +thermal_max_r) do
        if(distSq1<thermSq or distSq2<thermSq or distSq3<thermSq or distSq4<thermSq) then
          table.insert(areas, {{x, y}, {x+100, position.y+thermal_max_r}});
        end
        x = x+100
      end
      if(x ~= position.x +thermal_max_r) then
        if(distSq1<thermSq or distSq2<thermSq or distSq3<thermSq or distSq4<thermSq) then
          table.insert(areas, {{x, y}, {position.x +thermal_max_r, position.y+thermal_max_r}});
        end
      end
    end
  end
  local cx = position.x
  local cy = position.y
  for _,a in pairs(areas) do
    for _,v in pairs(surface.find_entities(a)) do
      if (v.valid and v.position) then
        local ePos = v.position
        local xdif = ePos.x-cx
        local ydif = ePos.y-cy
        local distSq = xdif*xdif + ydif*ydif
        if(distSq <= thermSq and distSq>fireballSq and v.prototype.max_health ~= 0
          and ePos.x>=a[1][1] and ePos.x<a[2][1] and ePos.y>=a[1][2] and ePos.y<a[2][2]) then
          damage_entity(surface, distSq, ePos, fireballSq, initialDamage, v, force, cause, corpseMap, deathStatsForTrees, deathStatsForOther)
        end
      end
    end
  end
  return {x = x, y = y};
end



local function atomic_thermal_blast(surface_index, position, force, cause, thermal_max_r, initialDamage, fireball_r, corpseMap)
  if not global.thermalBlasts then
    global.thermalBlasts = {}
  end

  local pos = atomic_thermal_blast_internal(surface_index, position, force, cause, thermal_max_r, initialDamage, fireball_r, position.x-thermal_max_r, position.y-thermal_max_r, corpseMap);
  if((pos.x ~= position.x+thermal_max_r or pos.y ~= position.y+thermal_max_r) and (pos.x ~= -1 or pos.y ~= -1)) then
    table.insert(global.thermalBlasts, {surface_index=surface_index, position=position, force=force, cause=cause, thermal_max_r=thermal_max_r, initialDamage=initialDamage, fireball_r=fireball_r, x=pos.x, y=pos.y})
  end
end

local function atomic_thermal_blast_move_along(corpseMap)
  for i,therm in pairs(global.thermalBlasts) do
    local pos = atomic_thermal_blast_internal(therm.surface_index, therm.position, therm.force, therm.cause, therm.thermal_max_r, therm.initialDamage, therm.fireball_r, therm.x, therm.y, corpseMap);
    therm.x = pos.x
    therm.y = pos.y
    if((math.abs(pos.x - (therm.position.x-therm.thermal_max_r))<1 and math.abs(pos.y - (therm.position.y+therm.thermal_max_r))<1) or (pos.x == -1 and pos.y == -1)) then
      global.thermalBlasts[i]=nil
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
  for _,v in pairs(surface.find_entities(chunkPosAndArea.area)) do
    if (v.valid and v.position) then
      local ePos = v.position
      local xdif = ePos.x-cx
      local ydif = ePos.y-cy
      local distSq = xdif*xdif + ydif*ydif
      if(distSq <= thermSq and distSq>fireballSq and v.prototype.max_health ~= 0
        and ePos.x>=x and ePos.x<x+32 and ePos.y>=y and ePos.y<y+32 and (killPlanes or v.type ~= "car")) then
        damage_entity(surface, distSq, ePos, fireballSq, init_thermal, v, force, cause, corpseMap, false, false)
      end
    end
  end
end


return {
  atomic_thermal_blast = atomic_thermal_blast,
  atomic_thermal_blast_move_along = atomic_thermal_blast_move_along,
  chunk_loaded = chunk_loaded
}
