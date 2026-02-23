require "util"

beltutil = {}
beltutil.belt_type_check = util.list_to_map({"transport-belt","underground-belt","splitter","loader","loader-1x1"})

-- These functions return a list of belt neighbors that includes underground belt input/output, since they are in a different API structure.
-- The exclude list is a map of unit_number->true that contains belts we have queued for deconstruction already, so ignore them as neighbors
function beltutil.get_belt_outputs(belt, exclude)
  local outputs = {}
  for _,neighbor in pairs(belt.belt_neighbours.outputs) do
    if not (exclude and exclude[neighbor.unit_number]) then
      table.insert(outputs,neighbor)
    end
  end
  if belt.type == "underground-belt" and belt.belt_to_ground_type == "input" then
    local neighbor = belt.neighbours
    if neighbor and not (exclude and exclude[neighbor.unit_number]) then
      table.insert(outputs,neighbor)  -- insert the output undie for this input undie, since that is downstream
    end
  end
  return outputs
end

function beltutil.get_belt_inputs(belt, exclude)
  local inputs = {}
  for _,neighbor in pairs(belt.belt_neighbours.inputs) do
    if not (exclude and exclude[neighbor.unit_number]) then
      table.insert(inputs,neighbor)
    end
  end
  if belt.type == "underground-belt" and belt.belt_to_ground_type == "output" then
    local neighbor = belt.neighbours
    if neighbor and not (exclude and exclude[neighbor.unit_number]) then
      table.insert(inputs,neighbor)  -- insert the input undie for this output undie, since that is upstream
    end
  end
  return inputs
end



