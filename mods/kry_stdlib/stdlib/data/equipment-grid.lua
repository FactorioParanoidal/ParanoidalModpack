local Data = require('__kry_stdlib__/stdlib/data/data')
local Table = require('__kry_stdlib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

--- EquipmentGrid
--- @class StdLib.Data.EquipmentGrid : StdLib.Data
local EquipmentGrid = {
    __class = 'EquipmentGrid',
    __index = Data,
}

function EquipmentGrid:__call(name)
    local new = self:get(name, 'equipment-grid')
    return new
end

setmetatable(EquipmentGrid, EquipmentGrid)

function EquipmentGrid:update_width(width)
    assert(type(width) == "number", "Expected argument to be a number")
	if self:is_valid() then
		self.width = width
		return true
	end
	return false
end

function EquipmentGrid:update_height(height)
    assert(type(height) == "number", "Expected argument to be a number")
	if self:is_valid() then
		self.height = height
		return true
	end
	return false
end

function EquipmentGrid:update_size(width,height)
    assert(type(width) == "number", "Expected second argument to be a number")
    assert(type(height) == "number", "Expected first argument to be a number")
	if self:is_valid() then
		self.width = width
		self.height = height
		return true
	end
	return false
end

function EquipmentGrid:set_categories(categories)
	if self:is_valid() then
		assert(type(categories) == "table" or type(categories) == "string",
			"Expected argument to be a table or a string. Received:\n"..serpent.block(categories))
		if type(categories) == "string" then
			self.equipment_categories = {categories}
		elseif type(categories) == "table" then
			self.equipment_categories = Table.deepcopy(categories)
		end
	end
end
EquipmentGrid.set_category = EquipmentGrid.set_categories
EquipmentGrid.set_cats = EquipmentGrid.set_categories
EquipmentGrid.set_cat = EquipmentGrid.set_categories

function EquipmentGrid:add_categories(new_categories)
	assert(type(new_categories) == "table" or type(new_categories) == "string",
		"Expected argument to be a table or a string.")
	if self:is_valid() then
		if type(new_categories) == "string" then
			table.insert(self.equipment_categories, new_categories)
		elseif type(new_categories) == "table" then
			Table.merge(self.equipment_categories, new_categories, true)
		end
	end
end
EquipmentGrid.add_category = EquipmentGrid.add_categories
EquipmentGrid.add_cats = EquipmentGrid.add_categories
EquipmentGrid.add_cat = EquipmentGrid.add_categories

function EquipmentGrid:remove_categories(categories)
	assert(type(categories) == "table" or type(categories) == "string",
		"Expected argument to be a table or a string.")
	if self:is_valid() then
		if type(categories) == "string" then
			Table.remove_string(self.equipment_categories, categories)
		elseif type(categories) == "table" then
			for _, cat_string in ipairs(categories) do
				Table.remove_string(self.equipment_categories,cat_string)
			end
		end
	end
end
EquipmentGrid.rem_category = EquipmentGrid.remove_categories
EquipmentGrid.rem_cats = EquipmentGrid.remove_categories
EquipmentGrid.rem_cat = EquipmentGrid.remove_categories

return EquipmentGrid
