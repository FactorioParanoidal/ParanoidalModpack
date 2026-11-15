
local function circularNoise(tableTarget, position, radius, depthMult, sliceCount)
  if (settings.global["nuke-crater-noise"].value) then
    for num=0,sliceCount do
      local slice_w = (math.floor(radius*depthMult/50)+1)
      for ang=0,math.ceil(3.1416*2*radius*slice_w*4/(num*num+1)) do
        local dist = math.floor(num*slice_w+slice_w*math.random())
        local offset = math.random()

        local noise_pos = {x = math.floor(position.x+(dist+radius-1)*math.sin(ang+offset)+0.5), y = math.floor(position.y+(dist+radius-1)*math.cos(ang+offset)+0.5)}
        if((position.x-noise_pos.x)*(position.x-noise_pos.x)+(position.y-noise_pos.y)*(position.y-noise_pos.y)<=radius*radius) then
        --Do nothing - used to remove rounding errors and prevent hitting the same tile twice
        else
          if(tableTarget[noise_pos.x]==nil) then
            tableTarget[noise_pos.x] = {}
          end
          tableTarget[noise_pos.x][noise_pos.y] = 1;
        end
      end
    end
  end
end

local function tileNoise(surface, tableTarget, position, radius, depthMult, tileMap, sliceCount)
  if (settings.global["nuke-crater-noise"].value) then
    local defaultOnly = true
    for k,v in pairs (tileMap) do
      if(k~="default") then
        defaultOnly=false;
        break;
      end
    end
    for num=0,sliceCount do
      local slice_w = (math.floor(radius*depthMult/50)+1)
      for ang=0,math.ceil(3.1416*2*radius*slice_w*4/(num*num+1)) do
        local dist = math.floor(math.random(num*slice_w, slice_w+num*slice_w))
        local offset = math.random()

        local noise_pos = {x = math.floor(position.x+(dist+radius-1)*math.sin(ang+offset)+0.5), y = math.floor(position.y+(dist+radius-1)*math.cos(ang+offset)+0.5)}
        local cur_tile = defaultOnly or surface.get_tile(noise_pos)
        if((not defaultOnly and cur_tile.name == "out-of-map") or (position.x-noise_pos.x)*(position.x-noise_pos.x)+(position.y-noise_pos.y)*(position.y-noise_pos.y)<=radius+0.5) then
        --Do nothing - used to remove rounding errors and prevent hitting the same tile twice
        elseif (defaultOnly or tileMap[cur_tile.name] == nil) then
          if(not(tileMap["default"] ==nil)) then
            table.insert(tableTarget, {name = tileMap["default"], position = noise_pos})
          end
        else
          table.insert(tableTarget, {name = tileMap[cur_tile.name], position = noise_pos})
        end
      end
    end
  end
end


local function tileNoiseLimited(surface, tableTarget, position, radius, depthMult, tileMap, sliceCount, lesserAngle, greaterAngle, minR, maxR, boundaryBox)
  if (settings.global["nuke-crater-noise"].value) then
    local defaultOnly = true
    for k,v in pairs (tileMap) do
      if(k~="default") then
        defaultOnly=false;
        break;
      end
    end
    local startAngle = lesserAngle
    local endAngle = greaterAngle
    local angleDiff = (endAngle-startAngle)
    if(angleDiff>5) then
      angleDiff = 6.283185307-angleDiff
      local tmp = startAngle;
      startAngle = endAngle;
      endAngle = tmp+6.283185307;
    end
    local slice_w = (math.floor(radius*depthMult/50)+1)
    for num=0,sliceCount do
      if(minR<=slice_w+num*slice_w+radius and maxR>=num*slice_w+radius-1) then
        for ang=0,math.ceil(angleDiff*radius*slice_w*4/(num*num+1)) do
          local dist = math.floor(math.random(num*slice_w, slice_w+num*slice_w))
          local offset = math.random()+sliceCount
          local angle = (ang+offset)%angleDiff+startAngle
          local noise_pos = {x = math.floor(position.x+(dist+radius-1)*math.cos(angle)+0.5), y = math.floor(position.y+(dist+radius-1)*math.sin(angle)+0.5)}
          if(boundaryBox.left_top.x<=noise_pos.x and boundaryBox.right_bottom.x>=noise_pos.x
            and boundaryBox.left_top.y<=noise_pos.y and boundaryBox.right_bottom.y>=noise_pos.y) then
            local cur_tile = defaultOnly or surface.get_tile(noise_pos)
            if(defaultOnly or (cur_tile.valid and cur_tile.name~="out-of-map")) then
              if((position.x-noise_pos.x)*(position.x-noise_pos.x)+(position.y-noise_pos.y)*(position.y-noise_pos.y)<=radius+0.5) then
              --Do nothing - used to remove rounding errors and prevent hitting the same tile twice
              elseif (defaultOnly or tileMap[cur_tile.name] == nil) then
                if(not(tileMap["default"] == nil)) then
                  table.insert(tableTarget, {name = tileMap["default"], position = noise_pos})
                end
              else
                table.insert(tableTarget, {name = tileMap[cur_tile.name], position = noise_pos})
              end
            end
          end
        end
      end
    end
  end
end
return {
  circularNoise = circularNoise,
  tileNoise = tileNoise,
  tileNoiseLimited = tileNoiseLimited
}
