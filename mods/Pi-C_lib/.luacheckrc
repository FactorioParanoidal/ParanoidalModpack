return {
  globals = {
    -- Math functions
    "abs", "ceil", "floor", "max", "min", "random", "sqrt",

    -- Factorio
    "mods", "settings", "data", "game", "script",
    "defines", "log", "math", "pairs", "remote", "rendering",
    "serpent", "string", "table", "table_size", "next",  "type", "util",
    "commands", "mod_gui",
    "storage",                  -- Used to be 'global' in Factorio <= 1.1.110
    "helpers", "prototypes",    -- New in Factorio 2.0

    -- Pi-C_lib
    "common", "PClib_must_log", "PClib_log",
  },

  ignore = {
    "213",  -- Unused loop variable
  },
  cache = true,

}
