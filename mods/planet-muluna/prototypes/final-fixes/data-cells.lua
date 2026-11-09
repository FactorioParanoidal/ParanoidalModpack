local rro =Muluna.rro

-- Paranoidal fork: home machines keep their fluid boxes and crafting categories; the data ports are on the own
-- data assembler (prototypes/entity/data-assembler.lua, data-updates), which also registers
-- crafting-with-fluid-and-data. Upstream rebuilt assembling-machine-3 and similar machines here.
local max_fluid_boxes=30 --Assuming that no modded machines have this many fluidboxes.
local dummy_fluidboxes = max_fluid_boxes-2

---Pin fluid ingredients/results away from the data port on recipes that can be
---crafted in a machine with one. A recipe that intentionally uses the data
---port sets fluidbox_index itself (the data recipes use index 30), so this
---leaves the port available to any data fluid rather than filtering it to one.
---
---This is public because another mod may replace a recipe's ingredient/result
---tables after Muluna's data-final-fixes. Such a mod can call this again after
---its own changes to restore the indexes.
function Muluna.data_fluids.apply_recipe_fluidbox_indexes()
    local machine_categories = {}
    for _,machine in pairs(data.raw["assembling-machine"]) do
        if rro.contains(machine.crafting_categories, "crafting-with-fluid-and-data") then
            machine_categories[#machine_categories + 1] = machine.crafting_categories
        end
    end

    local function craftable_in_data_port_machine(recipe)
        local categories = recipe.categories or {"crafting"}
        for _,categories_available in pairs(machine_categories) do
            -- Recipe categories are alternatives: a machine can craft the
            -- recipe when it has any one of them. Recipes often add extra
            -- machine categories (for example electric-engine-unit has
            -- mechanics and maraxsis-hydro-plant alongside crafting-with-fluid).
            if rro.contains_any(categories_available, categories) then
                return true
            end
        end
        return false
    end

    -- Match every recipe that is craftable in a machine with a data port,
    -- rather than only the vanilla "crafting-with-fluid" category, so modded
    -- fluid categories (for example Castra's "castra-crafting-with-fluid")
    -- are covered too.
    for _,recipe in pairs(data.raw["recipe"]) do
        if craftable_in_data_port_machine(recipe) then
            for _,entries in pairs({recipe.ingredients,recipe.results}) do
                local i = 1
                if rro.count(entries,function(entry) return entry.type == "fluid" end) <= 1 then
                    for _,entry in pairs(entries) do
                        if entry.type == "fluid" and (entry.fluidbox_index == nil or entry.fluidbox_index == 0) then
                            entry.fluidbox_index = i
                            entry.optional_fluidbox_indexes = rro.range(2,25)
                            i = i + 1
                        end
                    end
                end
            end
        end
    end
end

Muluna.data_fluids.apply_recipe_fluidbox_indexes()

local crusher_2 = data.raw["assembling-machine"]["muluna-crusher-2"]

crusher_2.fluid_boxes = {

}
local crusher_linked_connection_id=100
while #crusher_2.fluid_boxes <= dummy_fluidboxes do
        crusher_linked_connection_id = crusher_linked_connection_id + 1
        table.insert(crusher_2.fluid_boxes,Muluna.data_fluids.dummy_fluidbox("input","input",crusher_linked_connection_id))
    end

table.insert(crusher_2.fluid_boxes, {production_type = "input",
                volume = 50,
                base_area = 1,
                height = 2,
                base_level = -1,
                pipe_connections = {
                    {connection_category="data", flow_direction = "input", direction = defines.direction.east, position = {0.5, -1}},
                },
                
                })