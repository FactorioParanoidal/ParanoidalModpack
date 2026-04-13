KuxCoreLib = require("__Kux-CoreLib__/lib/init") --[[@as KuxCoreLib]]
KuxGuiLib = require("__Kux-GuiLib__/lib/init") --[[@as KuxGuiLib]]

---@class Mod : KuxCoreLib.ModInfo Mod Kux-OrbitalIonCannon
local mod = KuxCoreLib.ModInfo.new{separator="-"}

--- all registered modules
---@type {[string]:(false|{[string]:any})}
mod.modules = {
	IonTargeter = false,
	IonCannon = false,
}

---technology names
mod.tech = {
	cannon = "orbital-ion-cannon",
	area_fire = "orbital-ion-cannon-area-fire",
	auto_targeting = "auto-targeting",
	cannon_mk2 = "orbital-ion-cannon-mk2",
	cannon_mk2_upgrade = "orbital-ion-cannon-mk2-upgrade"
}

---technology recipe names
mod.recipe = {
	cannon = "orbital-ion-cannon",
	targeter = "ion-cannon-targeter",
	targeter_mk2 = "ion-cannon-targeter-mk2",
	cannon_mk2 = "orbital-ion-cannon-mk2"
}

mod.defines = {}

mod.defines.sound = {
	ready = "ion-cannon-ready",
	unable_to_comply = "unable-to-comply",
	charging = "ion-cannon-charging",
	select_target = "select-target"
}

_G.trace = KuxCoreLib.Trace
trace.prefix_sign = "🛰️"
trace.sign_color = trace.colors.purple
trace.text_color = trace.colors.lightpurple
trace.background_color = trace.colors.gray_32

mod:protect()
_G.mod = mod
return mod