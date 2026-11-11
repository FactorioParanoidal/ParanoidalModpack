local aircraft = require("shared.aircraft")
local definitions = {
  {"aircraft-sound-setting", true}, {"aircraft-hardmode", false}, {"aircraft-belt-immunity", true},
  {"non-combat-mode", false}, {"inserter-immunity", false}, {"lock-surfaces-space-age", true},
  {"carbon-fiber-aircraft", true}, {"disable-tank-controls", true}, {"aircraft-change-vanilla-tech-tree", true},
  -- Defaults retain the previously unconditional HelicopterRevival integration; players can now opt out.
  {"helicopter-tech", true, not mods["HelicopterRevival"]},
  {"heli-equipment-grid", true, not mods["HelicopterRevival"]}
}
for i, definition in ipairs(definitions) do
  data:extend({{
    type = "bool-setting", name = definition[1], setting_type = "startup",
    default_value = definition[2], hidden = definition[3] or false, order = string.format("a-%02d", i)
  }})
end
data:extend({{
  type = "double-setting", name = "fuel-consumption-multiplier", setting_type = "startup",
  default_value = 10, minimum_value = 0.1, maximum_value = 100, order = "b"
}})

if mods["AircraftRealism"] then
  for _, spec in ipairs(aircraft.aircraft) do
    for _, carbon in ipairs({false, true}) do
      local name = aircraft.name(spec, carbon)
      local speed = aircraft.liftoff(spec, carbon)
      data:extend({
        {
          type = "double-setting", name = "transition-speed-" .. name, setting_type = "runtime-global",
          default_value = speed, minimum_value = 1, maximum_value = 1000, order = "c-" .. name
        },
        {
          type = "double-setting", name = "shadow-end-animation-speed-" .. name, setting_type = "startup",
          default_value = speed * 3, minimum_value = 1, maximum_value = 3000, hidden = true, order = "d-" .. name
        }
      })
    end
  end
end
