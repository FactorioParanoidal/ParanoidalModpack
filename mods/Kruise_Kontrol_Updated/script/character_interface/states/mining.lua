local Mining = {}

Mining.metatable = {__index = Mining}

function Mining.new(Character, target, amount)
  local state =
  {
    type = "mining",
    character = Character,
    target = target or error("No mining target?"),
    amount = amount or 1, --related to mining resources, how many times we want to mine it.
    progress = 0
  }
  return setmetatable(state, Mining.metatable)
end

function Mining:cleanup()
  self:update_player_entity_setting(true)
end

function Mining:finish()
  self.character.entity.mining_state = {mining = false}
  self.character.entity.clear_selected_entity()
  self:cleanup()
  self.character:pop_state()
end

function Mining:get_selection_position()
  if self.selection_position then return self.selection_position end

  self.selection_position = self.target.position

  self.character.entity.update_selected_entity(self.target.position)
  if self.character.entity.selected == self.target then
    return true
  end

  local box = self.target.selection_box

  for i, x in pairs({box.left_top.x, box.right_bottom.x}) do
    for j, y in pairs({box.left_top.y, box.right_bottom.y}) do
      local position = {x, y}
      self.character.entity.update_selected_entity(position)
	  self.character.entity.selected = self.target
      if self.character.entity.selected == self.target then
        self.selection_position = position
        return true
      end
    end
  end

  return false

end

function Mining:update_player_entity_setting(bool)
  if self.character.entity.player then
    if self.character.entity.player.valid then
      self.character.entity.player.game_view_settings.update_entity_selection = bool
    end
  end
end

function Mining:update()
  if not self.target.valid then
    --I guess we did it!
    self:finish()
    return
  end

  if not (self.target.minable and self.target.prototype.mineable_properties.minable and not self.target.prototype.mineable_properties.required_fluid) then
    --We cannot mine it
    self:finish()
    return
  end

  if not self.character:can_reach_entity(self.target) then
    --We are out of range, move to range
    self:update_player_entity_setting(true)
    self.character:move_to(self.target, self.character:get_mining_distance(self.target.type) - self.target.get_radius())
    return
  end

  if not self:get_selection_position() then
    self:finish()
    return
  end


  self:update_player_entity_setting(false)
  self.character.entity.mining_state = {mining = true, position = self.selection_position}

  if self.progress > self.character:get_mining_progress() then
    --Our progress is higher than the current, which means we must have mined a piece
    self.amount = self.amount - 1
    if self.amount == 0 then
      self:finish()
      return
    end
  end

  self.progress = self.character:get_mining_progress()
end

return setmetatable(Mining, {__call = function(this, ...) return Mining.new(...) end})