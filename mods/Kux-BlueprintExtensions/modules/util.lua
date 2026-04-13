-- Library functions and defines

local Util = {}

--- @class Updater
--- @field name string
--- @field label string
--- @field icons table
--- @field status any

--- @class PlayerData
--- @field updater Updater
--TODO define

---Wrapper for LuaItemStack or LuaRecord
---@class BlueprintItem : LuaItemStack, LuaRecord
---@field record LuaRecord? The LuaRecord if that is one, else nil
---@field itemStack LuaItemStack? The LuaItemStack if that is one, else nil
---@field valid_for_write boolean
---@field item LuaItem?
---@field export_stack fun():string

---@Class BlueprintItemClass
---@overload fun(obj: LuaItemStack|LuaRecord):BlueprintItem
local BlueprintItem = {
	__class="BlueprintItemClass"
}

---@param self BlueprintItem
local function export_stack(self)
	if self.itemStack then return self.itemStack.export_stack() end
	if self.record then return Util.export_record(self.record) end
	return nil
end

---@diagnostic disable-next-line: param-type-mismatch
setmetatable(BlueprintItem, {

	---Returns a new instance of BlueprintItem
	---@param self any
	---@param obj LuaItemStack|LuaRecord
	---@return BlueprintItem
	__call = function(self, obj)
		local newObj = {} --@type BlueprintItem
		newObj.__base = obj
		newObj.record = obj.object_name=="LuaRecord" and obj or false
		newObj.itemStack  = obj.object_name=="LuaItemStack" and obj or false
		newObj.valid_for_write = (newObj.itemStack and true) or (newObj.record and newObj.record.valid_for_write) or false
		newObj.item = (newObj.itemStack and newObj.item and newObj.item) or false
		newObj.export_stack = function() return export_stack(newObj) end
		setmetatable(newObj,{
			__index = obj,
			__newindex = obj
		})
		return setmetatable({}, {
			__index = function (t, key)
				if key=="record"    then return newObj.record and newObj.record or nil end
				if key=="itemStack" then return newObj.itemStack and newObj.itemStack or nil end
				if key=="item"      then return newObj.item and newObj.item or nil end
				return newObj[key] or obj[key]
			end,
			__newindex=function () error("Invalid oparation") end,
		})
	end,
	__index=function () error("Invalid oparation") end,
	__newindex=function () error("Invalid oparation") end,
	__metatable = false
}
)

--[[
--- Returns the item if it is a blueprint, the selected blueprint in the book if it is a blueprint book, or nil.
--- @param bp LuaItemStack?
--- @return LuaItemStack?
function Util.get_blueprint(bp)
    if not (bp and bp.valid and bp.valid_for_read) then return nil end
    if bp.is_blueprint_book and bp.active_index then
        local inventory = bp.get_inventory(defines.inventory.item_main)
		if not inventory then return nil end
        if inventory.get_item_count() == 0 then return nil end
        return Util.get_blueprint(inventory[bp.active_index])
    end
    if not bp.is_blueprint then return nil end
    return bp
end
]]

---FIX for Factorios BUG itemStack.active_index point to invalid slot
local function getValidBlueprint(inventory, startIndex)
	local size = #inventory
	for i = startIndex, size do
		local slot = inventory[i]
		if slot.valid_for_read then return slot end
	end
	-- optional: Schleife abbrechen, wenn du Verhalten exakt wie Factorio willst
	return nil
end

local function coerce_active_index(inventory, active_index)
	local size = #inventory
	for offset = 0, size - 1 do
		local idx = ((active_index - 1 + offset) % size) + 1
		if inventory[idx].valid_for_read then return idx end
	end
	return nil
end

