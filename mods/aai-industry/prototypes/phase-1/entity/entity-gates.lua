local util = require("data-util")


local stone = data.raw.gate["gate"]
stone.icon = "__aai-industry__/graphics/icons/stone-gate.png"
util.replace_filenames_recursive(stone, "__base__/graphics", "__aai-industry__/graphics")
util.replace_filenames_recursive(stone, "entity/gate", "entity/stone-gate")

stone.fast_replaceable_group = data.raw.wall["stone-wall"].fast_replaceable_group
stone.max_health = data.raw.wall["stone-wall"].max_health
stone.next_upgrade = "concrete-gate"
stone.hide_resistances = false
stone.resistances = data.raw.wall["stone-wall"].resistances


local concrete = table.deepcopy(stone)
concrete.name = "concrete-gate"
concrete.minable.result = "concrete-gate"
concrete.icon = "__aai-industry__/graphics/icons/concrete-gate.png"
util.replace_filenames_recursive(concrete, "stone-gate", "concrete-gate")

concrete.max_health = data.raw.wall["concrete-wall"].max_health
concrete.next_upgrade = "steel-gate"
concrete.resistances = data.raw.wall["concrete-wall"].resistances


local steel = table.deepcopy(concrete)
steel.name = "steel-gate"
steel.minable.result = "steel-gate"
steel.icon = "__aai-industry__/graphics/icons/steel-gate.png"
util.replace_filenames_recursive(steel, "concrete-gate", "steel-gate")

steel.max_health = data.raw.wall["steel-wall"].max_health
steel.next_upgrade = nil
steel.resistances = data.raw.wall["steel-wall"].resistances
steel.attack_reaction = data.raw.wall["steel-wall"].attack_reaction
steel.mined_sound = data.raw.wall["steel-wall"].mined_sound
steel.vehicle_impact_sound = data.raw.wall["steel-wall"].vehicle_impact_sound


data:extend{concrete, steel}

-- todo: remnants (graphics already colored)
