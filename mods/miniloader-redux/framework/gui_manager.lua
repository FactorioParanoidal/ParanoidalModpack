------------------------------------------------------------------------
-- Manage GUIs and GUI state -- loosely inspired by flib
------------------------------------------------------------------------
assert(script)

local Event = require('stdlib.event.event')
local Player = require('stdlib.event.player')
local table = require('stdlib.utils.table')

require('stdlib.utils.string')

local FrameworkGui = require('framework.gui')

local GUI_UPDATE_TICK_INTERVAL = 11

------------------------------------------------------------------------
-- types
------------------------------------------------------------------------

--- A handler function to invoke when receiving GUI events for this element.
---@alias framework.gui.element_handler fun(e: framework.gui.event_data, gui: framework.gui)
---@alias framework.gui.custominput_handler fun(e: framework.gui.custominput_data, gui: framework.gui)
---@alias framework.gui.update_callback fun(gui: framework.gui): boolean
---@alias framework.gui.context table<string, any?>
---@alias framework.gui_events table<string, string>
---@alias framework.custominput_events table<defines.events, string>

--- Aggregate type of all possible GUI events.
---@alias framework.gui.event_data EventData.on_gui_checked_state_changed|EventData.on_gui_click|EventData.on_gui_closed|EventData.on_gui_confirmed|EventData.on_gui_elem_changed|EventData.on_gui_location_changed|EventData.on_gui_opened|EventData.on_gui_selected_tab_changed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_text_changed|EventData.on_gui_value_changed

---@class framework.gui_manager.create_gui
---@field player_index integer      Player Index
---@field type string GUI type
---@field parent LuaGuiElement      Parent to associate with
---@field ui_tree_provider fun(context: framework.gui): framework.gui.element_definitions?
---@field existing_elements table<string, LuaGuiElement>? Optional set of existing GUI elements.
---@field context framework.gui.context? Context element
---@field entity_id integer? The entity for which a gui is created
---@field retain_open_guis boolean? If true, retain the existing windows. If false or missing, close all open windows for that player

--- Externalize the functions called for events; they can not be serialized so they can not be stored in storage
---@class framework.gui_manager.event_definition
---@field events table<string, framework.gui.element_handler>? Map of all known events and the functions to call
---@field custominput_events table<defines.events, table<string, framework.gui.custominput_handler>>? Map of all known custom input events
---@field callback framework.gui.update_callback? Optional update callback that is executed when the GUI is open
---@field cleanup framework.gui.update_callback? Optional cleanup callback that is executed when the GUI is closed

--- Per player state for the currently fired custom-input event
---@class framework.gui_manager.custominput_event
---@field input_name string
---@field tick uint32
---@field element LuaGuiElement?

---@alias framework.guis table<string, framework.gui> gui Type to actual gui element

---@class framework.gui_manager.player_state
---@field custominput_event framework.gui_manager.custominput_event -- last custom input event registered
---@field guis framework.guis All registered and known guis for this manager.

---@class framework.gui_manager
---@field GUI_PREFIX string The prefix for all registered handlers and other global information.
---@field known_gui_types table<string, framework.gui_manager.event_definition>
local FrameworkGuiManager = {
    GUI_PREFIX = Framework.PREFIX .. 'gui-',
    known_gui_types = {},
}

------------------------------------------------------------------------
--
------------------------------------------------------------------------

---@param player_index integer
---@return framework.gui_manager.player_state state Manages GUI state
function FrameworkGuiManager:playerState(player_index)
    local state = Framework.runtime:player_storage(assert(player_index))

    ---@type framework.gui_manager.player_state
    state.gui_manager = state.gui_manager or {
        custominput_event = {},
        guis = {},
    }

    return state.gui_manager
end

------------------------------------------------------------------------

