local States = require("script/character_interface/states/states")
local util = require("script/character_script_util")

local script_data =
{
  characters = {}
}

local Character = {}

Character.metatable =
{
  __index = Character,
}

function Character.get_character(unit_number)
  local character = script_data.character[unit_number]
  if character and character.entity.valid then
    return character
  end
end

function Character.new(character_entity)

  if character_entity.type ~= "character" then
    error("Character interface only works on character entities." .. character_entity.type)
  end

  script.register_on_entity_destroyed(character_entity)

  local character =
  {
    entity = character_entity,
    state_stack = {},
    index = character_entity.unit_number,
  }

  setmetatable(character, Character.metatable)

  script_data.characters[character.index] = character
  return character
end

function Character:update()
  --error(serpent.block(self.state_stack))
  if not self.entity.valid then
    return
  end

  local state = self.state_stack[1]
  if state and state.update then
    state:update()
  end

end

function Character:pop_state(dont_update_state)
  self:print("Popped state "..self.state_stack[1].type)
  table.remove(self.state_stack, 1)
  --maybe?
  if dont_update_state == nil or dont_update_state == false then
    self:update()
  end
end

function Character:push_state(state)
  self:print("Pushed state "..state.type)
  table.insert(self.state_stack, 1, state)
end

function Character:emplace_state(state)
  self:print("Emplaced state "..state.type)
  table.insert(self.state_stack, state)
end

function Character:clear_state()
  for k, state in pairs (self.state_stack) do
    if state.cleanup then
      state:cleanup()
    end
  end
  self.state_stack = {}
end

function Character:follow(target, distance)
  self:push_state(States.follow(self, target, distance))
end

local resource_type =
{
  ["resource"] = true,
  ["tree"] = true,
  ["simple-entity"] = true
}

function Character:get_mining_distance(type)
  if type and resource_type[type] then
    return self.entity.resource_reach_distance
  else
    return self.entity.reach_distance
  end
end

function Character:get_repair_distance()
  return self.entity.reach_distance
end

function Character:get_reach_distance()
  return self.entity.reach_distance
end

function Character:get_slurp_distance()
  return self.entity.item_pickup_distance
end

function Character:get_build_distance()
  return self.entity.build_distance
end

function Character:can_reach_entity(entity)
  return self.entity.can_reach_entity(entity)
end

function Character:distance(entity_or_position)
  return util.distance(self.entity.position, entity_or_position.position or entity_or_position)
end

function Character:move_to(entity_or_position, distance, timeout)
  local vehicle = self.entity.vehicle
  if vehicle then
    if vehicle.type == "spider-vehicle" then
      self:push_state(States.moving_spider(self, entity_or_position, distance))
      return
    end
    if vehicle.type == "car" then
      self:push_state(States.moving_vehicle(self, entity_or_position, distance or 10))
      return
    end
  end
  self:push_state(States.moving(self, entity_or_position, distance, timeout))
end

function Character:mine(entity, amount)
  self:push_state(States.mining(self, entity, amount))
end

function Character:batch_job(job_type, entities)
  self:push_state(States.batch_job(self, job_type, entities))
end

function Character:find_and_batch(job_type, param)
  self:push_state(States.find_and_batch(self, job_type, param))
end

function Character:repair(entity)
  self:push_state(States.repair(self, entity))
end

function Character:upgrade(entity)
  self:push_state(States.upgrade(self, entity))
end

function Character:attack(entity, timeout)
  self:push_state(States.attack(self, entity, timeout))
end

function Character:attack_area(position, radius)
  self:push_state(States.combat(self, position, radius))
end

function Character:build_ghost(entity)
  self:push_state(States.build_ghost(self, entity))
end

function Character:wait(ticks)
  self:push_state(States.idle(self, ticks))
end

function Character:nearest_enemy(radius, position)
  return self.entity.surface.find_nearest_enemy
  {
    position = position or self.entity.position,
    max_distance = radius or 64,
    force = self.entity.force
  }
end

function Character:defer_job(position, entity)
  self:emplace_state(States.deferred_job(self, position, entity))
end

function Character:is_idle()
  return not self.state_stack[1]
end

function Character:clear_remark()
  if not self.remark_id then return end
  return rendering.is_valid(self.remark_id) and rendering.destroy(self.remark_id)
end

