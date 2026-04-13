--- Data Utilities
--- @class StdLib.Data.Util : StdLib.Core
local Util = {
    __class = 'Util',
    __index = require('__Kux-CoreLib__/stdlib/core') --[[@as StdLib.Core]]
}
setmetatable(Util, Util)

local Is = require('__Kux-CoreLib__/stdlib/utils/is') --[[@as StdLib.Utils.Is]]
local table = require('__Kux-CoreLib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

function Util.extend(proto_array)
    assert(Is.Assert.Table(proto_array) 'Missing table or array to extend')
    data:extend(#proto_array > 0 and proto_array or { proto_array })
end

function Util.disable_control(control)
    if data.raw['custom-input'] and data.raw['custom-input'][control] then
        data.raw['custom-input'][control].enabled = false
    end
end

function Util.extend_style(style)
    data.raw['gui-style'].default[style.name] = style
end

function Util.extend_style_by_name(name, style)
    data.raw['gui-style'].default[name] = style
end

--- Quickly duplicate an existing prototype into a new one.
--- @param data_type string The type of the object to duplicate
--- @param orig_name string The name of the object to duplicate
--- @param new_name string The new name to use.
--- @param mining_result nil|string|boolean  [opt] If true set mining_result to new_name, if truthy set mining_result to value
function Util.duplicate(data_type, orig_name, new_name, mining_result)
    mining_result = type(mining_result) == 'boolean' and new_name or mining_result
    if data.raw[data_type] and data.raw[data_type][orig_name] then
        local proto = table.deep_copy(data.raw[data_type][orig_name])
        proto.name = new_name

        if mining_result then
            if proto.minable and proto.minable.result then
                proto.minable.result = mining_result
            end
        end

        if proto.place_result then
            proto.place_result = new_name
        end

        if proto.result then
            proto.result = new_name
        end

        return (proto)
    else
        error('Unknown Prototype ' .. data_type .. '/' .. orig_name)
    end
end

-- load the data portion of stdlib into globals, by default it loads everything into an ALLCAPS name.
-- Alternatively you can pass a dictionary of `[global names] -> [require path]`.
--- @param files table? [opt]
-- @usage
-- require('__Kux-CoreLib__/stdlib/data/data).util.create_data_globals()
function Util.create_data_globals(files)
    _ENV.STDLIB.create_stdlib_data_globals(files)
end

return Util
