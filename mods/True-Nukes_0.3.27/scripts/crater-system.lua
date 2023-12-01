local water = require("water-system")
local util = require("crater-util")

local  circularNoise = util.circularNoise
local  tileNoise = util.tileNoise
local  tileNoiseLimited = util.tileNoiseLimited

local function nukeTileChangesHeightAwareHuge(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
  local tileTable = {}

  --fireball boils water...
  for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5, name=water.waterTypes}) do
    if(water.waterDepths[v.name]) then
      table.insert(tileTable, {name = water.depthsForCrater[water.waterDepths[v.name]], position = v.position})
    end
    if(#tileTable >=1000) then
      game.surfaces[surface_index].set_tiles(tileTable)
      tileTable = {};
    end
  end
  local groundNoise = {}
  circularNoise(groundNoise, position, fireball_r, 1, 3)
  for x,xtiles in pairs(groundNoise) do
    for y,_ in pairs(xtiles) do
      local tile = game.surfaces[surface_index].get_tile(x, y)
      if not(water.waterDepths[tile.name] == nil) then
        table.insert(tileTable, {name = water.depthsForCrater[water.waterDepths[tile.name]], position = {x = x, y = y}})
      end
    end
    if(#tileTable >=1000) then
      game.surfaces[surface_index].set_tiles(tileTable)
      tileTable = {};
    end
  end
  -- make the crater
  for x = math.floor(-crater_external_r+0.5), math.floor(crater_external_r+0.5) do
    for y = math.floor(-crater_external_r+0.5), math.floor(crater_external_r+0.5) do
      local tilepos = {position.x + x, position.y + y}
      local distSq = x*x+y*y
      if(distSq<crater_internal_r*crater_internal_r/9) then
        table.insert(tileTable, {name = water.depthsForCrater[-3], position = tilepos})
      elseif(distSq<crater_internal_r*crater_internal_r*4/9) then
        table.insert(tileTable, {name = water.depthsForCrater[-2], position = tilepos})
      elseif(distSq<crater_internal_r*crater_internal_r) then
        table.insert(tileTable, {name = water.depthsForCrater[-1], position = tilepos})
      elseif(distSq<crater_external_r*crater_external_r) then
        table.insert(tileTable, {name = water.depthsForCrater[1], position = tilepos})
      end
      if(#tileTable >=1000) then
        game.surfaces[surface_index].set_tiles(tileTable)
        tileTable = {};
      end
    end
  end
  -- add noise
  tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r/3, 1, {default = water.depthsForCrater[-3]}, 3);
  if(#tileTable >=1000) then
    game.surfaces[surface_index].set_tiles(tileTable)
    tileTable = {};
  end
  tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r*2/3, 1, {default = water.depthsForCrater[-2]}, 3);
  if(#tileTable >=1000) then
    game.surfaces[surface_index].set_tiles(tileTable)
    tileTable = {};
  end
  tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r, 2, {default = water.depthsForCrater[0]}, 3);
  if(#tileTable >=1000) then
    game.surfaces[surface_index].set_tiles(tileTable)
    tileTable = {};
  end
  tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r, 1, {default = water.depthsForCrater[-1]}, 3);
  game.surfaces[surface_index].set_tiles(tileTable)
  -- ensure noise for crater goes on top of lakes
  local tileTable2 = {}
  --noise around the crater
  local externalNoise = {default = "nuclear-ground"}
  tileNoise(game.surfaces[surface_index], tileTable2, position, crater_external_r, 1, externalNoise, 3);

  --high noise around crater
  local externalNoise2 = {default = "nuclear-high"}
  tileNoise(game.surfaces[surface_index], tileTable2, position, crater_external_r-2, 1, externalNoise2, 3);
  game.surfaces[surface_index].set_tiles(tileTable2)

  --make the high ground removable
  for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5, name="nuclear-high"}) do
    game.surfaces[surface_index].set_hidden_tile(v.position, "nuclear-ground")
  end

  -- setup craters to fill with water
  for xChunkPos = math.floor((position.x-fireball_r*1.1)/8-1),math.floor((position.x+fireball_r*1.1)/8+1) do
    for yChunkPos = math.floor((position.y-fireball_r*1.1)/8-1),math.floor((position.y+fireball_r*1.1)/8+1) do
      if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name =  water.waterTypes, limit = 1} == 0)) and
        (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name =  water.craterTypes0, limit = 1} == 0)) then
        local height = -2;
        if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name =  water.waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
          height = 0;
        end
        -- have both water and crater
        if(global.cratersFast[surface_index]==nil)then
          global.cratersFast[surface_index] = {}
          global.cratersFastData[surface_index] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
        end
        if(global.cratersFast[surface_index][xChunkPos]==nil)then
          global.cratersFast[surface_index][xChunkPos] = {}
          global.cratersFastData[surface_index].xCount = global.cratersFastData[surface_index].xCount + 1
        end
        global.cratersFast[surface_index][xChunkPos][yChunkPos] = height
      end
    end
  end
  -- slow filling - no checks required, all the chunks get this anyway
  for xChunkPos = math.floor((position.x-fireball_r*1.1)/32-1),math.floor((position.x+fireball_r*1.1)/32+1) do
    for yChunkPos = math.floor((position.y-fireball_r*1.1)/32-1),math.floor((position.y+fireball_r*1.1)/32+1) do
      if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*32, yChunkPos*32}, {xChunkPos*32+32, yChunkPos*32+32}}, name =  water.craterTypes0, limit = 1} == 0)) then
        table.insert(global.cratersSlow, {t = 0, x = xChunkPos, y = yChunkPos, surface = surface_index});
      end
    end
  end
