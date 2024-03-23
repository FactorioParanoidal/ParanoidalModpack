--[[

--]]

require "ltn-combinator"

ltnc = {
  gui = nil,
} 

-- ltnc.mod_init
ltnc.mod_init = function()
  -- initialize gui
  ltnc.gui.mod_init()
end 

-- ltnc.mod_configuration_changed
ltnc.mod_configuration_changed = function()
  ltnc.gui.mod_configuration_changed()
end

-- ltnc.on_player_joined
ltnc.on_player_joined = function(event)
   ltnc.gui.on_player_joined(event)
end

-- ltnc.on_gui_opened
ltnc.on_gui_opened = function(event)
  if not event.entity or event.entity.name ~= "ltn-combinator" then return end
  
  -- safety feature to show vannilla gui
  if global.vanilla_gui == true then
    return
  end
  
  local obj = ltn_combinator:new(event.entity)
  if not obj then
    dlog("Failed to create LTN-C object")
  end
 
  -- open and register ltn-c window 
  local win = ltnc.gui.open(event.player_index, obj, true)
  game.players[event.player_index].opened = win
end

-- ltnc.on_gui_closed
ltnc.on_gui_closed = function(event)
  if not event.element or event.element.name ~= "ltnc-main-container" then return end
  if event.entity and event.entity.name == "ltn-combinator" then return end
  
  if ltnc.gui.is_visible(event.player_index) then
    ltnc.gui.close(event.player_index)
  end
end

ltnc.event_map = function(events)
  -- [[ EVENTS ]] --
  events.map_gui_opened["ltn-combinator"] = ltnc.on_gui_opened
  events.map_gui_closed["ltnc-main-container"] = ltnc.on_gui_closed
end

-- ltnc.find_combinator_in_network_tree
-- TODO: find green or red
ltnc.find_combinator_in_network_tree = function(first_entity, max_depth, green_wire)
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
      for _,child in pairs(children) do
        if child ~= nil and not id_stack[child.unit_number] then
          entity_stack[child.unit_number] = child
          --dlog("---- putting to stack: " .. child.name)
        end
      end
    end
    
    entity_stack[entity.unit_number] = nil
  end
  
  return result
end

-- ltnc.find_combinator_in_area
ltnc.find_combinator_in_area = function(entity, max_area)
  -- TODO: support different surfaces
  local surface = game.surfaces["nauvis"]
  if not surface then return false end
  
  local area = {{entity.position.x - max_area, entity.position.y - max_area}, {entity.position.x + max_area, entity.position.y + max_area}}
  local entities = surface.find_entities_filtered {area = area, name = {"ltn-combinator"}}
  
  if not entities or #entities == 0 then return nil end
  
  if #entities >= 2 then
    dlog("Multiple combinators found. Picking the first")
  end
  
  return entities[1]
end

-- ltnc.open_combinator
ltnc.open_combinator = function(player_index, entity, register)
  if not global.gui[player_index] then return false end
  if not entity or not entity.valid then return false end
  if entity.type == "entity-ghost" then return false end
  
  local combinator = ltnc.find_combinator_in_network_tree(entity, 10, true)
  if not combinator then
    combinator = ltnc.find_combinator_in_network_tree(entity, 10, false)
  end 
  --local combinator = ltnc.find_combinator_in_area(entity, 5)
  if not combinator then return false end
  
  local obj = ltn_combinator:new(combinator)
  if not obj then return false end
  
  register = register or false
  
  local win = ltnc.gui.open(player_index, obj, register)
  
  if register == true then
    game.players[player_index].opened = win
  end
  
  return true
end

-- ltnc.close_combinator
ltnc.close_combinator = function(player_index)
  if not global.gui[player_index] then return false end

  ltnc.gui.close(player_index)
end

--[[ 
        THIS IS THE END  
--]] ----------------------------------------------------------------------------------
return ltnc