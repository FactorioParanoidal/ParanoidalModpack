require "util"
local fire = util.table.deepcopy(data.raw.fire["fire-flame"])
fire.initial_lifetime = 600
fire.name="oil-fire-flame"
fire.damage_per_tick = {amount = 1, type = "fire"},
data:extend({fire})