function Character:remark(string, color)
  self:clear_remark()
  self.remark_id = rendering.draw_text
  {
    text = string,
    surface = self.entity.surface,
    target = self.entity,
    target_offset = {0, -3},
    color = color or {1, 1, 1},
    scale = 1,
    time_to_live = 120,
    forces = {self.entity.force},
    players = {self.player},
    visible = true,
    draw_on_ground = false,
    orientation = 0,
    alignment = "center",
    scale_with_zoom = true,
    only_in_alt_mode = false
  }
end

local can_follow =
{
  ["car"] = true,
  ["locomotive"] = true,
  ["cargo-wagon"] = true,
  ["fluid-wagon"] = true,
  ["artillery-wagon"] = true,
  ["unit"] = true,
  ["character"] = true,

}

function Character:determine_job(entity, position)

  if not (entity and entity.valid) then
    self:remark{"move-command", string.format("(%.0f, %.0f)", position.x, position.y)}
    self:move_to{position.x, position.y}
    return
  end

  if self.entity.vehicle then
    -- If we're in a vehicle, we just go to the position
    self:remark{"move-command", string.format("(%.0f, %.0f)", position.x, position.y)}
    self:move_to{position.x, position.y}
    return
  end

  local force = entity.force

  if force == self.entity.force then

    if entity.type == "entity-ghost" then
      self:remark{"build-command"}
      self:find_and_batch("build", {type = "entity-ghost", force = force})
      self:build_ghost(entity, -1)
      return
    end

    if entity.type == "tile-ghost" then
      self:remark{"build-command"}
      self:find_and_batch("build", {type = "tile-ghost", force = force})
      self:build_ghost(entity, -1)
      return
    end

    if entity.to_be_deconstructed() then
      self:remark{"deconstruct-command"}
      self:find_and_batch("mine", {to_be_deconstructed = true, force = force})
      self:mine(entity, -1)
      return
    end

    if entity.get_health_ratio() and entity.get_health_ratio() < 1 then
      self:remark{"repair-command"}
      self:find_and_batch("repair", {radius = 50, force = force})
      self:repair(entity)
      return
    end

    if entity.to_be_upgraded() then
      self:remark{"upgrade-command"}
      self:find_and_batch("upgrade", {to_be_upgraded = true})
      self:upgrade(entity)
      return
    end

    local fuel_inventory = entity.get_fuel_inventory()
    if fuel_inventory and fuel_inventory.is_empty() then
      self:remark{"fuel-command"}
      self:find_and_batch("fuel", {radius = 50, force = force})
      self:fuel_entity(entity)
      return
    end

  end

  if entity.to_be_deconstructed() and (force.name == "neutral") then
    self:remark{"deconstruct-command"}
    self:find_and_batch("mine", {to_be_deconstructed = true, force = {"neutral", self.entity.force.name}})
    self:mine(entity, -1)
    return
  end

  if entity.type == "resource" then
    self:remark{"mine-entity-command", entity.localised_name}
    self:find_and_batch("mine", {type = "resource", name = entity.name, amount = -1})
    self:mine(entity, -1)
    return
  end

  if entity.type == "tree" then
    self:remark{"mine-trees-command"}
    self:find_and_batch("mine", {type = "tree"})
    self:mine(entity, -1)
    return
  end

  if entity.type == "simple-entity" and force.name == "neutral" then
    self:remark{"mine-entity-command", entity.localised_name}
    self:find_and_batch("mine", {type = "simple-entity"})
    self:mine(entity, -1)
    return
  end

  if self.entity.force.get_cease_fire(entity.force) == false then
    self:remark{"attack-command"}
    --self:find_and_batch("attack", {radius = 50, force = entity.force})
    self:attack_area(entity.position, 64)
    return
  end

  if can_follow[entity.type] then
    self:remark{"follow-command", entity.localised_name}
    self:follow(entity)
  else
    self:remark{"move-command", entity.localised_name}
    self:move_to(entity)
  end

end

function Character:is_moving()
  return self.state_stack[1] and self.state_stack[1].type == States.moving.type
end

function Character:craft_item(name, count)
  self:print("Told to find item "..name.." x"..count)
  self:push_state(States.craft_item(self, name, count))
end

function Character:get_mining_progress()
  return self.entity.character_mining_progress
end

function Character:find_item(name, count)
  self:push_state(States.find_item(self, name, count))
end

function Character:has_item(name, count)
  return self.entity.get_item_count(name) >= ((count or 1))
end

function Character:get_item_count(name)
  return self.entity.get_item_count(name)
end

function Character:find_entities_filtered(param)
  return self.entity.surface.find_entities_filtered(param)
end

function Character:find_entity(param)
  param.limit = 1
  local entities = self.entity.surface.find_entities_filtered(param)
  return entities[1]
