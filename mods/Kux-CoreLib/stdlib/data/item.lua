local Data = require('__Kux-CoreLib__/stdlib/data/data') --[[@as StdLib.Data]]
local Table = require('__Kux-CoreLib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

--- Item
--- @class StdLib.Data.Item : StdLib.Data
local Item = {
    __class = 'Item',
    __index = Data,
    __call = Data.__call
}
setmetatable(Item, Item)

local function make_table(params)
    if not params then
        return Table.keys(data.raw.lab)
    else
        return type(params) == 'table' and params or { params }
    end
end

local function change_inputs(name, lab_names, add)
    lab_names = make_table(lab_names)
    local Entity = require('__Kux-CoreLib__/stdlib/data/entity') --[[@as StdLib.Data.Entity]]
    for _, lab_name in pairs(lab_names) do
        Entity(lab_name, 'lab'):change_lab_inputs(name, add)
    end
end

function Item:add_to_labs(lab_names)
    if self:is_valid() then
        change_inputs(self.name, lab_names, true)
    end
    return self
end

function Item:remove_from_labs(lab_names)
    if self:is_valid() then
        change_inputs(self.name, lab_names, false)
    end
    return self
end

return Item
