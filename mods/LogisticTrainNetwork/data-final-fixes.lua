--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

local data_util = require('prototypes.data-util')

local tools = require('script.tools')

local icon_encoded_position = { { icon = '__LogisticTrainNetwork__/graphics/icons/encoded-position.png', icon_size = 64, tint = { r = 1, g = 1, b = 1, a = 1 } } }

local function create_signal(prototype, order)
    local signal = {
        type = 'virtual-signal',
        name = 'ltn-position-' .. prototype.name,
        icons = data_util.create_icons(prototype, icon_encoded_position) or icon_encoded_position,
        icon_size = nil,
        subgroup = 'ltn-position-signal',
        order = order,
        localised_name = { 'virtual-signal-name.ltn-position', prototype.localised_name or { 'entity-name.' .. prototype.name } }
    }
    data:extend { signal }
end

local lococount = 0
for _, loco in pairs(data.raw['locomotive']) do
    lococount = lococount + 1
    create_signal(loco, 'a' .. string.format('%02d', lococount))
end

local wagoncount = 0
for _, wagon in pairs(data.raw['cargo-wagon']) do
    wagoncount = wagoncount + 1
    create_signal(wagon, 'b' .. string.format('%02d', wagoncount))
end

local wagoncount_fluid = 0
for _, wagon in pairs(data.raw['fluid-wagon']) do
    wagoncount_fluid = wagoncount_fluid + 1
    create_signal(wagon, 'c' .. string.format('%02d', wagoncount_fluid))
end

local wagoncount_artillery = 0
for _, wagon in pairs(data.raw['artillery-wagon']) do
    wagoncount_artillery = wagoncount_artillery + 1
    create_signal(wagon, 'd' .. string.format('%02d', wagoncount_artillery))
end

tools.log(0, 'data_final_fixes', 'Found %d locomotives, %d cargo wagons, %d fluid wagons, %d artillery wagons.', function()
    return lococount, wagoncount, wagoncount_fluid, wagoncount_artillery
end)
