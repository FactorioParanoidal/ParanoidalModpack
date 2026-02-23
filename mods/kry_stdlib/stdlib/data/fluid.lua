local Data = require('__kry_stdlib__/stdlib/data/data') --[[@as StdLib.Data]]

--- Fluid
--- @class StdLib.Data.Fluid : StdLib.Data
local Fluid = {
    __class = 'Fluid',
    __index = Data,
}

function Fluid:__call(fluid)
    return self:get(fluid, 'fluid')
end
setmetatable(Fluid, Fluid)

return Fluid
