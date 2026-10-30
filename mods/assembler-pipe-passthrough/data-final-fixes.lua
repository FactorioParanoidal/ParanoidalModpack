--[[
  Pass-through pipes for assembling machines, done in data-final-fixes so that the changes of other mods are in place.
  Every "input" fluid box gets an input-output pair of connections on the north/south faces and every "output" box
  a pair on the east/west faces, so a row of machines passes the fluid through like electric mining drills do.

  A machine is left alone when it is blacklisted (appmod.blacklist), has no input/output fluid boxes, is not square or
  not centred, has more boxes than fit on one face, has fluid boxes of another production type, has connections other
  than "normal", or already has a pass-through connection (flow_direction "input-output", also when omitted: it is the
  2.0 default).

  Mining drills and pumpjacks cannot pass their result fluid through, so only assembling-machine is handled.
]]

local CORNER_NUDGE = 0.175 -- corner connections move toward the centre so the alt-mode icons do not overlap
local EPS = 0.01
local NORTH, EAST, SOUTH, WEST = defines.direction.north, defines.direction.east, defines.direction.south,
    defines.direction.west

-- Positions of `count` connections along one face, `size` tiles long, relative to the machine centre.
local function face_positions(size, count)
  local half = (size - 1) / 2
  local offset = (size % 2 == 0) and 0.5 or 0
  -- Layout of the earlier releases, kept so that existing builds stay connected.
  local first = (size % count) - offset
  if first > half + EPS or first - 2 * (count - 1) < -half - EPS then
    -- It leaves the face on even sizes and on 9x9 with four boxes: centre the connections instead.
    first = (count - 1) - offset
  end
  local positions = {}
  for i = 0, count - 1 do
    local position = first - 2 * i
    if math.abs(math.abs(position) - half) < EPS then
      position = position > 0 and position - CORNER_NUDGE or position + CORNER_NUDGE
    end
    positions[#positions + 1] = position
  end
  return positions
end

local function connection(x, y, direction)
  return { position = { x, y }, flow_direction = 'input-output', direction = direction }
end

-- Returns the new fluid boxes, or nil and the reason to skip the machine (nil reason: nothing to report).
local function passthrough_fluid_boxes(machine)
  local inputs, outputs = {}, {}
  for index, box in ipairs(machine.fluid_boxes or {}) do
    local production_type = box.production_type or 'none'
    if production_type == 'input' then
      inputs[#inputs + 1] = index
    elseif production_type == 'output' then
      outputs[#outputs + 1] = index
    else
      return nil, 'has a fluid box of production type "' .. production_type .. '"'
    end
    for _, pipe in ipairs(box.pipe_connections or {}) do
      local connection_type = pipe.connection_type or 'normal'
      if connection_type ~= 'normal' then
        return nil, 'has a pipe connection of type "' .. connection_type .. '"'
      end
      if (pipe.flow_direction or 'input-output') == 'input-output' then
        return nil, 'already has input-output connections'
      end
    end
  end
  if #inputs == 0 and #outputs == 0 then return nil end

  local box = machine.collision_box
  if not box then return nil, 'has no collision box' end
  local width, height = box[2][1] - box[1][1], box[2][2] - box[1][2]
  if math.abs(box[1][1] + box[2][1]) > EPS or math.abs(box[1][2] + box[2][2]) > EPS then
    return nil, 'has a collision box that is not centred'
  end
  local size = math.ceil(width)
  if size ~= math.ceil(height) then return nil, 'is not square' end
  local per_face = size - math.ceil((size - 1) / 2)
  if #inputs > per_face or #outputs > per_face then
    return nil, 'has more fluid boxes than fit on one face'
  end

  local half = (size - 1) / 2
  local boxes = table.deepcopy(machine.fluid_boxes)
  if #inputs > 0 then
    for k, x in ipairs(face_positions(size, #inputs)) do
      local north, south = connection(x, -half, NORTH), connection(x, half, SOUTH)
      boxes[inputs[k]].pipe_connections = x < 0 and { north, south } or { south, north }
    end
  end
  if #outputs > 0 then
    for k, y in ipairs(face_positions(size, #outputs)) do
      boxes[outputs[k]].pipe_connections = { connection(half, y, EAST), connection(-half, y, WEST) }
    end
  end
  return boxes
end

local changed = {}
for name, machine in pairs(data.raw['assembling-machine']) do
  if not appmod.blacklist[name] then
    local boxes, reason = passthrough_fluid_boxes(machine)
    if boxes then
      machine.fluid_boxes = boxes
      changed[#changed + 1] = name
    elseif reason then
      log('[INFO] APP: ' .. name .. ' ' .. reason .. '; skipped.')
    end
  end
end
table.sort(changed)
log('[INFO] APP: pass-through connections added to ' .. #changed .. ' machines: ' .. table.concat(changed, ', '))
