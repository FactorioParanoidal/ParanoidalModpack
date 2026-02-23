------------------------------------------------------------------------
-- Manage GUIs and GUI state -- loosely inspired by flib
------------------------------------------------------------------------
assert(script)

local Event = require('stdlib.event.event')
local Is = require('stdlib.utils.is')
local table = require('stdlib.utils.table')

require('stdlib.utils.string')

local FrameworkGui = require('framework.gui')

local GUI_UPDATE_TICK_INTERVAL = 11

------------------------------------------------------------------------
-- types
------------------------------------------------------------------------

--- A handler function to invoke when receiving GUI events for this element.
---@alias framework.gui.element_handler fun(e: framework.gui.event_data, gui: framework.gui)
---@alias framework.gui.update_callback fun(gui: framework.gui): boolean
---@alias framework.gui.context table<string, any?>
---@alias framework.gui_events table<string, string>

--- Aggregate type of all possible GUI events.
---@alias framework.gui.event_data EventData.on_gui_checked_state_changed|EventData.on_gui_click|EventData.on_gui_closed|EventData.on_gui_confirmed|EventData.on_gui_elem_changed|EventData.on_gui_location_changed|EventData.on_gui_opened|EventData.on_gui_selected_tab_changed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_text_changed|EventData.on_gui_value_changed

---@class framework.gui_manager.create_gui
---@field player_index number
---@field type string GUI type
---@field parent LuaGuiElement
---@field ui_tree_provider fun(context: framework.gui): framework.gui.element_definitions
---@field existing_elements table<string, LuaGuiElement>? Optional set of existing GUI elements.
---@field context framework.gui.context? Context element
---@field entity_id number? The entity for which a gui is created

---@class framework.gui_manager.event_definition
---@field events table<string, framework.gui.element_handler>
---@field callback framework.gui.update_callback?

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

---@return framework.gui_manager.state state Manages GUI state
function FrameworkGuiManager:state()
    local state = Framework.runtime:storage()

    ---@class framework.gui_manager.state
    ---@field guis table<number, framework.gui> All registered and known guis for this manager.
    state.gui_manager = state.gui_manager or {
        guis = {},
    }

    return state.gui_manager
end

------------------------------------------------------------------------

--- Dispatch an event to a registered gui.
---@param event framework.gui.event_data
---@return boolean handled True if an event handler was called, False otherwise.
function FrameworkGuiManager:dispatch(event)
    if not event then return false end

    ---@type LuaGuiElement
    local elem = event.element
    if not Is.Valid(elem) then return false end

    -- find the GUI for the player
    local player_index = event.player_index
    local gui = self:find_gui(player_index)
    if not gui then return false end

    -- find the event mapping for the GUI
    local gui_type = self.known_gui_types[gui.type]
    assert(gui_type)

    local event_handler_map = gui.event_handlers[event.name]
    assert(event_handler_map)

    local handler_id = event_handler_map[elem.name]
    if handler_id then
        -- per-element registered handler
        local event_handler = gui_type.events[handler_id]
        if not event_handler then return false end
        event_handler(event, gui)
        return true
    elseif type(elem.tags.handler) == 'table' then
        -- tag defined handler table.
        -- use per-element registered handler
        -- workaround for https://forums.factorio.com/viewtopic.php?t=130401
        handler_id = elem.tags.handler[event.name] or elem.tags.handler[tostring(event.name)]
        local event_handler = gui_type.events[handler_id]
        if not event_handler then return false end
        event_handler(event, gui)
        return true
    end
    return false
end

------------------------------------------------------------------------

--- Finds a gui.
---@param player_index number
---@return framework.gui? framework_gui
function FrameworkGuiManager:find_gui(player_index)
    local state = self:state()
    return state.guis[player_index]
end

---@param player_index number
---@parameter gui framework.gui
function FrameworkGuiManager:set_gui(player_index, gui)
    assert(gui)
    local state = self:state()
    state.guis[player_index] = gui
end

---@param player_index number
---@return framework.gui?
function FrameworkGuiManager:clear_gui(player_index)
    local state = self:state()
    local root = state.guis[player_index]
    state.guis[player_index] = nil

    return root
end

---@return table<number, framework.gui>
function FrameworkGuiManager:all_guis()
    local state = self:state()
    return state.guis
end

------------------------------------------------------------------------

--- Registers a GUI type with the event table and callback with the GUI manager.
---@param gui_type string
---@param event_definition framework.gui_manager.event_definition
function FrameworkGuiManager:register_gui_type(gui_type, event_definition)
    assert(gui_type)
    assert(event_definition.events, 'events is unset!')

    self.known_gui_types[gui_type] = event_definition
end

--- Creates a new GUI instance.
---@param map framework.gui_manager.create_gui
---@return framework.gui A framework gui instance
function FrameworkGuiManager:create_gui(map)
    assert(map)

    assert(map.type)
    local type = map.type

    assert(map.player_index)
    local player_index = map.player_index

    local gui_type = self.known_gui_types[type]

    assert(gui_type, 'No Gui definition for "' .. map.type .. '" registered!')

    -- must be set
    assert(map.parent)

    local gui = FrameworkGui.create {
        type = type,
        prefix = self.GUI_PREFIX,
        gui_events = table.array_to_dictionary(table.keys(gui_type.events)),
        entity_id = map.entity_id,
        player_index = map.player_index,
        context = map.context or {},
    }

    local ui_tree = map.ui_tree_provider(gui)
    -- do not change to table_size, '#' returning 0 is the whole point of the check...
    assert(Is.Table(ui_tree) and #ui_tree == 0, 'The UI tree must have a single root!')


    self:destroy_gui(player_index)
    local root = gui:add_child_elements(map.parent, ui_tree, map.existing_elements)
    gui.root = root

    self:set_gui(player_index, gui)

    self.gui_update_tick()

    return gui
end

------------------------------------------------------------------------

---@param entity_id integer?
function FrameworkGuiManager:destroy_gui_by_entity_id(entity_id)
    if not entity_id then return end

    local destroy_list = {}
    for _, player in pairs(game.players) do
        local gui = self:find_gui(player.index)
        if gui and gui.entity_id == entity_id then
            table.insert(destroy_list, player.index)
        end
    end

    for _, player_index in pairs(destroy_list) do
        self:destroy_gui(player_index)
    end
end

------------------------------------------------------------------------

--- Destroys a GUI instance.
---@param player_index number? The gui to destroy
function FrameworkGuiManager:destroy_gui(player_index)
    if not player_index then return end

    local gui = self:find_gui(player_index)
    if not gui then return end

    if gui.root then gui.root.destroy() end

    self:clear_gui(player_index)
end

------------------------------------------------------------------------
-- Update ticker
------------------------------------------------------------------------

function FrameworkGuiManager.gui_update_tick()
    local guis = FrameworkGuiManager:all_guis()
    if table_size(guis) == 0 then return end

    local destroy_list = {}
    for gui_id, gui in pairs(guis) do
        local gui_type = FrameworkGuiManager.known_gui_types[gui.type]
        assert(gui_type)
        if gui_type.callback then
            if not gui_type.callback(gui) then
                destroy_list[gui_id] = gui
            end
        end
    end

    if table_size(destroy_list) == 0 then return end

    for gui_id in pairs(destroy_list) do
        Framework.gui_manager:destroy_gui(gui_id)
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
                Framework.gui_manager:dispatch(ev)
            end)
        end
    end

    Event.on_nth_tick(GUI_UPDATE_TICK_INTERVAL, FrameworkGuiManager.gui_update_tick)
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
