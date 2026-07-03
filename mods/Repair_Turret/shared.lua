--Shared data interface between data and script, notably prototype names.

local data = {}

data.entities =
{
  repair_turret = "repair-turret",
}

data.repair_range = settings.startup["repair_turret_range"].value

return data
