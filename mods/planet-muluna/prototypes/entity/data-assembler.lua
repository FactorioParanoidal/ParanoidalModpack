-- Paranoidal fork: the data ports of Muluna live in an own machine, the data assembler, unlocked with the telescope.
-- Upstream rebuilt the home assembling machine 3 in data-final-fixes (about 60 fluid boxes, a new crafting category)
-- and pinned the fluid boxes of every home recipe it can craft: in Paranoidal the home machine has pass-through boxes
-- (the rotated data ports collided with them) and nothing before the rocket may change. The machine is made here, in
-- data-updates, so that the build's data-final-fixes (quality, defects, production modes, modules, recycling) see it.
local rro = Muluna.rro

local NAME = "muluna-data-assembler"
local DATA_CATEGORY = "crafting-with-fluid-and-data"
local MAX_FLUID_BOXES = 30 -- data fluids use fluidbox_index 30 (see prototypes/overrides/data-cells.lua)

local function rotate_position(position)
    local x = position.x or position[1]
    local y = position.y or position[2]
    return {-y, x}
end

local rotate_direction = {
    [defines.direction.north] = defines.direction.east,
    [defines.direction.south] = defines.direction.west,
    [defines.direction.east] = defines.direction.north,
    [defines.direction.west] = defines.direction.south,
}

-- Upstream data-cells.lua: one ordinary input and output box, then for each of them 28 dummy boxes and a copy
-- turned by 90° on the "data" connection category, so the data port is the 30th input and the 30th output box.
local function add_data_ports(machine)
    local linked_connection_id = 100
    local boxes = {machine.fluid_boxes[1], machine.fluid_boxes[2]}
    for _, original in pairs(boxes) do
        local box = table.deepcopy(original)
        for _ = 1, MAX_FLUID_BOXES - 2 do
            linked_connection_id = linked_connection_id + 1
            table.insert(machine.fluid_boxes, Muluna.data_fluids.dummy_fluidbox(box.production_type,
                box.pipe_connections[1].flow_direction, linked_connection_id))
        end
        box.pipe_picture = nil
        box.pipe_picture_frozen = nil
        box.pipe_covers = nil
        box.pipe_covers_frozen = nil
        for _, connection in pairs(box.pipe_connections) do
            connection.position = rotate_position(connection.position)
            connection.connection_category = "data"
            connection.direction = rotate_direction[connection.direction] or connection.direction
        end
        table.insert(machine.fluid_boxes, box)
    end
    machine.use_mirroring = true
end

local am3 = data.raw["assembling-machine"]["assembling-machine-3"]
local am3_item = data.raw["item"]["assembling-machine-3"]
if not (am3 and am3_item) then return end

local machine = table.deepcopy(am3)
machine.name = NAME
machine.localised_name = nil
machine.localised_description = nil
machine.minable = {mining_time = (am3.minable and am3.minable.mining_time) or 0.2, result = NAME}
machine.next_upgrade = nil
machine.crafting_categories = {DATA_CATEGORY}
machine.icon = nil
machine.icons = Muluna.icons.dual_icon("assembling-machine-3", "muluna-astronomical-data")
machine.icon_size = nil

-- Two plain boxes like the vanilla machine (input north, output south); the data ports then sit east and west.
local input = table.deepcopy(am3.fluid_boxes and am3.fluid_boxes[1] or {production_type = "input", volume = 1000})
local output = table.deepcopy(am3.fluid_boxes and am3.fluid_boxes[2] or {production_type = "output", volume = 1000})
input.production_type = "input"
output.production_type = "output"
input.pipe_connections = {{flow_direction = "input", direction = defines.direction.north, position = {0, -1}}}
output.pipe_connections = {{flow_direction = "output", direction = defines.direction.south, position = {0, 1}}}
machine.fluid_boxes = {input, output}
machine.fluid_boxes_off_when_no_fluid_recipe = true
add_data_ports(machine)

local item = table.deepcopy(am3_item)
item.name = NAME
item.localised_name = nil
item.localised_description = nil
item.place_result = NAME
item.subgroup = "muluna-telescope"
item.order = "b[" .. NAME .. "]"
item.icon = nil
item.icons = machine.icons
item.icon_size = nil

local recipe = {
    type = "recipe",
    name = NAME,
    enabled = false,
    energy_required = 10,
    ingredients = {
        {type = "item", name = "assembling-machine-3", amount = 1},
        {type = "item", name = "muluna-data-cable", amount = 10},
        {type = "item", name = "processing-unit", amount = 10},
    },
    results = {{type = "item", name = NAME, amount = 1}},
}

Muluna:extend{
    {
        type = "recipe-category",
        name = DATA_CATEGORY,
        order = "a[fluid]-b[data]",
    },
    machine,
    item,
    recipe,
}

local technology = data.raw["technology"]["muluna-telescope"]
if technology then
    technology.effects = technology.effects or {}
    rro.soft_insert(technology.effects, {type = "unlock-recipe", recipe = NAME})
end
