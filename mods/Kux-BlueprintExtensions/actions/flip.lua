local Util = require('modules/util')
local actions = require('modules/actions')
local mod_gui = require("mod-gui")
local FluidPermutation = require("modules/FluidPermutation")
local Table = KuxCoreLib.Table

local N = defines.direction.north
local E = defines.direction.east
local S = defines.direction.south
local W = defines.direction.west

local numWays = isV1 and 8 or 16
local function turn90(direction) return isV1 and (direction + 2)%8 or (direction + 4)%16 end
local function turn180(direction) return isV1 and (direction + 4)%8 or (direction + 8)%16 end
local function turn270(direction) return isV1 and (direction + 6)%8 or (direction + 12)%16 end
local function isNorS(direction) return isV1 and direction % 4 == 0 or direction % 8 == 0 end
local function isEorW(direction) return isV1 and direction % 4 == 2 or direction % 8 == 4 end

---@class Translation
---@field axis string
---@field rail_offset number
---@field default_offset number
---@field signals table<number, number>
---@field train_stops table<number, number>

---@class Translations
---@field v Translation
---@field h Translation

---@class Flip
local Flip = {
	---@type Translations
    translations = {
		---@type Translation
		v = {
			axis = 'y',
			rail_offset = isV1 and 13 or 26,
			default_offset = isV1 and 12 or 24,
			signals = {
				[1] = isV1 and 7 or 14,
				[2] = isV1 and 6 or 12,
				[3] = isV1 and 5 or 10,
				[5] = isV1 and 3 or 6,
				[6] = isV1 and 2 or 4,
				[7] = isV1 and 1 or 2
			},
			train_stops = {
				[2] = isV1 and 6 or 12,
				[6] = isV1 and 2 or 4
			},
		},
		h = {
			axis = 'x',
			rail_offset = isV1 and 9 or 18,
			default_offset = isV1 and 16 or 32,
			signals = {
				[0] = isV1 and 4 or 8,
				[1] = isV1 and 3 or 6,
				[3] = isV1 and 1 or 2,
				[4] = isV1 and 0 or 0,
				[5] = isV1 and 7 or 14,
				[7] = isV1 and 5 or 10
			},
			train_stops = {
				[0] = isV1 and 4 or 8,
				[4] = isV1 and 1 or 2
			},
		},
	},
	---@type table<"left"|"right", string>
    sides = {
        left = 'right',
        right = 'left'
    },
}

local railNames = Table.toFlagsDictionary{"curved-rail", "curved-rail-a", "curved-rail-b","half-diagonal-rail","elevated-curved-rail", "elevated-curved-rail-a", "elevated-curved-rail-b","elevated-half-diagonal-rail","legacy-curved-rail"}

--function Flip.setup_gui(player)
--    local show = (player.mod_settings["BlueprintExtensions_show-buttons"].value)
--    local flow = mod_gui.get_button_flow(player)
--
--    if show and not flow.BPEX_Flip_H then
--        local button
--        button = flow.add {
--            name = "BPEX_Flip_H",
--            type = "sprite-button",
--            style = mod_gui.button_style,
--            sprite = "BPEX_Flip_H",
--            tooltip = { "controls.BlueprintExtensions_flip-h" }
--        }
--        button.visible = true
--        print(serpent.block(button))
--        button = flow.add {
--            name = "BPEX_Flip_V",
--            type = "sprite-button",
--            style = mod_gui.button_style,
--            sprite = "BPEX_Flip_V",
--            tooltip = { "controls.BlueprintExtensions_flip-v" }
--        }
--        button.visible = true
--    elseif not show then
--        if flow.BPEX_Flip_H then flow.BPEX_Flip_H.destroy() end
--        if flow.BPEX_Flip_V then flow.BPEX_Flip_V.destroy() end
--    end
--    --
--    --    local top = player.gui.top
--    --
--    --    if show and not top["BPEX_Flow"] then
--    --        local flow = top.add{type = "flow", name = "BPEX_Flow", direction = 'horizontal'}
--    --        flow.add{type = "button", name = "BPEX_Flip_H", style = "BPEX_Button_H"}
--    --        flow.add{type = "button", name = "BPEX_Flip_V", style = "BPEX_Button_V"}
--    --    elseif not show and top["BPEX_Flow"] then
--    --        top["BPEX_Flow"].destroy()
--    --    end
--end


