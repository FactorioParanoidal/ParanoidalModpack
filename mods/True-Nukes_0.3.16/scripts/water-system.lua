-- These allow lookups to find tiles of interest in an area.
local waterAndCraterTypes = {"nuclear-deep", "nuclear-crater", "nuclear-shallow", "nuclear-crater-shallow-fill", "nuclear-deep-shallow-fill", "nuclear-deep-fill", "deepwater", "water", "water-shallow", "water-mud"}

local waterTypes = {"water-shallow", "water-mud", "nuclear-crater-shallow-fill", "water", "nuclear-deep-shallow-fill", "nuclear-deep-fill", "deepwater"}


local craterTypes0 = {"nuclear-deep", "nuclear-crater", "nuclear-shallow", "nuclear-crater-shallow-fill", "nuclear-deep-shallow-fill", "nuclear-deep-fill"}
local craterTypes1 = {"nuclear-deep", "nuclear-crater", "nuclear-deep-shallow-fill"}
local craterTypes2 = {"nuclear-deep"}


-- These allow water to be emptied, by getting the depth of the ground beneath the water.
local waterDepths = {}
waterDepths["nuclear-shallow"] = -1
waterDepths["water-shallow"] = -1
waterDepths["water-mud"] = -1
waterDepths["nuclear-crater"] = -2
waterDepths["nuclear-crater-shallow-fill"] = -2
waterDepths["water"] = -2
waterDepths["nuclear-deep"] = -3
waterDepths["nuclear-deep-shallow-fill"] = -3
waterDepths["nuclear-deep-fill"] = -3
waterDepths["deepwater"] = -3
waterDepths["nuclear-high"] = 1
--everything else is treated as 0


-- these are the heights of water given a tile, as far as nearby tiles are concerned
local waterInCraterGoingOutDepths = {}
waterInCraterGoingOutDepths["nuclear-shallow"] = -10
waterInCraterGoingOutDepths["water-shallow"] = 0
waterInCraterGoingOutDepths["water-mud"] = 0
waterInCraterGoingOutDepths["nuclear-crater"] = -10
waterInCraterGoingOutDepths["nuclear-crater-shallow-fill"] = -1
waterInCraterGoingOutDepths["water"] = 0
waterInCraterGoingOutDepths["nuclear-deep"] = -10
waterInCraterGoingOutDepths["nuclear-deep-shallow-fill"] = -2
waterInCraterGoingOutDepths["nuclear-deep-fill"] = -1
waterInCraterGoingOutDepths["deepwater"] = 0

-- these are the waters for different heights, so that we can find the water height in any given area
local waterInCraterGoingOutDepth0Only = {"deepwater", "water", "water-shallow", "water-mud"}
local waterInCraterGoingOutDepth1Only = {"nuclear-crater-shallow-fill", "nuclear-deep-fill"}
local waterInCraterGoingOutDepth2Only = {"nuclear-deep-shallow-fill"}

-- these are the height of water given a tile, for whether that tile will be filled with water
local waterInCraterGoingInDepths = {}
waterInCraterGoingInDepths["nuclear-shallow"] = -1
waterInCraterGoingInDepths["water-shallow"] = 0
waterInCraterGoingInDepths["water-mud"] = 0
waterInCraterGoingInDepths["nuclear-crater"] = -2
waterInCraterGoingInDepths["nuclear-crater-shallow-fill"] = -1
waterInCraterGoingInDepths["water"] = 0
waterInCraterGoingInDepths["nuclear-deep"] = -3
waterInCraterGoingInDepths["nuclear-deep-shallow-fill"] = -2
waterInCraterGoingInDepths["nuclear-deep-fill"] = -1
waterInCraterGoingInDepths["deepwater"] = 0

-- these allow empty crater to be created from a height
local depthsForCrater = {}
depthsForCrater[-3] = "nuclear-deep"
depthsForCrater[-2] = "nuclear-crater"
depthsForCrater[-1] = "nuclear-shallow"
depthsForCrater[0] = "nuclear-ground"
depthsForCrater[1] = "nuclear-high"

