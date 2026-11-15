-- Warheads (merged from Warheads_Continued_Continued 1.0.2) first, as before the merge.
require("warheads-settings")

data:extend({
  {
    type = "bool-setting",
    name = "nuke-random-fires",
    setting_type = "runtime-global",
    default_value = true,
    order = "a1"
  },
  {
    type = "bool-setting",
    name = "nuke-crater-noise",
    setting_type = "runtime-global",
    default_value = true,
    order = "a2"
  },
  {
    type = "bool-setting",
    name = "destroy-resources-in-crater",
    setting_type = "runtime-global",
    default_value = true,
    order = "a4"
  },
  {
    type = "bool-setting",
    name = "nukes-cause-pollution",
    setting_type = "runtime-global",
    default_value = true,
    order = "a5"
  },
  {
    type = "bool-setting",
    name = "retain-death-statistics",
    setting_type = "runtime-global",
    default_value = false,
    order = "a6"
  },
  {
    type = "bool-setting",
    name = "retain-death-statistics-small",
    setting_type = "runtime-global",
    default_value = true,
    order = "a7"
  },
  {
    type = "bool-setting",
    name = "retain-death-statistics-for-trees",
    setting_type = "runtime-global",
    default_value = false,
    order = "a8"
  },
  {
    type = "bool-setting",
    name = "retain-death-statistics-for-trees-small",
    setting_type = "runtime-global",
    default_value = true,
    order = "a9"
  },
  {
    type = "double-setting",
    name = "large-nuke-fire-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 50,
    default_value = 1,
    order = "b0"
  },
  {
    type = "double-setting",
    name = "huge-nuke-fire-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 100,
    default_value = 2,
    order = "b1"
  },
  {
    type = "double-setting",
    name = "general-nuke-range-scaledown",
    setting_type = "runtime-global",
    minimum_value = 0.5,
    maximum_value = 40,
    default_value = 1,
    order = "c+"
  },
  {
    type = "double-setting",
    name = "large-nuke-range-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 40,
    default_value = 1.5,
    order = "c0"
  },
  {
    type = "double-setting",
    name = "huge-nuke-range-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 4,
    default_value = 1.5,
    order = "c1"
  },
  {
    type = "double-setting",
    name = "really-huge-nuke-range-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 40,
    default_value = 1.5,
    order = "c2"
  },
  {
    type = "bool-setting",
    name = "optimise-100kt",
    setting_type = "runtime-global",
    default_value = true,
    order = "c4"
  },
  {
    type = "bool-setting",
    name = "actually-generate-crater",
    setting_type = "runtime-global",
    default_value = true,
    order = "c5"
  },


  {
    type = "string-setting",
    name = "small-boom-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = {"same-as-boom","true-nukes-default", "mod-dependant", "custom"},
    order = "b0"
  },
  {
    type = "string-setting",
    name = "small-boom-material-name",
    setting_type = "startup",
    default_value = "californium",
    order = "b1"
  },
  {
    type = "string-setting",
    name = "boom-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = { "true-nukes-default", "mod-dependant", "custom"},
    order = "b2"
  },
  {
    type = "string-setting",
    name = "boom-material-name",
    setting_type = "startup",
    default_value = "uranium-235",
    order = "b3"
  },
  {
    type = "string-setting",
    name = "dead-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = { "default", "mod-dependant", "custom"},
    order = "b4"
  },
  {
    type = "string-setting",
    name = "dead-material-name",
    setting_type = "startup",
    default_value = "uranium-238",
    order = "b5"
  },
  {
    type = "string-setting",
    name = "computer-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = {"true-nukes-default", "mod-dependant", "custom"},
    order = "b6"
  },
  {
    type = "string-setting",
    name = "computer-material-name",
    setting_type = "startup",
    default_value = "processing-unit",
    order = "b7"
  },
  {
    type = "string-setting",
    name = "light-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = {"true-nukes-default", "mod-dependant", "custom"},
    order = "b8"
  },
  {
    type = "string-setting",
    name = "light-material-name",
    setting_type = "startup",
    default_value = "low-density-structure",
    order = "b9"
  },


  {
    type = "bool-setting",
    name = "enable-small-thermobarics",
    setting_type = "startup",
    default_value = true,
    order = "f0"
  },
  {
    type = "bool-setting",
    name = "enable-medium-thermobarics",
    setting_type = "startup",
    default_value = true,
    order = "f1"
  },
  {
    type = "bool-setting",
    name = "enable-large-thermobarics",
    setting_type = "startup",
    default_value = true,
    order = "f2"
  },

  {
    type = "bool-setting",
    name = "enable-small-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f3"
  },
  {
    type = "bool-setting",
    name = "enable-compact-small-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f4"
  },

  {
    type = "bool-setting",
    name = "enable-medium-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f5"
  },
  {
    type = "bool-setting",
    name = "enable-compact-medium-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f6"
  },

  {
    type = "bool-setting",
    name = "enable-large-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f7"
  },

  {
    type = "bool-setting",
    name = "enable-compact-large-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f8"
  },
  {
    type = "bool-setting",
    name = "enable-15kt",
    setting_type = "startup",
    default_value = true,
    order = "f9"
  },
  {
    type = "bool-setting",
    name = "enable-compact-15kt",
    setting_type = "startup",
    default_value = true,
    order = "fa"
  },
  {
    type = "bool-setting",
    name = "enable-fusion",
    setting_type = "startup",
    default_value = true,
    order = "fc"
  },

  {
    type = "bool-setting",
    name = "enable-compact-fusion",
    setting_type = "startup",
    default_value = true,
    order = "fd"
  },
  {
    type = "bool-setting",
    name = "enable-big-fusion-weapons",
    setting_type = "startup",
    default_value = true,
    order = "fh"
  },
  {
    type = "bool-setting",
    name = "enable-nuclear-tests",
    setting_type = "startup",
    default_value = true,
    order = "fg"
  },



  {
    type = "bool-setting",
    name = "TN-mushroom-cloud-style-nuclear-flash",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "a0",
  }
})