--- find a custominput event (usually toggle or confirm hotkey for GUI)
---@param event framework.gui.event_data
---@param gui framework.gui
---@return string? handler_id
---@return framework.gui.custominput_handler? input_handler
function FrameworkGuiManager:determineCustominputHandlerId(event, gui)
    -- find the event mapping for the GUI
    local gui_definition = assert(self.known_gui_types[gui.type])

    if not (gui_definition.custominput_events and gui_definition.custominput_events[event.name]) then return nil end

    local state = Framework.gui_manager:playerState(event.player_index)
    local custominput_event = assert(state.custominput_event)
    -- is it a stale event?
    if custominput_event.tick ~= game.tick then return end

    -- only look at events intended for this gui
    if custominput_event.element and custominput_event.element.tags['__GUI_TYPE'] ~= gui.type then return end

    -- find a handler and return it
    local input_handler = gui_definition.custominput_events[event.name][custominput_event.input_name]
    if not input_handler then return end

    return custominput_event.input_name, input_handler
end

--- Execute a gui event handler
---@param handler_id string
---@param event framework.gui.event_data
---@param gui framework.gui
---@return boolean handled True if an event handler was called, False otherwise.
function FrameworkGuiManager:executeGuiHandler(handler_id, event, gui)
    -- find the event mapping for the GUI
    local gui_definition = assert(self.known_gui_types[gui.type])
    local event_handler = gui_definition.events[handler_id]
    if not event_handler then return false end
    event_handler(event, gui)
    return true
end

---@param event framework.gui.event_data
---@param gui framework.gui
---@return string? handler_id
function FrameworkGuiManager:determineGuiHandlerId(event, gui)
    local event_handler_map = assert(gui.event_handlers[event.name])

    ---@type LuaGuiElement
    local elem = event.element
    assert(elem and elem.valid)
    return event_handler_map[elem.name]
end

--- Dispatch an event to a registered gui.
---@param event framework.gui.event_data
---@return boolean handled True if an event handler was called, False otherwise.
function FrameworkGuiManager:dispatch(event)
    if not event then return false end

    ---@type LuaGuiElement
    local elem = event.element
    if not (elem and elem.valid) then return false end

    local player_index = event.player_index

    -- find the GUI for the player
    local gui_type = elem.tags['__GUI_TYPE']
    if not gui_type then return false end

    local gui = self:findGui(player_index, gui_type)
    if not gui then return false end

    -- check if it is a custom input event
    local handler_id, input_handler = self:determineCustominputHandlerId(event, gui)
    if handler_id and input_handler then
        ---@type framework.gui.custominput_data
        local data = {
            input_name = handler_id,
            player_index = event.player_index,
            tick = game.tick
        }
        input_handler(data, gui)
        return true
    else
        -- dispatch the event to the gui handlers
        handler_id = self:determineGuiHandlerId(event, gui)
        if handler_id then
            -- per-element registered handler
            return self:executeGuiHandler(handler_id, event, gui)
        elseif type(elem.tags.handler) == 'table' then
            -- tag defined handler table.
            -- use per-element registered handler
            -- tostring is a workaround for https://forums.factorio.com/viewtopic.php?t=130401
            handler_id = elem.tags.handler[event.name] or elem.tags.handler[tostring(event.name)]
            if handler_id then
                return self:executeGuiHandler(handler_id, event, gui)
            end
        end
    end

    return false
end

------------------------------------------------------------------------

--- Finds all guis for a player.
---@param player_index integer
---@return framework.guis framework_guis
function FrameworkGuiManager:findAllGuis(player_index)
    assert(player_index)

    local state = self:playerState(player_index)
    return assert(state.guis)
end

--- Finds a gui based on player index and gui_type
---@param player_index integer
---@param gui_type string?
---@return framework.gui[] framework_guis
function FrameworkGuiManager:findGuis(player_index, gui_type)
    assert(player_index)

    local state = self:playerState(player_index)
    local result = {}
    for gui_name, gui in pairs(state.guis) do
        if gui_type then
            if gui_name == gui_type then
                table.insert(result, gui)
            end
        else
            table.insert(result, gui)
        end
    end

    return result
end

