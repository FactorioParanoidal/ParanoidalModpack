--[[
    Do all the changes in data-final-fixes.lua, in case other mods have modified the assemblers
    1. Add "input throughput" pipes on N/S plane
    2. Add "output throughput" pipes on E/W plane

    Note to future me: mining-drills and pumpjacks are not able to passthrough result fluid due to the construction method of the entity type
]]
local function get_entity_size_in_tiles(entity)
  if entity.collision_box then
    return {
      math.ceil(entity.collision_box[2][1] - entity.collision_box[1][1]),
      math.ceil(entity.collision_box[2][2] - entity.collision_box[1][2])
    }
  end
end

-- returns a count of all fluid_boxes of an entity
local function get_fluidbox_types(entity)
  local result = { ['input'] = 0, ['output'] = 0, ['input-output'] = 0 }
  if entity.fluid_boxes then
    for _, fb in ipairs(entity.fluid_boxes) do
      result[fb.production_type] = result[fb.production_type] + 1
    end
  end
  return result
end

local function process_fluidboxes(entity, entitytype)
  -- make a local copy of the entity
  local entity = table.deepcopy(data.raw[entitytype][entity.name])
  -- get the entity size, in tiles
  local entity_size = get_entity_size_in_tiles(entity)

  -- corner offset tweak
  local corner_offset = 0.175

  -- helper function: check if a given position is on a *corner* of the entity footprint
  local function is_corner_connection(pos, size)
    local half_w = (size[1] - 1) / 2
    local half_h = (size[2] - 1) / 2
    -- allow for floating-point jitter
    local eps = 0.01
    local on_x_edge = math.abs(math.abs(pos[1]) - half_w) < eps
    local on_y_edge = math.abs(math.abs(pos[2]) - half_h) < eps
    return on_x_edge and on_y_edge
  end

  -- get bounding box (prefer collision_box; fallback to selection_box)
  -- We will clamp pipe-connection coordinates to this box to avoid the "position must be inside bounding box" error.
  local bbox = entity.collision_box or entity.selection_box
  local bbox_min_x, bbox_min_y, bbox_max_x, bbox_max_y = nil, nil, nil, nil
  if bbox and bbox[1] and bbox[2] then
    bbox_min_x = bbox[1][1]
    bbox_min_y = bbox[1][2]
    bbox_max_x = bbox[2][1]
    bbox_max_y = bbox[2][2]
  else
    -- As a very safe fallback, compute bounds from tile size (should rarely be needed)
    local half_tile = (entity_size[1] - 1) / 2
    bbox_min_x = -half_tile - 0.2
    bbox_min_y = -half_tile - 0.2
    bbox_max_x = half_tile + 0.2
    bbox_max_y = half_tile + 0.2
  end

  -- helper function: clamp a position to be strictly inside the bounding box (with a tiny epsilon)
  local function clamp_to_bbox(x, y)
    local eps = 0.001 -- small margin to avoid exact-edge floating point issues
    if x < (bbox_min_x + eps) then x = (bbox_min_x + eps) end
    if x > (bbox_max_x - eps) then x = (bbox_max_x - eps) end
    if y < (bbox_min_y + eps) then y = (bbox_min_y + eps) end
    if y > (bbox_max_y - eps) then y = (bbox_max_y - eps) end
    return x, y
  end

  if (entity_size[1] == entity_size[2]) then
    -- it's a square, do the magic
    -- calculate the maximum number of pipe connections on each face
    local max_pipes_on_south_face = entity_size[1] - math.ceil((entity_size[1] - 1) / 2)
    local max_pipes_on_east_face = entity_size[2] - math.ceil((entity_size[2] - 1) / 2)
    -- get the count of fluidboxes on the original entity
    local fluidbox_types = get_fluidbox_types(entity)
    -- check if max number of pipes on southern and eastern faces is greater or equal to the actual number of fluid boxes
    if ((max_pipes_on_south_face >= fluidbox_types['input']) and (max_pipes_on_east_face >= fluidbox_types['output'])) then
      -- make a local copy of the fluidboxes
      local fluid_boxes = table.deepcopy(entity.fluid_boxes)
      -- define indexes
      local i_index = 0
      local o_index = 0
      local x_offset, y_offset = 0, 0

      if (entity_size[1] % 2 == 0) then
        x_offset = 0.5
      end
      if (entity_size[2] % 2 == 0) then
        y_offset = 0.5
      end

      local first_input_fb_pos = {
        ((entity_size[1] % fluidbox_types['input']) - x_offset),
        (entity_size[1] - 1) / 2
      }
      local first_output_fb_pos = {
        (entity_size[2] - 1) / 2,
        (entity_size[2] % fluidbox_types['output']) - y_offset
      }
      -- store local checksum; this gets set to 0 if an entity already has input-output fluidboxes
      local extend_entity_check = 1
      for _, fb in ipairs(fluid_boxes) do -- ipairs because array with a boolean on the end
        for _, pc in pairs(fb.pipe_connections) do
          if pc.flow_direction == "input-output" then
            -- it's already input-output, skip this entity
            extend_entity_check = 0
            log('[WARN] APP: ' .. entity.name .. ' already has input-output fluidboxes, skipping.')
            break
          end
        end
        if (extend_entity_check == 0) then
          break
        end
        if fluidbox_types['input'] > 0 then
          if (fb.production_type == 'input') then
            -- calculate base positions for inputs
            local base_input_x = first_input_fb_pos[1] - (i_index * 2)
            local input_y_south = first_input_fb_pos[2]
            local input_y_north = -first_input_fb_pos[2]
            local need_input_nudge = false
            if is_corner_connection({ base_input_x, input_y_south }, entity_size) or is_corner_connection({ base_input_x, input_y_north }, entity_size) then
              need_input_nudge = true
            end

            local input_x = base_input_x
            if need_input_nudge then
              -- nudge toward the centre: if X>0 move left, if X<0 move right
              if input_x > 0 then
                input_x = input_x - corner_offset
              else
                input_x = input_x + corner_offset
              end
            end
            -- clamp both positions to entity bounding box to avoid "outside bounding box" errors
            local sx, sy = clamp_to_bbox(input_x, input_y_south)
            local nx, ny = clamp_to_bbox(input_x, input_y_north)
            if input_x < 0 then
              -- west face: north then south
              fb.pipe_connections = {
                {
                  position = { nx, ny },
                  flow_direction = 'input-output',
                  direction = defines.direction.north
                },
                {
                  position = { sx, sy },
                  flow_direction = 'input-output',
                  direction = defines.direction.south
                }
              }
            else
              -- east face: south then north
              fb.pipe_connections = {
                {
                  position = { sx, sy },
                  flow_direction = 'input-output',
                  direction = defines.direction.south
                },
                {
                  position = { nx, ny },
                  flow_direction = 'input-output',
                  direction = defines.direction.north
                }
              }
            end

            fb.base_level = -1
            i_index = i_index + 1
          end
        end
        if fluidbox_types['output'] > 0 then
          if fb.production_type == 'output' then
            -- calculate base positions for outputs
            local base_output_x_east = first_output_fb_pos[1]
            local base_output_x_west = -first_output_fb_pos[1]
            local base_output_y = first_output_fb_pos[2] - (o_index * 2)
            local need_output_nudge = false
            if is_corner_connection({ base_output_x_east, base_output_y }, entity_size) or is_corner_connection({ base_output_x_west, base_output_y }, entity_size) then
              need_output_nudge = true
            end
            local output_y = base_output_y
            if need_output_nudge then
              -- nudge toward the centre: if Y>0 move up (subtract), if Y<0 move down (add)
              if output_y > 0 then
                output_y = output_y - corner_offset
              else
                output_y = output_y + corner_offset
              end
            end
            -- clamp both positions to entity bounding box
            local ex, ey = clamp_to_bbox(base_output_x_east, output_y)
            local wx, wy = clamp_to_bbox(base_output_x_west, output_y)

            fb.pipe_connections = {
              {
                position = { ex, ey },
                flow_direction = 'input-output',
                direction = defines.direction.east
              },
              {
                position = { wx, wy },
                flow_direction = 'input-output',
                direction = defines.direction.west
              }
            }
            fb.base_level = 0
            o_index = o_index + 1
          end
          fb.height = 2
          fb.base_area = 0.5
        end
      end
      if (extend_entity_check == 1) then
        entity.fluid_boxes = table.deepcopy(fluid_boxes)
        data:extend({ entity })
      end
    else
      log('[INFO] APP: ' .. entity.name .. ' unable to adjust fluidboxes, skipping.')
    end
  else
    log('[INFO] APP: ' .. entity.name .. ' unable to adjust fluidboxes, skipping.')
  end
end

-- loop through all entities of type assembling-machine in data.raw
for _, j in pairs(data.raw['assembling-machine']) do
  if not appmod.blacklist[j.name] then
    -- check if there are fluid_boxes
    if j.fluid_boxes then
      log('[INFO] APP: Processing ' .. j.name)
      process_fluidboxes(j, 'assembling-machine')
    else
      log('[INFO] APP: ' .. j.name .. ' does not have fluidboxes; skipping.')
    end
  end
end
