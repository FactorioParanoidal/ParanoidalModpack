--[=[
    
    File containing the primary logic for the mod.

    Since v2.0.0 no more state is stored in the
    global table, and instead all information can
    be derived from the researched technologies.

]=]

local flua = require('flua')
local config_ext = require('config_ext')
local setting_name_formats = require('defines.setting_name_formats')
local player_technology_format = 'qol-%s-%d-%d'
local internal_technology_format = 'qolinternal-%s-%d'

local is_logging_enabled = false
local should_suppress_research_unlocks = false

local function plog(str, ...)
    if is_logging_enabled then
        log(('[qol] ' .. str):format(...))
    end
end

local function pprint(...)
    local message

    local n = select('#', ...)
    if n == 1 then
        message = '[qol] ' .. tostring(...)
    else
        local str = { '[qol] ' }
        for i = 1, n do
            local v = select(i, ...)
            str[i + 1] = tostring(v)
        end
        message = table.concat(str, '')
    end
    log(message)
    for _, player in pairs(game and game.players or {}) do
        player.print(message)
    end
end

--[=[
    Calculates the total bonus at a particular set of levels.

    Params:
      entry  ConfigExt
        The entry of research.
      levels  number[]
        The levels at which each tier is researched.
      multiplier number
        Optional. Override for the multiplier setting.
]=]
local function calculate_research_bonus_at(entry, levels, multiplier)
    if not entry.is_research_enabled then
        return 0
    end
    assert(#levels == #entry.config, 'levels size must be match tier count')
    if multiplier == nil then
        multiplier = entry.setting_multiplier
    end
    
    local value = flua.ipairs(entry.config)
        :map(function (index, tier)
            return tier.effect_value * levels[index]
        end, 1)
        :sum() * multiplier

    if entry.type == 'double' then
        return value
    else
        return math.ceil(value)
    end
end

--[=[
    Determines the current level at which a tier is researched at for a force.
    @param  force          LuaForce
    @param  entry          ConfigExt
    @param  research_tier  number     Tier index
    @return number  Index of the tier that was **finished** researching! 
--]=]
local function get_tier_research_level(force, entry, research_tier)
    if not entry.is_research_enabled then return end
    local tier_depth = entry.config[research_tier].tier_depth
    -- If infinite research
    if tier_depth == 0 then
        return force.technologies[('qol-%s-%d-1'):format(entry.name, research_tier)].level - 1
    end
    for i = tier_depth, 1, -1 do
        if force.technologies[('qol-%s-%d-%d'):format(entry.name, research_tier, i)].researched then
            return i
        end
    end
    return 0
end

--[=[
    Gets the level of each research tier.
    @param  force          LuaForce
    @param  entry          ConfigExt
    @return number[]  All research tier levels.
]=]
local function get_tier_research_levels(force, entry)
    return flua.range(#entry.config)
        :map(function (tier_index)
            return tier_index, get_tier_research_level(force, entry, tier_index)
        end, 2)
        :table()
end

--[=[
    Updates the field values for a specific force and entry.
    @param  force          LuaForce
    @param  entry          ConfigExt
]=]
local function update_for_force_and_entry(force, entry)
    if not entry.is_enabled then return end
    local bonus = entry.setting_flat_bonus
    if entry.is_research_enabled then
        local levels = get_tier_research_levels(force, entry)
        bonus = bonus + calculate_research_bonus_at(entry, levels)
    end
    
    if bonus < 0 then
        plog('detected negative bonus for %q of value %s, clamping', entry.name, bonus)
        bonus = 0
    end

    local technology_count = entry.field_technology.count
    local value_scale = entry.field_technology.value_scale
    for field in entry.fields:iter() do
        local remainder = math.ceil(bonus / value_scale - 0.01)
        if not entry.field_is_enabled[field] then
            remainder = 0
        end
        local pending_disables = {}
        for n = entry.field_technology.count - 1, 0, -1 do
            local value = math.pow(2, n)
            local tech = force.technologies[internal_technology_format:format(field, n + 1)]
            
            if remainder >= value then
                remainder = remainder - value
                if not tech.researched then
                    plog(' enabled internal tech: %q (%d * %f) for force %q', tech.name, value, value_scale, force.name)
                    tech.researched = true
                end
            elseif tech.researched then
                plog('disabled internal tech: %q (%d * %f) for force %q', tech.name, value, value_scale, force.name)
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
    for _, entry in ipairs(config_ext) do
        if entry.is_enabled then
            update_for_force_and_entry(force, entry)
        end
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
            entry           ConfigExt
            research_tier   number
            research_level  number
]=]
local function parse_research_name(research_name)
    local research_type, research_tier, research_level = research_name:match('^qol%-([a-z-]-)%-(%d+)%-(%d)$')
    if not research_type then return end

    local entry = flua.ivalues(config_ext):first(function (v) return v.name == research_type end)
    research_tier, research_level = tonumber(research_tier), tonumber(research_level)

    if not entry or
        not research_tier or
        not research_level or
        research_tier <= 0 or
        research_level <= 0 or
        research_tier > #entry.config
        then
        pprint('warning: unknown technology, bug or conflicting mod? ', research.name)
        return
    end

    return entry, research_tier, research_level
