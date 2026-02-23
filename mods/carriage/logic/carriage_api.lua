-- Make the global variables and remote interface to add new carriages
local math2d = require("math2d")

local default_offset = {      -- Relative position to place engine for each straight rail direction
  [0] = { x = 0, y = 9.5 },   -- North-facing
  [1] = { x = -4.4, y = 8.4 }, -- NNE-facing
  [2] = { x = -7, y = 7 },    -- Northeast-facing
  [3] = { x = -8.4, y = 4.4 }, -- ENE-facing
  [4] = { x = -9.5, y = 0 },  -- East-facing
  [5] = { x = -8.4, y = -4.4 }, -- ESE-facing
  [6] = { x = -7, y = -7 },   -- Southeast-facing
  [7] = { x = -4.4, y = -8.8 }, -- SSE-facing
  [8] = { x = 0, y = -9.5 },  -- South-facing
  [9] = { x = 4.4, y = -8.8 }, -- SSW-facing
  [10] = { x = 7, y = -7 },   -- Southwest-facing
  [11] = { x = 8.8, y = -4.4 }, -- WSW-facing
  [12] = { x = 9.5, y = 0 },  -- West-facing
  [13] = { x = 8.8, y = 4.4 }, -- WNW-facing
  [14] = { x = 7, y = 7 },    -- Northwest-facing
  [15] = { x = 4.4, y = 8.8 }, -- NNW-facing
}

function create_storage()
  storage.carriage_engines = storage.carriage_engines or {}
  storage.carriage_bodies = storage.carriage_bodies or {}
  storage.enter_carriage_entities = storage.enter_carriage_entities or {}
end

