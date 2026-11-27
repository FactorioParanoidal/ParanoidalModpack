local Build_ghost = {}

Build_ghost.metatable = { __index = Build_ghost }

function Build_ghost.new(Character, target)
    return setmetatable({ type = "build_ghost", character = Character, target = assert(target) }, Build_ghost.metatable)
end

function Build_ghost:step_aside(box)
    local character, entity = self.character, self.character.entity
    if self.stepped_aside then return false end
    self.stepped_aside = true
    local function try(x, y)
        if not entity.surface.can_place_entity { name = entity.name, position = { x, y } } then return false end
        self.approach_result = nil
        return character:approach({ x, y }, 0.25)
    end
    for _, x in ipairs { box.left_top.x - 1, box.right_bottom.x + 1 } do
        for y = box.left_top.y - 1, box.right_bottom.y + 1 do
            if try(x, y) then return true end
        end
    end
    for _, y in ipairs { box.left_top.y - 1, box.right_bottom.y + 1 } do
        for x = box.left_top.x - 1, box.right_bottom.x + 1 do
            if try(x, y) then return true end
        end
    end
    return false
end

function Build_ghost:clear_obstacles()
    local character, target = self.character, self.target
    if target.type ~= "entity-ghost" or self.cleared_obstacles then return false end
    local box = target.bounding_box
    local mask = target.ghost_prototype.collision_mask.layers
    local entities = target.surface.find_entities_filtered { area = box, collision_mask = mask }
    if #entities == 0 then
        local extended = { { box.left_top.x - 1, box.left_top.y - 1 }, { box.right_bottom.x + 1, box.right_bottom.y + 1 } }
        entities = target.surface.find_entities_filtered { area = extended, collision_mask = mask, to_be_deconstructed = true }
    end
    for _, entity in ipairs(entities) do
        if entity.type == "cliff" then return false end
    end
    for _, entity in ipairs(entities) do
        if entity == character.entity then return self:step_aside(box) end
    end
    self.cleared_obstacles = true
    local found = false
    for _, entity in ipairs(entities) do
        if entity ~= target then
            character:mine(entity)
            found = true
        end
    end
    return found
end

function Build_ghost:update()
    local character, target = self.character, self.target
    if not target.valid then
        character:pop_state()
        return
    end

    local item, searching = character:placement_item(self, target.ghost_prototype.items_to_place_this, target.quality.name)
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
    if target.type == "entity-ghost" and not self.cleared_trees then
        self.cleared_trees = true
        local trees = target.surface.find_entities_filtered {
            type = "tree", position = target.position, radius = target.get_radius(), to_be_deconstructed = false
        }
        for _, tree in ipairs(trees) do character:mine(tree) end
        if #trees > 0 then return end
    end

    local revived = character:with_item_payment(item, function()
        return target.revive { raise_revive = true }
    end)
    if character.state_stack[1] ~= self then return end
    if revived then
        character:pop_state(true)
        character:wait(5)
    elseif not self:clear_obstacles() then
        character:pop_state()
    end
end

return setmetatable(Build_ghost, { __call = function(this, ...) return Build_ghost.new(...) end })