-- These allow water to fill craters intelligently
local depthsForCraterWater = {}
depthsForCraterWater[-3] = {}
depthsForCraterWater[-3][-3] = "nuclear-deep"
depthsForCraterWater[-3][-2] = "nuclear-deep-shallow-fill"
depthsForCraterWater[-3][-1] = "nuclear-deep-fill"
depthsForCraterWater[-3][0] = "deepwater"
depthsForCraterWater[-2] = {}
depthsForCraterWater[-2][-2] = "nuclear-crater"
depthsForCraterWater[-2][-1] = "nuclear-crater-shallow-fill"
depthsForCraterWater[-2][0] = "water"
depthsForCraterWater[-1] = {}
depthsForCraterWater[-1][-1] = "nuclear-shallow"
depthsForCraterWater[-1][0] = "water-mud"


local function fastFill(event)
  -- fast crater filling
  if(global.cratersFast==nil) then
    global.cratersFast = {}
  end
  if(global.cratersFastItterationCount == nil) then
    global.cratersFastItterationCount = 0
  end
  if(global.cratersFastData == nil) then
    global.cratersFastData = {}
  end
  global.cratersFastItterationCount = global.cratersFastItterationCount + 1
  if(global.cratersFastItterationCount > 53) then
    global.cratersFastItterationCount = 1
  end
  for surface,chunks in pairs(global.cratersFast) do
    if(not game.surfaces[surface]) then
      global.cratersFast[surface] = nil;
    else
      global.cratersFastData[surface].synch = global.cratersFastData[surface].synch+1
      if(global.cratersFastData[surface].synch == 5) then
        global.cratersFastData[surface].synch = 1
      end
      if(global.cratersFastItterationCount == 1) then
        global.cratersFastData[surface].xCountSoFar = 0
        global.cratersFastData[surface].xDone = {}
      end
      for x,xchunks in pairs(chunks) do
        if(global.cratersFastData[surface].xDone[x]==nil) then  --ignore all the ones we have already done
          if(global.cratersFastData[surface].xCountSoFar > global.cratersFastData[surface].xCount*global.cratersFastItterationCount/53) then
            break;
        end
        global.cratersFastData[surface].xDone[x] = 1
        global.cratersFastData[surface].xCountSoFar = global.cratersFastData[surface].xCountSoFar + 1
        local count = 0;
        for y,foundChunkH in pairs(xchunks) do
          local tileChanges = {}
          local ghostChanges = {}

          local targetTiles
          local chunkH = foundChunkH

          if(chunkH >= 0 and global.cratersFastData[surface].synch==1) then
            targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*8, y*8}, {x*8+8, y*8+8}}, name=craterTypes0}
          elseif(chunkH >= -1 and (global.cratersFastData[surface].synch == 3 or global.cratersFastData[surface].synch == 1)) then
            targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*8, y*8}, {x*8+8, y*8+8}}, name=craterTypes1}
          else
            targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*8, y*8}, {x*8+8, y*8+8}}, name=craterTypes2}
          end
          if(#targetTiles>0) then
            count = count+1;
            local relevantTiles = game.surfaces[surface].find_tiles_filtered{area={{x*8-1, y*8-1}, {x*8+9, y*8+9}}, name=waterTypes}

            local tileH = {}
            local existsChunks = {};
            if(existsChunks[math.floor(x/4)] == nil) then
              existsChunks[math.floor(x/4)] = {}
            end
            existsChunks[math.floor(x/4)][math.floor(y/4)] = game.surfaces[surface].is_chunk_generated({math.floor(x/4), math.floor(y/4)});
            existsChunks[math.floor(x/4)][math.floor((y+1)/4)] = game.surfaces[surface].is_chunk_generated({math.floor(x/4), math.floor((y+1)/4)});
            existsChunks[math.floor(x/4)][math.floor((y-1)/4)] = game.surfaces[surface].is_chunk_generated({math.floor(x/4), math.floor((y-1)/4)});

            if(existsChunks[math.floor((x-1)/4)] == nil) then
              existsChunks[math.floor((x-1)/4)] = {}
            end
            existsChunks[math.floor((x-1)/4)][math.floor(y/4)] = game.surfaces[surface].is_chunk_generated({math.floor((x-1)/4), math.floor(y/4)});

            if(existsChunks[math.floor((x+1)/4)] == nil) then
              existsChunks[math.floor((x+1)/4)] = {}
            end
            existsChunks[math.floor((x+1)/4)][math.floor(y/4)] = game.surfaces[surface].is_chunk_generated({math.floor((x+1)/4), math.floor(y/4)});



            for _,t in pairs(relevantTiles) do
              if(tileH[t.position.x] == nil) then
                tileH[t.position.x] = {}
              end
              if(existsChunks[math.floor(t.position.x/32)][math.floor(t.position.y/32)]) then
                tileH[t.position.x][t.position.y] = waterInCraterGoingOutDepths[t.name];
              end
            end
            local hasHeightDiff = false;
            for _,t in pairs(targetTiles) do
              local heightDiff = 0;
              local currentH = waterInCraterGoingInDepths[t.name];
              chunkH = math.max(chunkH, currentH)
              local h1
              local h2
              if(tileH[t.position.x] ~=nil) then
                h1 = tileH[t.position.x][t.position.y+1];
                h2 = tileH[t.position.x][t.position.y-1];
              end

              local h3
              if(tileH[t.position.x+1] ~=nil) then
                h3 = tileH[t.position.x+1][t.position.y];
              end
              local h4
              if(tileH[t.position.x-1] ~=nil) then
                h4 = tileH[t.position.x-1][t.position.y];
              end

              if((not (h1 == nil)) and h1>currentH)then
                heightDiff = heightDiff+h1-currentH;
                chunkH = math.max(chunkH, h1)
              end
              if((not (h2 == nil)) and h2>currentH)then
                heightDiff = heightDiff+h2-currentH;
                chunkH = math.max(chunkH, h2)
              end
              if((not (h3 == nil)) and h3>currentH)then
                heightDiff = heightDiff+h3-currentH;
                chunkH = math.max(chunkH, h3)
              end
              if((not (h4 == nil)) and h4>currentH)then
                heightDiff = heightDiff+h4-currentH;
                chunkH = math.max(chunkH, h4)
              end
              if(heightDiff>0) then
                hasHeightDiff = true;
              end
              if(heightDiff>0 and (heightDiff>=3 or math.random()*3<heightDiff))then
                if(currentH == waterDepths[t.name]) then
                  for _,f in pairs(game.surfaces[surface].find_entities_filtered{area={{t.position.x, t.position.y}, {t.position.x+1, t.position.y+1}}, type="fire"}) do
                    f.destroy();
                  end
                end
                chunkH = math.max(chunkH, currentH+1)
                table.insert(tileChanges, {name=depthsForCraterWater[waterDepths[t.name]][currentH+1], position = t.position})
                for _,tileGhost in pairs(game.surfaces[surface].find_entities_filtered{position = {t.position.x+0.5, t.position.y+0.5}, name = "tile-ghost"}) do
                  table.insert(ghostChanges, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = {t.position.x+0.5, t.position.y+0.5}})
                end
                if(t.position.x == x*8) then
                  if(chunks[x-1]==nil) then
                    chunks[x-1] = {};
                    global.cratersFastData[surface].xCount = global.cratersFastData[surface].xCount + 1
                  end
                  if(chunks[x-1][y]==nil) then
                    chunks[x-1][y] = currentH+1
                  else
                    chunks[x-1][y] = math.max(currentH+1, chunks[x-1][y])
                  end
                elseif(t.position.x == x*8+7) then
                  if(chunks[x+1]==nil) then
                    chunks[x+1] = {};
                    global.cratersFastData[surface].xCount = global.cratersFastData[surface].xCount + 1
                  end
                  if(chunks[x+1][y]==nil) then
                    chunks[x+1][y] = currentH+1
                  else
                    chunks[x+1][y] = math.max(currentH+1, chunks[x+1][y]);
                  end
                end
                if(t.position.y == y*8) then
                  if(xchunks[y-1]==nil) then
                    xchunks[y-1] = currentH+1
                  else
                    xchunks[y-1] = math.max(currentH+1, xchunks[y-1]);
                  end
                elseif(t.position.y == y*8+7) then
                  if(xchunks[y+1]==nil) then
                    xchunks[y+1] = currentH+1
                  else
                    xchunks[y+1] = math.max(currentH+1, xchunks[y+1]);
                  end
                end
              end
            end
            game.surfaces[surface].set_tiles(tileChanges)
            for _,ghost in pairs(ghostChanges) do
              game.surfaces[surface].create_entity{name="tile-ghost",position=ghost.pos,inner_name=ghost.ghost_name,force=ghost.force}
            end
            xchunks[y] = chunkH; -- just to set the height back to being correct, in case it has changed (e.g. a new, higher water level has been found)
            if global.cratersFastData[surface].synch==1 and not hasHeightDiff then
              xchunks[y] = nil
              if next(xchunks) == nil then
                global.cratersFastData[surface].xCount = global.cratersFastData[surface].xCount-1
                chunks[x] = nil
              end
              if next(chunks) == nil then
                global.cratersFast[surface] = nil
                global.cratersFastData[surface] = nil
              end
            end
          elseif(global.cratersFastData[surface].synch ~= 1) then
            count = count+1;
          else
            xchunks[y] = nil;
          end
        end
        if (count==0) then
          chunks[x] = nil;
        end
        end
      end
    end
  end