--[[
    add_carriage:  Adds definition for a new carriage and carriage engine (rolling-stock types)
    parameters:
      name (string, mandatory): Name of the carriage body entity
      engine (string, optional): Name of engine entity
      engine_offset (table of Position, optional): Table of relative positions to place the engine. [0]=N, [1]=NNE, etc.
      engine_scale (float, optional): Ignored if engine_offset is present. Defaults to 1 if not specified. Scales the standard cargo carriage offset table.
      engine_at_front (boolean, optional): Ignored if engine_offset is present. If true, the engine is placed in front of the carriage body rather than behind. Applies negative sign to engine_scale.
      engine_orientation (table of Integer, optional): Lookup table for engine direction, if different from default. Usually don't need to specify this.
      recover_fuel (boolean, optional): Whether fuel items in this carriage's engine should be collected when mining the carriage. If not specified, will use the engine's prototype data.
--]]
function add_carriage(params)
  local carriage_data = {}
  log("Adding carriage '" .. tostring(params.name) .. "':")
  create_storage()

  -- Check carriage name
  if not (params.name and prototypes.entity[params.name]) then
    log("Error adding carriage data: Cannot find entity named '" .. tostring(params.name) .. "'")
    return
  end
  if storage.carriage_bodies[params.name] then
    log("Warning: carriage '" .. params.name .. "' already added")
  end
  carriage_data.name = params.name

  -- Process engine data, if any
  if params.engine and prototypes.entity[params.engine] then
    carriage_data.engine = params.engine
    if params.engine_offset then
      -- Engine offset coordinates specified explicitly
      for i = 0, 15 do
        if not params.engine_offset[i] then
          log("Error adding carriage data: engine_offset must have array indicies 0 through 15")
          return
        end
        params.engine_offset[i] = math2d.position.ensure_xy(params.engine_offset[i])
        if not (params.engine_offset[i].x and params.engine_offset[i].y) then
          log("Error adding carriage data: each engine_offset must be a 2d vector")
          return
        end
      end
      carriage_data.engine_offset = table.deepcopy(params.engine_offset)
      if carriage_data.engine_offset[0].y > 0 then
        carriage_data.coupled_engine = defines.rail_direction.back  -- Engine is behind body
      else
        carriage_data.coupled_engine = defines.rail_direction.front -- Engine is in front of body
      end
    else
      -- Engine offset coordinates specified by scale and/or direction
      local offset_scale = 1
      if params.engine_scale then
        if type(params.engine_scale) == "number" and params.engine_scale > 0 then
          offset_scale = params.engine_scale
        else
          log("Error adding carriage data: engine_scale must be a number greater than 0")
          return
        end
      end
      -- Record coupling direction
      carriage_data.coupled_engine = defines.rail_direction.back -- 1=Engine is behind body by default (carriage)
      if params.engine_at_front then
        offset_scale = offset_scale * -1
        carriage_data.coupled_engine = defines.rail_direction.front -- -1=Engine is in front of body (boat)
      end
      -- Apply scaling to default offset table
      carriage_data.engine_offset = table.deepcopy(default_offset)
      for i = 0, 15 do
        carriage_data.engine_offset[i] = math2d.position.multiply_scalar(carriage_data.engine_offset[i], offset_scale)
      end
    end

    -- If set, use default orientation. otherwise don't store the orientation table at all
    if params.engine_orientation then
      -- Engine orientation specified in a custom table
      for i = 0, 15 do
        if not (params.engine_orientation[i] and type(params.engine_orientation[i]) == "number" and params.engine_orientation[i] >= 0 and params.engine_orientation[i] <= 15) then
          log(
          "Error adding carriage data: engine_orientation must have array indices 0 through 15 and contain integers valued 0 through 15")
          return
        end
      end
      carriage_data.engine_orientation = table.deepcopy(params.engine_orientation)
    end

    -- Add data on this engine
    if not storage.carriage_engines[carriage_data.engine] then
      storage.carriage_engines[carriage_data.engine] = {
        name = carriage_data.engine,
        -- engine is coupled in opposite direction from body
        coupled_carriage = carriage_data.coupled_engine == defines.rail_direction.front and defines.rail_direction.back or
        defines.rail_direction.front,
        compatible_carriages = { [carriage_data.name] = true },
      }

      -- Check if fuel should be recovered when mining the carriage
      if params.engine_recover_fuel ~= nil then
        storage.carriage_engines[carriage_data.engine].recover_fuel = params.engine_recover_fuel -- Use specified value
      elseif (prototypes.entity[carriage_data.engine] and prototypes.entity[carriage_data.engine].burner_prototype and
            (prototypes.entity[carriage_data.engine].burner_prototype.fuel_inventory_size > 0 or
              prototypes.entity[carriage_data.engine].burner_prototype.burnt_inventory_size > 0)) then
        storage.carriage_engines[carriage_data.engine].recover_fuel = true  -- Engine prototype has burner inventories
      else
        storage.carriage_engines[carriage_data.engine].recover_fuel = false -- Not specified, and no burner inventories
      end

      -- Add to map of enterable carriages
      if prototypes.entity[carriage_data.engine].allow_passengers then
        storage.enter_carriage_entities[carriage_data.engine] = true
      end
    else
      -- Engine already exists, make sure things match
      if storage.carriage_engines[carriage_data.engine].coupled_carriage == carriage_data.coupled_engine then
        log("Error adding carriage data: Engine '" ..
        carriage_data.engine .. "' has already been added by another carriage with the wrong coupling direction")
        return
      end

      -- Add this carriage to map of compatible carriages
      storage.carriage_engines[carriage_data.engine].compatible_carriages[carriage_data.name] = true
    end
  end

  storage.carriage_bodies[carriage_data.name] = carriage_data

  -- Add to map of enterable carriages
  if prototypes.entity[carriage_data.name].allow_passengers then
    storage.enter_carriage_entities[carriage_data.name] = true
  end

  log("Added carriage specification:\n" .. serpent.line(carriage_data))
end

function init_carriage_globals()
  -- Clear the existing carriage database
  storage.carriage_bodies = {}
  storage.carriage_engines = {}
  storage.enter_carriage_entities = {}
  
  -- Create the built-in carriages and boat
  add_carriage({
    name = "carriage-engine",
    engine = "carriage",
    engine_scale = 0.34,
    engine_at_front = false,
  })

  -- List carriage engines
  log("carriage Engines Defined:")
  for _, eng in pairs(storage.carriage_engines) do
    log(serpent.line(eng))
  end

  -- List of entities to use the "Enter carriage" command with (any of the above that accepts passengers)
  log("Enterable carriages:\n" .. serpent.line(storage.enter_carriage_entities))
end

remote.add_interface("cargo-carriages", {

  add_carriage = function(params)
    add_carriage(params)
    init_events()
  end,

}
)
