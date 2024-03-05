local Upgrade = {}

Upgrade.metatable = {__index = Upgrade}

function Upgrade.new(Character, target)
  local state =
  {
    type = "upgrade",
    character = Character,
    target = target or error("No target?"),
    check_index = nil
  }
  return setmetatable(state, Upgrade.metatable)
end

local items_to_place = {}

local function get_items_to_place(entity)
  local upgrade_prototype = entity.get_upgrade_target()
  local name = upgrade_prototype.name
  if items_to_place[name] then
    return items_to_place[name]
  end
  items_to_place[name] = upgrade_prototype.items_to_place_this
  return items_to_place[name]
end

function Upgrade:fail()
  self.character:pop_state()
end

function Upgrade:succeed()
  self.character:pop_state()
  self.character:wait(15)
end

function Upgrade:upgrade_target()
  local created = self.character.entity.surface.create_entity
  {
    name = self.target.get_upgrade_target().name,
    position = self.target.position,
    force = self.target.force,
    direction = self.target.get_upgrade_direction(),
    player = self.character.entity.player,
    fast_replace = true,
    raise_built = true
  }
  if created then
    self.character:remove_item(self.item.name, self.item.count)
  end
end

function Upgrade:update()

  if not self.target.valid then
    --ghost is gone or something
    self:fail()
    return
  end

  if not self.target.to_be_upgraded() then
    self:fail()
    return
  end

  
  if not self.item or not self.character:has_item(self.item.name, self.item.count) then
    self.check_index, self.item = next(get_items_to_place(self.target), self.check_index)
  end

  if not self.item then
    --no items to build
    self:fail()
    return
  end

  if not self.character:has_item(self.item.name, self.item.count) then
    self.character:find_item(self.item.name, self.item.count)
    return
  end

  if self.character:distance(self.target) > self.character:get_build_distance() then
    --We are out of range, move to range
    self.character:move_to(self.target, self.character:get_build_distance() - (self.target.get_radius() + 0.5))
    return
  end

  self.character.entity.direction = self.character:get_direction_to(self.target)

  local success = self:upgrade_target()

  self:succeed()
end

return setmetatable(Upgrade, {__call = function(this, ...) return Upgrade.new(...) end})