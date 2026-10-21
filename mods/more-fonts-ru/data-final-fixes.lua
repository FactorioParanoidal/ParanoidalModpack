-- Replaces the base font families in all font prototypes, including fonts of
-- other mods (that is why it runs in data-final-fixes).
local choice = settings.startup["more-fonts-ru-font-family"].value
if choice == "default" then return end

local size = nil
for _, family in ipairs(require("families")) do
  if family.id == choice then size = family.size end
end
if size == nil then return end

local target = {
  ["default"] = choice,
  ["default-semibold"] = choice .. "-semibold",
  ["default-bold"] = choice .. "-bold",
}

for name, font in pairs(data.raw.font) do
  local to = target[font.from]
  if to and not name:find("^more%-fonts%-ru%-preview%-") then
    font.from = to
    font.size = font.size + size
  end
end
