-- Equipment-related methods
local Equipment = {}

-- Initializes an Inventory for the default equipment Blueprint(s)
---@param default string
---@return LuaInventory
function Equipment.Init(default)
    local equipment = game.create_inventory(1)
    Equipment.Set(equipment, default)
    return equipment
end

-- Updates the default equipment Blueprint(s)
---@param equipment LuaInventory
---@param default string
function Equipment.Set(equipment, default)
    equipment[1].import_stack(default)
end

--[[
Before 1.1.87, there was a bug that did not correctly forcefully generate
chunks for surfaces with the Lab Tiles setting, which required us to
fix those tiles after generation but before placing the Blueprint.
This but was fixed in 1.1.87, however, it introduced another bug where
building a blueprint then did not immediately work on those tiles,
but building entities seemed to, since the forceful generation was not working.
In 2.0.24, this was finally fixed for real, but apparently the fog-of-war setting
is inverted, so it may break in the future if that API changes.
]]
---@param stack LuaItemStack
---@param surface LuaSurface
---@param forceName ForceID
function Equipment.Place(stack, surface, forceName)
    if stack.is_blueprint then
        Equipment.Prepare(stack, surface)
        Equipment.BuildBlueprint(stack, surface, forceName)
        return true
    end
end

-- Prepares a Surface for an Equipment Blueprint
---@param stack LuaItemStack
---@param surface LuaSurface
function Equipment.Prepare(stack, surface)
    -- We need to know how many Chunks must be generated to fit this Blueprint
    local radius = 0
    ---@param thing BlueprintEntity | Tile
    local function updateRadius(thing)
        local x = math.abs(thing.position.x)
        local y = math.abs(thing.position.y)
        radius = math.max(radius, x, y)
    end
    local entities = stack.get_blueprint_entities()
    local tiles = stack.get_blueprint_tiles()
    if entities then
        for _, thing in pairs(entities) do
            updateRadius(thing)
        end
    end
    if tiles then
        for _, thing in pairs(tiles) do
            updateRadius(thing)
        end
    end

    -- Then, we can forcefully generate the necessary Chunks
    local chunkRadius = 1 + math.ceil(radius / 32)
    surface.request_to_generate_chunks({ x = 0, y = 0 }, chunkRadius)
    surface.force_generate_chunk_requests()
end

-- Applies an Equipment Blueprint to a Surface
---@param stack LuaItemStack
---@param surface LuaSurface
---@param forceName ForceID
function Equipment.BuildBlueprint(stack, surface, forceName)
    -- Then, place the Tiles ourselves since it might prevent placing the Blueprint
    local tiles = stack.get_blueprint_tiles()
    if tiles then
        surface.set_tiles(tiles, true, true, true, true)
    end

    -- Finally, we can place the Blueprint
    stack.build_blueprint({
        surface = surface.name,
        force = forceName,
        position = { 0, 0 },
        build_mode = defines.build_mode.superforced,
        skip_fog_of_war = false, -- This works BACKWARDS??
        raise_built = true,
    })

    -- Since we may have changed the ghosts into real entities, we need to simply count entities
    local surfaceEntityCount = surface.count_entities_filtered({})
    local blueprintEntityCount = stack.get_blueprint_entity_count()
    if surfaceEntityCount ~= blueprintEntityCount then
        log("Surface has " .. surfaceEntityCount .. " entities, Blueprint wanted " .. blueprintEntityCount .. " entities")
    end
end

return Equipment
