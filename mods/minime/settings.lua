------------------------------------------------------------------------------------
--                                Start-up settings                               --
------------------------------------------------------------------------------------
-- Settings for character scaling
data:extend({
  { -- Scale factor
    type = "int-setting",
    name = "minime_character-size",
    setting_type = "startup",
    default_value = 70,
    maximum_value = 250,
    minimum_value = 25,
    order = "[minime]-aa"
  },
  { -- Scale resource distance reach?
    type = "bool-setting",
    name = "minime_scale-reach_resource_distance",
    setting_type = "startup",
    default_value = false,
    order = "[minime]-ab"
  },
  { -- Scale tool attack distance?
    type = "bool-setting",
    name = "minime_scale-tool-attack-distance",
    setting_type = "startup",
    default_value = false,
    order = "[minime]-ac"
  },
})

-- Character-related, not scaling
data:extend({
  { -- Scale collision box of characters?
    type = "bool-setting",
    name = "minime_small-character-collision-box",
    setting_type = "startup",
    default_value = true,
    order = "[minime]-ba"
  },
  { -- Remove armor animations?
    type = "bool-setting",
    name = "minime_remove-armor-animations",
    setting_type = "startup",
    default_value = false,
    order = "[minime]-bb"
  },
})

-- Settings for GUI
data:extend({
  { -- Enable character selector?
    type = "bool-setting",
    name = "minime_character-selector",
    setting_type = "startup",
    default_value = true,
    order = "[minime]-ca"
  },
  { -- Icon scheme to use for shortcut or toggle button
    type = "string-setting",
    name = "minime_icon-scheme",
    setting_type = "startup",
    allowed_values = {
      "default",
      "plexpt_1",
      "plexpt_2",
    },
    default_value = "default",
    order = "[minime]-cb"
  },
})

-- Debugging
data:extend({
  { -- Enable debugging to log?
    type = "bool-setting",
    name = "minime_debug_to_log",
    setting_type = "startup",
    default_value = false,
    order = "[minime]-da"
  },
})


------------------------------------------------------------------------------------
--                                 Global settings                                --
------------------------------------------------------------------------------------
-- GUI-related
data:extend({
  { -- Show character removal buttons (entering god/editor mode)
    type = "bool-setting",
    name = "minime_show-character-removal-buttons",
    setting_type = "runtime-global",
    default_value = false,
    order = "[minime]-[map]-a"
  },
})


------------------------------------------------------------------------------------
--                                  User settings                                 --
------------------------------------------------------------------------------------
-- GUI-related
data:extend({
  { -- Close GUI when a character has been selected?
    type = "bool-setting",
    name = "minime_close-gui-on-selection",
    setting_type = "runtime-per-user",
    default_value = false,
    order = "[minime]-[user]-a"
  },
  { -- Use shortcut or toggle button to toggle character selector GUI?
    type = "string-setting",
    name = "minime_toggle-gui-with",
    setting_type = "runtime-per-user",
    allowed_values = {
      "button",
      "shortcut",
    },
    default_value = "button",
    order = "[minime]-[user]-b"
  },
})

-- Character-related
data:extend({
  { -- Follow mode when exiting editor/god mode
    type = "string-setting",
    name = "minime_followmode",
    setting_type = "runtime-per-user",
    allowed_values = {
      "player_follows_character",
      "character_follows_player",
    },
    default_value = "player_follows_character",
    order = "[minime]-[user]-c"
  },
})
