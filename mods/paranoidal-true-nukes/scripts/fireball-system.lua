local cache = require("entity-cache")

local decorativeMap = {}
decorativeMap["brown-asterisk"] = {"tiny-rock", 1/4}
decorativeMap["green-asterisk"] = {"brown-asterisk", 1/4}
decorativeMap["green-asterisk-mini"] = {"brown-asterisk", 1/10}
decorativeMap["brown-asterisk-mini"] = {"brown-asterisk", 1/20}
decorativeMap["red-asterisk"] = {"brown-asterisk", 1/4}

decorativeMap["green-pita"] = {"tiny-rock", 1/10}
decorativeMap["red-pita"] = {"small-rock", 1/10}
decorativeMap["green-croton"] = {"small-sand-rock", 1/10}
decorativeMap["red-croton"] = {"red-desert-decal", 1/10}
decorativeMap["green-pita-mini"] = {"enemy-decal-transparent", 1/20}

decorativeMap["brown-fluff"] = {"tiny-rock", 1/10}
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

decorativeMap["medium-rock"] = {}
decorativeMap["small-rock"] = {}
decorativeMap["tiny-rock"] = {}
decorativeMap["medium-sand-rock"] = {}
decorativeMap["small-sand-rock"] = {}

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



-- Names of decorativeMap entries that exist in this game (the loops below may keep or replace them).
-- Every other decorative inside the fireball is destroyed, so inside the square inscribed in the
-- circle one destroy_decoratives call with an inverted name filter does what the per-decorative
-- loop did one API call at a time (Paranoidal 9.0.0; tens of thousands of calls for a 15 kt fireball).
local mapped_names = nil
local function get_mapped_names()
  if mapped_names == nil then
    mapped_names = {}
    for name in pairs(decorativeMap) do
      if prototypes.decorative[name] then
        table.insert(mapped_names, name)
      end
    end
  end
  return mapped_names
end

local function bulk_destroy_unmapped(surface, area)
  local names = get_mapped_names()
  if #names > 0 then
    surface.destroy_decoratives{area = area, name = names, invert = true}
  else
    surface.destroy_decoratives{area = area}
  end
end

-- One chunk-sized cell of the fireball of a normal detonation (Paranoidal 9.0.0). True Nukes killed the
-- whole fireball in the detonation tick (full_fireball); now detonation-jobs.lua runs the cells nearest
-- first under a budget per tick, with the same rules:
--   pass "kill":  everything with health in the circle dies (trees and the vanilla biters/worms without
--                 death statistics are destroyed instead, as before); resources in the crater and the
--                 decoratives in the circle are removed or replaced
--   pass "sweep": the second pass of True Nukes: whatever is left in the circle (remnants, items on the
--                 ground, things spawned by the deaths) dies or is destroyed; ghosts and resources stay
-- Returns the number of killed or destroyed entities.
local function kill_or_destroy(v, force, cause)
  if cause and cause.valid then
    if not v.die(force, cause) and v.valid and v.destructible then v.destroy{raise_destroy = true} end
  elseif not v.die(force) and v.valid and v.destructible then
    v.destroy{raise_destroy = true}
  end
end