--- Returns the item if it is a blueprint, the selected blueprint in the book if it is a blueprint book, or nil.
--- @param obj LuaItemStack|LuaRecord|LuaPlayer
--- @param player LuaPlayer? If obj is a `blueprint-book`, then 'player' must be specified.
--- @return BlueprintItem?
--- @overload fun(obj: LuaPlayer):BlueprintItem?
--- @overload fun(obj: LuaRecord, LuaPlayer):BlueprintItem?
function Util.get_blueprint(obj, player)
	if not obj then return nil end
	if obj.object_name=="LuaPlayer" then
		return Util.get_blueprint(obj.cursor_record, obj) or Util.get_blueprint(obj.cursor_stack, obj) or nil
	elseif obj.object_name=="LuaRecord" then local record = obj --[[@as LuaRecord]]
		if record.type=="blueprint-book" then
			if not record.contents then return nil end
			if #record.contents == 0 then return nil end
			if not pcall(function() return type(record["get_active_index"])=="function" end) then
				log("record.get_active_index() requires Factorio 2.0.29")
				return nil
			end --
			if not player then return nil end -- TODO revise silent fail!
			return Util.get_blueprint(record.contents[record.get_active_index(player)], player)
		elseif record.type=="blueprint" then
			return BlueprintItem(record)
		else return nil --"deconstruction-planner" "upgrade-planner"
		end
	elseif obj.object_name=="LuaItemStack" then local itemStack = obj --[[@as LuaItemStack]]
		if not (itemStack and itemStack.valid and itemStack.valid_for_read) then return nil end
		if itemStack.is_blueprint_book and itemStack.active_index then
			local inventory = itemStack.get_inventory(defines.inventory.item_main)
			if not inventory then return nil end
			local active_index = coerce_active_index(inventory, itemStack.active_index)
			return active_index and Util.get_blueprint(inventory[active_index]) or nil
		end
		if not itemStack.is_blueprint then return nil end
		if itemStack.prototype.hidden then return nil end -- new  feature. ignore hidden blueprints
		return BlueprintItem(itemStack)
	else return nil
	end
end

--- will replace Util.get_blueprint
--- @param player LuaPlayer
function Util.tryGetBlueprint(player)
	local bp = Util.get_blueprint(player.cursor_stack)
	if bp and not bp.is_blueprint_setup() then return nil end

	-- COMBATIBILIY 1.1.0
	if player.is_cursor_blueprint and player.is_cursor_blueprint() then -- Returns whether the player is holding a blueprint, it takes into account a blueprint as an item as well as blueprint from the blueprint record from the blueprint library.
		-- player.get_blueprint_entities() -- array of blueprint entity	Returns the same type of data as LuaItemStack::readBlueprintEntities, but works for the currently selected blueprint, regardless of it being in a blueprint book or picked from the blueprint library.
		-- TODO no tiles are returned, we have to wait for a better version
		return player
	end
end

--- Create or return a dummy storage surface
--- @return LuaSurface
function Util.get_dummy_surface()
    if game.surfaces.surface_of_holding then return game.surfaces.surface_of_holding end

    local none = { frequency = "none" }
    local autoplace_controls = {}
    for k,_ in pairs(prototypes.autoplace_control) do autoplace_controls[k] = none end
    return game.create_surface('surface_of_holding',
        { width=1, height=1, autoplace_controls = autoplace_controls }
    )
end

function Util.get_temp_surface_name(name) return "BPEx_temp_surface_"..name end

function Util.get_temp_surface(name)
	name = Util.get_temp_surface_name(name)
    if game.surfaces[name] then return game.surfaces[name] end

    local none = { frequency = "none" }
    local autoplace_controls = {}
    for k,_ in pairs(prototypes.autoplace_control) do autoplace_controls[k] = none end
    return game.create_surface(name,
        { width=1, height=1, autoplace_controls = autoplace_controls }
    )
end

---
---@param surface LuaSurface
---@param index integer?
---@return LuaEntity
function Util.get_temp_chest(surface, index)
	if not index or index < 1 then index = 1 end
	local position = {x = index, y = 0}
	local entities = surface.find_entities_filtered{name = "steel-chest", position = position}
	if #entities > 0 then return entities[1] end
	local chest = surface.create_entity{name = "steel-chest", position = position, force = "neutral"}
	return chest or error("Failed to create temp chest")
end

function Util.get_temp_inventory()
	local chest = Util.get_temp_chest(Util.get_temp_surface("temp_inventory"))
	return chest.get_inventory(defines.inventory.chest)
end

function Util.destroy_temp_inventory()
	local surface = Util.get_temp_surface_name("temp_inventory")
	if game.surfaces[surface] then game.delete_surface(game.surfaces[surface]) end
end

