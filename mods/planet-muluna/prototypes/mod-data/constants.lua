Muluna.constants.oxygen_per_MJ = 10000
Muluna.constants.oxygen_restriction_blacklist = {"cerys-radiative-tower"} --List of entities that should not have their surface conditions changed to require oxygen.

Muluna.constants.cargo_drop_spawn_imports = {}

Muluna.constants.cargo_drop_spawn_imports = { --Generated from Claude Code. See scripts/new_surface.lua.
    
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.engine-unit",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.steel-plate",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.plastic-bar",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.electric-furnace",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.electric-mining-drill",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.pipe",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.pipe-to-ground",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.chemical-plant",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.solar-panel",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.medium-electric-pole",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.tungsten-plate",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.holmium-plate",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.superconductor",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.carbon-fiber",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.spoilage",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.tree-seed",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.wood",
    "__planet-muluna__.scripts.cargo-drop-spawns.vanilla.iron-chest",

}

Muluna.constants.cargo_drop_rare_drops = {
        moshine = "moshine-tech-magnet",
        maraxsis = data.raw["item"]["maraxsis-ooozma-specimen"] and "maraxsis-ooozma-specimen" or "maraxsis-wyrm-specimen",
        corrundum = "platinum-plate",
        secretas = "gold-plate",
        tenebris = "quartz-crystal",
        ["tenebris-prime"] = "quartz-crystal",
        --janus = "janus-shiftite-alpha",
        castra = "nickel-plate",
        ["dea-dia-system"] = "fossil",
        terrapalus = "palusium-plate"
}



Muluna.constants.recycling_recipes_to_fix = {"copper-cable"}


Muluna.constants.robot_names = {"construction-robot","logistic-robot"}