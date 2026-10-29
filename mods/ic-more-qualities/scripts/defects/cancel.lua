-- Cancelled handcraft (Paranoidal fix 2026-10-19). A prerequisite the game queued itself is crafted
-- without a defect roll (handcraft.queued_prerequisite): its consumer expects it. Cancelling the
-- consumer returned that item at standard quality, so a defect-capable product could be farmed by
-- queueing its consumer and cancelling it (e.g. stone furnaces from burner drills).
--
-- Simple variant chosen by the user: the player remembers the names of finished products that skipped
-- their roll as prerequisites while the queue is not empty; every standard item of such a name returned
-- by a cancel gets one roll per item, also the player's own ones that went into the cancelled craft.
-- Materials, raw resources, items without defects (no_defect) and non-standard returned items are never
-- touched. The returned items are converted one tick later in the main inventory: the event does not
-- say whether they are already there, and changing event.items is not documented to have an effect.
local model = require("scripts.defects.model")
local M = {}

-- Same item kinds as the handcraft adapter; other kinds keep their returned quality.
local rebuildable = {
    item = true, module = true, capsule = true, gun = true, ammo = true, tool = true,
    ["repair-tool"] = true, armor = true, ["rail-planner"] = true, ["item-with-entity-data"] = true,
}

local function data()
    local root = storage.ic_cancel
    if not root then
        root = {skipped = {}, pending = {}}
        storage.ic_cancel = root
    end
    return root
end

-- Only defect-capable finished products: materials, raw resources and exempt items are never remembered.
function M.can_roll(name, finished, no_defect)
    return finished[name] == true and not (no_defect and no_defect[name])
end

-- A prerequisite skipped its roll (handcraft at control level below 10, standard result).
function M.remember(player_index, name, finished, no_defect)
    if not M.can_roll(name, finished, no_defect) then return end
    local skipped = data().skipped
    local names = skipped[player_index]
    if not names then
        names = {}
        skipped[player_index] = names
    end
    names[name] = true
end

function M.forget(player_index)
    local root = storage.ic_cancel
    if root then root.skipped[player_index] = nil end
end

local function queue_empty(player)
    return not player.character or player.crafting_queue_size == 0
end

-- Forget once the queue has run out: no remembered prerequisite can come back any more.
function M.forget_if_idle(player)
    local root = storage.ic_cancel
    if root and root.skipped[player.index] and queue_empty(player) then root.skipped[player.index] = nil end
end

-- on_player_cancelled_crafting: queue the returned standard items of remembered names.
function M.on_cancelled(event, finished, no_defect)
    local root = storage.ic_cancel
    local names = root and root.skipped[event.player_index]
    local items = event.items
    if not names or not (items and items.valid) then return 0 end
    local queued = 0
    for index = 1, #items do
        local stack = items[index]
        if stack.valid_for_read and names[stack.name] and stack.quality.name == "normal"
            and M.can_roll(stack.name, finished, no_defect) then
            local pending = root.pending
            pending[#pending + 1] = {player = event.player_index, name = stack.name, count = stack.count,
                tick = event.tick}
            queued = queued + stack.count
        end
    end
    return queued
end

function M.has_pending()
    local root = storage.ic_cancel
    return root ~= nil and root.pending[1] ~= nil
end

local function definition(stack, kind, count, quality)
    local result = {name = stack.name, count = count, quality = quality,
        health = stack.health, spoil_percent = stack.spoil_percent}
    if kind == "ammo" then result.ammo = stack.ammo end
    if kind == "tool" or kind == "repair-tool" then
        local prototype = stack.prototype
        local old_max, new_max = prototype.get_durability("normal"), prototype.get_durability(quality)
        if not old_max or not new_max or old_max <= 0 then return nil end
        result.durability = math.min(1, stack.durability / old_max) * new_max
    end
    return result
end

local function plain(stack, name)
    if not (stack.valid_for_read and stack.name == name and stack.quality.name == "normal") then return nil end
    local kind = stack.prototype.type
    if not rebuildable[kind] then return nil end
    local grid = stack.grid
    if grid and next(grid.equipment) then return nil end
    if kind == "item-with-entity-data" and (stack.entity_label or stack.entity_color) then return nil end
    return kind
end

-- Turns `count` standard items `name` of the main inventory into `quality`; returns how many changed.
local function convert(player, inventory, name, count, quality)
    local changed = 0
    for index = 1, #inventory do
        if changed >= count then break end
        local stack = inventory[index]
        local kind = plain(stack, name)
        if kind then
            local take = math.min(count - changed, stack.count)
            local result = definition(stack, kind, take, quality)
            if not result then break end
            if take == stack.count then
                if stack.set_stack(result) then changed = changed + take end
            else
                stack.count = stack.count - take
                local inserted = inventory.insert(result)
                if inserted < take then
                    result.count = take - inserted
                    player.surface.spill_item_stack({position = player.position, stack = result,
                        enable_looted = true, force = player.force, allow_belts = false})
                end
                changed = changed + take
            end
        end
    end
    return changed
end

-- One roll per returned item. Returns the number of defective items made.
function M.process(tick, get_player, random, finished, no_defect)
    local root = storage.ic_cancel
    if not root or not root.pending[1] then return 0 end
    local later, made = {}, 0
    for _, entry in ipairs(root.pending) do
        if entry.tick >= tick then
            later[#later + 1] = entry
        else
            local player = get_player(entry.player)
            local inventory = player and player.valid and player.get_main_inventory()
            if inventory and M.can_roll(entry.name, finished, no_defect) then
                local level = model.completed_level(player.force.technologies)
                if level < 10 then
                    local grades = {}
                    for _ = 1, entry.count do
                        local grade = model.draw(level, random())
                        if grade < 0 then grades[grade] = (grades[grade] or 0) + 1 end
                    end
                    for grade = -5, -1 do
                        if grades[grade] then
                            made = made + convert(player, inventory, entry.name, grades[grade],
                                model.quality_name(grade))
                        end
                    end
                end
            end
            if player and player.valid then M.forget_if_idle(player) end
        end
    end
    root.pending = later
    return made
end

function M.remove_player(player_index)
    local root = storage.ic_cancel
    if not root then return end
    root.skipped[player_index] = nil
    local kept = {}
    for _, entry in ipairs(root.pending) do
        if entry.player ~= player_index then kept[#kept + 1] = entry end
    end
    root.pending = kept
end

return M
