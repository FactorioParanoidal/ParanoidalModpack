-- Builds technology prototypes from chain descriptions (prototypes/chains.lua).
--
-- A chain is one upgrade line shown under one name; its tiers are separate technologies
-- "<chain>-<first level>" that cover the levels first..last. Each tier requires the previous one,
-- so the line reads as a single technology with growing level in the research screen.

local chain = {}

local function fail(message, ...)
    error("paranoidal-upgrade-tech: " .. string.format(message, ...), 2)
end

local function copy_list(list)
    local result = {}
    for index, value in ipairs(list or {}) do result[index] = value end
    return result
end

-- Layer list of a technology icon with the "constant" sign in the lower right corner,
-- laid out as util.technology_icon_constant_* of the base game does it.
function chain.constant_icon(picture, constant)
    return {
        {icon = picture, icon_size = 256},
        {
            icon = "__core__/graphics/icons/technology/constants/" .. constant .. ".png",
            icon_size = 128,
            scale = 0.5,
            shift = {50, 50},
            floating = true,
        },
    }
end

local function effects_of(tier)
    local effects = {}
    for index, effect in ipairs(tier.effects) do
        effects[index] = {type = effect[1], modifier = effect[2]}
    end
    return effects
end

-- Checks the description before anything is created: every mistake here is a mistake in chains.lua.
local function validate(description)
    if type(description.name) ~= "string" then fail("chain without a name") end
    if not description.icons then fail("chain '%s' has no icons", description.name) end
    local expected = 1
    for index, tier in ipairs(description.tiers or {}) do
        local where = description.name .. " tier " .. index
        if tier.first ~= expected then
            fail("%s starts at level %s, expected %d (levels must follow each other)", where, tostring(tier.first), expected)
        end
        if tier.last ~= "infinite" and (type(tier.last) ~= "number" or tier.last < tier.first) then
            fail("%s: last level must be a number >= first or \"infinite\"", where)
        end
        if tier.last == "infinite" and index ~= #description.tiers then
            fail("%s: only the last tier may be infinite", where)
        end
        if (tier.count == nil) == (tier.count_formula == nil) then
            fail("%s: set exactly one of count and count_formula", where)
        end
        if not (tier.effects and tier.effects[1]) then fail("%s has no effects", where) end
        if not (tier.ingredients and tier.ingredients[1]) then fail("%s has no ingredients", where) end
        if type(tier.time) ~= "number" or tier.time <= 0 then fail("%s: time must be a positive number", where) end
        expected = tier.last ~= "infinite" and tier.last + 1 or nil
    end
    if expected == 1 then fail("chain '%s' has no tiers", description.name) end
end

-- Technology name of a tier: the level is part of the name, the engine reads it from the "-<number>" suffix.
function chain.tier_name(description, tier)
    return description.name .. "-" .. tier.first
end

-- Returns the technology prototypes of one chain (not yet added to data).
function chain.build(description)
    validate(description)
    local technologies = {}
    local previous
    for _, tier in ipairs(description.tiers) do
        local name = chain.tier_name(description, tier)
        local prerequisites = copy_list(tier.prerequisites)
        if previous then table.insert(prerequisites, 1, previous) end
        local max_level
        if tier.last == "infinite" then
            max_level = "infinite"
        elseif tier.last > tier.first then
            max_level = tier.last
        end
        technologies[#technologies + 1] = {
            type = "technology",
            name = name,
            -- No localised_name: like base research-speed-N, the engine takes technology-name.<chain>
            -- for "<chain>-<level>" and shows the level itself.
            icons = table.deepcopy(description.icons),
            effects = effects_of(tier),
            prerequisites = prerequisites,
            unit = {
                count = tier.count,
                count_formula = tier.count_formula,
                ingredients = table.deepcopy(tier.ingredients),
                time = tier.time,
            },
            upgrade = true,
            max_level = max_level,
            order = tier.order or description.order,
        }
        previous = name
    end
    return technologies
end

-- Names of every technology created by the chains, in creation order.
function chain.names(descriptions)
    local names = {}
    for _, description in ipairs(descriptions) do
        for _, tier in ipairs(description.tiers) do names[#names + 1] = chain.tier_name(description, tier) end
    end
    return names
end

return chain
