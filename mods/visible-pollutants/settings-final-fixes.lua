Settings = require("scripts.settings")

if mods["space-exploration"] then
  data.raw["bool-setting"][Settings.EnableSolarOcclusion].hidden = true
  data.raw["bool-setting"][Settings.EnableSolarOcclusion].forced_value = false
end