end


local function nukeTileChangesHeightAware(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
  local tileTable = {}
  local noiseTables = {}
  if (crater_internal_r<5) then
    noiseTables[1] = {}
    --no extra noise needed
  elseif (crater_internal_r<10) then
    noiseTables[1] = {}
    noiseTables[2] = {}
    circularNoise(noiseTables[2], position, crater_internal_r, 1/2, 3)
    circularNoise(noiseTables[1], position, crater_external_r, 1/2, 3)
  elseif (crater_internal_r<20) then
    noiseTables[1] = {}
    noiseTables[2] = {}
    noiseTables[3] = {}
    noiseTables[4] = {}
    circularNoise(noiseTables[4], position, crater_internal_r/2, 1/2, 3)
    circularNoise(noiseTables[3], position, crater_internal_r, 1/2, 3)
    circularNoise(noiseTables[2], position, crater_internal_r, 1, 3)
    circularNoise(noiseTables[1], position, crater_external_r, 1/2, 3)
  else
    local noiseLevel = 1/2;
    if(crater_internal_r>50)then
      noiseLevel = 1;
    end
    noiseTables[1] = {}
    noiseTables[2] = {}
    noiseTables[3] = {}
    noiseTables[4] = {}
    noiseTables[5] = {}
    noiseTables[6] = {}
    noiseTables[7] = {}
    circularNoise(noiseTables[7], position, crater_internal_r/3, noiseLevel, 3)
    circularNoise(noiseTables[6], position, crater_internal_r*2/3, noiseLevel, 3)
    circularNoise(noiseTables[5], position, crater_internal_r, noiseLevel, 3)
    circularNoise(noiseTables[4], position, crater_internal_r, noiseLevel*2, 3)
    circularNoise(noiseTables[3], position, crater_external_r*1/3+crater_internal_r*2/3, noiseLevel, 3)
    circularNoise(noiseTables[2], position, crater_external_r*2/3+crater_internal_r*1/3, noiseLevel, 3)
    circularNoise(noiseTables[1], position, crater_external_r-1, noiseLevel, 3)
  end
  -- do the noise around the craters
  if (crater_external_r>8) then
    local externalNoise = {default = "nuclear-ground"}
    for tile,h in pairs( water.waterDepths) do
      externalNoise[tile] = water.depthsForCrater[h];
    end
    tileNoise(game.surfaces[surface_index], tileTable, position, crater_external_r, 1, externalNoise, 3);
  end
  for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5}) do
    local distSq = (v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)
    if(v.name == "out-of-map")then
    elseif(distSq>crater_external_r*crater_external_r and (noiseTables[1][v.position.x]==nil or noiseTables[1][v.position.x][v.position.y]==nil)) then
      if(water.waterDepths[v.name]) then
        table.insert(tileTable, {name = water.depthsForCrater[water.waterDepths[v.name]], position = v.position})
      end
    else
      local curr_height = water.waterDepths[v.name]
      if(curr_height==nil) then
        curr_height = 0;
      end
      if (crater_internal_r<5) then
        if(distSq<=crater_internal_r*crater_internal_r) then
          curr_height = math.min(curr_height, -1)
        end
      elseif (crater_internal_r<10) then
        if(distSq<=crater_internal_r*crater_internal_r) then
          curr_height = math.min(curr_height, -1)
        elseif (noiseTables[2][v.position.x]==nil or noiseTables[2][v.position.x][v.position.y]==nil)then
          -- any tile not hit by the noise does this, otherwise we leave it
          curr_height = curr_height+1;
        end
      elseif (crater_internal_r<20) then
        if(distSq<=crater_internal_r*crater_internal_r/4) then
          curr_height = math.min(curr_height, -2)
        elseif(distSq<=crater_internal_r*crater_internal_r) then
          if (noiseTables[4][v.position.x]==nil or noiseTables[4][v.position.x][v.position.y]==nil)then
            curr_height = math.min(curr_height, -1)
          else
            curr_height = math.min(curr_height, -2)
          end
        elseif not (noiseTables[3][v.position.x]==nil or noiseTables[3][v.position.x][v.position.y]==nil)then
          curr_height = math.min(curr_height, -1)
        elseif (noiseTables[2][v.position.x]==nil or noiseTables[2][v.position.x][v.position.y]==nil)then
          curr_height = curr_height+1;
        end
      else
        if(distSq<=crater_internal_r*crater_internal_r/9) then
          curr_height = math.min(curr_height, -3)
        elseif(distSq<=crater_internal_r*crater_internal_r*4/9) then
          if  (noiseTables[7][v.position.x]==nil or noiseTables[7][v.position.x][v.position.y]==nil)then
            curr_height = math.min(curr_height, -2)
          else
            curr_height = math.min(curr_height, -3)
          end
        elseif(distSq<=crater_internal_r*crater_internal_r) then
          if  (noiseTables[6][v.position.x]==nil or noiseTables[6][v.position.x][v.position.y]==nil)then
            curr_height = math.min(curr_height, -1)
          else
            curr_height = math.min(curr_height, -2)
          end
        elseif(distSq<=(crater_external_r*1/3+crater_internal_r*2/3)*(crater_external_r*1/3+crater_internal_r*2/3)) then
          if  not (noiseTables[5][v.position.x]==nil or noiseTables[5][v.position.x][v.position.y]==nil)then
            curr_height = math.min(curr_height, -1)
          elseif  (noiseTables[4][v.position.x]==nil or noiseTables[4][v.position.x][v.position.y]==nil)then
            curr_height = curr_height+1;
          end
        elseif(distSq<=(crater_external_r*2/3+crater_internal_r*1/3)*(crater_external_r*2/3+crater_internal_r*1/3)) then
          if  (noiseTables[3][v.position.x]==nil or noiseTables[3][v.position.x][v.position.y]==nil)then
            curr_height = curr_height+2;
          else
            curr_height = curr_height+1;
          end
        else
          if  (noiseTables[2][v.position.x]==nil or noiseTables[2][v.position.x][v.position.y]==nil)then
            curr_height = curr_height+1;
          else
            curr_height = curr_height+2;
          end
        end
      end
      if(curr_height > 1) then
        table.insert(tileTable, {name = "nuclear-high", position = v.position})
      else
        table.insert(tileTable, {name = water.depthsForCrater[curr_height], position = v.position})
      end
      if(#tileTable >=1000) then
        game.surfaces[surface_index].set_tiles(tileTable)
        tileTable = {};
      end
    end
  end

  if (fireball_r>8) then
    local groundNoise = {}
    circularNoise(groundNoise, position, fireball_r, 1, 3)
    for x,xtiles in pairs(groundNoise) do
      for y,_ in pairs(xtiles) do
        local tile = game.surfaces[surface_index].get_tile(x, y)
        if(tile ~= "out-of-map")then
          local tileDepth = water.waterDepths[tile.name];
          if not(tileDepth == nil) then
            table.insert(tileTable, {name = water.depthsForCrater[tileDepth], position = {x = x, y = y}})
          end
        end
      end
    end
  end

  game.surfaces[surface_index].set_tiles(tileTable)
  --make the high ground removable
  for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5, name="nuclear-high"}) do
    game.surfaces[surface_index].set_hidden_tile(v.position, "nuclear-ground")
  end

  -- setup craters to fill with water
  for xChunkPos = math.floor((position.x-fireball_r*1.1)/8-1),math.floor((position.x+fireball_r*1.1)/8+1) do
    for yChunkPos = math.floor((position.y-fireball_r*1.1)/8-1),math.floor((position.y+fireball_r*1.1)/8+1) do
      if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = water.waterTypes, limit = 1} == 0)) and
        (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = water.craterTypes0, limit = 1} == 0)) then
        local height = -2;
        if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = water.waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
          height = 0;

        end
        -- have both water and crater
        if(global.cratersFast[surface_index]==nil)then
          global.cratersFast[surface_index] = {}
          global.cratersFastData[surface_index] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
        end
        if(global.cratersFast[surface_index][xChunkPos]==nil)then
          global.cratersFast[surface_index][xChunkPos] = {}
          global.cratersFastData[surface_index].xCount = global.cratersFastData[surface_index].xCount + 1
        end
        global.cratersFast[surface_index][xChunkPos][yChunkPos] = height
      end
    end
  end
  if(not global.cratersSlow)then
    global.cratersSlow = {}
  end
  -- slow filling - no checks required, all the chunks get this anyway
  for xChunkPos = math.floor((position.x-fireball_r*1.1)/32-1),math.floor((position.x+fireball_r*1.1)/32+1) do
    for yChunkPos = math.floor((position.y-fireball_r*1.1)/32-1),math.floor((position.y+fireball_r*1.1)/32+1) do
      if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*32, yChunkPos*32}, {xChunkPos*32+32, yChunkPos*32+32}}, name = water.craterTypes0, limit = 1} == 0)) then
        table.insert(global.cratersSlow, {t = 0, x = xChunkPos, y = yChunkPos, surface = surface_index});
      end
    end
  end
