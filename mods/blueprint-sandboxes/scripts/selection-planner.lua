-- Custom Planners to set some special Tiles
local SelectionPlanner = {}

SelectionPlanner.name = BPSB.pfx .. "selection-planner"
SelectionPlanner.pfx = BPSB.pfx .. "sp-"
local pfxLength = string.len(SelectionPlanner.pfx)

SelectionPlanner.forTiles = SelectionPlanner.pfx .. "tile"
SelectionPlanner.forEntities = SelectionPlanner.pfx .. "entity"

--- @class ThingWithQuality
--- @field name string
--- @field quality string | nil

-- Whether the Thing is a Selection Planner
---@param name string
---@return boolean
function SelectionPlanner.IsSelectionPlanner(name)
    return string.sub(name, 1, pfxLength) == SelectionPlanner.pfx
end

---@param player LuaPlayer
---@param guiElementName string
---@return ThingWithQuality | nil
local function GetSelectedPrototypeNameAndQuality(player, guiElementName)
    local selector = ToggleGUI.FindByName(player, guiElementName)
    if selector == nil or selector.type ~= "choose-elem-button" then return end
    local selected = selector.elem_value
    if selected == nil then return end
    if type(selected) == "string" then return { name = selected} end
    if type(selected) == "table" then return { name = selected.name, quality = selected.quality } end
    return nil
end

-- Set Tiles in a certain area to checkerboard lab tiles
---@param surface LuaSurface
---@param area BoundingBox
local function SetLabTilesInArea(surface, area)
    surface.destroy_decoratives({ area = area })
    surface.build_checkerboard(area)
end

-- Set all Tiles in a certain area
---@param surface LuaSurface
---@param area BoundingBox
---@param name string
local function SetTilesInArea(surface, area, name)
    if name == "lab-dark-1" or name == "lab-dark-2" then
        SetLabTilesInArea(surface, area)
        return
    end
    local tiles = {} --[[@as (Tile)[] ]]
    for x = math.floor(area.left_top.x), math.floor(area.right_bottom.x) do
        for y = math.floor(area.left_top.y), math.floor(area.right_bottom.y) do
            table.insert(tiles, { name = name, position = { x, y }})
        end
    end
    surface.destroy_decoratives({ area = area })
    surface.set_tiles(tiles, true, true, true, true)
end

-- Determine how many entities to spawn at each point
---@param prototype LuaEntityPrototype
---@param dense boolean
---@return number
local function GetEntityDensity(prototype, dense)
    local density = 1
    if prototype.type == "resource" then
        local multiplier = 1
        if dense then multiplier = 2 end
        density = multiplier * math.max(
            5000,
            (prototype.autoplace_specification and prototype.autoplace_specification.placement_density) or 0,
            prototype.minimum_resource_amount or 0,
            prototype.normal_resource_amount or 0
        )
        local max_richness = 0
        for _, planet in pairs(game.planets) do
            if planet.prototype.map_gen_settings then
                local autoplace_controls = planet.prototype.map_gen_settings.autoplace_controls
                if autoplace_controls and autoplace_controls[prototype.name] then
                    max_richness = math.max(max_richness, autoplace_controls[prototype.name].richness)
                end
            end
        end
        for _, surface in pairs(game.surfaces) do
            if surface.map_gen_settings then
                local autoplace_controls = surface.map_gen_settings.autoplace_controls
                if autoplace_controls and autoplace_controls[prototype.name] then
                    max_richness = math.max(max_richness, autoplace_controls[prototype.name].richness)
                end
            end
        end
        if max_richness <= 0 then max_richness = 1 end
        density = density * max_richness
    end
    return math.max(1, density)
end

-- Determine how often to spawn entities
---@param prototype LuaEntityPrototype
---@param dense boolean
---@return MapPosition
local function GetEntitySpacing(prototype, dense)
    local box = prototype.map_generator_bounding_box
    local spacing = 1.5
    if prototype.type == "resource" then spacing = 1 end
    if dense then spacing = 1 end
    return {
        x = spacing * math.max(1, math.ceil(box.right_bottom.x - box.left_top.x)),
        y = spacing * math.max(1, math.ceil(box.right_bottom.y - box.left_top.y)),
    }
end

