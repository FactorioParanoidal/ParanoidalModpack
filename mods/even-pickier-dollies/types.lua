---@meta
----------------------------------------------------------------------------------------------------
--- class definitions
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--- prototypes
----------------------------------------------------------------------------------------------------

---@class epd.ModData
---@field blacklist_names table<string, boolean>

----------------------------------------------------------------------------------------------------
--- constants.lua
----------------------------------------------------------------------------------------------------

---@class epd.TransporterControl
---@field control_fields string[]?
---@field control_objects string[]?
---@field fields string[]?
---@field filters boolean?

----------------------------------------------------------------------------------------------------
--- interface.lua
----------------------------------------------------------------------------------------------------

---@class EvenPickierDolliesRemoteInterfaceDollyMovedEvent: EventData
---@field player_index uint
---@field moved_entity LuaEntity
---@field start_pos MapPosition
---@field start_direction defines.direction
---@field start_unit_number integer?

---@class EvenPickierDolliesRemoteInterface
---@field dolly_moved_entity_id fun(): uint
---@field add_oblong_name fun(entity_name: string): boolean
---@field remove_oblong_name fun(entity_name: string): boolean
---@field get_oblong_names fun(): {[string]: true}
---@field add_blacklist_name fun(entity_name: string): boolean
---@field remove_blacklist_name fun(entity_name: string): boolean
---@field get_blacklist_names fun(): {[string]: true}

----------------------------------------------------------------------------------------------------
--- control.lua
----------------------------------------------------------------------------------------------------

---@class EvenPickierDolliesStorage
---@field players {[uint]: EvenPickierDolliesPlayerData}
---@field blacklist_names {[string]: true}
---@field oblong_names {[string]: true}

---@class EvenPickierDolliesPlayerData
---@field dolly_tick uint
---@field dolly LuaEntity?

---@class EvenPickierDolliesMoveEvent
---@field player LuaPlayer
---@field pdata EvenPickierDolliesPlayerData
---@field tick integer,
---@field entity LuaEntity
---@field save_time uint,
---@field direction defines.direction?
---@field rotate defines.direction?
---@field distance number
