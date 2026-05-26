--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

local data_util = require('prototypes.data-util')

local ltn_stop = data_util.copy_prototype(data.raw['item']['train-stop'], 'logistic-train-stop')
ltn_stop.icon = '__LogisticTrainNetwork__/graphics/icons/train-stop.png'
ltn_stop.icon_size = 64
ltn_stop.order = ltn_stop.order .. '-c'

local ltn_stop_in = data_util.copy_prototype(data.raw['item']['small-lamp'], 'logistic-train-stop-input')
ltn_stop_in.hidden = true
ltn_stop_in.hidden_in_factoriopedia = true
ltn_stop_in.flags = {
    'only-in-cursor',
}

local ltn_stop_out = data_util.copy_prototype(data.raw['item']['constant-combinator'], 'logistic-train-stop-output')
ltn_stop_out.icon = '__LogisticTrainNetwork__/graphics/icons/output.png'
ltn_stop_out.hidden = true
ltn_stop_out.hidden_in_factoriopedia = true
ltn_stop_out.icon_size = 64
ltn_stop_out.flags = {
    'only-in-cursor',
}

local ltn_lamp_control = data_util.copy_prototype(data.raw['item']['constant-combinator'], 'logistic-train-stop-lamp-control')
ltn_lamp_control.hidden = true
ltn_lamp_control.hidden_in_factoriopedia = true
ltn_lamp_control.icon = '__LogisticTrainNetwork__/graphics/icons/empty.png'
ltn_lamp_control.icon_size = 32
ltn_lamp_control.flags = {
    'only-in-cursor',
}

data:extend {
    ltn_stop,
    ltn_stop_in,
    ltn_stop_out,
    ltn_lamp_control
}

-- support for cargo ship ports
if mods['cargo-ships'] then
    ltn_port = data_util.copy_prototype(data.raw['item']['port'], 'ltn-port')
    ltn_port.icon = '__LogisticTrainNetwork__/graphics/icons/port.png'
    ltn_port.icon_size = 64
    ltn_port.order = ltn_port.order .. '-c'

    data:extend {
        ltn_port
    }
end
