

local stateDisplay = {
  ["off"] = "*", -- default

  ["0"] = "+",
  ["1"] = "-",
  ["2"] = "/",
  ["3"] = "%",
  ["4"] = "^",
  ["5"] = "<<",
  ["6"] = ">>",
  ["7"] = "AND",
  ["8"] = "OR",
  ["9"] = "XOR"
}



local validNixieNumber = {
  ['SNTD-old-nixie-tube'] = 1,
  ['SNTD-nixie-tube'] = 1,
  ['SNTD-nixie-tube-small'] = 2
}



local function removeNixieSprites(nixie)
  for _,sprite in pairs(global.SNTD_nixieSprites[nixie.unit_number]) do
    if sprite.valid then
      sprite.destroy()
    end
  end
end



--sets the state(s) and update the sprite for a nixie
local function setStates(nixie, newstates)
  for key,new_state in pairs(newstates) do
    if not new_state then new_state = "off" end
    --game.print("key: "..key.." state: "..new_state)

    local sprite = global.SNTD_nixieSprites[nixie.unit_number][key]
    if sprite and sprite.valid then
      local behavior = sprite.get_or_create_control_behavior()
      local parameters = behavior.parameters
      if nixie.energy >= 50 then
        -- new_state is a string of the new state (see stateDisplay)
        parameters.operation = stateDisplay[new_state]

      else
        if parameters.operation ~= stateDisplay["off"] then
          parameters.operation = stateDisplay["off"]
        end
      end
      behavior.parameters = parameters
    else
      game.print("invalid nixie?")
    end
  end
end



-- from binbinhfr/SmartDisplay, modified to check both wires and add them
local function get_signal_value(entity, sig)
  local behavior = entity.get_control_behavior()
  if behavior == nil then	return nil end

  local condition = behavior.circuit_condition
  if condition == nil then return nil end

  -- shortcut, return stored value if unchanged
  if not sig and condition.fulfilled and condition.comparator == "=" then
    return condition.constant, false
  end

  -- get the variable to display; return if none selected
  local signal
  if sig then
    signal = sig
  else
    signal = condition.condition.first_signal
  end

  if signal == nil or signal.name == nil then return(nil)	end

  -- check both wires of the variable
  local redval, greenval = 0, 0
  local network = entity.get_circuit_network(defines.wire_type.red)
  if network then
	  redval = network.get_signal(signal)
  end
  network = entity.get_circuit_network(defines.wire_type.green)
  if network then
    greenval = network.get_signal(signal)
  end

  local val = redval + greenval
  --game.print("value: "..val..(" red:"..redval.." green:"..greenval))

  -- If no signal has been set, make sure to init condition
  if not sig then
    condition.comparator="="
    condition.constant=val
    condition.second_signal=nil
    behavior.circuit_condition = condition
  end

  return val, true
end



local function displayValueString(entity, vs)

  if not (entity and entity.valid) then return end

  local nextDigit = global.SNTD_nextNixieDigit[entity.unit_number]
  local spriteCount = #global.SNTD_nixieSprites[entity.unit_number]

  if not vs then
    setStates(entity, (spriteCount==1)and{"off"} or {"off","off"})
  elseif #vs < spriteCount then
    setStates(entity, {"off",vs})
  elseif #vs >= spriteCount then
    setStates(entity, (spriteCount==1)and{vs:sub(-1)} or {vs:sub(-2,-2),vs:sub(-1)})
  end

  if nextDigit then
    if vs and #vs > spriteCount then
      displayValueString(nextDigit, vs:sub(1,-(spriteCount+1)))
    else
      displayValueString(nextDigit) -- Set next digit to 'off'
    end
  end

end



