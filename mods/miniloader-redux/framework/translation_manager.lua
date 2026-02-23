------------------------------------------------------------------------
-- Manage translations
------------------------------------------------------------------------
assert(script)

local Event = require('stdlib.event.event')
local Player = require('stdlib.event.player')

---@class framework.translation.Manager
local FrameworkTranslationManager = {
    DEFAULT_REQUEST_SIZE = 5,
}

---@alias framework.translation.key string

---@class framework.translation.player_state
---@field queue table<framework.translation.key, framework.translation.key>
---@field active_ids table<integer, boolean>
---@field dictionary table<string, string>

------------------------------------------------------------------------
-- internal management
------------------------------------------------------------------------

--- Initialize the per-player state for translations
---@return framework.translation.player_state
local function init()
    return {
        -- translations queued
        queue = {},
        -- currently active translation ids
        active_ids = {},
        -- dictionary
        dictionary = {},
    }
end

--- Trigger processing the translation queue.
---@param player LuaPlayer
local function trigger_translation(player)
    local player_data = assert(Player.pdata(player.index))
    player_data.translation = player_data.translation or init()
    ---@type framework.translation.player_state
    local translation = player_data.translation

    local active_size = table_size(translation.active_ids)

    if active_size < FrameworkTranslationManager.DEFAULT_REQUEST_SIZE then
        local queue_size = table_size(translation.queue)
        if queue_size == 0 then return end

        local req_size = FrameworkTranslationManager.DEFAULT_REQUEST_SIZE - active_size
        local req = {}

        for _, key in pairs(translation.queue) do
            if req_size <= 0 then break end
            table.insert(req, { key })
            req_size = req_size - 1
        end

        assert(table_size(req) <= FrameworkTranslationManager.DEFAULT_REQUEST_SIZE)

        if #req then
            local ids = assert(player.request_translations(req))
            for _, id in pairs(ids) do
                translation.active_ids[id] = true
            end
        end
    end
end

--- Trigger retranslation for a given player. This might happen if the player changes their locale.
---@param player LuaPlayer
local function retranslate(player)
    local player_data = assert(Player.pdata(player.index))
    player_data.translation = player_data.translation or init()
    ---@type framework.translation.player_state
    local translation = player_data.translation

    local keys = {}
    for key in pairs(translation.dictionary) do
        table.insert(keys, key)
    end

    translation.active_ids = {}
    translation.dictionary = {}

    FrameworkTranslationManager:registerTranslation(player, keys)
end

---@param player LuaPlayer
local function reset_active(player)
    local player_data = assert(Player.pdata(player.index))
    player_data.translation = player_data.translation or init()
    ---@type framework.translation.player_state
    local translation = player_data.translation

    -- invalidate all operations in flight, they need to be retriggered
    translation.active_ids = {}

    trigger_translation(player)
end

---@param event EventData.on_string_translated
local function process_translation(event)
    local player_data = assert(Player.pdata(event.player_index))
    if not player_data.translation then return end

    ---@type framework.translation.player_state
    local translation = player_data.translation

    if translation.active_ids[event.id] then
        local key = assert(event.localised_string[1]) --[[@as string]]
        -- received a translation
        translation.dictionary[key] = event.translated and event.result or key
        translation.queue[key] = nil
        translation.active_ids[event.id] = nil
    end

    if table_size(translation.active_ids) == 0 then
        local player = Player.get(event.player_index)
        if not player then return end
        trigger_translation(player)
    end
end

------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------

--- Register a number of string keys for translation. The keys must be present
--- in the locale files.
---@param player LuaPlayer
---@param keys framework.translation.key|framework.translation.key[]
function FrameworkTranslationManager:registerTranslation(player, keys)
    local player_data = assert(Player.pdata(player.index))
    player_data.translation = player_data.translation or init()
    ---@type framework.translation.player_state
    local translation = player_data.translation

    if type(keys) ~= 'table' then
        keys = { keys }
    end

    for _, key in pairs(keys) do
        if not translation.dictionary[key] then
            translation.queue[key] = key
        end
    end

    trigger_translation(player)
end

--- Translate a specific string key for a given player. As multiple players can play with different locales,
--- each player has their own dictionary. This is inefficient for huge multiplayer setups (there only one dictionary per
--- language would be better). I will fix this if it becomes a problem for players.
---@param player LuaPlayer
---@param key string
---@return string? result
function FrameworkTranslationManager:translate(player, key)
    local player_data = assert(Player.pdata(player.index))
    ---@type framework.translation.player_state
    local translation = assert(player_data.translation)

    return translation.dictionary[key]
end

------------------------------------------------------------------------
-- Event handlers
------------------------------------------------------------------------

---@params event EventData.on_player_joined
local function on_player_joined(event)
    local player = Player.get(event.player_index)
    if not player then return end

    reset_active(player)
end

---@params event EventData.on_singleplayer_init
local function on_singleplayer_init()
    for _, player in pairs(game.players) do
        reset_active(player)
    end
end

---@params event EventData.on_player_locale_changed
local function on_player_locale_changed(event)
    local player = Player.get(event.player_index)
    if not player then return end

    retranslate(player)
end

---@param event EventData.on_string_translated
local function on_string_translated(event)
    process_translation(event)
end

--------------------------------------------------------------------------------
-- event registration and management
--------------------------------------------------------------------------------

local function register_events()
    Event.register(defines.events.on_singleplayer_init, on_singleplayer_init)
    Event.register(defines.events.on_player_joined_game, on_player_joined)
    Event.register(defines.events.on_player_locale_changed, on_player_locale_changed)
    Event.register(defines.events.on_string_translated, on_string_translated)
end

local function on_init()
    register_events()
end

local function on_load()
    register_events()
end

Event.on_init(on_init)
Event.on_load(on_load)

return FrameworkTranslationManager
