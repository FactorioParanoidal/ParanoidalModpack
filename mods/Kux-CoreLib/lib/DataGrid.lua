--because Table is already used we call it DataGrid

require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---DRAFT Provides DataGrid functions
---@class KuxCoreLib.DataGrid : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.DataGrid
local DataGrid = {
	__class  = "DataGrid",
	__guid   = "{114989BE-8900-4ABF-91F4-BC5D19537396}",
	__origin = "Kux-CoreLib/lib/DataGrid.lua",

    ---@type integer The number of entries in the list
    count = 0
}
if not KuxCoreLib.__classUtils.ctor(DataGrid) then return self end
---------------------------------------------------------------------------------------------------


local function array_getRowIndex(array, index, columns)
	return math.floor((index - 1) / columns) + 1
end
local function array_getColumnIndex(array, index, columns)
	return (index - 1) % columns + 1
end
local function array_getIndex(array, row, column, columns)
	return (row - 1) * columns + column
end
local function array_removeRow(array, row, columns)
	local index = array_getIndex(array, row, 1, columns)
	for i = 1, columns, 1 do
		table.remove(array, index)
	end
end
local function array_removeRowByIndex(array, index, columns)
	local row = array_getRowIndex(array, index, columns)
	array_removeRow(array, row, columns)
end

function DataGrid.new(columns, rows, default_value)
	local self = setmetatable({}, {__index = DataGrid})
	self.columns = columns
	self.rows = rows
	self.default_value = default_value
	self.data = {}
	for i = 1, columns * rows, 1 do
		self.data[i] = default_value
	end
	return self
end

function DataGrid.fromArray(array, columns)
	local self = setmetatable({}, {__index = DataGrid})
	self.columns = columns
	self.rows = math.ceil(#array / columns)
	self.data = {}
	for i = 1, #array, 1 do
		self.data[i] = array[i]
	end
	return self
end

function DataGrid:toArray(nullValue)
	local array = {}
	for i = 1, self.columns * self.rows, 1 do
		array[i] = self.data[i]~=nil and self.data[i] or nullValue
	end
	return array
end

function DataGrid:removeRow(row)
	array_removeRow(self.data, row, self.columns)
	self.rows = self.rows - 1
end

function DataGrid:removeRowByIndex(index)
	array_removeRowByIndex(self.data, index, self.columns)
	self.rows = self.rows - 1
end

function DataGrid:insertRow(row, default_value)
	local index = array_getIndex(self.data, row, 1, self.columns)
	for i = 1, self.columns, 1 do
		table.insert(self.data, index, default_value or self.default_value)
	end
	self.rows = self.rows + 1
end

function DataGrid:insertRowByIndex(index)
	local row = array_getRowIndex(self.data, index, self.columns)
	self:insertRow(row)
end

return DataGrid