---@class BlueprintData
---@field entities BlueprintEntity[]?
---@field tiles Tile[]?
---@field absolute_snapping boolean
---@field position_relative_to_grid TilePosition?
---@field snap_to_grid TilePosition?
---@field icons BlueprintSignalIcon[]
---@field label string


---@param record LuaRecord
---@return BlueprintData
function Util.copy_record_to_table(record)
	local bp_data = {
		entities = table.deepcopy(record.get_blueprint_entities()),
		tiles = table.deepcopy(record.get_blueprint_tiles()),
		absolute_snapping = record.blueprint_absolute_snapping,
		position_relative_to_grid = record.blueprint_position_relative_to_grid,
		snap_to_grid = record.blueprint_snap_to_grid,
		icons = table.deepcopy(record.default_icons),
		--TODO: label = record.label ???  missing API
	}
	return bp_data
end

---@param bp_data BlueprintData
---@param item_stack LuaItemStack
function Util.copy_table_to_item_stack(bp_data, item_stack)
	item_stack.set_blueprint_entities(bp_data.entities)
	item_stack.set_blueprint_tiles(bp_data.tiles)
	item_stack.blueprint_absolute_snapping = bp_data.absolute_snapping
	item_stack.blueprint_snap_to_grid = bp_data.snap_to_grid
	item_stack.blueprint_position_relative_to_grid = bp_data.position_relative_to_grid
	--item_stack.label = NOT the BP name! / bp_data.label --TODO: record.label -- missing API
	--item_stack.default_icons = bp_data.icons -- default_icons is read only.
	item_stack.preview_icons = bp_data.icons
	-- item_stack.allow_manual_label_change = true
	--item_stack.label_color = ???
end

---
---@param record LuaRecord
---@return string
function Util.export_record(record)
	local bp_data = Util.copy_record_to_table(record)

	local inventory = Util.get_temp_inventory()
	inventory.insert("blueprint")
	local item_stack = inventory[1]
	Util.copy_table_to_item_stack(bp_data, item_stack)

	local blueprint_string = item_stack.export_stack()
	Util.destroy_temp_inventory()
	return blueprint_string
end

function Util.copy_blueprint(bp, item_stack)
	local bp_data = Util.copy_record_to_table(bp)
	Util.copy_table_to_item_stack(bp_data, item_stack)
end


-- Store an item stack in the Surface of Holding(tm)
function Util.store_item(player_index, key, item)
    local pdata = Util.get_pdata(player_index)
    if not pdata.stored_items then
        pdata.stored_items = {}
    end

    if not (pdata.stored_items[key] and pdata.stored_items[key].valid) then
        pdata.stored_items[key] = Util.get_dummy_surface().create_entity{name='item-on-ground', position={x=0,y=0}, stack={name='blueprint'}}
    end
    pdata.stored_items[key].stack.set_stack(item)
    return pdata.stored_items[key].stack
end

-- Clear an item stack in the Surface of Holding(tm)
function Util.clear_item(player_index, key)
    local pdata = storage.playerdata[player_index]
    if not pdata or not pdata.stored_items or not pdata.stored_items[key] then
        return
    end
    if pdata.stored_items[key].valid then
        pdata.stored_items[key].destroy()
    end
    pdata.stored_items[key] = nil
end

-- Clear ALL item stacks in the Surface of Holding
function Util.clear_all_items(player_index)
    local pdata = storage.playerdata[player_index]
    if not pdata or not pdata.stored_items then
        return
    end
    for _,ent in pairs(pdata.stored_items) do
        if ent and ent.valid then
            ent.destroy()
        end
    end
    pdata.stored_items = {}
end

-- Fetch an item stack in the Surface of Holding(tm)
function Util.fetch_item(player_index, key)
    local pdata = storage.playerdata[player_index]
    if not pdata or not pdata.stored_items or not pdata.stored_items[key] then
        return nil
    end
    if pdata.stored_items[key].valid then
        return pdata.stored_items[key].stack
    end
    pdata.stored_items[key] = nil
    return
end

--- Get or initialize player data.
--- @param player_index integer
--- @return PlayerData
function Util.get_pdata(player_index)
    local pdata = storage.playerdata[player_index]
    if not pdata then
        pdata = {

		}
        storage.playerdata[player_index] = pdata
    end
    return pdata
end


return Util
