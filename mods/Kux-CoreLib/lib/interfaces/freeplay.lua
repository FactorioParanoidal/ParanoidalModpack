--- Wrapper for the "freeplay" remote interface.
---@class KuxCoreLib.FreeplayInterface
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field created_items table<string, uint> # Items the player starts with
---@field respawn_items table<string, uint> # Items the player receives on respawn
---@field skip_intro boolean                # Whether the intro sequence is skipped
---@field custom_intro_message string       # Message shown at game start
---@field chart_distance number             # Radius around start location to auto-reveal
---@field disable_crashsite boolean         # Whether crashsite is disabled
---@field init_ran boolean                  # Whether the scenario init has run
---@field ship_items table<string, uint>    # Items found in the crashed ship
---@field debris_items table<string, uint>  # Items found in the crash debris
---@field ship_parts table<string, MapPosition> # Positions of crashed ship parts
local Freeplay = {}

---Gets a value indicating whether the 'freeplay' remote interfaces is available.
Freeplay.isAvailable = remote.interfaces["freeplay"] ~= nil

---Gets the created items.
---@return table
function Freeplay:get_created_items()
	return remote.call("freeplay", "get_created_items")
end

---Sets the created items.
---@param items table
function Freeplay:set_created_items(items)
	remote.call("freeplay", "set_created_items", items)
end

---Gets the respawn items.
---@return table
function Freeplay:get_respawn_items()
	return remote.call("freeplay", "get_respawn_items")
end

---Sets the respawn items.
---@param items table
function Freeplay:set_respawn_items(items)
	remote.call("freeplay", "set_respawn_items", items)
end

---Sets whether to skip the intro.
---@param skip boolean
function Freeplay:set_skip_intro(skip)
	remote.call("freeplay", "set_skip_intro", skip)
end

---Gets whether the intro is set to be skipped.
---@return boolean
function Freeplay:get_skip_intro()
	return remote.call("freeplay", "get_skip_intro")
end

---Sets the custom intro message.
---@param message string
function Freeplay:set_custom_intro_message(message)
	remote.call("freeplay", "set_custom_intro_message", message)
end

---Gets the custom intro message.
---@return string
function Freeplay:get_custom_intro_message()
	return remote.call("freeplay", "get_custom_intro_message")
end

---Sets the chart distance.
---@param distance number
function Freeplay:set_chart_distance(distance)
	remote.call("freeplay", "set_chart_distance", distance)
end

--[[ MISSING
---Gets the chart distance.
---@return number
function Freeplay:get_chart_distance()
	return remote.call("freeplay", "get_chart_distance")
end
]]

---Sets whether the crash site is disabled.
---@param disable boolean
function Freeplay:set_disable_crashsite(disable)
	remote.call("freeplay", "set_disable_crashsite", disable)
end

---Gets whether the crash site is disabled.
---@return boolean
function Freeplay:get_disable_crashsite()
	return remote.call("freeplay", "get_disable_crashsite")
end

---Gets whether the initialization has run.
---@return boolean
function Freeplay:get_init_ran()
	return remote.call("freeplay", "get_init_ran")
end

---Gets the ship items.
---@return table
function Freeplay:get_ship_items()
	return remote.call("freeplay", "get_ship_items")
end

---Sets the ship items.
---@param items table
function Freeplay:set_ship_items(items)
	remote.call("freeplay", "set_ship_items", items)
end

---Gets the debris items.
---@return table
function Freeplay:get_debris_items()
	return remote.call("freeplay", "get_debris_items")
end

---Sets the debris items.
---@param items table
function Freeplay:set_debris_items(items)
	remote.call("freeplay", "set_debris_items", items)
end

---Gets the ship parts.
---@return table
function Freeplay:get_ship_parts()
	return remote.call("freeplay", "get_ship_parts")
end

---Sets the ship parts.
---@param parts table
function Freeplay:set_ship_parts(parts)
	remote.call("freeplay", "set_ship_parts", parts)
end

setmetatable(Freeplay, {
	__index = function(t, k)
		if remote.interfaces.freeplay["get_" .. k] then
			return remote.call("freeplay", "get_" .. k)
		end
		error("Attempt to access non-existant Member '"..k.."' in Freeplay interface.")
	end,
})

