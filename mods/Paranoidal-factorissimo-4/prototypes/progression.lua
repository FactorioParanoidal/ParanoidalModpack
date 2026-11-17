-- Paranoidal: progression of factory buildings.
-- Hidden technologies with a "scripted" trigger mark events for Milestones (script/stats.lua researches them
-- through LuaForce::script_trigger_research). They unlock nothing and cannot be researched in labs.
-- Tips and tricks explain the rules of factory buildings.

local F = "__Paranoidal-factorissimo-4__"
local pf = "p-q-"

local function milestone(name, picture, order)
    return {
        type = "technology",
        name = name,
        icons = {{icon = F .. "/graphics/technology/" .. picture .. ".png", icon_size = 256}},
        hidden = true,
        essential = false,
        effects = {},
        research_trigger = {type = "scripted", trigger_description = {"technology-description." .. name}},
        order = pf .. "z-" .. order,
    }
end

data:extend {
    milestone("factory-milestone-nested", "factory-recursion-1", "a"),
    milestone("factory-milestone-clean", "factory-architecture-2", "b"),
}

-- Tips and tricks

local category = "factorissimo"
local function tip(name, order, trigger, extra)
    local item = {
        type = "tips-and-tricks-item",
        name = "factorissimo-" .. name,
        category = category,
        order = order,
        indent = 1,
        starting_status = "locked",
        trigger = trigger,
    }
    for k, v in pairs(extra or {}) do item[k] = v end
    return item
end

local unlocked = {type = "unlock-recipe", recipe = "factory-1"}
-- Paranoidal: language-neutral schemes (graphics/tips, drawn by the workspace tool tools/tips-schemes) and the
-- port animation (prototypes/tips-simulations.lua).
local images = "__Paranoidal-factorissimo-4__/graphics/tips/"
local simulations = require("prototypes.tips-simulations")

data:extend {
    {type = "tips-and-tricks-item-category", name = category, order = "z-factorissimo"},
    tip("introduction", "a", unlocked, {indent = 0, is_title = true, tag = "[item=factory-1]", image = images .. "introduction.png"}),
    tip("connections", "b", unlocked, {simulation = simulations.ports}),
    tip("connection-research", "c", {type = "research", technology = "factory-connection-type-fluid"},
        {image = images .. "connection-types.png"}),
    tip("connection-settings", "d", {type = "research", technology = "factory-connection-type-fluid"},
        {image = images .. "indicators.png"}),
    tip("recursion", "e", {type = "research", technology = "factory-recursion-t1"}, {image = images .. "recursion.png"}),
    tip("dispatch", "f", unlocked, {tag = "[img=factorissimo-dispatch-button]"}),
    tip("hull", "g", {type = "research", technology = "factory-hull-1"}, {image = images .. "hull.png"}),
}
