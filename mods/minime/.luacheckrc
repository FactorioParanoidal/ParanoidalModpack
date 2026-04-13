return {
  globals = {
    -- Math functions
    "abs", "ceil", "floor", "max", "min", "random", "sqrt",

    -- Factorio
    "mods", "settings", "data", "game", "script",
    "defines", "log", "math", "pairs", "remote", "rendering",
    "serpent", "string", "table", "table_size", "next",  "type", "util",
    "commands", "mod_gui",
    --~ "global",         -- Used in Factorio <=1.1.110
    -- New in Factorio 2.0
    "storage",        -- Used to be 'global' in Factorio <= 1.1.110
    "helpers", "prototypes",

    -- minime
    "minime", "minime_gui", "minime_gui_names", "minime_forces", "minime_player",
    "minime_character", "minime_corpse", "minime_inventories", "minime_surfaces",
    "minime_if", "minime_events", "minime_commands",

    "init",


    "common", "mod",

    -- Data stage
    "ignore_patterns",




    -- minime constants
    "MINIME_2_0",

    -- Other mods
    "AUTODRIVE", "NULLIUS", "BP_SANDBOXES",
  },

  ignore = {
    "213",  -- Unused loop variable
  },
  cache = true,

}