local p = setmetatable({}, {
	__index = Freeplay,
	__newindex = function(t, k, v)
		if remote.interfaces.freeplay["set_" .. k] then
			remote.call("freeplay", "set_" .. k, v)
			return
		end
		error("Attempt to write to protected object. Member '"..k.."' in Freeplay interface.")
	end,
})
return p --[[@as KuxCoreLib.FreeplayInterface]]

--[[2.0
---Wrapper for the remote interface "freeplay".
---Provides strongly-typed access to scripting functions exposed by the base scenario.
---@class freeplay_remote
local freeplay_remote = {}

---Returns the list of items given at creation.
---@return table<string, uint> @Dictionary of item names to counts
function freeplay_remote.get_created_items()
	return remote.call("freeplay", "get_created_items")
end

---Sets the list of items given at creation.
---@param v table<string, uint> @Dictionary of item names to counts
function freeplay_remote.set_created_items(v)
	remote.call("freeplay", "set_created_items", v)
end

---Returns the list of items given on respawn.
---@return table<string, uint> @Dictionary of item names to counts
function freeplay_remote.get_respawn_items()
	return remote.call("freeplay", "get_respawn_items")
end

---Sets the list of items given on respawn.
---@param v table<string, uint> @Dictionary of item names to counts
function freeplay_remote.set_respawn_items(v)
	remote.call("freeplay", "set_respawn_items", v)
end

---Skips the intro sequence when set to true.
---@param v boolean @True to skip intro, false to show it
function freeplay_remote.set_skip_intro(v)
	remote.call("freeplay", "set_skip_intro", v)
end

---Returns whether the intro sequence will be skipped.
---@return boolean
function freeplay_remote.get_skip_intro()
	return remote.call("freeplay", "get_skip_intro")
end

---Sets a custom message to be shown in the intro.
---@param v string @The custom message to display
function freeplay_remote.set_custom_intro_message(v)
	remote.call("freeplay", "set_custom_intro_message", v)
end

---Gets the currently configured custom intro message.
---@return string
function freeplay_remote.get_custom_intro_message()
	return remote.call("freeplay", "get_custom_intro_message")
end

---Sets the chart distance revealed at game start.
---@param v number @Distance in tiles
function freeplay_remote.set_chart_distance(v)
	remote.call("freeplay", "set_chart_distance", v)
end

---Returns whether the crashsite feature is disabled.
---@return boolean
function freeplay_remote.get_disable_crashsite()
	return remote.call("freeplay", "get_disable_crashsite")
end

---Sets whether to disable the crashsite visuals and items.
---@param v boolean @True to disable, false to enable
function freeplay_remote.set_disable_crashsite(v)
	remote.call("freeplay", "set_disable_crashsite", v)
end

---Returns whether the init script has already run.
---@return boolean
function freeplay_remote.get_init_ran()
	return remote.call("freeplay", "get_init_ran")
end

---Gets the items provided at the crashed ship location.
---@return table<string, uint> @Dictionary of item names to counts
function freeplay_remote.get_ship_items()
	return remote.call("freeplay", "get_ship_items")
end

---Sets the items to be provided at the crashed ship location.
---@param v table<string, uint> @Dictionary of item names to counts
function freeplay_remote.set_ship_items(v)
	remote.call("freeplay", "set_ship_items", v)
end

---Gets the debris items scattered near the crash site.
---@return table<string, uint> @Dictionary of item names to counts
function freeplay_remote.get_debris_items()
	return remote.call("freeplay", "get_debris_items")
end

---Sets the debris items to scatter near the crash site.
---@param v table<string, uint> @Dictionary of item names to counts
function freeplay_remote.set_debris_items(v)
	remote.call("freeplay", "set_debris_items", v)
end

---Gets the positions of ship parts to be spawned.
---@return table<string, MapPosition> @Dictionary of part names to positions
function freeplay_remote.get_ship_parts()
	return remote.call("freeplay", "get_ship_parts")
end

---Sets the positions of ship parts to be spawned.
---@param v table<string, MapPosition> @Dictionary of part names to positions
function freeplay_remote.set_ship_parts(v)
	remote.call("freeplay", "set_ship_parts", v)
end

return freeplay_remote

]]