-- Paranoidal 9.0.0 (user decision 2026-11-15): only the runtime settings of the blasts are shown. Startup
-- settings (materials, charge tiers, carriers, nuclear tests) are fixed to the build's values: one changed
-- box breaks the progression the build is balanced for.
local fixed = {}
for _, name in pairs({
  "small-boom-material", "small-boom-material-name", "boom-material", "boom-material-name", "dead-material",
  "dead-material-name", "computer-material", "computer-material-name", "light-material",
  "light-material-name", "enable-small-thermobarics", "enable-medium-thermobarics",
  "enable-large-thermobarics", "enable-small-atomics", "enable-compact-small-atomics",
  "enable-medium-atomics", "enable-compact-medium-atomics", "enable-large-atomics",
  "enable-compact-large-atomics", "enable-15kt", "enable-compact-15kt", "enable-fusion",
  "enable-compact-fusion", "enable-big-fusion-weapons", "enable-nuclear-tests", "enable-cannon-shell",
  "enable-small-rocket", "enable-big-rocket", "enable-artillery-shell", "enable-land-mine"
}) do fixed[name] = true end
local startup = {}
for _, kind in pairs({"bool-setting", "string-setting", "double-setting"}) do
  for name, s in pairs(data.raw[kind] or {}) do
    if s.setting_type == "startup" and fixed[name] then startup[#startup + 1] = s end
  end
end
for _, s in pairs(startup) do
  s.hidden = true
  if s.type == "bool-setting" then
    s.forced_value = s.default_value
  elseif s.type == "string-setting" then
    s.allowed_values = {s.default_value}
  else
    s.minimum_value, s.maximum_value = s.default_value, s.default_value
  end
end