local function fireball_cell(surface, area, cx, cy, fireball_r, crater_edge, pass, force, cause, corpseMap, deathStatsForTrees, deathStatsForOther)
  local fireballSq = fireball_r*fireball_r
  local count = 0
  local list = pass == "kill" and cache.find_with_health(surface, area) or surface.find_entities_filtered{area = area}
  for _,v in pairs(list) do
    if v.valid then
      local t = v.type
      local p = v.position
      local dx, dy = p.x-cx, p.y-cy
      if dx*dx+dy*dy <= fireballSq and t ~= "resource" and t ~= "entity-ghost" and t ~= "tile-ghost" then
        count = count + 1
        if t == "tree" and not deathStatsForTrees then
          v.destroy()
        elseif t == "character" then
          if cause and cause.valid then v.die(force, cause) else v.die(force) end
        elseif corpseMap[v.name] and not deathStatsForOther then
          v.destroy{raise_destroy = true}
        else
          kill_or_destroy(v, force, cause)
        end
      end
    end
  end
  if pass ~= "kill" then return count end
  if settings.global["destroy-resources-in-crater"].value then
    local edgeSq = crater_edge*crater_edge
    for _,v in pairs(surface.find_entities_filtered{area = area, type = "resource"}) do
      local p = v.position
      if v.valid and (p.x-cx)*(p.x-cx)+(p.y-cy)*(p.y-cy) <= edgeSq then v.destroy() end
    end
  end
  -- decoratives in the fireball: unmapped ones destroyed in bulk where the cell lies inside the circle
  local far = 0
  for _,x in pairs({area.left_top.x, area.right_bottom.x}) do
    for _,y in pairs({area.left_top.y, area.right_bottom.y}) do
      far = math.max(far, (x-cx)*(x-cx)+(y-cy)*(y-cy))
    end
  end
  if far <= fireballSq then bulk_destroy_unmapped(surface, area) end
  for _,v in pairs(surface.find_decoratives_filtered{area = area}) do
    local vp = v.position
    if (vp.x-cx)*(vp.x-cx)+(vp.y-cy)*(vp.y-cy) <= fireballSq then
      local result = decorativeMap[v.decorative.name]
      if result == nil then
        surface.destroy_decoratives{position = vp}
      elseif result[1] == v.decorative.name then
        if math.random() <= result[2] then surface.destroy_decoratives{position = vp} end
      elseif result[1] ~= nil then
        local rnd = math.random()
        surface.destroy_decoratives{position = vp}
        if rnd <= result[2] then
          surface.create_decoratives{decoratives = {{name = result[1], position = vp, amount = 1}}}
        end
      end
    end
  end
  return count
end

-- The fireball in one chunk of a 100 kt or larger detonation (chunk jobs of control.lua). Returns the number
-- of killed or destroyed entities, trees counted as 0.1 (9.0.0: the budget of the chunk jobs; True Nukes
-- returned nothing).
local function partial_fireball(surface_index, chunkLoaderStruct, chunkPosAndArea, originPos, x, y, killPlanes, force, cause, corpseMap)
  local count = 0
  local entities = game.surfaces[surface_index].find_entities_filtered{area = chunkPosAndArea.area}
  local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
  for _,e in pairs(entities) do
    if(e.valid and (not (string.match(e.type, "ghost"))) and ((e.type ~= "resource") and (killPlanes or (e.type ~= "car")))
      and --e.position.x>=x and e.position.x<x+32 and e.position.y>=y and e.position.y<y+32 and
      (e.position.x-originPos.x)*(e.position.x-originPos.x) + (e.position.y-originPos.y)*(e.position.y-originPos.y)<=fireballSq) then
      count = count + 1
      if e.type=="tree" then
        count = count - 0.9 -- a destroyed tree costs about a tenth of a death (no death event, remnants, loot)
        e.destroy()
      elseif e.type == "character" then
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
      count = count + 1
      if e.type=="tree" then
        count = count - 0.9 -- a destroyed tree costs about a tenth of a death (no death event, remnants, loot)
        e.destroy()
      elseif e.type == "character" then
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
  local area = chunkPosAndArea.area
  local far = 0
  for _,cx in pairs({area.left_top.x, area.right_bottom.x}) do
    for _,cy in pairs({area.left_top.y, area.right_bottom.y}) do
      far = math.max(far, (cx-originPos.x)*(cx-originPos.x) + (cy-originPos.y)*(cy-originPos.y))
    end
  end
  if far <= fireballSq then
    -- the whole chunk lies inside the fireball
    bulk_destroy_unmapped(game.surfaces[surface_index], area)
  end
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
  return count
end
return {
  fireball_cell = fireball_cell,
  partial_fireball = partial_fireball,
  decorativeMap = decorativeMap
}
