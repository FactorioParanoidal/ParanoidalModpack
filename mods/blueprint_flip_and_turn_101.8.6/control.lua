
local modwarning = require "modwarning"

-- position and direction of the buttons
local blpflip_location = "top" -- top/left/center
local blpflip_flow_direction = "horizontal" -- horizontal/vertical

local flipdata = require "flip-data"
local fv,fh = assert(flipdata.fv), assert(flipdata.fh)

--------------------------------------------------------------------
-- a generic function to walk into structure to manage avoid error when it does not exists.
local walk = require "walk"
local safecall = require "safecall"
local get_user_setting = require "get_user_setting"

local function getBlueprintCursorStack(player)
	local cursor = player.cursor_stack
	if cursor == nil then
		return nil
	end

	if (
		cursor.valid and cursor.valid_for_read and
		(cursor.is_blueprint or cursor.is_blueprint_book) and
		safecall(cursor.is_blueprint_setup) -- 0.18 (>= 0.18.37 ?) can raise an error "Item is no blueprint", catch it to avoid game crash.
	) then --check if is a blueprint, work in book as well
		return cursor
	end
	return nil
end
--[[
	--old way setup -- OH my god Why???
	if cursor.valid_for_read and cursor.name == "blueprint" and cursor.is_blueprint_setup() then
		return cursor
	elseif cursor.valid_for_read and cursor.name == "blueprint-book" then
		local bookInv = cursor.get_inventory(defines.inventory.item_active)
		if (bookInv[1].valid_for_read and bookInv[1].name == "blueprint") then
			if bookInv[1].is_blueprint_setup() then
				return bookInv[1]
			end
		end
	end
]]--

local function flip_v(player_index)
	local player = game.players[player_index]
	local cursor = getBlueprintCursorStack(player)
	if cursor then
		if cursor.get_blueprint_entities() ~= nil then
			local ents = cursor.get_blueprint_entities()
			for i = 1, #ents do
				local ent = ents[i]
--				local dir = ent.direction or 0
				local handler = fv[ent.name] or fv["*"]
				handler(ent)
