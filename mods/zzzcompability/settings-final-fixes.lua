local setting = data.raw["bool-setting"]["bobmods-burnerphase"]

-- The setting was previously hidden and bypassed by bobtech itself if aai-industry was active.
-- We removed that hardcode in bobtech, so we can now safely define its properties here.
if setting then
	setting.hidden = false
	setting.forced_value = false -- Allow user to toggle it
	setting.default_value = true
end