end
local function slowFill(event)
  -- slow crater filling
  if(global.cratersSlow == nil) then
    global.cratersSlow = {}
  end
  for index,chunk in pairs(global.cratersSlow) do
    chunk.t = chunk.t+1;
    if(chunk.t>30) then
      local target = nil
      if not game.surfaces[chunk.surface] then
        global.cratersSlow[index] = nil
      elseif (not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes2, limit = 1} == 0)) then
        local prob = 128;
        if(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
          prob = prob/8
        elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth1Only, limit = 1} == 0)) then
          prob = prob/4
        elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
          prob = prob/2
        end
        prob = prob - math.floor((chunk.t-30)/3)
        if(math.random(1, math.max(prob,2)) == 1) then
          local targets = game.surfaces[chunk.surface].find_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes2}
          target = targets[math.random(1, #targets)]
        end
      elseif (not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes1, limit = 1} == 0)) then
        local prob = 512;
        if(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
          prob = prob/32
        elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth1Only, limit = 1} == 0)) then
          prob = prob/16
        elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
          prob = prob/2
        end
        prob = prob - math.floor((chunk.t-30)/3)
        if(math.random(1, math.max(prob,2)) == 1) then
          local targets = game.surfaces[chunk.surface].find_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes1}
          target = targets[math.random(1, #targets)]
        end
      elseif (not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes0, limit = 1} == 0)) then
        local prob = 2048;
        if(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
          prob = prob/32
        elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth1Only, limit = 1} == 0)) then
          prob = prob/4
        elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
          prob = prob/2
        end
        prob = prob - math.floor((chunk.t-30)/3)
        if math.random(1, math.max(prob,2)) == 1 then
          local targets = game.surfaces[chunk.surface].find_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes0}
          target = targets[math.random(1, #targets)]
        end
      else
        global.cratersSlow[index] = nil
      end
      if not (target==nil) then
        local h = waterInCraterGoingInDepths[target.name]+1
        local pos = target.position;

        -- ensure we preserve ghosts, e.g. landfill
        local tileGhosts = {}
        for _,t in pairs(game.surfaces[chunk.surface].find_entities_filtered{position = {pos.x+0.5, pos.y+0.5}, name = "tile-ghost"}) do
          table.insert(tileGhosts, {ghost_name = t.ghost_name, force = t.force})
        end
        game.surfaces[chunk.surface].set_tiles({{name = depthsForCraterWater[waterDepths[target.name]][h], position = pos}});
        for _,t in pairs(tileGhosts) do
          game.surfaces[chunk.surface].create_entity{name="tile-ghost",position={pos.x+0.5, pos.y+0.5},inner_name=t.ghost_name,force=t.force}
        end

        if(global.cratersFast[chunk.surface]==nil)then
          global.cratersFast[chunk.surface] = {}
          global.cratersFastData[chunk.surface] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
        end
        local xChunkPos = math.floor(pos.x/8)
        if(global.cratersFast[chunk.surface][xChunkPos]==nil)then
          global.cratersFast[chunk.surface][xChunkPos] = {}
          global.cratersFastData[chunk.surface].xCount = global.cratersFastData[chunk.surface].xCount + 1
        end
        if(global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/8)] == nil) then
          global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/8)] = h
        else
          global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/8)] = math.max(global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/8)], h)
        end
      end
    end
  end
