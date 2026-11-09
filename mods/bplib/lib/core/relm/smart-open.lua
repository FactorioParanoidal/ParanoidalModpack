-- Smart `player.opened` handling

local event = require("lib.core.event")
local tlib = require("lib.core.table")

local lib = {}

---@class SmartOpenDummyTags
---@field opened [string,string][] List of {element name, on_object_destroyed registration number} pairs for currently opened GUIs
---@field reg_nums table<string, boolean> Set of on_object_destroyed registration numbers for currently opened GUIs, for quick lookup

---@param player LuaPlayer
local function dummy_create(player)
	local dummy = player.gui.screen.add({
		type = "empty-widget",
		name = "relm_smart_open_dummy",
	})
	dummy.tags = { opened = {}, reg_nums = {} }
	player.opened = dummy
	return dummy
end

---@param player LuaPlayer
---@return LuaGuiElement?
local function dummy_get(player)
	local dummy = player.gui.screen["relm_smart_open_dummy"]
	return dummy
end

---@param player LuaPlayer
local function dummy_destroy(player)
	local dummy = dummy_get(player)
	if player.opened == dummy then player.opened = nil end
	if dummy and dummy.valid then dummy.destroy() end
end

---@param player LuaPlayer
---@param elt LuaGuiElement
local function dummy_add_elt(player, elt)
	local dummy = dummy_get(player)
	if not dummy or not dummy.valid then dummy = dummy_create(player) end
	local reg_num = tostring(script.register_on_object_destroyed(elt))
	local tags = dummy.tags
	if tags.reg_nums[reg_num] then
		-- elt is already opened
		return
	end
	tags.opened[#tags.opened + 1] = { elt.name, reg_num }
	tags.reg_nums[reg_num] = true
	dummy.tags = tags
end

---@param player LuaPlayer
local function dummy_remove_elt(player, reg_num)
	local dummy = dummy_get(player)
	if not dummy or not dummy.valid then return end
	local tags = dummy.tags --[[@as SmartOpenDummyTags]]
	reg_num = tostring(reg_num)
	if not tags.reg_nums[reg_num] then return end
	tags.reg_nums[reg_num] = nil
	tlib.filter_in_place(
		tags.opened,
		function(entry) return entry[2] ~= reg_num end
	)
	dummy.tags = tags
	if #tags.opened == 0 then dummy_destroy(player) end
end

local function dummy_remove_elt_all(reg_num)
	for _, player in pairs(game.players) do
		dummy_remove_elt(player, reg_num)
	end
end

local function dummy_close_all(player)
	local dummy = dummy_get(player)
	if not dummy or not dummy.valid then return end
	local tags = dummy.tags --[[@as SmartOpenDummyTags]]
	for _, entry in pairs(tags.opened) do
		local elt = player.gui.screen[entry[1]]
		if elt and elt.valid then elt.destroy() end
	end
	dummy.tags = { opened = {}, reg_nums = {} }
end

event.bind(defines.events.on_gui_closed, function(ev)
	local player = game.get_player(ev.player_index)
	if not player then return end
	local opened = ev.element
	if not opened or not opened.valid then return end
	if opened.name ~= "relm_smart_open_dummy" then return end
	dummy_close_all(player)
	dummy_destroy(player)
end)

event.bind(
	defines.events.on_object_destroyed,
	function(ev) dummy_remove_elt_all(ev.registration_number) end
)

---@param player LuaPlayer
---@param new_elt LuaGuiElement
local function smart_replace_open_elt(player, new_elt)
	dummy_create(player)
	dummy_add_elt(player, new_elt)
end

---@param player LuaPlayer
---@param new_elt LuaGuiElement
local function smart_add_elt(player, new_elt)
	local dummy = dummy_get(player)
	if not dummy or not dummy.valid then return end
	dummy_add_elt(player, new_elt)
end

---Smart-open a GUI element for the given player using `player.opened`.
---If the player already has a smart-opened GUI opened, it will open alongside
---that one. If the player has
---a non-smart-opened GUI opened, it will optionally replace the existing one.
---@param player LuaPlayer
---@param elt LuaGuiElement
---@param replace boolean? Whether to replace an existing non-smart-opened GUI. Defaults to `false`.
function lib.smart_open(player, elt, replace)
	local opened_gui_type = player.opened_gui_type
	if not opened_gui_type then
		-- No gui opened, just open the new one and set up the dummy.
		smart_replace_open_elt(player, elt)
	elseif opened_gui_type == defines.gui_type.custom then
		local opened_elt = player.opened
		if (not opened_elt) or not opened_elt.valid then
			-- This case shouldn't happen, but if somehow nothing is open, just open the new element.
			return smart_replace_open_elt(player, elt)
		end
		if opened_elt.name == "relm_smart_open_dummy" then
			-- Already smart-opened; just add the new element to the storage.
			return smart_add_elt(player, elt)
		end
		if replace then
			-- Replace the existing non-smart-opened GUI with the new one
			return smart_replace_open_elt(player, elt)
		end
	else
		if replace then return smart_replace_open_elt(player, elt) end
	end
end

return lib
