--[[
    "name": "auto-stock",
    "title": "Auto Stock",
    "author": "canidae",
    "contact": "canidae@exent.net",
    "homepage": "http://exent.net",
    "description": "Automatically stock player with configured items in the in-game auto trash feature when you have less than the specified amount."
--]]

local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')

local TECH = 'auto-character-logistic-trash-slots'

local function check_filters(event)
    local player, pdata = Player.get(event.player_index)
    if player.character and player.force.technologies[TECH].researched and not game.active_mods['AutoTrash'] and player.mod_settings['picker-auto-stock'].value then
        local atf = player.auto_trash_filters
        if atf then
            -- add any temporarily ignored auto trash rules
            pdata.auto_stock = pdata.auto_stock or {}

            local config = pdata.auto_stock
            if config.ignored then
                for item, count in pairs(config.ignored) do
                    atf[item] = count
                end
                config.ignored = nil
            end
            local slots = player.character.request_slot_count
            -- create table of existing requests
            local logistics = {}
            for slot = 1, slots do
                local item = player.character.get_request_slot(slot)
                if item ~= nil then
                    logistics[item.name] = item.count
                end
            end
            -- compare with auto trash settings and modify logistics table as needed
            for item, count in pairs(atf) do
                if logistics[item] and logistics[item] ~= count and (not config.previous or not config.previous[item] or config.previous[item] == count) then
                    -- user setup custom logistics request and user haven't changed auto trash for item, temporarily remove auto trash setting
                    if not config.ignored then
                        config.ignored = {}
                    end
                    config.ignored[item] = count
                    atf[item] = nil
                else
                    if player.get_item_count(item) < count then
                        -- missing items in inventory, request more
                        logistics[item] = count
                    else
                        -- have enough of item in inventory, remove any request for such items
                        logistics[item] = nil
                    end
                end
                if config.previous then
                    config.previous[item] = nil
                end
            end
            -- check if player removed any auto trash filter
            if config.previous then
                for item  in pairs(config.previous) do
                    logistics[item] = nil
                end
            end
            -- setup new auto trash
            player.auto_trash_filters = atf
            -- remember old auto trash settings so we can detect when player changes anything
            config.previous = atf
            -- setup new requests
            local slot = 1
            for item, count in pairs(logistics) do
                if slot > slots then
                    break
                end
                if count > 0 then
                    player.character.set_request_slot({name = item, count = count}, slot)
                    slot = slot + 1
                end
            end
            -- clear remaining request slots
            for i = slot, slots do
                player.character.clear_request_slot(i)
            end
        end
    end
end
Event.register(defines.events.on_player_main_inventory_changed, check_filters)
