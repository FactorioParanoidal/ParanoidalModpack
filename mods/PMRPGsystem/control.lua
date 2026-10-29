-- PMRPGsystem 9.0.5 is a migration bridge. The RPG system and the base journal moved to the mod
-- paranoidal-CodexRPG. Factorio keeps the storage of a mod under the mod's own name, so on old saves the
-- experience, levels, skills and statistics stay here; paranoidal-CodexRPG takes them over once, when it
-- is added to the save. This mod adds no gameplay, prototypes or settings.

-- GUI elements that PMRPGsystem 9.0.4 and earlier created: GUI root -> element names.
local OLD_GUI = {
	screen = {"char-panel", "rpg-stats-passport"},
	center = {"char-panel"},
	top = {"chartopframe", "btcharxp"},
	left = {"rpg-list"},
}

local function destroy_own(parent, name)
	local element = parent and parent.valid and parent[name]
	if element and element.valid and element.get_mod() == script.mod_name then element.destroy() end
end

-- Removes the windows and buttons of the old version for every player, also offline ones.
local function remove_gui()
	for _, player in pairs(game.players) do
		local gui = player.gui
		for root, names in pairs(OLD_GUI) do
			for _, name in ipairs(names) do destroy_own(gui[root], name) end
		end
		-- the RPG button in the shared top panel (both layouts of core/lualib/mod-gui.lua)
		local frame = gui.top.mod_gui_top_frame
		destroy_own(frame and frame.mod_gui_inner_frame, "btcharxp")
		destroy_own(gui.top.mod_gui_button_flow, "btcharxp")
	end
end

-- Everything the old version kept in this save, without transient fields; nil when there is nothing.
local function get_storage()
	if type(storage.personalxp) ~= "table" then return nil end
	local copy = {}
	for key, value in pairs(storage) do
		if key ~= "last_overkill" then copy[key] = value end
	end
	local stats = copy.rpg_stats
	if type(stats) == "table" then
		local trimmed = {}
		for key, value in pairs(stats) do
			if key ~= "job" and key ~= "queue" then trimmed[key] = value end
		end
		copy.rpg_stats = trimmed
	end
	return copy
end

remote.add_interface("PMRPGsystemMigration", {
	get_storage = get_storage,
	remove_gui = remove_gui,
})

script.on_configuration_changed(remove_gui)
