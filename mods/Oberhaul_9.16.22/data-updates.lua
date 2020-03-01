local base_speed = 1/32
if settings.startup["bobmods-logistics-ugdistanceoverhaul"].value then
data.raw["transport-belt"]["basic-transport-belt"].speed = 0.5 * base_speed

end
data.raw["transport-belt"]["transport-belt"].speed = base_speed

data.raw["transport-belt"]["fast-transport-belt"].speed = 2 * base_speed

data.raw["transport-belt"]["express-transport-belt"].speed = 4 * base_speed

data.raw["transport-belt"]["turbo-transport-belt"].speed = 8 * base_speed