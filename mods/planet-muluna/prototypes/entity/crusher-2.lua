Muluna:extend{
    {
        type = "recipe-category",
        name = "muluna-crusher-2"
    }
}
local flib_data_util=require("__flib__.data-util")


local crusher_2=table.deepcopy(data.raw["assembling-machine"]["crusher"])

-- Paranoidal fork: own name; "crusher-2" is a placeholder of the Angels recipe builder (it took the item for the
-- ingredient of the home ore crusher 2).
crusher_2.name="muluna-crusher-2"
crusher_2.module_slots=crusher_2.module_slots + 2
crusher_2.minable.result="muluna-crusher-2"
crusher_2.graphics_set = require("__muluna-graphics__.graphics.entities.crusher.crusher-2-pictures")
crusher_2.crafting_speed=crusher_2.crafting_speed*(mods["rigor-module"] and 1.25 or 1.5)
crusher_2.max_health=crusher_2.max_health+50
crusher_2.use_mirroring=true
local energy, suffix=flib_data_util.get_energy_value(crusher_2.energy_usage)
crusher_2.energy_usage=tostring(energy*2) .. suffix
crusher_2.energy_source.emissions_per_minute["pollution"] = crusher_2.energy_source.emissions_per_minute["pollution"]*0.75
table.insert(crusher_2.crafting_categories,"muluna-crusher-2")
--crusher_2.energy_usage=crusher_2.crafting_speed*2
crusher_2.localised_name={"",{"item-name.crusher"}," 2"}
crusher_2.icon="__muluna-graphics__/graphics/icons/crusher-2.png"

crusher_2.rigor_base_value=mods["rigor-module"] and 50 or nil

Muluna:extend{crusher_2}

data.raw["assembling-machine"]["crusher"].next_upgrade = crusher_2.name