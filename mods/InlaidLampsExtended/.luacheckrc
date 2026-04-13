return {
  globals = {
    -- Factorio
    "mods", "settings", "data", "game", "script",
    "defines", "log", "math", "pairs", "remote", "rendering",
    "serpent", "string", "table", "table_size", "next",  "type", "util",
    "commands", "mod_gui",
    --~ "global",         -- Used in Factorio <=1.1.110
    -- New in Factorio 2.0
    "storage",        -- Used to be 'global' in Factorio <= 1.1.110
    "helpers", "prototypes",

    -- This mod

    -- Data stage
    "INLAID_LAMP_NAMES",

  },

  ignore = {
    "213",  -- Unused loop variable
  },
  cache = true,

}
