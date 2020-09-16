local minime = require("__minime__/common")("minime")

-- If alternative characters are available, it wouldn't be nice if the main character's
-- localized name would be just "Character", so we need to change it to something more meaningful.

local found = false

for name, char in pairs(data.raw["character"]) do
  name = string.upper(name or "")
  minime.dprint("Found character " .. name)

  if string.find(name, minime.pattern) then
    minime.dprint(name .. " matches pattern " .. minime.pattern .. "!")
    found = true
    break
  end
end

if found then
  data.raw.character["character"].localised_name = {"minime-misc.base-character"}
  minime.dprint({"", "Changed name of base character to ", data.raw.character["character"].localised_name, "!"})
end
