--[[
    "name": "BlueprintExtensions",
    "title": "Blueprint Extensions",
    "author": "Dewin",
    "contact": "https://github.com/dewiniaid/BlueprintExtensions",
    "homepage": "https://github.com/dewiniaid/BlueprintExensions",
    "description": "Adds tools for updating and placing blueprints."
--]]
local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')
local Inventory = require('__stdlib__/stdlib/entity/inventory')
local lib = require('__PickerAtheneum__/utils/lib')

local evt = defines.events

local CLONED_BLUEPRINT = 'picker-bp-updater'
local VERSION_PATTERN = '(v[.]?)(%d)$' -- Matches version number at end of blueprints.
local DEFAULT_VERSION = ' v.2'

local AWAITING_GUI = 1
local AWAITING_BP = 2

local Updater = {}

local function increment_version(v, n)
    return v .. (n + 1)
end

local function get_or_create_buffer(player, pdata)
    if not (pdata.buffer_inventory and pdata.buffer_inventory.valid) then
        pdata.buffer_inventory = lib.create_buffer_corpse(player, true).get_inventory(defines.inventory.character_corpse)
    end
    return pdata.buffer_inventory
end

local function load_stack(pdata)
    if pdata.stored_bp and pdata.stored_bp.valid_for_read then
        return pdata.stored_bp
    end
end

local function save_stack(player, pdata, stack)
    local inv = get_or_create_buffer(player, pdata)
    pdata.stored_bp = inv[1]
    pdata.stored_bp.set_stack(stack)
end

-- Capabilities related to updating blueprints.
function Updater.clone(event)
    local player, pdata = Player.get(event.player_index)
    local bp = Inventory.get_blueprint(player.cursor_stack, true)
    if bp then
        local updater = {
            name = bp.name,
            label = bp.label,
            icons = bp.blueprint_icons,
            status = nil
        }
        -- Create replacer tool, drop orignal back into inventory
        if player.clean_cursor() then
            pdata.updater = updater
            player.cursor_stack.set_stack(CLONED_BLUEPRINT)
            if updater.label then
                player.cursor_stack.label = updater.label
            end
        end -- Warning about not being able to clean?
    end
end

function Updater.on_selected_area(event)
    if event.item == CLONED_BLUEPRINT then
        local alt = (event.name == defines.events.on_player_alt_selected_area)

        local player, pdata = Player.get(event.player_index)
        local cursor = player.cursor_stack

        -- Handle blueprint replacer.
        if pdata.updater then
            local area = event.area
            cursor.set_stack(pdata.updater.name)
            cursor.create_blueprint {
                surface = player.surface,
                force = player.force,
                always_include_tiles = true,
                area = area
            }

            if not cursor.is_blueprint_setup() then
                -- Empty blueprint area?
                return cursor.set_stack(CLONED_BLUEPRINT)
            end

            local label = pdata.updater.label or 'v.1'
            if label then
                cursor.blueprint_icons = pdata.updater.icons

                local versioning = player.mod_settings[alt and 'picker-bp-updater-alt-version-increment' or 'picker-bp-updater-version-increment'].value
                if versioning ~= 'off' then
                    local found
                    label, found = label:gsub(VERSION_PATTERN, increment_version)
                    if found == 0 and versioning == 'on' then
                        label = label .. DEFAULT_VERSION
                    end
                end
                cursor.label = label
            end

            -- Move this blueprint to a temporary item
            local stack = player.cursor_stack
            stack.set_stack(save_stack(player, pdata.updater, stack)) -- returns nil, effectivly calling clear()
            pdata.updater.status = AWAITING_GUI
            player.opened = load_stack(pdata.updater)
        else
            cursor.clear()
        end
    end
end

function Updater.on_gui_opened(event)
    -- If opening an item, this means our target blueprint was closed at some point and that any
    -- on_player_configured_blueprint events we see are nonsense.
    if event.gui_type == defines.gui_type.item then
        local _, pdata = Player.get(event.player_index)
        if pdata.updater then
            pdata.updater.status = pdata.updater.status == AWAITING_GUI and AWAITING_BP or nil
        end
    end
end

function Updater.on_player_configured_blueprint(event)
    local player, pdata = Player.get(event.player_index)
    if pdata.updater and pdata.updater.status == AWAITING_BP then
        if not player.clean_cursor() then
            -- rarest of rare edge cases
            player.print({'blueprint-updater.error_cannot_set_stack', {'item-name.'..pdata.updater.name}})
            local ground = player.surface.create_entity{name = 'item-on-ground', position = player.position, stack = {name = pdata.updater.name, amount = 1}}
            ground.stack.set_stack(load_stack(pdata))
        else
            player.cursor_stack.set_stack(load_stack(pdata.updater))
        end
    end
    pdata.updater = nil -- Nuke this.
end

if settings.startup['picker-tool-bp-updater'].value then
    Event.register({evt.on_player_selected_area, evt.on_player_alt_selected_area}, Updater.on_selected_area)
    Event.register('picker-bp-update', Updater.clone)
    Event.register(evt.on_gui_opened, Updater.on_gui_opened)
    Event.register(evt.on_player_configured_blueprint, Updater.on_player_configured_blueprint)
end

return Updater