--- Finds a single gui for a player.
---@param player_index integer
---@param gui_type string
---@return framework.gui? framework_gui
function FrameworkGuiManager:findGui(player_index, gui_type)
    assert(player_index)

    local state = self:playerState(player_index)
    return state.guis[gui_type]
end

---@param player_index integer The player to add the GUI for.
---@param gui framework.gui   The Framework GUI definition.
function FrameworkGuiManager:addGui(player_index, gui)
    assert(player_index)
    assert(gui)

    local state = self:playerState(player_index)
    assert(not state.guis[gui.type])
    state.guis[gui.type] = gui
end

---@param player_index integer
---@return framework.guis
function FrameworkGuiManager:clearAllGuis(player_index)
    assert(player_index)
    local state = self:playerState(player_index)

    -- don't use util.copy; that does a deep copy
    local result = {}
    for gui_type, gui in pairs(state.guis) do
        result[gui_type] = gui
    end

    state.guis = {}

    return result
end

--- Closes either a single or all player GUIs.
---@param player_index integer
---@param gui_type string?
---@return (framework.gui)[]
function FrameworkGuiManager:clearGuis(player_index, gui_type)
    assert(player_index)
    local state = self:playerState(player_index)
    local result = {}
    for g_type, gui in pairs(state.guis) do
        if not gui_type or g_type == gui_type then
            table.insert(result, gui)
            state.guis[g_type] = nil
        end
    end

    return result
end

------------------------------------------------------------------------

--- Registers a GUI type with the event table and callback with the GUI manager.
---@param gui_type string
---@param event_definition framework.gui_manager.event_definition
function FrameworkGuiManager:registerGuiType(gui_type, event_definition)
    assert(gui_type)
    assert(not self.known_gui_types[gui_type])

    event_definition.events = event_definition.events or {}
    event_definition.custominput_events = event_definition.custominput_events or {}

    self.known_gui_types[gui_type] = event_definition
end