function beltutil.find_target_line(drill, target)
  if not target or not beltutil.belt_type_check[target.type] then
    return
  end
  
  -- Figure out all the cases for where the miner can drop the item on the belt.
  -- If drop_pos is at exactly 0.5, it defaults to the right line
  local belt_pos = target.position
  local drop_pos = drill.drop_position
  local belt_dir = target.direction
  
  local target_line_index = 0
  
  if target.type == "transport-belt" and target.belt_shape == "left" then
    -- Left turn belt, can only ever deposit on the right line (assuming miner drops close to itself)
    target_line_index = defines.transport_line.right_line
      
  elseif target.type == "transport-belt" and target.belt_shape == "right" then
    -- Right turn belt, can only ever deposit on the left line (assuming miner drops close to itself)
    target_line_index = defines.transport_line.left_line
    
  elseif target.type == "transport-belt" or target.type == "underground-belt" then
    -- Straight belt or underground
    if belt_dir == defines.direction.north then
      if drop_pos.x < belt_pos.x then
        target_line_index = defines.transport_line.left_line
      else
        target_line_index = defines.transport_line.right_line
      end
    elseif belt_dir == defines.direction.south then
      if drop_pos.x > belt_pos.x then
        target_line_index = defines.transport_line.left_line
      else
        target_line_index = defines.transport_line.right_line
      end
    elseif belt_dir == defines.direction.east then
      if drop_pos.y  < belt_pos.y then
        target_line_index = defines.transport_line.left_line
      else
        target_line_index = defines.transport_line.right_line
      end
    elseif belt_dir == defines.direction.west then
      if drop_pos.y > belt_pos.y then
        target_line_index = defines.transport_line.left_line
      else
        target_line_index = defines.transport_line.right_line
      end
    end
  elseif target.type == "splitter" then
    -- Splitter has 8 different lines
    -- "right_line" and "left_line" refer to the leftmost input belt
    -- "secondary_*" refer to the rightmost input belt
    -- "*_split_*" refer to the output belts
    -- When dropping from the side or the front, items only go to the output belts
    -- When dropping from the back, items go to the input belts
    
    -- When drop-pos is at 0.5 lengthwise, defaults to input belts
    -- Divide area into 8 zones for each of the 4 cardinal directions
    
    
    if belt_dir == defines.direction.north then
      -- when facing north, outputs are negative y and left lane is negative x
      -- Check if input or output
      if drop_pos.y < belt_pos.y then
        -- Use output belts
        if drop_pos.x < belt_pos.x-0.5 then
          target_line_index = defines.transport_line.left_split_line
        elseif drop_pos.x < belt_pos.x then
          target_line_index = defines.transport_line.right_split_line
        elseif drop_pos.x < belt_pos.x+0.5 then
          target_line_index = defines.transport_line.secondary_left_split_line
        else
          target_line_index = defines.transport_line.secondary_right_split_line
        end
      else
        -- Use input belts
        if drop_pos.x < belt_pos.x-0.5 then
          target_line_index = defines.transport_line.left_line
        elseif drop_pos.x < belt_pos.x then
          target_line_index = defines.transport_line.right_line
        elseif drop_pos.x < belt_pos.x+0.5 then
          target_line_index = defines.transport_line.secondary_left_line
        else
          target_line_index = defines.transport_line.secondary_right_line
        end
      end
    
    elseif belt_dir == defines.direction.south then
      -- when facing south, outputs are positive y and left lane is positive x
      -- Check if input or output
      if drop_pos.y > belt_pos.y then
        -- Use output belts
        if drop_pos.x > belt_pos.x+0.5 then
          target_line_index = defines.transport_line.left_split_line
        elseif drop_pos.x > belt_pos.x then
          target_line_index = defines.transport_line.right_split_line
        elseif drop_pos.x > belt_pos.x-0.5 then
          target_line_index = defines.transport_line.secondary_left_split_line
        else
          target_line_index = defines.transport_line.secondary_right_split_line
        end
      else
        -- Use input belts
        if drop_pos.x > belt_pos.x+0.5 then
          target_line_index = defines.transport_line.left_line
        elseif drop_pos.x > belt_pos.x then
          target_line_index = defines.transport_line.right_line
        elseif drop_pos.x > belt_pos.x-0.5 then
          target_line_index = defines.transport_line.secondary_left_line
        else
          target_line_index = defines.transport_line.secondary_right_line
        end
      end
    
    elseif belt_dir == defines.direction.east then
      -- when facing east, outputs are positive x and left lane is negative y
      -- Check if input or output
      if drop_pos.x > belt_pos.x then
        -- Use output belts
        if drop_pos.y < belt_pos.y-0.5 then
          target_line_index = defines.transport_line.left_split_line
        elseif drop_pos.y < belt_pos.y then
          target_line_index = defines.transport_line.right_split_line
        elseif drop_pos.y < belt_pos.y+0.5 then
          target_line_index = defines.transport_line.secondary_left_split_line
        else
          target_line_index = defines.transport_line.secondary_right_split_line
        end
      else
        -- Use input belts
        if drop_pos.y < belt_pos.y-0.5 then
          target_line_index = defines.transport_line.left_line
        elseif drop_pos.y < belt_pos.y then
          target_line_index = defines.transport_line.right_line
        elseif drop_pos.y < belt_pos.y+0.5 then
          target_line_index = defines.transport_line.secondary_left_line
        else
          target_line_index = defines.transport_line.secondary_right_line
        end
      end
    
    elseif belt_dir == defines.direction.west then
      -- when facing west, outputs are negative x and left lane is positive y
      -- Check if input or output
      if drop_pos.x < belt_pos.x then
        -- Use output belts
        if drop_pos.y > belt_pos.y+0.5 then
          target_line_index = defines.transport_line.left_split_line
        elseif drop_pos.y > belt_pos.y then
          target_line_index = defines.transport_line.right_split_line
        elseif drop_pos.y > belt_pos.y-0.5 then
          target_line_index = defines.transport_line.secondary_left_split_line
        else
          target_line_index = defines.transport_line.secondary_right_split_line
        end
      else
        -- Use input belts
        if drop_pos.y > belt_pos.y+0.5 then
          target_line_index = defines.transport_line.left_line
        elseif drop_pos.y > belt_pos.y then
          target_line_index = defines.transport_line.right_line
        elseif drop_pos.y > belt_pos.y-0.5 then
          target_line_index = defines.transport_line.secondary_left_line
        else
          target_line_index = defines.transport_line.secondary_right_line
        end
      end
    
    end
  
  end
  -- Return the selected transport line reference
  if target_line_index > 0 then
    return target.get_transport_line(target_line_index)
  end

end