--game.print("DEBUG fv: "..tostring(i).."/"..tostring(#ents).." name="..tostring(ent.name).." dir="..dir.." ent.direction="..tostring(ent.direction).." handler="..(handler==fv["*"] and "default" or tostring(handler)) .. " ent is "..type(ent))
				ent.position.y = -ent.position.y
				if ent.drop_position then
					ent.drop_position.y = -ent.drop_position.y
				end
				if ent.pickup_position then
					ent.pickup_position.y = -ent.pickup_position.y
				end
			end
			cursor.set_blueprint_entities(ents)
		end
		-- also flip tiles if they exists in the blueprint
		if cursor.get_blueprint_tiles() ~= nil then
			local ents = cursor.get_blueprint_tiles()
			for i = 1, #ents do
				local ent = ents[i]
				local dir = ent.direction or 0
				ent.direction = (12 - dir)%8
				ent.position.y = -ent.position.y
			end
			cursor.set_blueprint_tiles(ents)
		end
	end
end

local function flip_h(player_index)
	local player = game.players[player_index]
	local cursor = getBlueprintCursorStack(player)
	if cursor then
		if cursor.get_blueprint_entities() ~= nil then
			local ents = cursor.get_blueprint_entities()
			for i = 1, #ents do
				local ent = ents[i]
--				local dir = ent.direction or 0
				local handler = fh[ent.name] or fh["*"]
				handler(ent)
--game.print("DEBUG fh: "..tostring(i).."/"..tostring(#ents).." name="..tostring(ent.name).." dir="..dir.." ent.direction="..tostring(ent.direction).." handler="..(handler==fh["*"] and "default" or tostring(handler)) )
				ent.position.x = -ent.position.x
				if ent.drop_position then
					ent.drop_position.x = -ent.drop_position.x
				end
				if ent.pickup_position then
					ent.pickup_position.x = -ent.pickup_position.x
				end
			end
			cursor.set_blueprint_entities(ents)
		end
		if cursor.get_blueprint_tiles() ~= nil then
			local ents = cursor.get_blueprint_tiles()
			for i = 1, #ents do
				local ent = ents[i]
				local dir = ent.direction or 0
				ent.direction = (16 - dir)%8
				ent.position.x = -ent.position.x
			end
			cursor.set_blueprint_tiles(ents)
		end
	end
end

local function reverse_inserters(player_index)
	local player = game.players[player_index]
	local cursor = getBlueprintCursorStack(player)
	if cursor then
		if cursor.get_blueprint_entities() ~= nil then
			local ents = cursor.get_blueprint_entities()
			for i = 1, #ents do
				local ent = ents[i]
				if ent.pickup_position and ent.drop_position then
					local old_drop_y = ent.drop_position.y
					local old_drop_x = ent.drop_position.x
					ent.drop_position.y = ent.pickup_position.y
					ent.drop_position.x = ent.pickup_position.x
					ent.pickup_position.y = old_drop_y
					ent.pickup_position.x = old_drop_x
				end
			end
			cursor.set_blueprint_entities(ents)
		end
	end
end

-- remove older mod stuff ? --
local function oldStrangeStuff(player_index)
	local gui_top = walk(game, {"players", player_index, "gui", "top"})
	if gui_top and gui_top.blueprint_flipper_flow  then
		gui_top.blueprint_flipper_flow.destroy()
	end
end

local function doButtons(player_index)
	local gui_location = walk(game, {"players", player_index, "gui", blpflip_location})
	if not gui_location then
		-- avoid error but there are something strange!
		modwarning("doButtons: there is no gui_location for player_index="..tostring(player_index)..". Please report it to the mod's Author.")
		return
	end
	local exists = walk(gui_location, {"blpflip_flow"})
	if not exists then
		local flow = gui_location.add{type = "flow", name = "blpflip_flow", direction = blpflip_flow_direction}
		flow.add{type = "button", name = "blueprint_flip_horizontal", style = "blpflip_button_horizontal"}
		flow.add{type = "button", name = "blueprint_flip_vertical", style = "blpflip_button_vertical"}
--		flow.add{type = "button", name = "blueprint_reverse_inserters", style = "blpflip_button_reverse_inserters"}
	end
	oldStrangeStuff(player_index)
end

-- hide buttons = remove them --
local function rmButtons(player_index)
	local exists = walk(game, {"players", player_index, "gui", blpflip_location, "blpflip_flow"})
	if exists then
		exists.destroy()
	end
end


-- create or hide buttons (per user) --
local function manageButtons(player_index)
	-- avoid strange case where player_index is nil
	if not player_index then return end

	-- get the user setting --
	local show_buttons = get_user_setting(player_index, "blueprint_flip_and_turn_show_buttons")
	-- it should be true or false (not nil)
	--if show_buttons == nil then show_buttons = true end

	if show_buttons then
		--game.print("DEBUG: show_buttons yes (doButtons)")
		doButtons(player_index)
	else
		--game.print("DEBUG: show_buttons nope (rmButtons)")
		rmButtons(player_index)
	end
end

-- button click -> action --
script.on_event(defines.events.on_gui_click,function(event)
	if event.element.name == "blueprint_flip_horizontal" then
		flip_h(event.player_index)
	elseif event.element.name == "blueprint_flip_vertical" then
		flip_v(event.player_index)
	elseif event.element.name == "blueprint_reverse_inserters" then
		reverse_inserters(event.player_index)
	end
end)

local function manageButtonsAllPlayers()
	for player_index=1,#game.players do manageButtons(player_index) end
end
-- create buttons --
script.on_event(defines.events.on_player_created,function(event)
	--game.print("DEBUG: EVENT on_player_created")
	manageButtons(event.player_index)
end)
-- compat-check: defines.events.on_player_created  0.16/0.17 ok

script.on_configuration_changed(function(data)
	--game.print("DEBUG: EVENT on_configuration_changed")
	manageButtonsAllPlayers()
end)
-- compat-check: script.on_configuration_changed 0.16/0.17 ok

script.on_init(function()
	--game.print("DEBUG: EVENT on_init")
	manageButtonsAllPlayers()
	--for i=1,#game.players do manageButtons(i) end
end)
-- compat-check: script.on_init 0.16/0.17 ok

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	-- player_index: the player index
	-- setting: the setting name (string)
	-- setting_type: "runtime-per-user", or "runtime-global"
	local setting, setting_type = event.setting, event.setting_type
	if setting_type=="runtime-per-user" and setting=="blueprint_flip_and_turn_show_buttons" then
		--game.print("DEBUG: EVENT on_runtime_mod_setting_changed "..tostring(setting).." "..tostring(setting_type))
		manageButtons(event.player_index)
	end
end)
-- compat-check: defines.events.on_runtime_mod_setting_changed 0.16/0.17 ok

-- actions by shortcut --
script.on_event("blueprint_hotkey_flip_horizontal", function(event) flip_h(event.player_index) end)
script.on_event("blueprint_hotkey_flip_vertical", function(event) flip_v(event.player_index) end)
--pcall(function()
--script.on_event("blueprint_hotkey_reverse_inserters", function(event) reverse_inserters(event.player_index) end)
--end)