end

local function check_fill(surface_index, chunkPosAndArea, x, y)
  if (not (game.surfaces[surface_index].count_tiles_filtered{
    area={{x=chunkPosAndArea.area.left_top.x+1, y=chunkPosAndArea.area.left_top.y+1},{x=chunkPosAndArea.area.right_bottom.x-1, y=chunkPosAndArea.area.right_bottom.y-1}}, name = craterTypes0, limit = 1
  } == 0)) then
    table.insert(global.cratersSlow, {t = 0, x = chunkPosAndArea.x, y = chunkPosAndArea.y, surface = surface_index});
    for xChunkPos = 0,4 do
      for yChunkPos = 0,4 do
        if (not (game.surfaces[surface_index].count_tiles_filtered{area={{x+xChunkPos*8, y+yChunkPos*8}, {x+xChunkPos*8+8, y+yChunkPos*8+8}}, name = waterTypes, limit = 1} == 0)) and
          (not (game.surfaces[surface_index].count_tiles_filtered{area={{x+xChunkPos*8, y+yChunkPos*8}, {x+xChunkPos*8+8, y+yChunkPos*8+8}}, name = craterTypes0, limit = 1} == 0)) then
          local height = -2;
          if (not (game.surfaces[surface_index].count_tiles_filtered{area={{x+xChunkPos*8, y+yChunkPos*8}, {x+xChunkPos*8+8, y+yChunkPos*8+8}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
            height = 0;
          end
          -- have both water and crater
          if(global.cratersFast[surface_index]==nil)then
            global.cratersFast[surface_index] = {}
            global.cratersFastData[surface_index] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
          end
          if(global.cratersFast[surface_index][chunkPosAndArea.x*4+xChunkPos]==nil)then
            global.cratersFast[surface_index][chunkPosAndArea.x*4+xChunkPos] = {}
            global.cratersFastData[surface_index].xCount = global.cratersFastData[surface_index].xCount + 1
          end
          global.cratersFast[surface_index][chunkPosAndArea.x*4+xChunkPos][chunkPosAndArea.y*4+yChunkPos] = height
        end
      end
    end
  end
end
return {
  waterAndCraterTypes = waterAndCraterTypes,
  waterTypes = waterTypes,
  craterTypes0 = craterTypes0,
  craterTypes1 = craterTypes1,
  craterTypes2 = craterTypes2,
  waterDepths = waterDepths,
  waterInCraterGoingOutDepths = waterInCraterGoingOutDepths,
  waterInCraterGoingOutDepth0Only = waterInCraterGoingOutDepth0Only,
  waterInCraterGoingOutDepth1Only = waterInCraterGoingOutDepth1Only,
  waterInCraterGoingOutDepth2Only = waterInCraterGoingOutDepth2Only,
  waterInCraterGoingInDepths = waterInCraterGoingInDepths,
  depthsForCrater = depthsForCrater,
  depthsForCraterWater = depthsForCraterWater,
  fastFill = fastFill,
  slowFill = slowFill,
  check_fill = check_fill
}
