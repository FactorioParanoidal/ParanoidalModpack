local math = require("__flib__.math")

local config = {}
local startup_settings = settings.startup

---@type uint
config.ltnc_ltn_signal_count      = 15
---@type uint
config.ltnc_misc_signal_count = 10 * startup_settings["ltnc-misc-signal-rows"].value --[[@as uint]]
---@type uint
config.ltnc_slot_count = config.ltnc_ltn_signal_count + config.ltnc_misc_signal_count
config.slider_max_fluid = 500000
config.slider_max_stacks = 960
---@type int
config.high_threshold = startup_settings["ltnc-high-threshold"].value --[[@as int]]
config.old_high_threshold = 50000000

---@alias LTNSignals
---| "ltn-network-id"
---| "ltn-min-train-length"
---| "ltn-max-train-length"
---| "ltn-max-trains"
---| "ltn-requester-threshold"
---| "ltn-requester-stack-threshold"
---| "ltn-requester-priority"
---| "ltn-disable-warnings"
---| "ltn-provider-threshold"
---| "ltn-provider-stack-threshold"
---| "ltn-provider-priority"
---| "ltn-locked-slots"
---| "ltn-depot"
---| "ltn-depot-priority"
---| "ltn-fuel-station"

---@alias LTNGroups
---| "network"
---| "common"
---| "requester"
---| "provider"
---| "depot"

---@type table<LTNSignals, {group: LTNGroups, default: number, slot: uint, min: number, max: number}>
config.ltn_signals = {
  ["ltn-network-id"]                = {group = "network", default = -1, slot = 1, min = math.min_int, max = math.max_int},
  ["ltn-min-train-length"]          = {group = "common", default = 0, slot = 2, min = 0, max = 1000},
  ["ltn-max-train-length"]          = {group = "common", default = 0, slot = 3, min = 0, max = 1000},
  ["ltn-max-trains"]                = {group = "common", default = 0, slot = 4, min = 0, max = 1000},
  ["ltn-requester-threshold"]       = {group = "requester", default = 1000, slot = 5, min = 0, max = math.max_int},
  ["ltn-requester-stack-threshold"] = {group = "requester", default = 0, slot = 6, min = 0, max = math.max_int},
  ["ltn-requester-priority"]        = {group = "requester", default = 0, slot = 7, min = math.min_int, max = math.max_int},
  ["ltn-disable-warnings"]          = {group = "requester", default = 0, slot = 8, min = 0, max = 1},
  ["ltn-provider-threshold"]        = {group = "provider", default = 1000, slot = 9, min = 0, max = math.max_int},
  ["ltn-provider-stack-threshold"]  = {group = "provider", default = 0, slot = 10, min = 0, max = math.max_int},
  ["ltn-provider-priority"]         = {group = "provider", default = 0, slot = 11, min = math.min_int, max = math.max_int},
  ["ltn-locked-slots"]              = {group = "provider", default = 0, slot = 12, min = 0, max = 40},
  ["ltn-depot"]                     = {group = "depot", default = 0, slot = 13, min = 0, max = 1},
  ["ltn-depot-priority"]            = {group = "depot", default = 0, slot = 14, min = math.min_int, max = math.max_int},
  ["ltn-fuel-station"]              = {group = "depot", default = 0, slot = 15, min = 0, max = 1},
}

---@enum BadSignals
config.bad_signals = {
  "signal-each",
  "signal-anything",
  "signal-everything"
}

---@enum Thresholds
config.thresholds = {
  "ltn-requester-threshold",
  "ltn-requester-stack-threshold",
  "ltn-provider-threshold",
  "ltn-provider-stack-threshold"
}

return config
