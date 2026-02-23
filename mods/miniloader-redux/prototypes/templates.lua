---@meta
------------------------------------------------------------------------
-- Loader templates
------------------------------------------------------------------------

local util = require('util')
local const = require('lib.constants')

local supported_mods = {
    ['base'] = 'base',
    ['space-age'] = 'space_age',
    ['matts-logistics'] = 'matt',
    ['Krastorio2'] = 'krastorio',
    ['boblogistics'] = 'bob',
    ['Load-Furn-2-SpaceAgeFix'] = 'adv_furnace_2',
    ['space-exploration'] = 'space_exploration',
}

-- contains switches for all enabled game modes. The keys are the canonical
-- values stores in the supported_mods table above.
---@type table<string, boolean>
local game_mode = {}
for mod_name, name in pairs(supported_mods) do
    if mods[mod_name] then
        game_mode[name] = true
    else
        game_mode[name] = false
    end
end

-- prototype processing functions for each game mode. These will be called before any
-- per-loader prototype processing functions, e.g. to set defaults.
---@type table<string, miniloader.PrototypeProcessor>)
local prototype_processors = {
    space_exploration = function(prototype)
        ---@diagnostic disable-next-line:inject-field
        prototype.se_allow_in_space = false
    end
}

local function check_base()
    return game_mode.base
end

local function check_space_age()
    return game_mode.space_age
end

local function check_chute()
    return Framework.settings:startup_setting(const.settings_names.chute_loader) == true
end

local function check_matt()
    return game_mode.matt
end

local function check_krastorio()
    return game_mode.krastorio
end

local function check_bob()
    return game_mode.bob and (settings.startup['bobmods-logistics-beltoverhaul'].value == true)
end

local function check_adv_furnace_2()
    -- that thing is a hot mess...
    local logistics_enabled = settings.startup['logist'] and settings.startup['logist'].value or false
    return game_mode.adv_furnace_2 and logistics_enabled
end

local function check_space_exploration()
    return game_mode.space_exploration
end

---@return data.VoidEnergySource energy_source
---@return number consumption_amount
---@return number drain_amount
local function energy_void()
    return { type = 'void' }, 0, 0
end

---@param prototype data.EntityWithOwnerPrototype
local function allow_in_space(prototype)
    ---@diagnostic disable-next-line:inject-field
    prototype.se_allow_in_space = true
end

-- highest available loader tier in the base / space age game
local max_loader = game_mode.space_age and 'turbo' or 'express'

---@param data table<string, any>
local function select_data(data)
    for name in pairs(game_mode) do
        if name ~= 'base' then
            -- mod + space age?
            if game_mode.space_age then
                local sa_name = name .. '_space_age'
                if data[sa_name] then return data[sa_name] end
            end
            -- just mod?
            if data[name] then return data[name] end
        end
    end

    -- when an inserter tier is under a condition switch, then
    -- the data must exist under that condition (e.g. for mod 'xxx', the
    -- data must have an 'xxx' key). Otherwise, it will fall back to base which
    -- may not exist
    assert(data.base, 'base data does not exist.')
    return data.base
end

