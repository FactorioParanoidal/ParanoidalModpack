data:extend({
  {
    type = "bool-setting",
    name = "autodeconstruct-preserve-inserter-chains",
    setting_type = "runtime-global",
    default_value = true,
    order = "ad-ab",
  },
  {
    type = "bool-setting",
    name = "autodeconstruct-remove-target",
    setting_type = "runtime-global",
    default_value = true,
    order = "ad-ab",
  },
  {
    type = "bool-setting",
    name = "autodeconstruct-remove-beacons",
    setting_type = "runtime-global",
    default_value = true,
    order = "ad-ac",
  },
  {
    type = "bool-setting",
    name = "autodeconstruct-remove-belts",
    setting_type = "runtime-global",
    default_value = false,
    order = "ad-ad",
  },
  {
    type = "bool-setting",
    name = "autodeconstruct-remove-wired-belts",
    setting_type = "runtime-global",
    default_value = false,
    order = "ad-ae",
  },
  {
    type = "bool-setting",
    name = "autodeconstruct-remove-tiles",
    setting_type = "runtime-global",
    default_value = false,
    order = "ad-af",
  },
  {
    type = "bool-setting",
    name = "autodeconstruct-remove-wired",
    setting_type = "runtime-global",
    default_value = false,
    order = "ad-aa",
  },
  {
    type = "bool-setting",
    name = "autodeconstruct-remove-fluid-drills",
    setting_type = "runtime-global",
    default_value = true,
    order = "ad-ba",
  },
  {
    type = "bool-setting",
    name = "autodeconstruct-build-pipes",
    setting_type = "runtime-global",
    default_value = true,
    order = "ad-bb",
  },
  {
    type = "string-setting",
    name = "autodeconstruct-pipe-name",
    setting_type = "runtime-global",
    default_value = "pipe",
    order = "ad-bc",
  },
  {
    type = "string-setting",
    name = "autodeconstruct-blacklist",
    setting_type = "runtime-global",
    default_value = "",
    allow_blank = true,
    order = "ad-ee"
  },
  {
    type = "string-setting",
    name = "autodeconstruct-ore-blacklist",
    setting_type = "runtime-global",
    default_value = "",
    allow_blank = true,
    order = "ad-ef"
  }
})
