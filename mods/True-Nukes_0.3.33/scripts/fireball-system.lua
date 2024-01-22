local achievement_system = require("achievement-system")

local decorativeMap = {}
decorativeMap["brown-asterisk"] = {"rock-tiny", 1/4}
decorativeMap["green-asterisk"] = {"brown-asterisk", 1/4}
decorativeMap["green-asterisk-mini"] = {"brown-asterisk", 1/10}
decorativeMap["brown-asterisk-mini"] = {"brown-asterisk", 1/20}
decorativeMap["red-asterisk"] = {"brown-asterisk", 1/4}

decorativeMap["green-pita"] = {"rock-tiny", 1/10}
decorativeMap["red-pita"] = {"rock-small", 1/10}
decorativeMap["green-croton"] = {"sand-rock-small", 1/10}
decorativeMap["red-croton"] = {"red-desert-decal", 1/10}
decorativeMap["green-pita-mini"] = {"enemy-decal-transparent", 1/20}

decorativeMap["brown-fluff"] = {"rock-tiny", 1/10}
decorativeMap["brown-fluff-dry"] = {"brown-asterisk", 1/10}
decorativeMap["garballo"] = {"brown-fluff", 1/10}
decorativeMap["garballo-mini-dry"] = {"brown-fluff-dry", 1/10}

decorativeMap["green-bush-mini"] = {"brown-fluff", 1/10}
decorativeMap["green-hairy-grass"] = {"brown-hairy-grass", 1/10}
decorativeMap["muddy-stump"] = nil

decorativeMap["green-carpet-grass"] = {"sand-decal", 1/2}

decorativeMap["green-desert-bush"] = {"red-desert-bush", 1/2}
decorativeMap["white-desert-bush"] = {"white-desert-bush", 1/4}

decorativeMap["red-desert-bush"] = {"red-desert-bush", 1/2}
decorativeMap["green-small-grass"] = {"brown-asterisk", 1/10}
decorativeMap["brown-carpet-grass"] = {"brown-carpet-grass", 1/2}
decorativeMap["brown-hairy-grass"] = {"brown-hairy-grass", 1/2}

decorativeMap["rock-medium"] = {}
decorativeMap["rock-small"] = {}
decorativeMap["rock-tiny"] = {}
decorativeMap["sand-rock-medium"] = {}
decorativeMap["sand-rock-small"] = {}

decorativeMap["red-desert-decal"] = {}
decorativeMap["dark-mud-decal"] = {}
decorativeMap["puberty-decal"] = {}
decorativeMap["light-mud-decal"] = {}
decorativeMap["sand-decal"] = {}

decorativeMap["sand-dune-decal"] = {}
decorativeMap["big-ship-wreck-grass"] = nil
decorativeMap["small-ship-wreck-grass"] = nil

decorativeMap["enemy-decal"] = {}
decorativeMap["enemy-decal-transparent"] = {}

decorativeMap["nuclear-ground-patch"] = {}
decorativeMap["shroom-decal"] = nil
decorativeMap["worms-decal"] = nil
decorativeMap["lichen-decal"] = nil


local function full_fireball(surface_index, position, fireball_r, crater_external_r, force, cause, corpseMap)
  local deathStatsForTrees = settings.global["retain-death-statistics-for-trees"].value or (fireball_r < 80 and settings.global["retain-death-statistics-for-trees-small"].value)
  local deathStatsForOther = settings.global["retain-death-statistics"].value or (fireball_r < 80 and settings.global["retain-death-statistics-small"].value)
  -- kill things in the fireball
  for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{position=position, radius=fireball_r}) do
    if(v.valid and (not (string.match(v.type, "ghost"))) and (not (v.type == "resource"))) then
      if v.type=="tree" and not deathStatsForTrees then
        v.destroy()
      elseif v.type == "character" then
        if(v.force == force and v.player) then
          achievement_system.nukedSelf(v.player);
        end
        if(cause and cause.valid) then
          v.die(force, cause)
        else
          v.die(force)
        end
      elseif(corpseMap[v.name] and not deathStatsForOther) then
        v.destroy{raise_destroy = true}
      elseif cause and cause.valid then
        if not v.die(force, cause) then
          if(v.destructible) then
            v.destroy{raise_destroy = true}
          end
        end
      elseif not v.die(force) then
        if(v.destructible) then
          v.destroy{raise_destroy = true}
        end
      end
    end
  end
  if(settings.global["destroy-resources-in-crater"].value) then
    -- destroy resources in crater (a bit more to account for the noise on crater edge)
    for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{position=position, radius=crater_external_r*1.1+4, type="resource"}) do
      if(v.valid) then
        v.destroy()
      end
    end
  end
  -- destroy decoratives in the fireball
  for _,v in pairs(game.surfaces[surface_index].find_decoratives_filtered{area = {{position.x-fireball_r, position.y-fireball_r}, {position.x+fireball_r, position.y+fireball_r}}}) do
    if((v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)<=fireball_r*fireball_r) then
      local tmpPos = v.position;
      local result = decorativeMap[v.decorative.name]
      if(result == nil) then
        game.surfaces[surface_index].destroy_decoratives{position = v.position};
      elseif(result[1] == v.decorative.name) then
        local rnd = math.random();
        if(rnd<=result[2]) then
          game.surfaces[surface_index].destroy_decoratives{position = v.position};
        end
      elseif(result[1] ~=nil) then
        local rnd = math.random();
        game.surfaces[surface_index].destroy_decoratives{position = v.position};
        if(rnd<=result[2]) then
          game.surfaces[surface_index].create_decoratives{decoratives={{name=result[1], position=tmpPos, amount=1}}}
        end
      end
    end
  end
  -- make sure everything is dead in the fireball
  for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{position=position, radius=fireball_r}) do
    if(v.valid and (not (string.match(v.type, "ghost"))) and (not (v.type == "resource"))) then
      if v.type == "character" then
        if(v.force == force and v.player) then
          achievement_system.nukedSelf(v.player);
        end
        if(cause and cause.valid) then
          v.die(force, cause)
        else
          v.die(force)
        end
      elseif(cause and cause.valid) then
        if not v.die(force, cause) then
          if(v.destructible) then
            v.destroy{raise_destroy = true}
          end
        end
      else
        if not v.die(force) then
          if(v.destructible) then
            v.destroy{raise_destroy = true}
          end
        end
      end
    end
  end
