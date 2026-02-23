local Assert = require("utils.assert")
local setting = data.raw["bool-setting"]["bobmods-burnerphase"]
log(serpent.block(setting))
Assert.AssertOutdated(
	setting and setting.hidden == true,
	"Expected bobmods-burnerphase setting to be hidden by angelsrefining mod"
)
local default = {
	default_value = true,
	forced_value = true,
	hidden = false,
	name = "bobmods-burnerphase",
	setting_type = "startup",
	type = "bool-setting",
}

setting.hidden = false
setting.forced_value = true
setting.default_value = true
log(serpent.block(setting))
