local Attack = {}

Attack.metatable = {__index = Attack}

function Attack.new(Character, target, timeout)
  local state =
  {
    type = "attack",
    character = Character,
    target = target or error("No target?"),
    tick_to_timeout = (timeout and game.tick + timeout) or nil
  }
  return setmetatable(state, Attack.metatable)
end

function Attack:prepare_gun()
  local gun_inventory = self.character.entity.get_inventory(defines.inventory.character_guns)
  local ammo_inventory = self.character.entity.get_inventory(defines.inventory.character_guns)
  local index = self.character.entity.selected_gun_index
  if gun_inventory[index].valid_for_read and ammo_inventory[index].valid_for_read then return true end

  for k = 1, 3 do
    if gun_inventory[k].valid_for_read and ammo_inventory[k].valid_for_read then
      self.character.entity.selected_gun_index = k
      return true
    end
  end

  --todo, find a pair of gun and ammo in the inventory.

  return false
end

function Attack:finish()
  self.character.entity.shooting_state = {state = defines.shooting.not_shooting, position = {0,0}}
  self.character:pop_state()
end

function Attack:get_range()
  return self:get_attack_parameters().range - (self.target.get_radius() + 1)
end

function Attack:get_attack_parameters()
  return game.item_prototypes[self.character.entity.get_inventory(defines.inventory.character_guns)[self.character.entity.selected_gun_index].name].attack_parameters
end

function Attack:can_shoot()
  if util.distance(self.character:get_position(), self.target.position) > self:get_range() then
    return false
  end
  return self.character.entity.can_shoot(self.target, self.target.position)
end

local does_damage = function(attack_parameters)
  if not attack_parameters then return end
  local ammo = attack_parameters.ammo_type
  for k, trigger_item in pairs (ammo.action) do
    for k, trigger_delivery in pairs (trigger_item.action_delivery) do
      if trigger_delivery.type == "projectile" then return true end
      for k, effect in pairs (trigger_delivery.target_effects or {}) do
        if effect.type == "damage" then return true end
      end
    end
  end
end

local heals = function(attack_parameters)
  if not attack_parameters then return end
  local ammo = attack_parameters.ammo_type
  for k, trigger_item in pairs (ammo.action) do
    for k, trigger_delivery in pairs (trigger_item.action_delivery) do
      for k, effect in pairs (trigger_delivery.target_effects or {}) do
        if effect.type == "damage" and effect.damage.amount < 0 then return true end
      end
    end
  end
end

local find_grenade = function(inventory)
  for k = 1, #inventory do
    local stack = inventory[k]
    if stack and stack.valid_for_read then
      if stack.type == "capsule" then
        local action = stack.prototype.capsule_action
        if action.type == "throw" then
          if does_damage(action.attack_parameters) then
            return stack
          end
        end
      end
    end
  end
end

local find_fish = function(inventory)
  for k = 1, #inventory do
    local stack = inventory[k]
    if stack and stack.valid_for_read then
      if stack.type == "capsule" then
        local action = stack.prototype.capsule_action
        if action.type == "use-on-self" then
          if heals(action.attack_parameters) then
            return stack
          end
        end
      end
    end
  end
end

function Attack:find_and_use_capsule(position)
  local player = self.character.entity.player
  if not player then return end

  player.clear_cursor()
  local inventory = player.get_main_inventory()
  if not inventory then return end

  local stack
  if self.character.entity.get_health_ratio() < 0.75 then
    stack = find_fish(inventory) or find_grenade(inventory)
  else
    stack = find_grenade(inventory)
  end

  if not stack then
    return
  end

  stack.swap_stack(player.cursor_stack)

  if player.cursor_stack.valid_for_read then
    player.use_from_cursor(position)
  end

  player.clear_cursor()

end

function Attack:update()

  if self.tick_to_timeout and game.tick > self.tick_to_timeout then
    self:finish()
    return
  end

  if not (self.target and self.target.valid and self.target.get_health_ratio() and self.target.get_health_ratio() > 0) then
    self:finish()
    return
  end

  if not self:prepare_gun() then
    --for now? just fail
    self:finish()
    return
  end

  if not self:can_shoot() then
    --We are out of range, move to range
    self.character.entity.shooting_state = {state = defines.shooting.not_shooting, position = self.target.position}
    self.character.entity.clear_selected_entity()
    self.character:move_to(self.target, self:get_range() - self.target.get_radius(), (self.tick_to_timeout and self.tick_to_timeout - game.tick) or nil)
    return
  end

  local direction = self.character:get_direction_to(self.target)
  if self.character:distance(self.target) < (self:get_range() * 0.8) then
    direction = (direction + defines.direction.south) % (defines.direction.south * 2)
    self.character.entity.walking_state = {walking = true, direction = direction}
  else
    local way = (((self.target.unit_number or 1) % 2 == 0) and defines.direction.east) or defines.direction.west
    direction = (direction + way) % (defines.direction.south * 2)
    self.character.entity.walking_state = {walking = true, direction = direction}
  end
  self.character.entity.update_selected_entity(self.target.position)
  self.character.entity.shooting_state = {state = defines.shooting.shooting_selected, position = self.target.position}

  if self.character:update_every_n_ticks(31) then
    self:find_and_use_capsule(self.target.position)
  end

end

return setmetatable(Attack, {__call = function(this, ...) return Attack.new(...) end})
