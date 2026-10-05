-- Approved circuit crafting rows; current IDs. Keep new 2.0 devices/icons.
return {
    rows = {
        {subgroup = "paranoidal-circuit-network", order = "a-01", recipes = {
            {["name"] = "hs_holo_sign", ["order"] = "01", ["icon"] = {["icon"] = "__zzzparanoidal__/graphics/circuit-menu-beta8/862e5ffa70d910c9cf1d.png", ["icon_size"] = 64}},
            {["name"] = "teleporter", ["order"] = "02"},
            {["name"] = "display-panel", ["order"] = "03"},
        }},
        {subgroup = "paranoidal-circuit-connection", order = "a-02", recipes = {
            {["name"] = "power-switch", ["order"] = "01"},
        }},
        {subgroup = "paranoidal-circuit-combinators", order = "a-03", recipes = {
            {["name"] = "arithmetic-combinator", ["order"] = "01"},
            {["name"] = "decider-combinator", ["order"] = "02"},
            {["name"] = "constant-combinator", ["order"] = "03"},
            {["name"] = "selector-combinator", ["order"] = "04"},
            {["name"] = "cybersyn-combinator", ["order"] = "05"},
        }},
        {subgroup = "paranoidal-circuit-visual", order = "a-04", recipes = {
            {["name"] = "deadlock-copper-lamp", ["order"] = "01", ["icon"] = {["icon"] = "__zzzparanoidal__/graphics/circuit-menu-beta8/f41f2849f5b20941d729.png", ["icon_size"] = 64}},
            {["name"] = "small-lamp", ["order"] = "02", ["icon"] = {["icon"] = "__zzzparanoidal__/graphics/circuit-menu-beta8/cdf15190566865c44761.png", ["icon_size"] = 64}},
            {["name"] = "deadlock-large-lamp", ["order"] = "03", ["icon"] = {["icon"] = "__zzzparanoidal__/graphics/circuit-menu-beta8/6648411e2caf0f0c146d.png", ["icon_size"] = 64}},
            {["name"] = "deadlock-floor-lamp", ["order"] = "04", ["icon"] = {["icon"] = "__zzzparanoidal__/graphics/circuit-menu-beta8/f3cdf75635771ed4e4c2.png", ["icon_size"] = 64}},
            {["name"] = "deadlock-electric-copper-lamp", ["order"] = "05"},
            {["name"] = "flat-lamp", ["order"] = "06"},
            {["name"] = "flat-lamp-big", ["order"] = "07"},
        }},
        {subgroup = "paranoidal-circuit-auditory", order = "a-05", recipes = {
            {["name"] = "programmable-speaker", ["order"] = "01"},
        }},
    },
}