-- Add a large amount of Entities in a certain area
---@param surface LuaSurface
---@param area BoundingBox
---@param thing ThingWithQuality
---@param dense boolean
local function AddEntitiesInArea(surface, area, thing, dense)
    local prototype = prototypes.entity[thing.name]
    if not prototype then return end
    local density = GetEntityDensity(prototype, dense)
    local spacing = GetEntitySpacing(prototype, dense)
    for x = area.left_top.x, area.right_bottom.x, spacing.x do
        for y = area.left_top.y, area.right_bottom.y, spacing.y do
            surface.create_entity({
                name = thing.name,
                position = { x = x, y = y },
                amount = density,
                quality = thing.quality,
                raise_built = true,
            })
        end
    end
end

-- Remove all Entities of a certain type in a certain area
---@param surface LuaSurface
---@param area BoundingBox
---@param name string
---@param more boolean
local function RemoveEntitiesInArea(surface, area, name, more)
    local prototype = prototypes.entity[name]
    if not prototype then return end
    surface.destroy_decoratives({ area = area })
    local filters = { area = area }
    if not more then filters["name"] = name end
    local entities = surface.find_entities_filtered(filters)
    for _, entity in pairs(entities) do
        entity.destroy({ raise_destroy = true })
    end
end

-- Create a Selection Planner for a specific Player
---@param element LuaGuiElement
---@param player LuaPlayer
local function GiveSelectionPlannerToPlayer(element, player)
    if element.type ~= "choose-elem-button" then return false end
    if element.elem_value == nil then return false end
    player.clear_cursor()
    if element.elem_type == "tile" then
        return player.cursor_stack.set_stack({ name = SelectionPlanner.forTiles })
    elseif element.elem_type == "entity" or element.elem_type == "entity-with-quality" then
        return player.cursor_stack.set_stack({ name = SelectionPlanner.forEntities })
    end
end

-- Create a Selection Planner when something is chosen from the GUI
---@param event EventData.on_gui_elem_changed
function SelectionPlanner.OnPrototypeSelected(event)
    local element = event.element
    local player = game.players[event.player_index]
    if element.valid and (element.name == ToggleGUI.entitySelectionPlannerGenerator
        or element.name == ToggleGUI.tileSelectionPlannerGenerator)
    then
        return GiveSelectionPlannerToPlayer(element, player)
    end
end

-- Create a Selection Planner when middle-clicking the element
---@param event EventData.on_gui_click
function SelectionPlanner.OnGuiClick(event)
    local element = event.element
    local player = game.players[event.player_index]
    if element.valid and (element.name == ToggleGUI.entitySelectionPlannerGenerator
        or element.name == ToggleGUI.tileSelectionPlannerGenerator)
    then
        return GiveSelectionPlannerToPlayer(element, player)
    end
end

-- Determine what the planner was meant to do, then do it
---@param event EventData.on_player_selected_area | EventData.on_player_alt_selected_area | EventData.on_player_reverse_selected_area | EventData.on_player_alt_reverse_selected_area
function SelectionPlanner.OnAreaSelected(event)
    if not SelectionPlanner.IsSelectionPlanner(event.item) then return false end
    if not Sandbox.IsSandbox(event.surface) then return false end
    local player = game.players[event.player_index]
    local alt = event.name == defines.events.on_player_alt_selected_area or event.name == defines.events.on_player_alt_reverse_selected_area
    local reverse = event.name == defines.events.on_player_reverse_selected_area or event.name == defines.events.on_player_alt_reverse_selected_area
    if event.item == SelectionPlanner.forTiles then
        if reverse then
            SetLabTilesInArea(event.surface, event.area)
        else
            local selection = GetSelectedPrototypeNameAndQuality(player, ToggleGUI.tileSelectionPlannerGenerator)
            if not selection then return false end
            SetTilesInArea(event.surface, event.area, selection.name)
        end
        return true
    elseif event.item == SelectionPlanner.forEntities then
        local selection = GetSelectedPrototypeNameAndQuality(player, ToggleGUI.entitySelectionPlannerGenerator)
        if not selection then return false end
        if reverse then
            RemoveEntitiesInArea(event.surface, event.area, selection.name, alt)
        else
            AddEntitiesInArea(event.surface, event.area, selection, alt)
        end
        return true
    end
end

return SelectionPlanner
