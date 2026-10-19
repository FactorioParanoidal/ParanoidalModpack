-- Paranoidal: progression of factory buildings.
-- Hidden technologies with a "scripted" trigger mark events for Milestones (script/stats.lua researches them
-- through LuaForce::script_trigger_research). They unlock nothing and cannot be researched in labs.
-- Tips and tricks explain the rules of factory buildings.

local F = "__factorissimo-2-notnotmelon__"
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

data:extend {
    {type = "tips-and-tricks-item-category", name = category, order = "z-factorissimo"},
    tip("introduction", "a", unlocked, {indent = 0, is_title = true, tag = "[item=factory-1]"}),
    tip("connections", "b", unlocked),
    tip("connection-research", "c", {type = "research", technology = "factory-connection-type-fluid"}),
    tip("connection-settings", "d", {type = "research", technology = "factory-connection-type-fluid"}),
    tip("recursion", "e", {type = "research", technology = "factory-recursion-t1"}),
    tip("dispatch", "f", unlocked, {tag = "[img=factorissimo-dispatch-button]"}),
    tip("hull", "g", {type = "research", technology = "factory-hull-1"}),
}