end

-- Handles adding bonuses for research 
script.on_event(defines.events.on_research_finished, function (event)
    if should_suppress_research_unlocks then return end
    local research = event.research
    local force = research.force

    local entry, research_tier, research_level = parse_research_name(research.name)
    if not entry then return end

    plog('research completed %q', research.name)
    update_for_force_and_entry(force, entry)
end)

-- Handles the modifications of the character bonus factors based on settings
local function on_init_or_runtime_mod_setting_changed()
    plog('init/runtime settings changed')
    update_for_all_forces()
end
script.on_init(on_init_or_runtime_mod_setting_changed)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_init_or_runtime_mod_setting_changed)

local function unlock_depended_upon_researches(force)
    should_suppress_research_unlocks = true
    local unlocked_total = 0
    local unlocked_previous = nil
    local techs = force.technologies

    -- Repeat the process until no more researches are unlocked
    while unlocked_total ~= unlocked_previous do
        unlocked_previous = unlocked_total
        local entries = flua.ivalues(config_ext)
            :filter(function (entry) return entry.is_research_enabled end)
        
        for entry in entries:iter() do
            -- Unlock researches that higher tiers depend on
            for tier_index, tier in flua.for_pairs(entry.config, #entry.config, 2, -1)
                :filter(function (_, tier) return tier.requirement ~= 0 end)
                :filter(function (index, tier)
                    local tech_name = player_technology_format:format(entry.name, index, 1)
                    return techs[tech_name].researched
                end)
                :iter() do
                local previous = techs[player_technology_format:format(entry.name, tier_index - 1, tier.requirement)]
                if not previous.researched then
                    plog('unlocked dependency \'%s\'', previous.name)
                    previous.researched = true
                    unlocked_total = unlocked_total + 1
                end
            end

            -- Unlock earlier entries in each tier
            for tier_index, tier in ipairs(entry.config) do
                local max_unlocked = flua.reverse_range(tier.tier_depth)
                    :first(function (index)
                        local tech_name = player_technology_format:format(entry.name, tier_index, index)
                        return techs[tech_name].researched
                    end)
                if max_unlocked ~= nil then
                    for tech in flua.reverse_range(max_unlocked - 1)
                        :filtermap(function (index)
                            local tech_name = player_technology_format:format(entry.name, tier_index, index)
                            local tech = techs[tech_name]
                            return (not tech.researched) and tech or nil
                        end):iter() do
                        plog('unlocked prior \'%s\'', tech.name)
                        tech.researched = true
                        unlocked_total = unlocked_total + 1
                    end
                end
            end
        end
    end
    
    should_suppress_research_unlocks = false
    return unlocked_total
end

script.on_configuration_changed(function (changes)
    plog('configuration change detected')

    -- Clear out the global table, it is no longer necessary
    for k, _ in pairs(global) do
        global[k] = nil
    end

    local qol_research = changes.mod_changes.qol_research
    local upgrade_from_v01 = false
    local reset_tech_effects = false
    if qol_research ~= nil then
        local old_version = qol_research.old_version
        if old_version ~= nil then
            local version_major, version_minor = old_version:match('^(%d+).(%d+).%d+$')
            version_major, version_minor = tonumber(version_major), tonumber(version_minor)

            upgrade_from_v01 = version_major == 0 and version_minor == 1

            if version_major < 2 or (version_major == 2 and version_minor < 2) then
                reset_tech_effects = true
            end
        end
    end

    local restore_count = flua.wrap(2, pairs(game.forces))
        :map(function (_, force)
            return unlock_depended_upon_researches(force)
        end, 1)
        :sum()
    if upgrade_from_v01 then
        if restore_count == 0 then
            pprint('Upgraded from beta version, you may have lost some researches.')
        elseif restore_count == 1 then
            pprint('Upgraded from beta version, 1 research was restored, but some may be lost.')
        else
            pprint(('Upgraded from beta version. %s researches were restored, but some may be lost.'):format(restore_count))
        end
    elseif restore_count > 0 then
        pprint(('Technology tree changed, %s depended upon researches were automatically unlocked.'):format(restore_count))
    end

    update_for_all_forces()

    if changes.mod_startup_settings_changed or reset_tech_effects then
        plog('resetting technology effects (startup settings changed: %s, mod structure change: %s)', changes.mod_startup_settings_changed, reset_tech_effects)
        for _, force in pairs(game.forces) do
            force.reset_technology_effects()
        end
    end
end)

commands.add_command('qol-reset', [[Syncs all technology effects, you can run this manually after using commands or mods to undo research.]], function (event)
    if game.players[event.player_index].admin then
        local was_logging_enabled = is_logging_enabled
        is_logging_enabled = true
        pprint('resetting, check factorio-current.log if you want details')
        update_for_all_forces()
        plog('reset completed')
        is_logging_enabled = was_logging_enabled
    else
        player.print('[qol] you must be an admin to run this command')
    end
end)
