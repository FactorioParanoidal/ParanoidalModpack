-- Preview fonts for the startup setting dropdown. They are not replaced.
local families = require("families")

local original = table.deepcopy(data.raw.font["default-dropdown"])
original.name = "more-fonts-ru-preview-default"

local previews = { original }
for _, family in ipairs(families) do
  previews[#previews + 1] = {
    type = "font",
    name = "more-fonts-ru-preview-" .. family.id,
    from = family.id,
    size = 14,
  }
end

data:extend(previews)
