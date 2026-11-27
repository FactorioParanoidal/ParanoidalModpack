local Upgrade = {}

Upgrade.metatable = { __index = Upgrade }

function Upgrade.new(Character, target)
    return setmetatable({ type = "upgrade", character = Character, target = assert(target) }, Upgrade.metatable)
end

function Upgrade:update()
    local character, target = self.character, self.target
    if not target.valid then
        character:pop_state()
        return
    end

    local prototype, quality = target.get_upgrade_target()
    if not (prototype and quality) then
        character:pop_state()
        return
    end
    if self.upgrade_name ~= prototype.name or self.upgrade_quality ~= quality.name then
        self.upgrade_name, self.upgrade_quality = prototype.name, quality.name
        self.searched_placement_items = nil
    end

    local item, searching = character:placement_item(self, prototype.items_to_place_this, quality.name)
    if not item then
        if not searching then character:pop_state() end
        return
    end

    local distance = character:get_build_distance()
    if character:distance(target) > distance then
        if not character:approach(target, distance - target.get_radius() - 0.5) then character:pop_state() end
        return
    end

    character:look_at(target)
    local created = character:with_item_payment(item, function()
        return target.surface.create_entity {
            name = prototype.name,
            position = target.position,
            force = target.force,
            direction = target.direction,
            player = character.entity.player,
            fast_replace = true,
            raise_built = true,
            quality = quality.name,
            type = target.type == "underground-belt" and target.belt_to_ground_type or nil
        }
    end)
    if character.state_stack[1] == self then
        character:pop_state(created ~= nil)
        if created then character:wait(15) end
    end
end

return setmetatable(Upgrade, { __call = function(this, ...) return Upgrade.new(...) end })
