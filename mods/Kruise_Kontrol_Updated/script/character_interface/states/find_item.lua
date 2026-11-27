local Find_item = {}
Find_item.metatable = { __index = Find_item }

function Find_item.new(Character, name, count, radius)
    assert(name)
    return setmetatable({
        type = "find_item", character = Character, name = name, radius = radius or 64,
        count = count and count > 0 and count or math.ceil(prototypes.item[name].stack_size * 0.25)
    }, Find_item.metatable)
end

local function target_key(entity)
    if entity.unit_number then return entity.unit_number end
    local p = entity.position
    return entity.name .. "@" .. p.x .. "," .. p.y
end

function Find_item:choose_target(params, can_supply)
    self.tried_targets = self.tried_targets or {}
    local candidates = {}
    for _, entity in ipairs(self.character:find_nearby_entities(self.radius, params)) do
        if not self.tried_targets[target_key(entity)] and can_supply(entity, self.name) then
            candidates[#candidates + 1] = entity
        end
    end
    if #candidates == 0 then return end
    local target = self.character:get_closest(candidates)
    self.tried_targets[target_key(target)] = true
    return target
end

local output_params = { type = { "container", "logistic-container", "furnace", "assembling-machine", "mining-drill" } }
local function has_output(entity, item)
    local inventory = entity.get_output_inventory()
    return inventory and inventory.get_item_count(item) > (entity.type == "mining-drill" and 5 or 0)
end

local belt_params = { type = "transport-belt" }
local function belt_has_item(entity, item)
    for i = 1, entity.get_max_transport_line_index() do
        if entity.get_transport_line(i).get_item_count(item) > 0 then return true end
    end
    return false
end

local mine_params = { type = { "tree", "resource", "simple-entity" } }
local product_cache = {}
local function yields_item(entity, item)
    if not entity.minable then return false end
    local products = product_cache[entity.name]
    if not products then
        local mineable = entity.prototype.mineable_properties
        products = {}
        if not mineable.required_fluid then
            for _, product in pairs(mineable.products or {}) do
                if product.type == "item" then products[product.name] = true end
            end
        end
        product_cache[entity.name] = products
    end
    return products[item]
end

function Find_item:update()
    local character = self.character
    local inventory = character.entity.get_main_inventory()
    local needed = inventory and self.count - inventory.get_item_count(self.name) or 0
    if needed <= 0 or not inventory.can_insert { name = self.name, count = 1 } then
        character:pop_state()
        return
    end

    local amount = math.max(needed, prototypes.item[self.name].stack_size)
    local target = self:choose_target(output_params, has_output)
    if target then
        character:take_item(target, self.name, amount)
        return
    end

    target = self:choose_target(belt_params, belt_has_item)
    if target then
        character:take_item_from_belt(target, self.name, amount)
        return
    end

    target = self:choose_target(mine_params, yields_item)
    if target then
        character:mine(target, amount)
        return
    end

    -- Alternate recipes can have cyclic dependencies. Do not recurse into a
    -- craft job already waiting for this item somewhere below us.
    for _, state in ipairs(character.state_stack) do
        if state.type == "craft_item" and state.name == self.name then
            character:pop_state()
            return
        end
    end
    character:pop_state(true)
    character:craft_item(self.name, self.count)
end

return setmetatable(Find_item, { __call = function(this, ...) return Find_item.new(...) end })
