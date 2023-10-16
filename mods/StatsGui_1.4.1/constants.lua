local constants = {}

constants.builtin_sensors = {
  { name = "research", enabled = true, order = "ba" },
  { name = "position", enabled = false, order = "bb" },
  { name = "evolution", enabled = true, order = "bc" },
  { name = "pollution", enabled = false, order = "bd" },
  { name = "playtime", enabled = true, order = "be" },
  { name = "daytime", enabled = true, order = "bf" },
}

constants.interface_version = 1

constants.research_progress_samples_count = 3

return constants