end

function Character:is_entity_nearby(radius, param)
  --Slightly optimised, will return true if there is any of the entity matching the params nearby.
  local param = param or {}
  param.position = self:get_position()
  param.radius = radius or 64
  param.limit = 1
  return self.entity.surface.count_entities_filtered(param) > 0
end

function Character:get_forces(type)
  if type == "any" then return nil end
  if type == "enemy" then return self:get_enemy_forces() end
  if type == "friend" then return self:get_friend_forces() end
  if type == "neutral" then return self:get_neutral_forces() end
end

function Character:get_enemy_forces()
  local forces = {}
  local our_force = self.entity.force
  for k, force in pairs (game.forces) do
    if our_force.get_cease_fire(force) == false then
      forces[k] = force.name
    end
  end
  return forces
end

function Character:get_friend_forces()
  local forces = {}
  local our_force = self.entity.force
  for k, force in pairs (game.forces) do
    if our_force.get_friend(force) then
      forces[k] = force.name
    end
  end
  return forces
end

function Character:get_neutral_forces()
  local forces =
  {
    [game.forces.neutral.index] = "neutral"
  }
  local our_force = self.entity.force
  for k, force in pairs (game.forces) do
    if our_force.get_cease_fire(force) and not our_force.get_friend(force) then
      forces[k] = force.name
    end
  end
  return forces
end

function Character:remove_item(name, count)
  --returns how many were removed

  local to_remove = count
  for k = 1, 10 do
    local inventory = self.entity.get_inventory(k)
    if not inventory then break end
    local stack = inventory.find_item_stack(name)

    if stack then
      local stack_count = stack.count
      if stack_count >= to_remove then
        stack.count = stack_count - to_remove
        return count
      end
      to_remove = to_remove - stack_count
      stack.clear()

      if to_remove < 1 then
        return count
      end

    end
  end

  if self.entity.player then
    local stack = self.entity.player.cursor_stack

    if stack then
      local stack_count = stack.count
      if stack_count >= to_remove then
        stack.count = stack_count - to_remove
        return count
      end
      to_remove = to_remove - stack_count
      stack.clear()

      if to_remove < 1 then
        return count
      end
    end

  end

  return count - to_remove
end

function Character:can_craft_recipe(recipe)
  if not recipe.enabled then return end

  if not self.entity.prototype.crafting_categories[recipe.category] then return end

  for k, ingredient in pairs (recipe.ingredients) do
    if ingredient.type == "fluid" then return end
  end

  return true
end

function Character:find_nearby_entities(radius, param)
  if not radius then error("Give me a radius dude") end
  local param = param or {}
  param.position = self:get_position()
  param.radius = radius
  return self.entity.surface.find_entities_filtered(param)
end

function Character:update_every_n_ticks(n)
  return (game.tick + self.index) % n == 0
end

function Character:clear_cursor()
  -- Returns true if the cursor is empty.
  local stack = self.entity.cursor_stack

  if not stack.valid_for_read then
    return true
  end

  local inventory = self.entity.get_main_inventory()

  local count = inventory.insert(stack)

  if count == 0 then
    return false
  end

  if count == stack.count then
    stack.clear()
    return true
  end

  stack.count = stack.count - count
  return false

end

local locale_cache = {}
local get_localised_item_name = function(name)
  local localised_name = locale_cache[name]
  if localised_name then
    return localised_name
  end
  localised_name = game.item_prototypes[name].localised_name
  locale_cache[name] = localised_name
  return localised_name
end

function Character:take_item_stack(stack, count, source)

  --game.print(stack.name..": "..stack.count.."; wanted: "..count)

  local inventory = self.entity.get_main_inventory()
  local original = stack.count
  local name = stack.name
  if count > original then count = original end
  stack.count = count
  local given = inventory.insert(stack)
  if given > original then
    error("WTF"..serpent.block({stack = stack.name, wanted_count = count, given = given, stack_count = stack.count, original = original}))
  end
  stack.count = original - given
  --self:say("Took "..given)
  if source and source.valid then
    source.surface.create_entity
    {
      name = "flying-text",
      text = {"", "+", given, " ", get_localised_item_name(name), " (", inventory.get_item_count(name), ")"},
      position = {source.position.x, source.position.y - 1}
    }
    if self.entity.player then
      self.entity.player.play_sound{path = "utility/inventory_move"}
    end
  end

  return given
end

