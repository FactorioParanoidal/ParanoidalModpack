-- NOTE: requires Factorio 2.0.67 or later

local lib = {}

---@alias Core.Blueprintish LuaItemStack|LuaRecord

---Given either a record or a stack, which might be a blueprint or a blueprint book,
---return the actual blueprint involved, stripped of any containing books.
---If both arguments are given, the record is preferred over the stack.
---@param player LuaPlayer The player who is manipulating the blueprint.
---@param record? LuaRecord
---@param stack? LuaItemStack
---@return Core.Blueprintish? blueprintish The actual blueprint involved, stripped of any containing books or nil if not found.
local function get_actual_blueprint(player, record, stack)
	if record then
		while record and record.type == "blueprint-book" do
			record = record.get_selected_record(player)
		end
		if record and not record.is_preview and record.type == "blueprint" then
			return record
		end
	elseif stack then
		if not stack.valid_for_read then return end
		while stack and stack.is_blueprint_book do
			local main_inventory = stack.get_inventory(defines.inventory.item_main)
			if not main_inventory then return end
			stack = main_inventory[
				stack.active_index --[[@as uint]]
			]
		end
		if stack and stack.is_blueprint then return stack end
	end
end
lib.get_actual_blueprint = get_actual_blueprint

return lib
