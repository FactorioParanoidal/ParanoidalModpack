require "util"
autodeconstruct = {}

local function find_resources(surface, position, range, resource_category)
	
    local resource_category = resource_category or 'basic-solid'
    local top_left = {x = position.x - range, y = position.y - range}
    local bottom_right = {x = position.x + range, y = position.y + range}

    local resources = surface.find_entities_filtered{area={top_left, bottom_right}, type='resource'}
    categorized = {}
    for _, resource in pairs(resources) do
        if resource.prototype.resource_category == resource_category then
            table.insert(categorized, resource)
        end
    end
    return categorized
end

local function find_all_entities(entity_type)
    local surface = game.surfaces['nauvis']
    local entities = {}
    for chunk in surface.get_chunks() do
        local chunk_area = {lefttop = {x = chunk.x*32, y = chunk.y*32}, rightbottom = {x = chunk.x*32+32, y = chunk.y*32+32}}
        local chunk_entities = surface.find_entities_filtered({area = chunk_area, type = entity_type})
        for i = 1, #chunk_entities do
            entities[#entities + 1] = chunk_entities[i]
        end
    end
    return entities
end

local function find_target(entity)
    if entity.drop_target then
        return entity.drop_target
    else
        local entities = entity.surface.find_entities_filtered{position=entity.drop_position}
        if global.debug then msg_all({"autodeconstruct-debug", "found " .. entities[1].name .. " at " .. util.positiontostr(entities[1].position)}) end
        return entities[1]
    end
end

local function find_targeting(entity)
    local range = global.max_radius
    local position = entity.position

    local top_left = {x = position.x - range, y = position.y - range}
    local bottom_right = {x = position.x + range, y = position.y + range}

    local surface = entity.surface
    local entities = {}
    local targeting = {}

    local entities = surface.find_entities_filtered{area={top_left, bottom_right}, type='mining-drill'}
    for i = 1, #entities do
        if find_target(entities[i]) == entity then
            targeting[#targeting + 1] = entities[i]
        end
    end

    entities = surface.find_entities_filtered{area={top_left, bottom_right}, type='inserter'}
    for i = 1, #entities do
        if find_target(entities[i]) == entity then
            targeting[#targeting + 1] = entities[i]
        end
    end
    if global.debug then msg_all({"autodeconstruct-debug", "found " .. #targeting .. " targeting"}) end
    return targeting
end

local function find_drills(entity)
    local position = entity.position
    local surface = entity.surface

    local top_left = {x = position.x - global.max_radius, y = position.y - global.max_radius}
    local bottom_right = {x = position.x + global.max_radius, y = position.y + global.max_radius}

    local entities = {}
    local targeting = {}

    local entities = surface.find_entities_filtered{area={top_left, bottom_right}, type='mining-drill'}
    if global.debug then msg_all({"autodeconstruct-debug", "found " .. #entities  .. " drills"}) end
    for i = 1, #entities do
        if math.abs(entities[i].position.x - position.x) < entities[i].prototype.mining_drill_radius and math.abs(entities[i].position.y - position.y) < entities[i].prototype.mining_drill_radius then
            autodeconstruct.check_drill(entities[i])
        end
    end
end

function autodeconstruct.init_globals()
    global.max_radius = 0.99
    drill_entities = find_all_entities('mining-drill')
    for _, drill_entity in pairs(drill_entities) do
        autodeconstruct.check_drill(drill_entity)
    end
end

function autodeconstruct.on_resource_depleted(event)
    if event.entity.prototype.resource_category ~= 'basic-solid' or event.entity.prototype.infinite_resource ~= false then
        if global.debug then msg_all({"autodeconstruct-debug", "on_resource_depleted", game.tick .. " amount " .. event.entity.amount .. " resource_category " .. event.entity.prototype.resource_category .. " infinite_resource " .. (event.entity.prototype.infinite_resource == true and "true" or "false" )}) end
        return
    end
    drill = find_drills(event.entity)
end

function autodeconstruct.check_drill(drill)
    if drill.mining_target ~= nil and drill.mining_target.valid then
        if drill.mining_target.amount > 0 then return end -- this should also filter out pumpjacks and infinite resources
    end

    local mining_drill_radius = drill.prototype.mining_drill_radius
    if mining_drill_radius > global.max_radius then
        global.max_radius = mining_drill_radius
    end

    if mining_drill_radius == nil then return end

    resources = find_resources(drill.surface, drill.position, mining_drill_radius, 'basic-solid')
    for i = 1, #resources do
        if resources[i].amount > 0 then return end
    end
    if global.debug then msg_all({"autodeconstruct-debug", util.positiontostr(drill.position) .. " found no resources, deconstructing"}) end
    autodeconstruct.order_deconstruction(drill)
end

function autodeconstruct.on_cancelled_deconstruction(event)
    if event.player_index ~= nil or event.entity.type ~= 'mining-drill' then return end
    if global.debug then msg_all({"autodeconstruct-debug", "on_cancelled_deconstruction", util.positiontostr(event.entity.position) .. " deconstruction timed out, checking again"}) end
    autodeconstruct.check_drill(event.entity)
end

function autodeconstruct.on_built_entity(event)
    if event.created_entity.type ~= 'mining-drill' then return end
    if event.created_entity.prototype.mining_drill_radius > global.max_radius then
        global.max_radius = event.created_entity.prototype.mining_drill_radius
        if global.debug then msg_all({"autodeconstruct-debug", "on_built_entity", "global.max_radius updated to " .. global.max_radius}) end
    end
end

function autodeconstruct.order_deconstruction(drill)
    if drill.to_be_deconstructed(drill.force) then
        if global.debug then msg_all({"autodeconstruct-debug", util.positiontostr(drill.position) .. " already marked"}) end
        return
    end

    local deconstruct = true

	if drill.fluidbox and #drill.fluidbox > 0 then
		deconstruct = false
	end

	if next(drill.circuit_connected_entities.red) ~= nil or next(drill.circuit_connected_entities.green) ~= nil then
		deconstruct = false
	end
    if deconstruct == true and drill.minable and drill.prototype.selectable_in_game and drill.has_flag("not-deconstructable") == false then
        if drill.order_deconstruction(drill.force) then
            if global.debug then msg_all({"autodeconstruct-debug", util.positiontostr(drill.position)  .. " " .. drill.name .. " success"}) end
        else
            msg_all({"autodeconstruct-err-specific", "drill.order_deconstruction", util.positiontostr(drill.position) .. " failed to order deconstruction on " .. drill.name })
        end
        if settings.global['autodeconstruct-remove-target'].value then
            target = find_target(drill)
            if target ~= nil and target.minable and target.prototype.selectable_in_game then
                if target.type == "logistic-container" or target.type == "container" then
                    targeting = find_targeting(target)
                    if targeting ~= nil then
                        for i = 1, #targeting do
                            if not targeting[i].to_be_deconstructed(targeting[i].force) then return end
                        end
                        -- we are the only one targeting
                        if target.to_be_deconstructed(target.force) then
                            target.cancel_deconstruction(target.force)
                        end
                        if target.order_deconstruction(target.force) then
                            if global.debug then msg_all({"autodeconstruct-debug", util.positiontostr(target.position) .. " " .. target.name .. " success"}) end
                        else
                            msg_all({"autodeconstruct-err-specific", "target.order_deconstruction", util.positiontostr(target.position) .. " failed to order deconstruction on " .. target.name})
                        end
                    end
                end
--[[ #TODO
                if target.type == "transport-belt" then
                    -- find entities with this belt as target
                end
--]]
            end
        end
    end
end