--- Creates a new GUI instance.
---@param map framework.gui_manager.create_gui
---@return framework.gui A framework gui instance
function FrameworkGuiManager:createGui(map)
    assert(map)

    assert(map.type)
    assert(map.player_index)
    local player_index = map.player_index

    local gui_type = self.known_gui_types[map.type]

    assert(gui_type, 'No Gui definition for "' .. map.type .. '" registered!')

    -- must be set
    assert(map.parent)

    ---@type framework.gui
    local gui = FrameworkGui.create {
        type = map.type,
        prefix = self.GUI_PREFIX .. map.type .. '-',
        gui_events = table.array_to_dictionary(table.keys(gui_type.events)),
        custominput_events = table.array_to_dictionary(table.keys(gui_type.custominput_events)),
        entity_id = map.entity_id,
        player_index = map.player_index,
        context = map.context or {},
    }

    local ui_tree = map.ui_tree_provider(gui)
    -- do not change to table_size, '#' returning 0 is the whole point of the check...
    assert(not ui_tree or (type(ui_tree) == 'table' and #ui_tree == 0), 'The UI tree must have a single root!')

    if map.retain_open_guis then
        -- only close the window we just opened
        self:destroyGui(player_index, map.type)
    else
        -- close all player GUIs
        self:destroyGuiByPlayer(player_index)
    end

    gui.root = gui:addChildElements(map.parent, ui_tree, map.existing_elements)

    self:addGui(player_index, gui)

    self.guiUpdateTick()

    return gui
end

------------------------------------------------------------------------

--- Close all GUIs that refer to this entity.
---@param entity_id integer?
function FrameworkGuiManager:destroyGuiByEntityId(entity_id)
    if not entity_id then return end

    local destroy_list = {}
    for _, player in pairs(game.players) do
        for _, gui in pairs(self:findAllGuis(player.index)) do
            if gui and gui.entity_id == entity_id then
                table.insert(destroy_list, gui)
            end
        end
    end

    for _, gui in pairs(destroy_list) do
        self:destroyGui(gui.player_index, gui.type)
    end
end

--- Find all GUIs that match this entity id
---@param entity_id integer?
---@return framework.gui[]
function FrameworkGuiManager:findGuisByEntityId(entity_id)
    local result = {}

    if not entity_id then return result end

    for _, player in pairs(game.players) do
        for _, gui in pairs(self:findAllGuis(player.index)) do
            if gui and gui.entity_id == entity_id then
                table.insert(result, gui)
            end
        end
    end

    return result
end

------------------------------------------------------------------------

--- Destroys a GUI instance.
---@param player_index integer? player information for the GUI
---@param gui_type string The GUI type
function FrameworkGuiManager:destroyGui(player_index, gui_type)
    if not (player_index and gui_type) then return end

    local gui = self:findGui(player_index, gui_type)
    if not gui then return end

    local gui_events = assert(FrameworkGuiManager.known_gui_types[gui.type])
    if gui_events.cleanup then gui_events.cleanup(gui) end

    if gui.root then gui.root.destroy() end

    self:clearGuis(player_index, gui_type)
end

--- Destroys all player Guis.
---@param player_index integer? player information for the GUI
function FrameworkGuiManager:destroyGuiByPlayer(player_index)
    if not player_index then return end

    for _, gui in pairs(self:findAllGuis(player_index)) do
        local gui_events = assert(FrameworkGuiManager.known_gui_types[gui.type])
        if gui_events.cleanup then gui_events.cleanup(gui) end
        if gui.root then gui.root.destroy() end
        self:clearGuis(player_index, gui.type)
    end
end

------------------------------------------------------------------------
-- Manage custom input events
------------------------------------------------------------------------

---@param player_index integer
---@param event EventData.CustomInputEvent|framework.gui_manager.custominput_event
function FrameworkGuiManager:createCustominput(player_index, event)
    assert(player_index)
    assert(event)

    local state = self:playerState(player_index)

    local custominput_event = state.custominput_event
    custominput_event.input_name = event.input_name
    custominput_event.tick = event.tick
    custominput_event.element = event.element
end

--------------------------------------------------------------------------------
-- Custom input actions
--------------------------------------------------------------------------------

---@param event EventData.CustomInputEvent
local function onCustomInputEvent(event)
    Framework.gui_manager:createCustominput(event.player_index, event)
end

------------------------------------------------------------------------
-- Update ticker
------------------------------------------------------------------------

function FrameworkGuiManager.guiUpdateTick()
    local player_ids = Player.known_players()
    local destroy_list = {}

    for _, player_id in pairs(player_ids) do
        local guis = FrameworkGuiManager:findAllGuis(player_id)
        for _, gui in pairs(guis) do
            local gui_events = assert(FrameworkGuiManager.known_gui_types[gui.type])
            if gui_events.callback then
                if not gui_events.callback(gui) then
                    table.insert(destroy_list, gui)
                end
            end
        end
    end

    if table_size(destroy_list) == 0 then return end

    for _, gui in pairs(destroy_list) do
        Framework.gui_manager:destroyGui(gui.player_index, gui.type)
    end
end

--------------------------------------------------------------------------------
-- event registration
--------------------------------------------------------------------------------

local function register_events()
    -- register all gui events with the framework
    for name, id in pairs(defines.events) do
        if name:starts_with('on_gui_') then
            Event.on_event(id, function(ev)
                Framework.gui_manager:dispatch(ev --[[@as framework.gui.event_data]])
            end)
        end
    end

    -- register all hotkey events for this mod from the framework
    for name in pairs(prototypes.custom_input) do
        if name:starts_with(Framework.PREFIX) then
            Event.on_event(name, onCustomInputEvent)
        end
    end

    Event.on_nth_tick(GUI_UPDATE_TICK_INTERVAL, FrameworkGuiManager.guiUpdateTick)
end

local function on_load()
    register_events()
end

local function on_init()
    register_events()
end

Event.on_init(on_init)
Event.on_load(on_load)

return FrameworkGuiManager
