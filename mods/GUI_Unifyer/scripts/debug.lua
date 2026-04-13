local function get_parent_chain(element)
    if not element or not element.valid then return {} end
    
    local parents = {}
    local current = element
    local depth = 0
    -- Limit depth to prevent any possible issues
    local max_depth = 10
    
    while current.parent and depth < max_depth do
        depth = depth + 1
        current = current.parent
        if not current.valid then break end
        
        parents[depth] = {
            name = current.name or "unnamed",
            type = current.type or "unknown"
        }
    end
    
    return parents
end

-- Factorio-specific GUI element inspection
local function get_element_details(element)
    if not element or not element.valid then return {} end
    
    local details = {}
    
    -- Standard GUI properties in Factorio
    local gui_props = {
        "type", "name", "caption", "tooltip", "enabled", 
        "visible", "style", "tags", "index"
    }
    
    for _, prop in pairs(gui_props) do
        if element[prop] ~= nil then
            details[prop] = element[prop]
        end
    end
    
    -- Sprite-button specific properties
    if element.type == "sprite-button" then
        details.sprite = element.sprite
    end
    
    -- Get mod name if available
    details.mod = element.get_mod and element.get_mod() or "unknown"
    
    return details
end

function debug_button(event)
    if not event or not event.element then return end
    
    local player = game.players[event.player_index]
    if not player or not player.valid then return end
    
    local element = event.element
    if not element.valid then
        player.print("Debug: Invalid GUI element")
        return
    end
    
    game.print("_________________________________________")
    
    -- Print element details
    local details = get_element_details(element)
    for key, value in pairs(details) do
        player.print(key .. " = " .. serpent.line(value, {comment = false}))
    end
    
    -- Print parent chain
    local parents = get_parent_chain(element)
    if next(parents) then
        player.print("\nParent hierarchy:")
        for depth, parent in pairs(parents) do
            player.print(string.rep("  ", depth - 1) .. parent.name .. " (" .. parent.type .. ")")
        end
    end
    
    -- Print current surface name
    player.print("\nsurface = " .. player.surface.name)
    
    game.print("_________________________________________")
end