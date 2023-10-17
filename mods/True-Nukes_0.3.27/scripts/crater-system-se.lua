local water = require("water-system")

local spaceTiles = {"se-regolith", "se-space-platform-plating", "se-space-platform-scaffold"}
local allSpaceTiles = {"se-regolith", "se-space-platform-plating", "se-space-platform-scaffold", "se-space"}

local function tileDown1Map(tile)
  if(tile.name == "se-regolith" or tile.name == "se-space-platform-scaffold")then
    return "se-space"
  elseif(tile.name == "se-space-platform-plating")then
    if(tile.hidden_tile == "se-space") then
      return "se-space-platform-plating"
    else
      return tile.hidden_tile or "se-space-platform-plating"
    end
    return "se-space-platform-scaffold"
  elseif(tile.name == "se-spaceship-floor")then
    return tile.hidden_tile or "se-space"
  else
    return "se-space"
  end
end

local function mapTile(tile, diff)
  if(diff <= 1) then
    return tileDown1Map(tile)
  else
    return "se-space"
  end
end
local bigMapDown1 = {default = "se-space"}
bigMapDown1["se-space-platform-plating"] = "se-space-platform-scaffold"


local util = require("crater-util")

local  circularNoise = util.circularNoise
local  tileNoise = util.tileNoise
local  tileNoiseLimited = util.tileNoiseLimited


local function nukeTileChangesHeightAware(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
  local hiddenTable = {}
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
  for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5}) do
    local distSq = (v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)
    local diffToDrop = 0
    if (crater_internal_r<10) then
      if(distSq<=crater_internal_r*crater_internal_r) then
        diffToDrop = 1
      end
    elseif (crater_internal_r<20) then
      if(distSq<=crater_internal_r*crater_internal_r/4) then
        diffToDrop = 2
      elseif(distSq<=crater_internal_r*crater_internal_r) then
        if (noiseTables[4][v.position.x]==nil or noiseTables[4][v.position.x][v.position.y]==nil)then
          diffToDrop = 1
        else
          diffToDrop = 2
        end
      elseif not (noiseTables[3][v.position.x]==nil or noiseTables[3][v.position.x][v.position.y]==nil)then
        diffToDrop = 1
      end
    else
      if(distSq<=crater_internal_r*crater_internal_r/9) then
        diffToDrop = 2
      elseif(distSq<=crater_internal_r*crater_internal_r*4/9) then
        if  (noiseTables[7][v.position.x]==nil or noiseTables[7][v.position.x][v.position.y]==nil)then
          diffToDrop = 2
        else
          diffToDrop = 2
        end
      elseif(distSq<=crater_internal_r*crater_internal_r) then
        if  (noiseTables[6][v.position.x]==nil or noiseTables[6][v.position.x][v.position.y]==nil)then
          diffToDrop = 1
        else
          diffToDrop = 2
        end
      elseif(distSq<=(crater_external_r*1/3+crater_internal_r*2/3)*(crater_external_r*1/3+crater_internal_r*2/3)) then
        if  not (noiseTables[5][v.position.x]==nil or noiseTables[5][v.position.x][v.position.y]==nil)then
          diffToDrop = 1
        end
      end
    end

    if(diffToDrop ~= 0) then
      if(v.hidden_tile) then
        hiddenTable[v.position] = v.hidden_tile
      end
      table.insert(tileTable, {name = mapTile(v, diffToDrop), position = v.position})
    end
    if(#tileTable >=1000) then
      game.surfaces[surface_index].set_tiles(tileTable)
      tileTable = {};
    end
  end

  game.surfaces[surface_index].set_tiles(tileTable)
  for pos,h in pairs(hiddenTable) do
    game.surfaces[surface_index].set_hidden_tile(pos, h)
  end
end


local function chunk_loaded(surface_index, chunkPosAndArea, chunkLoaderStruct, originPos, x, y, ang1, ang2, ang3, ang4, minR, maxR)
  local hiddenTable = {}

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
      if(distSq<crater_internal_r*crater_internal_r/2) then
        table.insert(tileTable, {name = "se-space", position = tilepos})
      elseif(distSq<crater_internal_r*crater_internal_r) then
        local tile = game.surfaces[surface_index].get_tile(x + xoffset, y + yoffset)
        if(tile.hidden_tile) then
          hiddenTable[tile.position] = tile.hidden_tile
        end
        table.insert(tileTable, {name = mapTile(tile, 1), position = tilepos})
      end
    end
  end
  game.surfaces[surface_index].set_tiles(tileTable)
  tileTable = {};
  -- add noise
  if(minR<crater_internal_r*1.1/2+10 and maxR> crater_internal_r/2-10) then
    tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r/2, 1, {default = "se-space"}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
  end
  if(minR<crater_internal_r*1.15+10 and maxR> crater_internal_r-10) then
    tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r, 1, bigMapDown1, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
  end
  game.surfaces[surface_index].set_tiles(tileTable)

  for pos,h in pairs(hiddenTable) do
    game.surfaces[surface_index].set_hidden_tile(pos, h)
  end
  for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{area=chunkPosAndArea.area, name="se-space-platform-scaffold"}) do
    if(not v.hidden_tile) then
      game.surfaces[surface_index].set_hidden_tile(v.position, "se-space")
    end
  end
end

return {
  nukeTileChangesHeightAware = nukeTileChangesHeightAware,
  nukeTileChangesHeightAwareHuge = nukeTileChangesHeightAware,
  chunk_loaded = chunk_loaded,
  chunk_loaded_outer = function() end,
  interesting_tiles = allSpaceTiles,
  use_fires = false
}
