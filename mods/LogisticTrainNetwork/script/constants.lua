--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

MOD_NAME = 'LogisticTrainNetwork'

ISDEPOT = 'ltn-depot'
DEPOT_PRIORITY = 'ltn-depot-priority'
ISFUEL_STATION = 'ltn-fuel-station'
NETWORKID = 'ltn-network-id'
MINTRAINLENGTH = 'ltn-min-train-length'
MAXTRAINLENGTH = 'ltn-max-train-length'
MAXTRAINS = 'ltn-max-trains'
REQUESTED_THRESHOLD = 'ltn-requester-threshold'
REQUESTED_STACK_THRESHOLD = 'ltn-requester-stack-threshold'
REQUESTED_PRIORITY = 'ltn-requester-priority'
NOWARN = 'ltn-disable-warnings'
PROVIDED_THRESHOLD = 'ltn-provider-threshold'
PROVIDED_STACK_THRESHOLD = 'ltn-provider-stack-threshold'
PROVIDED_PRIORITY = 'ltn-provider-priority'
LOCKEDSLOTS = 'ltn-locked-slots'

---@type table<string, SignalID>
ControlSignals = {
    [ISDEPOT] = { type = 'virtual', name = ISDEPOT, quality = 'normal', },
    [DEPOT_PRIORITY] = { type = 'virtual', name = DEPOT_PRIORITY, quality = 'normal', },
    [ISFUEL_STATION] = { type = 'virtual', name = ISFUEL_STATION, quality = 'normal', },
    [NETWORKID] = { type = 'virtual', name = NETWORKID, quality = 'normal', },
    [MINTRAINLENGTH] = { type = 'virtual', name = MINTRAINLENGTH, quality = 'normal', },
    [MAXTRAINLENGTH] = { type = 'virtual', name = MAXTRAINLENGTH, quality = 'normal', },
    [MAXTRAINS] = { type = 'virtual', name = MAXTRAINS, quality = 'normal', },
    [REQUESTED_THRESHOLD] = { type = 'virtual', name = REQUESTED_THRESHOLD, quality = 'normal', },
    [REQUESTED_STACK_THRESHOLD] = { type = 'virtual', name = REQUESTED_STACK_THRESHOLD, quality = 'normal', },
    [REQUESTED_PRIORITY] = { type = 'virtual', name = REQUESTED_PRIORITY, quality = 'normal', },
    [NOWARN] = { type = 'virtual', name = NOWARN, quality = 'normal', },
    [PROVIDED_THRESHOLD] = { type = 'virtual', name = PROVIDED_THRESHOLD, quality = 'normal', },
    [PROVIDED_STACK_THRESHOLD] = { type = 'virtual', name = PROVIDED_STACK_THRESHOLD, quality = 'normal', },
    [PROVIDED_PRIORITY] = { type = 'virtual', name = PROVIDED_PRIORITY, quality = 'normal', },
    [LOCKEDSLOTS] = { type = 'virtual', name = LOCKEDSLOTS, quality = 'normal', },
}

---@type table<string, number>
ltn_stop_entity_names = { -- ltn stop entity.name with I/O entity offset away from tracks in tiles
    ['logistic-train-stop'] = 0,
    ['ltn-port'] = 1,
}

ltn_stop_input = 'logistic-train-stop-input'
ltn_stop_output = 'logistic-train-stop-output'
ltn_stop_output_controller = 'logistic-train-stop-lamp-control'

---@enum ltn.ErrorCodes
ErrorCodes = {
    [-1] = 'white', -- not initialized
    [1] = 'red',    -- short circuit / disabled
    [2] = 'pink',   -- duplicate stop name
    [3] = 'grey',   -- no fuel signal
}

---@enum ltn.Colors
ColorLookup = {
    red = 'signal-red',
    green = 'signal-green',
    blue = 'signal-blue',
    cyan = 'signal-cyan',
    pink = 'signal-pink',
    yellow = 'signal-yellow',
    white = 'signal-white',
    grey = 'signal-grey',
    black = 'signal-black'
}

-- often used strings and functions
MATCH_STRING = '([^,]+),([^,]+)'

-- LTN Interrupt name
LTN_INTERRUPT_NAME = 'LTN Fuel'