--function Flip.check_for_other_mods()
----    if game.active_mods["PickerExtended"] then
----        game.print("[Blueprint Extensions] Picker Extended is installed.  Disabling our version of blueprint flipping.")
----        Flip.enabled = false
--    if game.active_mods["Blueprint_Flip_Turn"] then
--        game.print("[Blueprint Extensions] Blueprint Flipper and Turner is installed.  Disabling our version of blueprint flipping.")
--        if game.active_mods["GDIW"] then
--            game.print("Blueprint Extensions includes some improved functionality when flipping blueprints, such as correctly flipping splitter priorities and taking advantage of GDIW recipes.  To enable this functionality, disable Blueprint Flipper and Turner.")
--        else
--            game.print("Blueprint Extensions includes some improved functionality when flipping blueprints, such as correctly flipping splitter priorities.  To enable this functionality, disable Blueprint Flipper and Turner.")
--        end
--        Flip.enabled = false
--    else
--        Flip.enabled = true
--    end
--end
--
--[[ GDIW reversals:
Unmodified: BR or IR or OR
IR: OR or none
OR: IR or none
BR: unmodified
 ]]

local function getRecipePrototypeOrNil(recipe)
    return (prototypes.recipe[recipe]) and recipe or nil
end

local function flipPosition(position, axis)
	local idx = (#position == 2) and ((axis == "x") and 1 or 2) or axis
	position[idx] = -position[idx]
end

---@param player LuaPlayer
---@param event table
---@param action Action
function Flip.flip_action(player, event, action)
	print("Flip.flip_action "..action.data)
    local translate = Flip.translations[action.data] --[[@as Translation]]
    local bp = Util.get_blueprint(player); if not bp then return end
    local prototype, name, direction
	local axis = translate.axis; print("  axis: "..tostring(axis))
	local support_gdiw = player.mod_settings["Kux-BlueprintExtensions_support-gdiw"].value
	local support_fluid_permutations = player.mod_settings["Kux-BlueprintExtensions_support-fluid_permutations"].value and FluidPermutation.isAvailable

    local entities = bp.get_blueprint_entities()
	print(serpent.block(entities))
    if entities then
        for _,entity in pairs(entities) do ---@cast entity BlueprintEntity|table
            prototype = prototypes.entity[entity.name]
            name = (prototype and prototype.type) or entity.name
            direction = entity.direction or 0
			local numWays = isV1 and 8 or 16
			local axisEquDirection = (axis == 'x' and (direction % (numWays / 2) == 0 or direction % (numWays / 2) == (numWays / 4)))
                      or (axis == 'y' and (direction % (numWays / 2) == (numWays / 8) or direction % (numWays / 2) == (3 * numWays / 8)))
			print("  "..entity.name.." "..(entity.direction or 0).." "..(entity.recipe or "no recipe").." axis: "..axis .." match direction: "..tostring(axisEquDirection))
            if entity.name:match("duct%-t%-junction") then
                -- Fluid Must Flow / storage-tank -
                if isNorS(direction) and axis == 'y' then
					entity.direction = turn180(direction)
                elseif isEorW(direction) and axis == 'x' then
                    entity.direction = turn180(direction)
                end
            elseif railNames[name] then
                entity.direction = (translate.rail_offset - direction)%numWays --[[@as defines.direction]]
            elseif name == "storage-tank" then
				entity.direction = isEorW(direction) and S or E --[[@as defines.direction]]
            elseif name == "rail-signal" or name == "rail-chain-signal" then
                if translate.signals[direction] ~= nil then
                    entity.direction = translate.signals[direction]
                end
            elseif name == "train-stop" then
                if translate.train_stops[direction] ~= nil then
                    entity.direction = translate.train_stops[direction]
                end
            else
                entity.direction = (translate.default_offset - direction)%numWays --[[@as defines.direction]]
            end

            entity.position[axis] = -entity.position[axis]
            if entity.drop_position ~= nil then
				flipPosition(entity.drop_position, axis)
            end
            if entity.pickup_position ~= nil then
				flipPosition(entity.pickup_position, axis)
            end

            if Flip.sides[entity.input_priority] then
                entity.input_priority = Flip.sides[entity.input_priority]
            end
            if Flip.sides[entity.output_priority] then
                entity.output_priority = Flip.sides[entity.output_priority]
			end
		-- Nullius
            if entity.name:match("^nullius%-") then
                -- Nullius support
                local mirrorName;
                if entity.name:match("^nullius%-mirror%-") then
                    mirrorName = "nullius-"..entity.name:sub(16, -1)
                else
                    mirrorName = "nullius-mirror-"..entity.name:sub(9, -1)
                    if prototypes.entity[mirrorName] == nil then
                        player.print("Mirror not available for ".. entity.name)
                        mirrorName = entity.name -- do not mirror
                    end
                end
                entity.name = mirrorName
                if entity.name:match("flotation%-cell%-[23]") then
                    -- FIX for nullius-mirror-flotation-cell-2/3
                    entity.direction = turn270(direction)
                end
		--Advanced fluid handling
			elseif(entity.name:match("%-overflow%-valve") or entity.name:match("%-top%-up%-valve") or entity.name=="check-valve") then
				if     (direction==N or direction==W) and axis == "y" then
					entity.direction = turn90(entity.direction)
				elseif (direction==E or direction==S) and axis == "y" then
					entity.direction = turn270(entity.direction)
				elseif (direction==N or direction==W) and axis == "x" then
					entity.direction = turn270(entity.direction)
				elseif (direction==E or direction==S) and axis == "x" then
					entity.direction = turn90(entity.direction)
				end
			elseif entity.name:match("underground%-L%-.-pipe") then
				entity.direction = turn90(entity.direction)
			elseif entity.name:match("^one%-to%-.-left.-%-pipe$") and (axis == 'y') ~= axisEquDirection then
                entity.name = entity.name:gsub("left", "right")
			elseif entity.name:match("^one%-to%-.-right.-%-pipe$") and (axis == 'y') ~= axisEquDirection then
                entity.name = entity.name:gsub("right", "left")
			elseif entity.name:match("^one%-to%-.-L%-RR.-%-pipe$") and (axis == 'y') ~= axisEquDirection then
                entity.name = entity.name:gsub("L%-RR", "L-RL")
			elseif entity.name:match("^one%-to%-.-L%-RL.-%-pipe$") and (axis == 'y') ~= axisEquDirection then
                entity.name = entity.name:gsub("L%-RL", "L-RR")
			elseif entity.name:match("^one%-to%-.-forward.-%-pipe$") and (axis == 'y') == axisEquDirection then
                entity.name = entity.name:gsub("forward", "reverse")
			elseif entity.name:match("^one%-to%-.-reverse.-%-pipe$") and (axis == 'y') == axisEquDirection then
                entity.name = entity.name:gsub("reverse", "forward")
			elseif entity.name:match("^one%-to%-.-perdicular.-%-pipe$") and (axis == 'y') == axisEquDirection then
                entity.name = entity.name:gsub("perdicular", "parallel-secondary")
			elseif entity.name:match("^one%-to%-.-parallel5-secondary.-%-pipe$") and (axis == 'y') == axisEquDirection then
                entity.name = entity.name:gsub("parallel%-secondary", "perdicular")

		-- Flow control + Space Exploration-Flow Control Bridge, Flow Control for Bob's Logistics
			elseif(entity.name=="pipe-junction" or entity.name=="space-pipe-t-junction" or entity.name:match("^pipe%-.-junction$")) then
				if     (direction==N or direction==W) and axis == "y" then
					entity.direction = turn90(entity.direction)
				elseif (direction==E or direction==S) and axis == "y" then
					entity.direction = turn270(entity.direction)
				elseif (direction==N or direction==W) and axis == "x" then
					entity.direction = turn270(entity.direction)
				elseif (direction==E or direction==S) and axis == "x" then
					entity.direction = turn90(entity.direction)
				end
			elseif(entity.name=="pipe-elbow" or entity.name=="space-pipe-elbow" or entity.name:match("^pipe%-.-elbow$")) then
				if(axis == "y" and (direction==N or direction==W)) then
					entity.direction = turn180(entity.direction)
				elseif(axis == "x" and (direction==E or direction==S)) then
					entity.direction = turn180(entity.direction)
				end
			elseif(entity.name=="pipe-straight" or (entity.name=="space-pipe-straight") or entity.name:match("^pipe%-.-straight$")) then
				entity.direction = (entity.direction + 2)%8
			elseif(entity.name=="overflow-valve" or entity.name=="top%-up%-valve"
				or (entity.name=="flowbob-check-valve" or entity.name=="flowbob-overflow-valve" or entity.name=="flowbob-topup-valve-1" or entity.name=="flowbob-topup-valve-2")) then
				if     (direction==N or direction==W) and axis == "y" then
					entity.direction = turn90(entity.direction)
				elseif (direction==E or direction==S) and axis == "y" then
					entity.direction = turn270(entity.direction)
				elseif (direction==N or direction==W) and axis == "x" then
					entity.direction = turn270(entity.direction)
				elseif (direction==E or direction==S) and axis == "x" then
					entity.direction = turn90(entity.direction)
				end
		-- recipe flipping
            elseif entity.recipe then
                if support_fluid_permutations then
					-- support fluid_permutations
					local result = FluidPermutation.flipRecipe(entity.recipe)
					if result and prototypes.recipe[result] then entity.recipe = result end
				elseif support_gdiw then
					-- Support GDIW
					local t
					local _, _, recipe, mod = string.find(entity.recipe, "^(.*)%-GDIW%-([BIO])R$")
					if mod == 'B' then      -- Both mirrored
						entity.recipe = recipe
					elseif mod == 'I' then  -- Input mirrored
						entity.recipe = getRecipePrototypeOrNil(recipe .. '-GDIW-OR') or recipe
					elseif mod == 'O' then  -- Output mirrored
						entity.recipe = getRecipePrototypeOrNil(recipe .. '-GDIW-IR') or recipe
					else  -- Neither mirrored
						recipe = entity.recipe
						entity.recipe = (
							   getRecipePrototypeOrNil(recipe .. '-GDIW-BR')
							or getRecipePrototypeOrNil(recipe .. '-GDIW-IR')
							or getRecipePrototypeOrNil(recipe .. '-GDIW-OR')
							or recipe
						)
					end
				end
			end
        end
        if bp.valid_for_write then bp.set_blueprint_entities(entities)
		else return end --TODO create a new blueprint
    end

    local tiles = bp.get_blueprint_tiles()
    if tiles then
        for _,tile in pairs(tiles) do
            --tile.direction = (translate.default_offset- (tile.direction or 0))%8
            tile.position[axis] = -tile.position[axis]
        end
        if bp.valid_for_write then bp.set_blueprint_tiles(tiles)
		else return end --TODO create a new blueprint
    end
end

actions['Kux-BlueprintExtensions_flip-h'].handler = Flip.flip_action
actions['Kux-BlueprintExtensions_flip-v'].handler = Flip.flip_action

--
--script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
--    Flip.check_for_other_mods()
--
--    if game.active_mods["Blueprint_Flip_Turn"] then return end
--
--    if event.setting_type == "runtime-per-user" and event.setting == "BlueprintExtensions_show-buttons" then
--        return Flip.setup_gui(game.players[event.player_index])
--    end
--end
--)
--
--script.on_event("BlueprintExtensions_flip-h", function(event) return Flip.flip(event.player_index, Flip.translations.h) end)
--script.on_event("BlueprintExtensions_flip-v", function(event) return Flip.flip(event.player_index, Flip.translations.v) end)
--script.on_event(defines.events.on_gui_click, function(event)
--    if event.element.name == "BPEX_Flip_H" then
--        return Flip.flip(event.player_index, Flip.translations.h)
--    elseif event.element.name == "BPEX_Flip_V" then
--        return Flip.flip(event.player_index, Flip.translations.v)
--    end
--end)
--
--

return Flip