function beltutil.is_belt_empty(belt)
  if not belt or not belt.valid then return true end  -- if belt can't be checked, then remove it from the queue
  -- Detect when splitter outputs are not connected
  if belt.type == "splitter" then
    -- First check splitter inputs
    if #belt.get_transport_line(defines.transport_line.left_line) > 0 then return false end
    if #belt.get_transport_line(defines.transport_line.right_line) > 0 then return false end
    if #belt.get_transport_line(defines.transport_line.secondary_left_line) > 0 then return false end
    if #belt.get_transport_line(defines.transport_line.secondary_right_line) > 0 then return false end
    
    -- Now check outputs, could be 0 1 or 2
    local outputs = belt.belt_neighbours.outputs
    local dir = belt.direction
    local pos = belt.position
    local left_output = nil
    local right_output = nil
    for _,output in pairs(outputs) do
      local outpos = output.position
      if (outpos.x == pos.x or outpos.y == pos.y) then
        -- this is an aligned splitter
        left_output = output
        right_output = output
      elseif (dir == defines.direction.north and outpos.x < pos.x) or
         (dir == defines.direction.south and outpos.x > pos.x) or
         (dir == defines.direction.east and outpos.y < pos.y) or
         (dir == defines.direction.west and outpos.y > pos.y) then
        left_output = output
      else
        right_output = output
      end
    end
    
    if left_output then
      local left_dir = left_output.direction
      if left_output.type == "underground-belt" and left_dir ~= dir then
        -- Underground belt placed 90 degrees at this splitter output so one lane will be blocked
        local left_input = left_output.belt_to_ground_type == "input"
        -- Left lane is blocked when it's an input rotated -2 or an output rotated +2
        if (left_input and ((left_dir+2)%8 == dir)) or (not left_input and (left_dir == (dir+2)%8)) then
          if #belt.get_transport_line(defines.transport_line.right_split_line) > 0 then return false end
        else
          if #belt.get_transport_line(defines.transport_line.left_split_line) > 0 then return false end
        end
      else
        if #belt.get_transport_line(defines.transport_line.left_split_line) > 0 then return false end
        if #belt.get_transport_line(defines.transport_line.right_split_line) > 0 then return false end
      end
    end
    if right_output then
      local right_dir = right_output.direction
      if right_output.type == "underground-belt" and right_dir ~= dir then
        -- Underground belt placed 90 degrees at this splitter output so one lane will be blocked
        local right_input = right_output.belt_to_ground_type == "input"
        -- left lane is blocked when it's an input rotated -2 or an output rotated +2
        if (right_input and ((right_dir+2)%8 == dir)) or (not right_input and (right_dir == (dir+2)%8)) then
          if #belt.get_transport_line(defines.transport_line.secondary_right_split_line) > 0 then return false end
        else
          if #belt.get_transport_line(defines.transport_line.secondary_left_split_line) > 0 then return false end
        end
      else
        if #belt.get_transport_line(defines.transport_line.secondary_left_split_line) > 0 then return false end
        if #belt.get_transport_line(defines.transport_line.secondary_right_split_line) > 0 then return false end
      end
    end
    if not left_output and not right_output then
      -- Nothing is connected to the outputs at all, so check all of them
      if #belt.get_transport_line(defines.transport_line.left_split_line) > 0 then return false end
      if #belt.get_transport_line(defines.transport_line.right_split_line) > 0 then return false end
      if #belt.get_transport_line(defines.transport_line.secondary_right_split_line) > 0 then return false end
      if #belt.get_transport_line(defines.transport_line.secondary_left_split_line) > 0 then return false end
    end

  else
    -- Straight belt or underground exit
    local output = belt.belt_neighbours.outputs[1]
    local dir = belt.direction
    local pos = belt.position
    
    if output then
      local out_dir = output.direction
      if output.type == "underground-belt" and out_dir ~= dir then
        -- Underground belt placed 90 degrees at this splitter output so one lane will be blocked
        local out_input = output.belt_to_ground_type == "input"
        -- Left lane is blocked when it's an input rotated -2 or an output rotated +2
        if (out_input and ((out_dir+2)%8 == dir)) or (not out_input and (out_dir == (dir+2)%8)) then
          if #belt.get_transport_line(defines.transport_line.left_line) > 0 then return false end
        else
          if #belt.get_transport_line(defines.transport_line.right_line) > 0 then return false end
        end
      else
        if #belt.get_transport_line(defines.transport_line.left_line) > 0 then return false end
        if #belt.get_transport_line(defines.transport_line.right_line) > 0 then return false end
      end
    else
      if #belt.get_transport_line(defines.transport_line.left_line) > 0 then return false end
      if #belt.get_transport_line(defines.transport_line.right_line) > 0 then return false end
    end
  end
  return true
end



return beltutil