function Character:give_item(name, count, target)

  local given = target.insert{name = name, count = count}
  self:remove_item(name, given)

  target.surface.create_entity
  {
    name = "flying-text",
    text = {"", "+", given, " ", get_localised_item_name(name), " (", self.entity.get_main_inventory().get_item_count(name), ")"},
    position = {target.position.x, target.position.y - 1}
  }

  if self.entity.player then
    self.entity.player.play_sound{path = "utility/inventory_move"}
  end

  return given
end

function Character:take_item(target, name, count)
  self:push_state(States.take_item(self, target, name, count))
end

function Character:take_item_from_belt(target, name, count)
  self:push_state(States.take_item_from_belt(self, target, name, count))
end

function Character:put_item(target, name, count)
  self:push_state(States.put_item(self, target, name, count))
end

function Character:fuel_entity(target)
  self:push_state(States.fuel_entity(self, target))
end

function Character:fuel_entities(entities)
  self:push_state(States.fuel_entities(self, entities))
end

local debug = false
function Character:print(text)
  if not debug then return end
  game.print(game.tick .. text)
  self:say(text)
end

function Character:say(text)
  self.entity.surface.create_entity{name = "tutorial-flying-text", text = text, position = {self.entity.position.x, self.entity.position.y - 1}}
end

function Character:show_speech_bubble(text)
  if self.speech_bubble and self.speech_bubble.valid then
    self.speech_bubble.start_fading_out()
    self.speech_bubble = nil
  end
  if not text then return end
  self.speech_bubble = self.entity.surface.create_entity{name = "compi-speech-bubble", text = text, position = {self.entity.position.x, self.entity.position.y - 1}, target = self.entity}
end

function Character:on_script_path_request_finished(event)
  local state = self.state_stack[1]
  if state and state.on_script_path_request_finished then
    state:on_script_path_request_finished(event)
  end
end

function Character:get_position()
  return self.entity.position
end

function Character:get_speed()
  return self.entity.character_running_speed
end

function Character:get_closest(entities)
  return self.entity.surface.get_closest(self.entity.position, entities)
end

local direction_size = 2 * defines.direction.south
function Character:get_direction_to(entity_or_position)

  local position = entity_or_position.position or entity_or_position
  -- Angle in rads
  local angle = util.angle(position, self:get_position())

  -- Convert to orientation
  local orientation =  (angle / (2 * math.pi)) - 0.25
  if orientation < 0 then orientation = orientation + 1 end

  --round to nearest 'direction'
  local direction = math.floor((orientation * direction_size) + 0.5)
  if direction == direction_size then direction = 0 end

  return direction
end

function Character:look_at(entity_or_position)
  local direction = self:get_direction_to(entity_or_position)
  self.entity.direction = direction
end

function Character:on_destroyed()
  --??
end

function Character:load()
  for k, state in pairs (self.state_stack) do
    local state_type = States[state.type]
    assert(state_type, "WTF IS THIS STATE? "..state.type)
    setmetatable(state, state_type.metatable)
  end
end

local on_tick = function(event)
  for k, character in pairs (script_data.characters) do
    character:update()
  end
end

local on_script_path_request_finished = function(event)
  for k, character in pairs (script_data.characters) do
    character:on_script_path_request_finished(event)
  end
end

local on_entity_destroyed = function(event)
  local unit_number = event.unit_number
  if not unit_number then return end
  local character = script_data.characters[unit_number]
  if character then
    character:on_destroyed()
    script_data.characters[unit_number] = nil
  end
end

local lib = {}

lib.events =
{
  [defines.events.on_tick] = on_tick,
  [defines.events.on_script_path_request_finished] = on_script_path_request_finished,
  [defines.events.on_entity_destroyed] = on_entity_destroyed,
}

lib.on_load = function()
  script_data = global.character_interface or script_data

  for k, character in pairs (script_data.characters) do
    setmetatable(character, Character.metatable)
    character:load()
  end

end

lib.on_init = function()
  global.character_interface = global.character_interface or script_data

  game.forces.player.set_cease_fire("neutral", true)
  game.forces.player.set_cease_fire("enemy", false)
  game.forces.player.set_cease_fire("player", true)
  game.forces.player.set_friend("player", true)

  game.forces.enemy.set_cease_fire("neutral", true)
  game.forces.enemy.set_cease_fire("player", false)
  game.forces.enemy.set_cease_fire("enemy", true)

  game.forces.neutral.set_cease_fire("neutral", true)
  game.forces.neutral.set_cease_fire("player", true)
  game.forces.neutral.set_cease_fire("enemy", false)
end

lib.new = function(character_entity)
  return Character.new(character_entity)
end

return lib