end


local function chunk_loaded(surface_index, chunkPosAndArea, chunkLoaderStruct, originPos, x, y, ang1, ang2, ang3, ang4, minR, maxR)
  if(settings.global["destroy-resources-in-crater"].value) then
    -- destroy resources in crater (a bit more to account for the noise on crater edge)
    local craterEdgeSq = (chunkLoaderStruct.crater_external_r*1.1+4)*(chunkLoaderStruct.crater_external_r*1.1+4)
    for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{area = chunkPosAndArea.area, type="resource"}) do
      if(v.valid and (v.position.x-originPos.x)*(v.position.x-originPos.x) + (v.position.y-originPos.y)*(v.position.y-originPos.y)<=craterEdgeSq) then
        v.destroy()
      end
    end
  end
  local startAngle = math.min(ang1, ang2, ang3, ang4)
  local endAngle = math.max(ang1, ang2, ang3, ang4)
  local crater_internal_r = chunkLoaderStruct.crater_internal_r
  local crater_external_r = chunkLoaderStruct.crater_external_r
  local tileTable = {};
  for xoffset = 0, 32 do
    for yoffset = 0, 32 do
      local tilepos = {x + xoffset, y + yoffset}
      local xdiff = x+xoffset-originPos.x
      local ydiff = y+yoffset-originPos.y
      local distSq = xdiff*xdiff+ydiff*ydiff
      if(distSq<crater_internal_r*crater_internal_r/9) then
        table.insert(tileTable, {name = water.depthsForCrater[-3], position = tilepos})
      elseif(distSq<crater_internal_r*crater_internal_r*4/9) then
        table.insert(tileTable, {name = water.depthsForCrater[-2], position = tilepos})
      elseif(distSq<crater_internal_r*crater_internal_r) then
        table.insert(tileTable, {name = water.depthsForCrater[-1], position = tilepos})
      elseif(distSq<crater_external_r*crater_external_r) then
        table.insert(tileTable, {name = water.depthsForCrater[1], position = tilepos})
      end
    end
  end
  game.surfaces[surface_index].set_tiles(tileTable)
  tileTable = {};
  -- add noise
  if(minR<crater_internal_r*1.1/3+10 and maxR> crater_internal_r/3-10) then
    tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r/3, 1, {default = water.depthsForCrater[-3]}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
  end
  if(minR<crater_internal_r*1.1*2/3+10 and maxR> crater_internal_r*2/3-10) then
    tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r*2/3, 1, {default = water.depthsForCrater[-2]}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
  end
  if(minR<crater_internal_r*1.15+10 and maxR> crater_internal_r-10) then
    tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r, 2, {default = water.depthsForCrater[0]}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
    tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r, 1, {default = water.depthsForCrater[-1]}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
  end
  game.surfaces[surface_index].set_tiles(tileTable)
  tileTable={};
  -- ensure noise for crater goes on top of lakes

  --noise around the crater
  if(minR<crater_external_r*1.1+10 and maxR> crater_external_r-10) then
    tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_external_r, 1, {default = "nuclear-ground"}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
  end
  --high noise around crater
  if(minR<crater_external_r*1.1+6 and maxR> crater_external_r-14) then
    tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_external_r-4, 1, {default = "nuclear-high"}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
  end

  game.surfaces[surface_index].set_tiles(tileTable)
  for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{area=chunkPosAndArea.area, name="nuclear-high"}) do
    game.surfaces[surface_index].set_hidden_tile(v.position, "nuclear-ground")
  end
