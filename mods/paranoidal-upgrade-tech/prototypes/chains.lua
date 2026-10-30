-- Upgrade chains of the mod: pure data, built by lib/chain.lua in data.lua.
--
-- Values are Beta 8 (zzzparanoidal 7.1.2 build, dump 2026-09-13): efficient-research 0.0.3 and
-- InfiniteTech 1.0.2 with the zzzparanoidal prerequisites on science packs.
--
-- Chain fields:
--   name     technology name without the level; also the locale key (technology-name/description)
--   icons    icon layers of every tier
--   order    sort order of the tiers (a tier may override it)
--   tiers    list of tiers, levels must follow each other from 1:
--     first, last     levels of this tier; last = "infinite" only for the last tier
--     effects         list of {modifier type, value per level}
--     count | count_formula   research units per level (formula: L = level)
--     ingredients     science packs of one unit, e.g. science.upto("chemical-science-pack")
--     time            seconds per unit
--     prerequisites   extra prerequisites; the previous tier is added automatically
--     order           optional, overrides the chain order

local chain = require("lib.chain")
local science = require("lib.science")

return {
    -- Directive 99-99 "Cost optimization" (efficient-research): +1% research productivity per level,
    -- paid with lab speed. Each tier needs the matching research-speed level, so the total lab speed
    -- bonus never drops below the base: after research-speed-1..N the sum stays positive.
    {
        name = "research-efficiency",
        icons = chain.constant_icon("__base__/graphics/technology/research-speed.png", "constant-mining-productivity"),
        tiers = {
            {
                first = 1, last = 3,
                effects = {{"laboratory-productivity", 0.01}, {"laboratory-speed", -0.06}},
                count_formula = "25*L+75",
                ingredients = science.upto("logistic-science-pack"),
                time = 45,
                prerequisites = {"research-speed-1"},
                order = "c-m-a-2",
            },
            {
                first = 4, last = 6,
                effects = {{"laboratory-productivity", 0.01}, {"laboratory-speed", -0.08}},
                count_formula = "25*L+100",
                ingredients = science.upto("logistic-science-pack"),
                time = 45,
                prerequisites = {"research-speed-2"},
                order = "c-m-b-2",
            },
            {
                first = 7, last = 9,
                effects = {{"laboratory-productivity", 0.01}, {"laboratory-speed", -0.10}},
                count_formula = "100*L-450",
                ingredients = science.upto("chemical-science-pack"),
                time = 45,
                prerequisites = {"research-speed-3"},
                order = "c-m-c-2",
            },
            {
                first = 10, last = 12,
                effects = {{"laboratory-productivity", 0.01}, {"laboratory-speed", -0.12}},
                count_formula = "500",
                ingredients = science.upto("chemical-science-pack"),
                time = 45,
                prerequisites = {"research-speed-4"},
                order = "c-m-d-2",
            },
            {
                first = 13, last = 16,
                effects = {{"laboratory-productivity", 0.01}, {"laboratory-speed", -0.09}},
                count_formula = "500",
                ingredients = science.upto("production-science-pack"),
                time = 45,
                prerequisites = {"research-speed-5"},
                order = "c-m-e-2",
            },
            {
                first = 17, last = 20,
                effects = {{"laboratory-productivity", 0.01}, {"laboratory-speed", -0.09}},
                count_formula = "100*L-1200",
                ingredients = science.upto("utility-science-pack"),
                time = 45,
                prerequisites = {"research-speed-6"},
                order = "c-m-f-2",
            },
        },
    },

    -- BnL LongCharge(TM) batteries (InfiniteTech): +10% worker robot battery per level,
    -- 11 finite levels, then infinite with the cost doubling every level.
    {
        name = "worker-robot-battery",
        icons = chain.constant_icon("__base__/graphics/technology/worker-robots-storage.png", "constant-battery"),
        order = "c-k-h-e",
        tiers = {
            {
                first = 1, last = 3,
                effects = {{"worker-robot-battery", 0.1}},
                count_formula = "100*L",
                ingredients = science.upto("chemical-science-pack"),
                time = 30,
                prerequisites = {"robotics", "chemical-science-pack"},
            },
            {
                first = 4, last = 7,
                effects = {{"worker-robot-battery", 0.1}},
                count_formula = "100*L",
                ingredients = science.upto("production-science-pack"),
                time = 45,
                prerequisites = {"production-science-pack"},
            },
            {
                first = 8, last = 11,
                effects = {{"worker-robot-battery", 0.1}},
                count_formula = "100*L",
                ingredients = science.upto("utility-science-pack"),
                time = 60,
                prerequisites = {"utility-science-pack"},
            },
            {
                first = 12, last = "infinite",
                effects = {{"worker-robot-battery", 0.1}},
                count_formula = "2^(L-11)*1000",
                ingredients = science.upto("space-science-pack"),
                time = 60,
                prerequisites = {"space-science-pack"},
            },
        },
    },
}
