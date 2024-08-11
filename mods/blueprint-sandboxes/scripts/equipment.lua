-- Equipment-related methods
local Equipment = {}

-- Initializes an Inventory for the default equipment Blueprint(s)
function Equipment.Init(default)
    local equipment = game.create_inventory(1)
    Equipment.Set(equipment, default)
    return equipment
end

-- Updates the default equipment Blueprint(s)
function Equipment.Set(equipment, default)
    equipment[1].import_stack(default)
end

--[[
Before 1.1.87, there was a bug that did not correctly forcefully generate
chunks for surfaces with the Lab Tiles setting, which required us to
fix those tiles after generation but before placing the Blueprint.
This but was fixed in 1.1.87, however, it introduced another bug where
building a blueprint then did not immediately work on those tiles,
but building entities seemed to. So, the workaround is to delay the blueprint
building, so we do some work when the surface is generated, then the rest
as soon as possible (aligning to generated chunks seems faster (in ticks)
than waiting any number of specific ticks).
]]
function Equipment.Place(stack, surface, forceName)
    if stack.is_blueprint then
        log("Beginning Equipment Placement")
        Equipment.Prepare(stack, surface)

        global.equipmentInProgress[surface.name] = {
            stack = stack,
            surface = surface,
            forceName = forceName,
            retries = 100,
        }
        Equipment.BuildBlueprint(stack, surface, forceName)
    else
        global.equipmentInProgress[surface.name] = nil
    end
    return true
end

-- Prepares a Surface for an Equipment Blueprint
function Equipment.Prepare(stack, surface)
    -- We need to know how many Chunks must be generated to fit this Blueprint
    local radius = 0
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
    log("Requesting Chunks for Blueprint Placement: " .. chunkRadius)
    surface.request_to_generate_chunks({ x = 0, y = 0 }, chunkRadius)
    surface.force_generate_chunk_requests()
    log("Chunks allegedly generated")
end

-- Applies an Equipment Blueprint to a Surface
function Equipment.IsReadyForBlueprint(stack, surface)
    local entities = stack.get_blueprint_entities()
    local tiles = stack.get_blueprint_tiles()
    local function is_chunk_generated(thing)
        return surface.is_chunk_generated({
            thing.position.x / 32,
            thing.position.y / 32,
        })
    end
    if entities then
        for _, thing in pairs(entities) do
            if not is_chunk_generated(thing) then
                return false
            end
        end
    end
    if tiles then
        for _, thing in pairs(tiles) do
            if not is_chunk_generated(thing) then
                return false
            end
        end
    end
    return true
end

-- Applies an Equipment Blueprint to a Surface
function Equipment.BuildBlueprint(stack, surface, forceName)
    local equipmentData = global.equipmentInProgress[surface.name]

    -- First, let's check if the Chunks are ready for us
    if not Equipment.IsReadyForBlueprint(stack, surface) then
        equipmentData.retries = equipmentData.retries - 1
        return false
    end

    -- Then, place the Tiles ourselves since it might prevent placing the Blueprint
    local tiles = stack.get_blueprint_tiles()
    if tiles then
        surface.set_tiles(tiles, true, true, true, true)
    end

    -- Finally, we can place the Blueprint
    local ghosts = stack.build_blueprint({
        surface = surface.name,
        force = forceName,
        position = { 0, 0 },
        skip_fog_of_war = true,
        raise_built = true,
    })

    -- But that may have not been successful, despite our attempts to ensure it!
    if #ghosts > 0 then
        log("Some ghosts created, ending repeated attempts; assuming Blueprint is placed")
        global.equipmentInProgress[surface.name] = nil
        return true
    elseif equipmentData.retries <= 0 then
        log("No ghosts created, but we've exceeded retry limit, ending repeated attempts")
        surface.print("Failed to place Equipment Blueprint after too many retries")
        global.equipmentInProgress[surface.name] = nil
        return false
    else
        equipmentData.retries = equipmentData.retries - 1
        return false
    end
end

return Equipment