---@type table<string, miniloader.LoaderDefinition>
local loaders = {
    -- regular miniloader, base game
    [''] = {
        condition = check_base,
        data = function()
            -- bob adds a tier below the regular belts and above the chute
            -- tweak the regular loader to accommodate for that
            local previous = game_mode.bob and 'bob-basic' or 'chute'

            return {
                order = 'd[a]-m',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('ffc340d9'),
                speed = data.raw['transport-belt']['transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                ingredients = function()
                    return select_data {
                        base = {
                            { type = 'item', name = 'underground-belt', amount = 1 },
                            { type = 'item', name = 'steel-plate',      amount = 4 },
                            { type = 'item', name = 'inserter',         amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        base = { 'logistics', 'steel-processing', 'electronics' },
                    }
                end,
                speed_config = {
                    items_per_second = 15,
                    rotation_speed = 0.075,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,
    },
    -- fast miniloader, base game
    ['fast'] = {
        condition = check_base,
        data = function(dash_prefix)
            local previous = ''

            return {
                order = 'd[a]-n',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('e31717d9'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                ingredients = function()
                    return select_data {
                        base = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = dash_prefix .. 'inserter',         amount = 2 },
                        },
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'long-handed-inserter',            amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        base = { 'logistics-2', const:name_from_prefix(''), },
                    }
                end,
                speed_config = {
                    items_per_second = 30,
                    rotation_speed = 0.125,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,
    },
    -- express miniloader, base game
    ['express'] = {
        condition = check_base,
        data = function(dash_prefix)
            local previous = 'fast'

            return {
                order = 'd[a]-o',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('43c0fad9'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                ingredients = function()
                    return select_data {
                        base = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bulk-inserter',                   amount = 2 },
                        },
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'fast-inserter',                   amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        base = { 'logistics-3', const:name_from_prefix('fast'), },
                    }
                end,
                speed_config = {
                    items_per_second = 45,
                    rotation_speed = 0.125,
                    inserter_pairs = 1,
                    stack_size_bonus = 1,
                },
            }
        end,
    },

    -- turbo miniloader, space age game
    ['turbo'] = {
        condition = check_space_age,
        data = function(dash_prefix)
            local previous = 'express'

            return {
                order = 'd[a]-p',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('A8D550d9'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                ingredients = function()
                    return select_data {
                        base = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bulk-inserter',                   amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        space_age = { 'turbo-transport-belt', 'metallurgic-science-pack', const:name_from_prefix('express'), },
                    }
                end,
                speed_config = {
                    items_per_second = 60,
                    rotation_speed = 0.25,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,
    },

    -- stack miniloader, space age game
    ['stack'] = {
        condition = check_space_age,
        data = function()
            local previous = 'turbo'

            return {
                order = 'd[a]-t',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('ffffffd9'),
                speed = data.raw['transport-belt']['turbo-transport-belt'].speed,
                bulk = true,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = 'turbo', -- use turbo animations, explosion etc.
                belt_gfx = 'turbo',
                ingredients = function()
                    return select_data {
                        space_age = {
                            { type = 'item', name = const:name_from_prefix(previous), amount = 1 },
                            { type = 'item', name = 'turbo-underground-belt',         amount = 1 },
                            { type = 'item', name = 'stack-inserter',                 amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        space_age = { 'logistics-3', 'stack-inserter', const:name_from_prefix('turbo'), },
                    }
                end,
                speed_config = {
                    items_per_second = 60,
                    rotation_speed = 0.25,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,
    },

    -- gravity assisted chute loader
    ['chute'] = {
        condition = check_chute,
        data = function()
            local gfx = game_mode.bob and 'bob-basic' or ''

            return {
                order = 'd[a]-h',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('b7410e'),
                speed = data.raw['transport-belt']['transport-belt'].speed / 4,
                energy_source = energy_void,
                research_trigger = {
                    type = 'craft-item', item = 'iron-gear-wheel', count = 100,
                },
                corpse_gfx = '',
                belt_gfx = gfx,
                nerf_mode = true,
                ingredients = function()
                    return select_data {
                        base = {
                            { type = 'item', name = 'transport-belt',  amount = 1 },
                            { type = 'item', name = 'iron-plate',      amount = 4 },
                            { type = 'item', name = 'burner-inserter', amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    local technology = game_mode.bob and 'logistics-0' or 'logistics'
                    return select_data {
                        base = { technology },
                    }
                end,
                speed_config = {
                    items_per_second = 3.75,
                    rotation_speed = 0.01875,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,
    },

    -- =================================================
    -- == Matt's logistics
    -- =================================================

    ['ultra-fast'] = {
        condition = check_matt,
        data = function(dash_prefix)
            local previous = game_mode.space_age and 'turbo' or 'express'

            return {
                order = 'd[b]-a',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('2ac217'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = max_loader, -- animations, explosion etc.
                entity_gfx = 'matt',
                ingredients = function()
                    return select_data {
                        matt = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bulk-inserter',                   amount = 4 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        matt = { 'logistics-4', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 90,
                    rotation_speed = 0.25,
                    inserter_pairs = 1,
                    stack_size_bonus = 3,
                },
            }
        end,
    },
    ['extreme-fast'] = {
        condition = check_matt,
        data = function(dash_prefix)
            local previous = 'ultra-fast'

            return {
                order = 'd[b]-b',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c34722'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = max_loader, -- animations, explosion etc.
                entity_gfx = 'matt',
                ingredients = function()
                    return select_data {
                        matt = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 2 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bulk-inserter',                   amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        matt = { 'logistics-5', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 180,
                    rotation_speed = 0.5,
                    inserter_pairs = 2,
                    stack_size_bonus = 2,
                },
            }
        end,
    },
    ['ultra-express'] = {
        condition = check_matt,
        data = function(dash_prefix)
            local previous = 'extreme-fast'

            return {
                order = 'd[b]-c',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('5a17c2'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = max_loader, -- animations, explosion etc.
                entity_gfx = 'matt',
                ingredients = function()
                    return select_data {
                        matt = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 2 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bulk-inserter',                   amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        matt = { 'logistics-6', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 270,
                    rotation_speed = 0.5,
                    inserter_pairs = 3,
                    stack_size_bonus = 2,
                },
            }
        end,
    },
    ['extreme-express'] = {
        condition = check_matt,
        data = function(dash_prefix)
            local previous = 'ultra-express'

            return {
                order = 'd[b]-d',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('1146d4'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = max_loader, -- animations, explosion etc.
                entity_gfx = 'matt',
                ingredients = function()
                    return select_data {
                        matt = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 2 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bulk-inserter',                   amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        matt = { 'logistics-7', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 360,
                    rotation_speed = 0.5,
                    inserter_pairs = 4,
                    stack_size_bonus = 2,
                },
            }
        end,
    },
    ['ultimate'] = {
        condition = check_matt,
        data = function(dash_prefix)
            local previous = 'extreme-express'

            return {
                order = 'd[b]-e',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('a6a6a6'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = max_loader, -- animations, explosion etc.
                entity_gfx = 'matt',
                ingredients = function()
                    return select_data {
                        matt = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 2 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bulk-inserter',                   amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        matt = { 'logistics-8', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 450,
                    rotation_speed = 0.5,
                    inserter_pairs = 4,
                    stack_size_bonus = 7,
                },
            }
        end,
    },

    -- =================================================
    -- == Krastorio 2
    -- =================================================

    ['kr-advanced'] = {
        condition = check_krastorio,
        data = function(dash_prefix)
            local previous = 'express'

            return {
                order = 'd[c]-a',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('22ec17'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                explosion_gfx = '',
                ingredients = function()
                    return select_data {
                        krastorio = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'kr-rare-metals',                  amount = 10 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        krastorio = { 'kr-logistic-4', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 60,
                    rotation_speed = 0.25,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,
    },
    ['kr-superior'] = {
        condition = check_krastorio,
        data = function(dash_prefix)
            local previous = 'kr-advanced'

            return {
                order = 'd[c]-b',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('d201f7'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                explosion_gfx = '',
                ingredients = function()
                    return select_data {
                        krastorio = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'kr-imersium-gear-wheel',          amount = 10 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        krastorio = { 'kr-logistic-5', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 90,
                    rotation_speed = 0.25,
                    inserter_pairs = 1,
                    stack_size_bonus = 3,
                },
            }
        end,
    },

    -- =================================================
    -- == Bob's Logistics
    -- =================================================

    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'chute'

            return {
                order = 'd[a]-l', -- slower than standard, faster than chute
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = '', -- use basic graphics for explosion and remnants
                ingredients = function()
                    local ingredients = {
                        { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                        { type = 'item', name = 'bob-steam-inserter',              amount = 2 },
                    }

                    if check_chute() then
                        table.insert(ingredients, { type = 'item', name = const:name_from_prefix(previous), amount = 1 })
                    else
                        table.insert(ingredients, { type = 'item', name = 'iron-plate', amount = 4 })
                    end

                    return ingredients
                end,
                prerequisites = function()
                    local prerequisites = { 'logistics-0' }
                    if check_chute() then
                        table.insert(prerequisites, const:name_from_prefix(previous))
                    end

                    return prerequisites
                end,
                research_trigger = {
                    type = 'craft-item', item = 'iron-gear-wheel', count = 200,
                },
                energy_source = energy_void,
                -- I really would like to make this steam powered just as the steam inserter
                -- but I can't seem to get this to work. So we keep this on electricity for now
                --
                -- energy_source = function()
                --     local inserter = assert(data.raw.inserter['bob-steam-inserter'])
                --     ---@type data.EnergySource
                --     local energy_source = util.copy(inserter.energy_source)
                --     energy_source.scale_fluid_usage = true
                --     energy_source.fluid_box.production_type = 'input'

                --     return energy_source, 25, 0
                -- end
                speed_config = {
                    items_per_second = 7.5,
                    rotation_speed = 0.046875,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,
    },
    ['bob-turbo'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'express'

            return {
                order = 'd[a]-q',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('b700ff'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = '', -- use basic graphics for explosion and remnants
                ingredients = function()
                    local inserter = (settings.startup['bobmods-logistics-inserteroverhaul'].value == true)
                        and 'bob-turbo-inserter'
                        or 'bob-express-inserter'

                    return select_data {
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = inserter,                          amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        bob = { 'logistics-4', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 60,
                    rotation_speed = 0.25,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,

    },
    ['bob-ultimate'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'bob-turbo'

            return {
                order = 'd[a]-r',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('1aeb2e'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = '', -- use basic graphics for explosion and remnants
                ingredients = function()
                    local inserter = (settings.startup['bobmods-logistics-inserteroverhaul'].value == true)
                        and 'bob-express-inserter'
                        or 'bob-express-bulk-inserter'
                    return select_data {
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = inserter,                          amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        bob = { 'logistics-5', const:name_from_prefix(previous), },
                    }
                end,
                speed_config = {
                    items_per_second = 75,
                    rotation_speed = 0.1875,
                    inserter_pairs = 1,
                    stack_size_bonus = 3,
                },
            }
        end,

    },
    ['af2-pro-1'] = {
        condition = check_adv_furnace_2,
        data = function()
            local previous = 'express'

            return {
                order = 'd[d]-a',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('eea500'),
                speed = data.raw['transport-belt']['transport-belt-pro'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = '', -- use basic graphics for explosion and remnants
                ingredients = function()
                    return select_data {
                        adv_furnace_2 = {
                            { type = 'item', name = const:name_from_prefix(previous), amount = 1 },
                            { type = 'item', name = 'underground-belt-pro',           amount = 1 },
                            { type = 'item', name = 'loader-pro-02',                  amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        adv_furnace_2 = { 'logistics-3', const:name_from_prefix(previous), },
                    }
                end,
                belt_color_selector = function(loader)
                    loader.belt_animation_set = util.copy(assert(data.raw['underground-belt']['underground-belt-pro'].belt_animation_set))
                end,
                speed_config = {
                    items_per_second = 75,
                    rotation_speed = 0.1875,
                    inserter_pairs = 1,
                    stack_size_bonus = 3,
                },
            }
        end,
    },
    ['af2-pro-2'] = {
        condition = check_adv_furnace_2,
        data = function()
            local previous = 'af2-pro-1'

            return {
                order = 'd[d]-b',
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('00fd53'),
                speed = data.raw['transport-belt']['transport-belt-pro2'].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = '', -- use basic graphics for explosion and remnants
                ingredients = function()
                    return select_data {
                        adv_furnace_2 = {
                            { type = 'item', name = const:name_from_prefix(previous), amount = 1 },
                            { type = 'item', name = 'underground-belt-pro2',          amount = 1 },
                            { type = 'item', name = 'loader-pro-03',                  amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        adv_furnace_2 = { 'logistics-3', const:name_from_prefix(previous), },
                    }
                end,
                belt_color_selector = function(loader)
                    loader.belt_animation_set = util.copy(assert(data.raw['underground-belt']['underground-belt-pro2'].belt_animation_set))
                end,
                speed_config = {
                    items_per_second = 105,
                    rotation_speed = 0.25,
                    inserter_pairs = 1,
                    stack_size_bonus = 5,
                },
            }
        end,
    },

    -- =================================================
    -- == Space Exploration
    -- =================================================

    ['se-space'] = {
        condition = check_space_exploration,
        data = function(dash_prefix)
            return {
                order = 'd[e]-a',
                subgroup = 'belt',
                stack_size = 50,
                tint = { r = 240 / 255, g = 240 / 255, b = 240 / 255, a = 125 / 255 },
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                corpse_gfx = 'express',
                ingredients = function()
                    return select_data {
                        space_exploration = {
                            { type = 'item', name = dash_prefix .. 'transport-belt',   amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bulk-inserter',                   amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        space_exploration = { 'se-space-belt', },
                    }
                end,
                prototype_processor = allow_in_space,
                speed_config = {
                    items_per_second = 45,
                    rotation_speed = 0.125,
                    inserter_pairs = 1,
                    stack_size_bonus = 1,
                }
            }
        end,
    },

    ['se-deep-space'] = {
        condition = check_space_exploration,
        data = function(dash_prefix)
            local previous = 'se-space'
            local color = '-black'

            return {
                order = 'd[e]-b',
                subgroup = 'belt',
                stack_size = 50,
                tint = { r = 25 / 255, g = 25 / 255, b = 25 / 255, a = 200 / 255 },
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt' .. color].speed,
                upgrade_from = const:name_from_prefix(previous),
                corpse_gfx = 'express',

                ingredients = function()
                    return select_data {
                        space_exploration = {
                            { type = 'item', name = const:name_from_prefix(previous),           amount = 2 },
                            { type = 'item', name = dash_prefix .. 'underground-belt' .. color, amount = 1 },
                            { type = 'item', name = 'se-nanomaterial',                          amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        space_exploration = { 'se-deep-space-transport-belt', const:name_from_prefix(previous) },
                    }
                end,
                belt_color_selector = function(loader)
                    loader.belt_animation_set = util.copy(
                        assert(
                            data.raw['underground-belt'][dash_prefix .. 'underground-belt' .. color].belt_animation_set
                        )
                    )
                end,
                prototype_processor = allow_in_space,
                speed_config = {
                    items_per_second = 90,
                    rotation_speed = 0.25,
                    inserter_pairs = 1,
                    stack_size_bonus = 3,
                }
            }
        end
    },
}

---@class miniloader.LoaderTemplates
---@field game_mode table<string, boolean>
---@field prototype_processors table<string, miniloader.PrototypeProcessor>
---@field loaders table<string, miniloader.LoaderDefinition>
local templates = {
    game_mode = game_mode,
    prototype_processors = prototype_processors,
    loaders = loaders
}

return templates
