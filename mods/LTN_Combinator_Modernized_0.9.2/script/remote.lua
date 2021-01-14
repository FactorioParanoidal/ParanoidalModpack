local ltnc = require("gui")

local function find_combinator_in_network_tree(first_entity, max_depth, green_wire)
  local id_stack     = {[first_entity.unit_number] = true}
  local entity_stack = {[first_entity.unit_number] = first_entity}

  -- set the min. green connections to 1 if entity is input lamp
  local min = first_entity.name == "logistic-train-stop-lamp-control" and 1 or 0

  --  -- check if green or red cable is connected. default: green
  --  local green_wire = g
  --  if #first_entity.circuit_connected_entities.green > 1 then
  --    green_wire = true
  --    dlog("green children found #" .. tostring(#first_entity.circuit_connected_entities.green) .. "minimum: " .. min)
  --  else
  --    dlog("red children found #" .. tostring(#first_entity.circuit_connected_entities.red) .. "minimum: " .. min)
  --    dlog("first child: " ..   tostring(first_entity.circuit_connected_entities.red[1].name))
  --  end

  --dlog("Using wire: " .. tostring(green_wire == true and "green" or "red"))
  local result = nil

  for depth = 1, max_depth do
    local _, entity = next(entity_stack)
    if not entity then break end

    --dlog("-- checking entity: " .. entity.name)
    if entity.name == "ltn-combinator" then 
      result = entity
      break
    end
    id_stack[entity.unit_number] = true
    if entity.circuit_connected_entities ~= nil then
      local children = green_wire == true and entity.circuit_connected_entities.green or entity.circuit_connected_entities.red
      for _, child in pairs(children) do
        if child ~= nil and not id_stack[child.unit_number] then
          entity_stack[child.unit_number] = child
          --dlog("---- putting to stack: " .. child.name)
        end
      end
    end
    entity_stack[entity.unit_number] = nil
  end
  return result
end -- find_combinator_in_network_tree()

local function open_combinator(player_index, entity, register)
    if not entity or not entity.valid then return false end
    if entity.type == "entity-ghost" then return false end

    local combinator = find_combinator_in_network_tree(entity, 10, true)
    if not combinator then
      combinator = find_combinator_in_network_tree(entity, 10, false)
    end
    --local combinator = ltnc.find_combinator_in_area(entity, 5)
    if not combinator then return false end

    ltnc.Open(player_index, combinator)

    return true
end -- open_combinator()

local function close_combinator(player_index)
  ltnc.Close(player_index)
end -- close_combinator()

-- register remote interfaces
remote.add_interface("ltn-combinator", {
    -- Usage: result = remote.call("ltn-combinator", "open_ltn_combinator", player_index (integer), entity (LuaEntity), register (boolean))
    --  player_index: (required)
    --  entity: any entity that is in the same green-circuit-network as the wanted ltn-combinator (required)
    --  register: registers the opened window in game.player[i].opened (optional, default true)
    --  returns a boolean, whether a combinator was opened
    open_ltn_combinator = open_combinator,

    -- Usage: result = remote.call("ltn-combinator", "close_ltn_combinator", player_index (integer))
    --  player_index: (required)
    --
    --  Calling this interface is only required if a ltn-combinator was previously opened with register = false.
    --  Use this method to keep your own window open.
    close_ltn_combinator = close_combinator
  })

  -- debugging tool for remote call testing
  local function ltnc_remote_open(event)
    local entity = nil
    if game.players[event.player_index] then
      entity = game.players[event.player_index].selected
    end

    if entity == nil or entity.valid ~= true then return end 
    remote.call("ltn-combinator", "open_ltn_combinator", event.player_index, entity, true)
  end

  local function ltnc_remote_close(event)
    remote.call("ltn-combinator", "close_ltn_combinator", event.player_index)
  end

  commands.add_command("ltncopen", "Use$/ltncopen while hovering an entity to open a near ltn combinator", ltnc_remote_open)
  commands.add_command("ltncclose", "Use$/ltncclose to close the opened ltn combinator", ltnc_remote_close)
