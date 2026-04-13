require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.ItemData : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.ItemData
local ItemData = {
	__class  = "KuxCoreLib.ItemData",
	__guid   = "{AD869786-5B06-420C-9866-E83F3AB736C0}",
	__origin = "Kux-CoreLib/lib/data/ItemData.lua",
}
if not KuxCoreLib.__classUtils.ctor(ItemData) then return self end
---------------------------------------------------------------------------------------------------
local DataRaw = KuxCoreLib.DataRaw
local Table = KuxCoreLib.Table
local utils = KuxCoreLib.PrototypeData.extend.utils


---Clone an item prototype
---@overload fun(name:string, entity:data.EntityPrototype, patch:table?):data.ItemPrototype
---@overload fun(name:string, new_name:string, patch:table?):data.ItemPrototype
function ItemData.clone(...)
	local args, count = {...}, select("#", ...)
	local arg_types = {}
	for i = 1, count, 1 do arg_types[i] = type(args[i]) end
	if arg_types[2] == "table" then return ItemData.clone_nep(...) end
	if arg_types[2] == "string" then return ItemData.clone_nnp(...) end
	error("Invalid arguments: "..table.concat(arg_types, ", "))
end

---Clone an item prototype
---@param name string The name of the item prototype to clone
---@param entity data.EntityPrototype The corresponding entity prototype
---@param patch table?
---@return data.ItemPrototype #The cloned item prototype
function ItemData.clone_nep(name, entity, patch)
	local base = data.raw["item"][name] or ItemData.find(name)
	if(not base) then error("Item prrototype not found: "..name) end
	local item = table.deepcopy(base)
	item.name = entity.name
	item.localised_name = {"item-name."..entity.name}
	item.place_result = entity.name
	item["base"] = base -- additional data, only for data stage
	if(patch) then utils.patch(item, patch) end -- apply patch if any
	return item
end

function ItemData.clone_nnp(name, new_name, patch)
	local base = data.raw["item"][name] or ItemData.find(name)
	if(not base) then error("Item prrototype not found: "..name) end
	local item = table.deepcopy(base)
	item.name = new_name
	item.localised_name = {"item-name."..new_name}
	--item.place_result = new_name
	item["base"] = base -- additional data, only for data stage
	if(patch) then utils.patch(item, patch) end -- apply patch if any
	return item
end

---Find an item prototype by name
---@param itemName string The name of the item prototype to find
---@return data.ItemPrototype? #The first found item prototype or nil
function ItemData.find(itemName)
    for _,typeName in ipairs(DataRaw.itemTypes) do
        local item = data.raw[typeName][itemName]
        if(item) then return item end
    end
end

---Find an item prototype by name and return the type
---@param itemName string The name of the item prototype to find
---@return string? #The type of the first found item prototype or nil
function ItemData.findType(itemName)
    for _,typeName in ipairs(DataRaw.itemTypes) do
        local item = data.raw[typeName][itemName]
        if(item) then return typeName end
    end
end

---Set the stack size of an item prototype
---@param itemName string The name of the item prototype
---@param stackSize number The new stack size
---@param exact boolean? #If false, the stack size is only set if the current stack size is less then the new stack size
function ItemData.setStackSize(itemName, stackSize, exact)
	local item = data.raw["item"][itemName]
	if not item then error("Item not found: "..itemName) end
	if not exact and item.stack_size >= stackSize then return end
	item.stack_size = stackSize
	if stackSize==1 then table.insert(item.flags, "not-stackable")
	else Table.remove(item.flags, "not-stackable") end
end

---------------------------------------------------------------------------------------------------
return ItemData