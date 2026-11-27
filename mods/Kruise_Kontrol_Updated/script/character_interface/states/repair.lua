local Repair = {}

Repair.metatable = { __index = Repair }

function Repair.new(Character, target, distance)
    local state =
    {
        type = "repair",
        character = Character,
        target = target or error("Нет цели?"),
    }
    return setmetatable(state, Repair.metatable)
end

local approach_timeout = 30 * 60

local function matches_tool(cursor, tool)
    return tool and cursor and cursor.valid_for_read
        and cursor.name == tool.name and cursor.quality.name == tool.quality
end

function Repair:cleanup()
    local entity = self.character.entity
    if not entity.valid then return end

    if self.repairing then
        entity.repair_state = { repairing = false, position = entity.position }
    end
    local player = entity.player
    if player and matches_tool(entity.cursor_stack, self.borrowed_tool) then
        player.clear_cursor()
    end
end

function Repair:finish()
    self:cleanup()
    self.character:pop_state()
end

local repair_tools

local get_repair_tools = function()
    if repair_tools then return repair_tools end
    repair_tools = {}
    for name, item in pairs(prototypes.item) do
        if item.speed then
            repair_tools[name] = true
        end
    end
    return repair_tools
end

function Repair:prepare_tool()
    local cursor = self.character.entity.cursor_stack
    if not matches_tool(cursor, self.borrowed_tool) then
        self.borrowed_tool = nil
    end
    if cursor.valid_for_read and get_repair_tools()[cursor.name] then
        return true
    end
    local main_inventory = self.character.entity.get_main_inventory()
    for name in pairs(get_repair_tools()) do
        local stack = main_inventory.find_item_stack(name)
        if stack and stack.swap_stack(cursor) then
            self.borrowed_tool = { name = cursor.name, quality = cursor.quality.name }
            return true
        end
    end
    return false
end

function Repair:update()
    if not self.target.valid or self.target.get_health_ratio() >= 1 then
        self:finish()
        return
    end

    if not self:prepare_tool() then
        self.search_tool = next(get_repair_tools(), self.search_tool)

        if not self.search_tool then
            self:finish()
            return
        end

        self.character:find_item(self.search_tool, 1)
        return
    end

    if not self.character:can_reach_entity(self.target) then
        -- Returning from a failed approach must not create a fresh path retry budget.
        if self.approach_attempted then
            self:finish()
        else
            self.approach_attempted = true
            self.character:move_to(self.target, self.character:get_repair_distance(), approach_timeout)
        end
        return
    end

    self.character.entity.update_selected_entity(self.target.position)
    self.character.entity.repair_state = { repairing = true, position = self.target.position }
    self.repairing = true
end

return setmetatable(Repair, { __call = function(this, ...) return Repair.new(...) end })
