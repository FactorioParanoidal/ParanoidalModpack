local DLL = require("prototypes.globals")

-- re-apply signal colours from vanilla lamp in case any other mod has added more
local signal_colours = data.raw.lamp["small-lamp"].signal_to_color_mapping
if signal_colours then
    data.raw.lamp[DLL.name].signal_to_color_mapping = signal_colours
end

-- Function to add recipes to specific crafting machines
local function add_to_crafting_machines(recipe_name, machines)
    if data.raw.recipe[recipe_name] then
        for _, machine in pairs(machines) do
            if data.raw["assembling-machine"][machine] then
                table.insert(data.raw["assembling-machine"][machine].crafting_categories, recipe_name)
            end
        end
    end
end

-- Define the AAI assembling machines
local aai_machines = { "aai-assembling-machine", "aai-manual-crafter" }

-- Add recipes to these machines
for _, recipe_name in pairs({ DLL.name, DLL.copper_name, DLL.electric_copper_name, DLL.floor_name }) do
    add_to_crafting_machines(recipe_name, aai_machines)
end
