MOD_STRING  = "LTN Combinator"

print, dlog = require "script.logger" ()
local config = require("config")
require("script.util")
require("script.gui")
require("script.remote")

-- TODO: Move mod / settings init here

-- grab default threshold from ltn settings
if settings.global["ltn-dispatcher-requester-threshold"] then
local threshold = settings.global["ltn-dispatcher-requester-threshold"].value
config.ltn_signals["ltn-requester-threshold"].default = threshold
end

if settings.global["ltn-dispatcher-provider-threshold"] then
local threshold = settings.global["ltn-dispatcher-provider-threshold"].value
config.ltn_signals["ltn-provider-threshold"].default = threshold
end

if settings.global["ltn-stop-default-network"] then
local default_networkid = settings.global["ltn-stop-default-network"].value
config.ltn_signals["ltn-network-id"].default = default_networkid
end