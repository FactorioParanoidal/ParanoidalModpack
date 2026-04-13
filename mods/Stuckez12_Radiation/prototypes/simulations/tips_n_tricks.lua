local simulations = require("prototypes.simulations.tips_n_tricks_simulations")

data:extend({
    {
        type = "tips-and-tricks-item-category",
        name = "Stuckez12-Radiation",
        order = "x-[Stuckez12-Radiation]"
    },
    {
        type = "tips-and-tricks-item",
        name = "Stuckez12-uranium-patch-walk-over",
        tag = "[technology=radiation-protection][item=uranium-ore]",
        category = "Stuckez12-Radiation",
        order = "a",
        indent = 0,
        trigger = {
            type = "research",
            technology  = "chemical-science-pack"
        },
        simulation = simulations.uranium_patch_walk_over
    },
    {
        type = "tips-and-tricks-item",
        name = "Stuckez12-radiation-entity-list",
        tag = "[item=uranium-ore][item=steel-chest]",
        category = "Stuckez12-Radiation",
        order = "b",
        indent = 1,
        trigger = {
            type = "research",
            technology  = "uranium-mining"
        },
        simulation = simulations.radiation_entity_list
    },
    {
        type = "tips-and-tricks-item",
        name = "Stuckez12-radiation-distance-impact",
        tag = "[item=uranium-ore][virtual-signal=signal-rightwards-leftwards-arrow]",
        category = "Stuckez12-Radiation",
        order = "c",
        indent = 1,
        trigger = {
            type = "research",
            technology  = "uranium-processing"
        },
        simulation = simulations.radiation_distance_impact
    },
    {
        type = "tips-and-tricks-item",
        name = "Stuckez12-radiation-resistance",
        tag = "[item=uranium-ore][item=radiation-absorption-equipment][item=radiation-reduction-equipment]",
        category = "Stuckez12-Radiation",
        order = "d",
        indent = 1,
        trigger = {
            type = "research",
            technology  = "radiation-protection"
        },
        dependencies = {"Stuckez12-radiation-distance-impact"},
        simulation = simulations.radiation_resistance
    },
    {
        type = "tips-and-tricks-item",
        name = "Stuckez12-radiation-walls",
        tag = "[item=uranium-ore][item=radiation-wall]",
        category = "Stuckez12-Radiation",
        order = "e",
        indent = 1,
        trigger = {
            type = "research",
            technology  = "advanced-radiation-protection"
        },
        dependencies = {"Stuckez12-radiation-distance-impact"},
        simulation = simulations.radiation_walls
    },
    {
        type = "tips-and-tricks-item",
        name = "Stuckez12-radiation-biters",
        tag = "[item=uranium-ore][entity=big-biter]",
        category = "Stuckez12-Radiation",
        order = "f",
        indent = 1,
        trigger = {
            type = "research",
            technology  = "advanced-radiation-protection"
        },
        dependencies = {"Stuckez12-radiation-distance-impact"},
        simulation = simulations.radiation_biters
    },
    {
        type = "tips-and-tricks-item",
        name = "Stuckez12-radiation-suit",
        tag = "[item=uranium-ore][item=radiation-suit]",
        category = "Stuckez12-Radiation",
        order = "g",
        indent = 1,
        trigger = {
            type = "research",
            technology  = "near-total-radiation-protection"
        },
        dependencies = {"Stuckez12-radiation-biters"},
        simulation = simulations.radiation_suit
    }
})
