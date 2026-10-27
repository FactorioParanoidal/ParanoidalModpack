local MOD = "__flamethrower-wagon-reforged__"
local NAME = "flamethrower-wagon"

local base_entity = data.raw["fluid-wagon"]["fluid-wagon"]
local base_item = data.raw["item-with-entity-data"]["fluid-wagon"]

local entity = table.deepcopy(base_entity)
entity.name = NAME
entity.icons = nil
entity.icon = MOD .. "/graphics/icon.png"
entity.icon_size = 64
entity.minable = { mining_time = base_entity.minable.mining_time, result = NAME }
entity.placeable_by = nil
entity.next_upgrade = nil
entity.fast_replaceable_group = nil
entity.factoriopedia_simulation = nil
entity.minimap_representation = {
    filename = MOD .. "/graphics/minimap-representation.png",
    flags = { "icon" },
    size = { 20, 40 },
    scale = 0.5,
}
entity.selected_minimap_representation = {
    filename = MOD .. "/graphics/selected-minimap-representation.png",
    flags = { "icon" },
    size = { 20, 40 },
    scale = 0.5,
}
entity.allow_passengers = false
entity.tank_count = 1 -- one fluid storage: the script reads and drains storage 1
entity.capacity = 5000
entity.quality_affects_capacity = true
entity.max_health = 800

-- Immune to its own fire, whatever resistances the copied wagon had.
local resistances = {}
for _, r in pairs(entity.resistances or {}) do
    if r.type ~= "fire" then resistances[#resistances + 1] = r end
end
resistances[#resistances + 1] = { type = "fire", percent = 100 }
entity.resistances = resistances

local item = table.deepcopy(base_item)
item.name = NAME
item.icons = nil
item.pictures = nil
item.icon = MOD .. "/graphics/icon.png"
item.icon_size = 64
item.order = "c[rolling-stock]-d[aaflamethrower-wagon]"
item.stack_size = 10 -- as every fluid wagon of the build
item.place_result = NAME
item.localised_name = { "entity-name." .. NAME }
item.localised_description = { "entity-description." .. NAME }

local recipe = {
    type = "recipe",
    name = NAME,
    localised_name = { "entity-name." .. NAME },
    energy_required = 5,
    enabled = false,
    -- Paranoidal price: the turrets already carry 10 engines; the pump feeds them from the tank,
    -- steel bearings carry the turret rings as in the other rolling stock of the build.
    ingredients = {
        { type = "item", name = "fluid-wagon", amount = 1 },
        { type = "item", name = "flamethrower-turret", amount = 2 },
        { type = "item", name = "pump", amount = 1 },
        { type = "item", name = "bob-steel-bearing", amount = 8 },
        { type = "item", name = "steel-plate", amount = 20 },
    },
    results = { { type = "item", name = NAME, amount = 1 } },
}

local technology = {
    type = "technology",
    name = NAME,
    icon = MOD .. "/graphics/technology.png",
    icon_size = 256,
    -- Right after the flamethrower, on its science tier (Bob's armoured trains come later, with blue).
    prerequisites = { "fluid-wagon", "flamethrower" },
    effects = { { type = "unlock-recipe", recipe = NAME } },
    unit = {
        count = 100,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "military-science-pack", 1 },
        },
        time = 30,
    },
}

data:extend({ entity, item, recipe, technology })