end

local function partial_fireball(surface_index, chunkLoaderStruct, chunkPosAndArea, originPos, x, y, killPlanes, force, cause, corpseMap)

  local entities = game.surfaces[surface_index].find_entities_filtered{area = chunkPosAndArea.area}
  local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
  for _,e in pairs(entities) do
    if(e.valid and (not (string.match(e.type, "ghost"))) and ((e.type ~= "resource") and (killPlanes or (e.type ~= "car")))
      and --e.position.x>=x and e.position.x<x+32 and e.position.y>=y and e.position.y<y+32 and
      (e.position.x-originPos.x)*(e.position.x-originPos.x) + (e.position.y-originPos.y)*(e.position.y-originPos.y)<=fireballSq) then

      if e.type=="tree" then
        e.destroy()
      elseif e.type == "character" then
        if(e.force == force and e.player) then
          achievement_system.nukedSelf(e.player);
        end
        if(cause and cause.valid) then
          e.die(force, cause)
        else
          e.die(force)
        end
      elseif(corpseMap[e.name]) then
        e.destroy{raise_destroy = true}
      elseif(cause ~= nil and cause.valid) then
        if not e.die(force, cause) then
          if(e.destructible) then
            e.destroy{raise_destroy = true}
          end
        end
      else
        if not e.die(force) then
          if(e.destructible) then
            e.destroy{raise_destroy = true}
          end
        end
      end
    end
  end
  entities = game.surfaces[surface_index].find_entities_filtered{area = chunkPosAndArea.area}
  for _,e in pairs(entities) do
    if(e.valid and (not (string.match(e.type, "ghost"))) and ((e.type ~= "resource")) and (killPlanes or e.type ~= "car")
      and --e.position.x>=x and e.position.x<x+32 and e.position.y>=y and e.position.y<y+32 and
      (e.position.x-originPos.x)*(e.position.x-originPos.x) + (e.position.y-originPos.y)*(e.position.y-originPos.y)<=fireballSq) then
      if e.type=="tree" then
        e.destroy()
      elseif e.type == "character" then
        if(e.force == force and e.player) then
          achievement_system.nukedSelf(e.player);
        end
        if(cause and cause.valid) then
          e.die(force, cause)
        else
          e.die(force)
        end
      elseif(corpseMap[e.name]) then
        e.destroy{raise_destroy = true}
      elseif(cause ~= nil and cause.valid) then
        if not e.die(force, cause) then
          if(e.destructible) then
            e.destroy{raise_destroy = true}
          end
        end
      else
        if not e.die(force) then
          if(e.destructible) then
            e.destroy{raise_destroy = true}
          end
        end
      end
    end
  end
  -- destroy decoratives in the fireball
  local craterEdgeSq = (chunkLoaderStruct.crater_external_r*1.1+4)*(chunkLoaderStruct.crater_external_r*1.1+4)
  for _,v in pairs(game.surfaces[surface_index].find_decoratives_filtered{area = chunkPosAndArea.area}) do
    local distSq = (v.position.x-originPos.x)*(v.position.x-originPos.x)+(v.position.y-originPos.y)*(v.position.y-originPos.y);
    if(distSq<=fireballSq) then
      local tmpPos = v.position;
      local result = decorativeMap[v.decorative.name]
      if(result == nil or distSq<craterEdgeSq) then
        game.surfaces[surface_index].destroy_decoratives{position = v.position};
      elseif(result[1] == v.decorative.name) then
        local rnd = math.random();
        if(rnd<=result[2]) then
          game.surfaces[surface_index].destroy_decoratives{position = v.position};
        end
      elseif(result[1] ~=nil) then
        local rnd = math.random();
        game.surfaces[surface_index].destroy_decoratives{position = v.position};
        if(rnd<=result[2]) then
          game.surfaces[surface_index].create_decoratives{decoratives={{name=result[1], position=tmpPos, amount=1}}}
        end
      end
    end
  end
end
return {
  full_fireball = full_fireball,
  partial_fireball = partial_fireball,
  decorativeMap = decorativeMap
}