end

local function chunk_loaded_outer(surface_index, chunkPosAndArea, chunkLoaderStruct, originPos, x, y, ang1, ang2, ang3, ang4, minR, maxR)
  local tiles = game.surfaces[surface_index].find_tiles_filtered{area=chunkPosAndArea.area, name=water.waterTypes};
  if(#tiles ~=0) then
    local startAngle = math.min(ang1, ang2, ang3, ang4)
    local endAngle = math.max(ang1, ang2, ang3, ang4)
    local tileTable = {};

    local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
    for _,v in pairs(tiles) do
      if((v.position.x-originPos.x)*(v.position.x-originPos.x)+(v.position.y-originPos.y)*(v.position.y-originPos.y)<=fireballSq) then
        local depth = water.waterDepths[v.name]
        if(depth) then
          --          if (depth == -2 and (v.position.x == x or v.position.x == x+31))then
          --depth = -3;
          --          elseif (depth == -2 and (v.position.y == y or v.position.y == y+31))then
          --depth = -3
          --          end
          table.insert(tileTable, {name = water.depthsForCrater[depth], position = v.position})
        end
      end
    end
    game.surfaces[surface_index].set_tiles(tileTable)
    if(maxR>chunkLoaderStruct.fireball_r-4) then
      tileTable = {};
      local waterMapping = {}
      for t,h in pairs(water.waterDepths) do
        waterMapping[t] = water.depthsForCrater[h]
      end
      tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, chunkLoaderStruct.fireball_r, 1, waterMapping, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
      game.surfaces[surface_index].set_tiles(tileTable)
    end
  end
end
return {
  nukeTileChangesHeightAware = nukeTileChangesHeightAware,
  nukeTileChangesHeightAwareHuge = nukeTileChangesHeightAwareHuge,
  chunk_loaded = chunk_loaded,
  chunk_loaded_outer = chunk_loaded_outer,
  use_fires = true
}