local function onPlaceEntity(event)

  local entity = event.created_entity or event.entity
  if not entity.valid then
    game.print("invalid placement?")
    return
  end

  local num = validNixieNumber[entity.name]
  if num then
    local pos = entity.position
    local surf = entity.surface

    local sprites = {}
    -- placing the base of the nixie
    for n=1, num do
      -- place nixie at same spot
      local name, position
      if num == 1 then -- large nixie, one sprites
        if entity.name == "SNTD-nixie-tube" then
          name = "SNTD-nixie-tube-sprite"
          position = {x = pos.x + 1/32, y = pos.y + 1/32}
        else -- old nixie tube
          name = "SNTD-old-nixie-tube-sprite"
          position = {x = pos.x + 1/32, y = pos.y + 3.5/32}
        end
      else -- small nixie, two sprites
        name = "SNTD-nixie-tube-small-sprite"
        position = {x = pos.x - 4/32 + ((n-1)*10/32), y = pos.y + 3/32}
      end

      local sprite = surf.create_entity(
        {
          name = name,
          position = position,
          force = entity.force
        })
      sprites[n]=sprite
    end
    global.SNTD_nixieSprites[entity.unit_number] = sprites
    -- game.print("created sprite for entity " .. entity.unit_number)

    -- properly reset nixies when (re)added
    local behavior = entity.get_or_create_control_behavior()
    local condition = behavior.circuit_condition
    condition.comparator = "="
    condition.constant = 0
    condition.second_signal = nil
    behavior.circuit_condition = condition

    --enslave guy to left, if there is one
    local neighbors = surf.find_entities_filtered{
      position = {x = entity.position.x-1, y = entity.position.y},
      name = entity.name}
    for _,n in pairs(neighbors) do
      if n.valid then

        if global.nextNixieController == n.unit_number then
          -- if it's currently the *next* controller, claim that too...
          global.nextNixieController = entity.unit_number
        end

        global.SNTD_nixieControllers[n.unit_number] = nil
        global.SNTD_nextNixieDigit[entity.unit_number] = n
      end
    end

    --slave self to right, if any, otherwise this will be the controller
    neighbors = surf.find_entities_filtered{
      position = {x = entity.position.x+1 , y = entity.position.y},
      name = entity.name}
    local foundright=false
    for _,n in pairs(neighbors) do
      if n.valid then
        foundright=true
        global.SNTD_nextNixieDigit[n.unit_number] = entity
      end
    end
    if not foundright then
      global.SNTD_nixieControllers[entity.unit_number] = entity
    end
  end

end



local function onRemoveEntity(event)
  local entity = event.entity
  if entity.valid then
    if validNixieNumber[entity.name] then
      removeNixieSprites(entity)

      --if it was a controller, deregister
      if global.nextNixieController == entity.unit_number then
        -- if it was the *next* controller, pass it forward...
        if not global.SNTD_nixieControllers[global.nextNixieController] then
          game.print("Invalid next_controller removal??")
          global.nextNixieController = nil
        end
        global.nextNixieController = next(global.SNTD_nixieControllers,global.nextNixieController)
      end
      global.SNTD_nixieControllers[entity.unit_number] = nil

      --if I had a next-digit, register it as a controller
      local nextDigit = global.SNTD_nextNixieDigit[entity.unit_number]
      if nextDigit and nextDigit.valid then
        global.SNTD_nixieControllers[nextDigit.unit_number] = nextDigit
        displayValueString(nextDigit)
      end

    end
  end
end



local function onTickController(entity)

  if not entity.valid then
    onRemoveEntity{entity=entity}
    game.print("Removed a invalid nixie (you're welcome)")
    return
  end

  local value,value_changed = get_signal_value(entity)
  if value then
    if value_changed then
      local format = "%i"
      local valueString = format:format(value)
      displayValueString(entity, valueString)
    end
  else
    displayValueString(entity)
  end
end



local function onTick(event)

  for _=1, settings.global["SNTD-nixie-tube-update-speed"].value do
    local nixie

    if global.nextNixieController and not global.SNTD_nixieControllers[global.nextNixieController] then
      -- game.print("Invalid next_controller??")
      global.nextNixieController = nil
    end

    global.nextNixieController, nixie = next(global.SNTD_nixieControllers, global.nextNixieController)

    if nixie then onTickController(nixie) end
  end
end



script.on_init(function()
  global.SNTD_nixieControllers = {}
  global.SNTD_nixieSprites = {}
  global.SNTD_nextNixieDigit = {}
end)

script.on_event({defines.events.on_built_entity,
                 defines.events.on_robot_built_entity,
                 defines.events.script_raised_revive,
                }, onPlaceEntity)

script.on_event({defines.events.on_pre_player_mined_item,
                 defines.events.on_robot_pre_mined,
                 defines.events.on_entity_died,
                 defines.events.script_raised_destroy,
                }, onRemoveEntity)

script.on_event(defines.events.on_tick, onTick)
