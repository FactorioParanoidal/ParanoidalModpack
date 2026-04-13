---@class Squeakthrough.const
local const = {}

const.groups = {
    chests = {
        "container",
        "infinity-container",
        "linked-container",
        "logistic-container",
    },
    circuits = {
        "arithmetic-combinator",
        "constant-combinator",
        "decider-combinator",
        "lamp",
        "power-switch",
        "programmable-speaker",
        "selector-combinator",
    },
    drills = {
        "mining-drill",
    },
    machines = {
        "assembling-machine",
        "furnace",
        "lab",
        "rocket-silo",
    },
    pipes = {
        "heat-interface",
        "heat-pipe",
        "infinity-pipe",
        "offshore-pump",
        "pipe",
        "pipe-to-ground",
        "pump",
        "storage-tank",
    },
    solar = {
        "accumulator",
        "electric-energy-interface",
        "solar-panel",
    },
    steam = {
        "boiler",
        "burner-generator",
        "generator",
        "reactor",
    },
    trees = {
        "tree",
    },
    turrets = {
        "artillery-turret",
        "ammo-turret",
        "electric-turret",
        "fluid-turret",
    },
    misc = {
        "beacon",
        "electric-pole",
        "inserter",
        "radar",
        "roboport",
        "train-stop",
    }
}

const.overrides = {
    ["pipe"] = 0.1,
    ["pipe-to-ground"] = 0.1,
    ["tree"] = 0.2,
}

return const