--[=[

    File containing the primary logic for the mod.

    Since v2.0.0 no more state is stored in the
    global table, and instead all information can
    be derived from the researched technologies.

]=]

local categories = require('categories')
local config = require('config')
local technology_formats = require('defines.technology_name_formats')
local setting_formats = require('defines.setting_name_formats')

local is_logging_enabled = false

local function plog(str, ...)
    if is_logging_enabled then
        log(('[qol] ' .. str):format(...))
    end
end

local function setting_is_research_enabled(category_name)
    return settings.startup[setting_formats.research_enabled:format(category_name)].value
end
local function setting_multiplier(category_name)
    return settings.global[setting_formats.multiplier:format(category_name)].value
end
local function setting_flat_bonus(category_name)
    return settings.global[setting_formats.flat_bonus:format(category_name)].value
end
local function setting_effect_enabled(category_name, effect_toggle)
    return settings.global[setting_formats.effect_flag:format(category_name, effect_toggle)].value
end

--[=[
    Calculates the total bonus at a particular set of levels.

    @param  category  Category
    @param  levels    number[]
        The amount of finished researches in each tier
]=]
local function calculate_technology_bonus_at(category, levels)
    if not setting_is_research_enabled(category.name) then
        return 0
    end
    local tiers = config[category.name]
    assert(#levels == #tiers, 'levels size must be match tier count')
    local multiplier = setting_multiplier(category.name)

    local bonus = 0
    for index, tier in ipairs(tiers) do
        bonus = bonus + tier.bonus_per_technology * levels[index]
    end
    bonus = bonus * multiplier

    if category.type == 'double' then
        return bonus
    else
        return math.ceil(bonus)
    end
end

--[=[
    Determines how many technologies have been researched in a specific category
    and tier.
    @param  force          LuaForce
    @param  category       Category
    @param  tier_index     number
    @return number  Index of the technology within the tier that has
                    **finished** being researched.
--]=]
local function get_researched_count_within_tier(force, category, tier_index)
    if not setting_is_research_enabled(category.name) then return end
    local technology_count = config[category.name][tier_index].technology_count
    -- If infinite research
    if technology_count == 0 then
        return force.technologies[technology_formats.player:format(category.name, tier_index, 1)].level - 1
    end
    for i = technology_count, 1, -1 do
        if force.technologies[('qol-%s-%d-%d'):format(category.name, tier_index, i)].researched then
            return i
        end
    end
    return 0
end

--[=[
    Runs get_researched_count_within_tier for each tier.
    @param  force          LuaForce
    @param  category       Category
    @return number[]
]=]
local function get_tier_research_levels(force, category)
    local levels = {}
    for tier_index = 1, #config[category.name] do
        levels[tier_index] = get_researched_count_within_tier(force, category, tier_index)
    end
    return levels
end

--[=[
    Updates the field values for a specific force and category.
    @param  force          LuaForce
    @param  category       Category
]=]
local function update_for_force_and_category(force, category)
    local bonus = setting_flat_bonus(category.name)
    if setting_is_research_enabled(category.name) then
        local levels = get_tier_research_levels(force, category)
        bonus = bonus + calculate_technology_bonus_at(category, levels)
    end

    if bonus < 0 then
        plog('detected negative bonus for %q of value %s, clamping', category.name, bonus)
        bonus = 0
    end

    local internal_technology_count = category.internal_technology_spec.count
    local internal_value_scale = category.internal_technology_spec.value_scale
    for _, effect in ipairs(category.effects) do
        local remainder = math.ceil(bonus / internal_value_scale - 0.01)
        if category.effect_settings and
            category.effect_settings[effect] and
            not setting_effect_enabled(category.name, category.effect_settings[effect])
        then
            remainder = 0
        end
        local pending_disables = {}
        for n = internal_technology_count - 1, 0, -1 do
            local value = math.pow(2, n)
            local tech = force.technologies[technology_formats.internal:format(effect, n + 1)]

            if remainder >= value then
                remainder = remainder - value
                if not tech.researched then
                    plog(' enabled internal tech: %q (%d * %f) for force %q', tech.name, value, internal_value_scale, force.name)
                    tech.researched = true
                end
            elseif tech.researched then
                plog('disabled internal tech: %q (%d * %f) for force %q', tech.name, value, internal_value_scale, force.name)
                pending_disables[#pending_disables + 1] = tech
            end
        end

        for _, tech in ipairs(pending_disables) do
            tech.researched = false
            tech.enabled = false
        end
    end
end

--[=[
    Updates the field values for a specific force.
    @param  force          LuaForce
]=]
local function update_for_force(force)
    for _, category in ipairs(categories.list) do
        update_for_force_and_category(force, category)
    end
end

--[=[
    Updates the field values for a all forces.
]=]
local function update_for_all_forces()
    for _, force in pairs(game.forces) do
        update_for_force(force)
    end
end

--[=[
    Parses the name of a technology
    @param  research_name  string
    @return nothing or
            category          Category
            tier_index        number
            technology_index  number
]=]
local function parse_research_name(research_name)
    local category_name, tier_index, technology_index = research_name:match('^qol%-([a-z-]-)%-(%d+)%-(%d)$')
    if not category_name then return end

    local tiers = config[category_name]
    local category = categories.map[category_name]
    tier_index, technology_index = tonumber(tier_index), tonumber(technology_index)

    if not tiers or
        not category or
        not tier_index or
        not technology_index or
        tier_index < 1 or
        tier_index > #tiers or
        technology_index < 1
        then
        game.print(('[qol] warning: unknown technology, bug or conflicting mod? %q'):format(research_name))
        return
    end

    return category, tier_index, technology_index
end

-- Handles adding bonuses for completed research
script.on_event(defines.events.on_research_finished, function (event)
    local research = event.research
    local force = research.force

    local category = parse_research_name(research.name)
    if not category then return end

    plog('research completed %q', research.name)
    update_for_force_and_category(force, category)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function ()
    log('setting changed')
    update_for_all_forces()
end)
script.on_init(function ()
    update_for_all_forces()
end)

script.on_event(defines.events.on_player_created, function (event)
    local player = game.players[event.player_index]
    if player.admin then
        player.print('[qol] Quality of Life Research v3 is installed')
        player.print('[qol] Check out https://qol-research.aidiakapi.com/ if you want to create your own configuration!')
    end
end)

script.on_configuration_changed(function (changes)
    local was_logging_enabled = is_logging_enabled
    is_logging_enabled = true

    plog('configuration change detected, updating for all forces and resetting technology effects')
    update_for_all_forces()
    for _, force in pairs(game.forces) do
        force.reset_technology_effects()
    end

    is_logging_enabled = was_logging_enabled

    local qol_research = changes.mod_changes.qol_research
    if qol_research ~= nil then
        local old_version = qol_research.old_version
        if old_version ~= nil then
            local version_major = old_version:match('^(%d+).(%d+).%d+$')
            version_major = tonumber(version_major)

            if version_major < 3 then
                game.print(('[qol] Updated to version 3'))
                game.print('[qol] Check out https://qol-research.aidiakapi.com/ if you want to create your own configuration!')
            end
        end
    end
end)

commands.add_command('qol-sync', [[Syncs all technology effects, you can run this manually after using commands or mods to undo researching a technology.]], function (event)
    local player = game.players[event.player_index]
    if player.admin then
        local was_logging_enabled = is_logging_enabled
        is_logging_enabled = true
        player.print('[qol] Synced, any details can be found in the log file.')
        update_for_all_forces()
        plog('syncing completed')
        is_logging_enabled = was_logging_enabled
    else
        player.print('[qol] You must be an admin to run this command.')
    end
end)

commands.add_command('qol-reset-technology-effects', [[Calls LuaForce::reset_technology_effects() for all forces.]], function (event)
    local player = game.players[event.player_index]
    if player.admin then
        for _, force in pairs(game.forces) do
            force.reset_technology_effects()
        end
        player.print('[qol] Technology effects reset.')
    else
        player.print('[qol] You must be an admin to run this command.')
    end
end)
