local loader_rail = util.table.deepcopy(data.raw["straight-rail"]["straight-rail"])
loader_rail.name = "railloader-rail"
loader_rail.flags = {"player-creation"}

data:extend{loader_rail}