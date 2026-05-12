-- This file adds quality information to factoriopedia.

local FACTORY_PUMPING_SPEED = 12000 -- per second

-- returns the default buff amount per quality level in vanilla
local function get_quality_buff(quality_level)
    return 1 + quality_level * 0.3
end

local function add_quality_factoriopedia_info(entity, factoriopedia_info)
    entity.custom_tooltip_fields = entity.custom_tooltip_fields or {}

    for _, factoriopedia_info in pairs(factoriopedia_info or {}) do
        local stat_to_buff, factoriopedia_function = unpack(factoriopedia_info)

        local quality_values = {}
        for _, quality in pairs(data.raw.quality) do
            local quality_level = quality.level
            if quality.hidden then goto continue end
            quality_values[quality.name] = tostring(factoriopedia_function(entity, quality_level))
            ::continue::
        end

        table.insert(
            entity.custom_tooltip_fields,
            {
                name = {"description." .. stat_to_buff},
                quality_header = "quality-tooltip." .. stat_to_buff,
                value = tostring(factoriopedia_function(entity, 0)),
                quality_values = quality_values
            }
        )
    end
end

add_quality_factoriopedia_info(data.raw["storage-tank"]["factory-1"], {
    {"interior-space",       function(entity, quality_level) return "30×30" end},
    {"connections", function(entity, quality_level)
        local connection_count
        if quality_level <= 0 then
            connection_count = 16
        elseif quality_level == 1 then
            connection_count = 18
        elseif quality_level == 2 then
            connection_count = 20
        elseif quality_level == 3 then
            connection_count = 22
        elseif quality_level == 4 then
            connection_count = 24
        else
            connection_count = 26
        end
        return connection_count
    end},
    {"fluid-transfer-speed", function(entity, quality_level) return tostring(FACTORY_PUMPING_SPEED * get_quality_buff(quality_level)) .. "/s" end}
})

add_quality_factoriopedia_info(data.raw["storage-tank"]["factory-2"], {
    {"interior-space",       function(entity, quality_level) return "46×46" end},
    {"connections", function(entity, quality_level)
        local connection_count
        if quality_level <= 0 then
            connection_count = 24
        elseif quality_level == 1 then
            connection_count = 26
        elseif quality_level == 2 then
            connection_count = 28
        elseif quality_level == 3 then
            connection_count = 30
        elseif quality_level == 4 then
            connection_count = 32
        else
            connection_count = 34
        end
        return connection_count
    end},
    {"fluid-transfer-speed", function(entity, quality_level) return tostring(FACTORY_PUMPING_SPEED * get_quality_buff(quality_level)) .. "/s" end}
})

add_quality_factoriopedia_info(data.raw["storage-tank"]["factory-3"], {
    {"interior-space",       function(entity, quality_level) return "60×60" end},
    {"connections", function(entity, quality_level)
        local connection_count
        if quality_level <= 0 then
            connection_count = 32
        elseif quality_level == 1 then
            connection_count = 34
        elseif quality_level == 2 then
            connection_count = 38
        elseif quality_level == 3 then
            connection_count = 42
        elseif quality_level == 4 then
            connection_count = 44
        else
            connection_count = 46
        end
        return connection_count
    end},
    {"fluid-transfer-speed", function(entity, quality_level) return tostring(FACTORY_PUMPING_SPEED * get_quality_buff(quality_level)) .. "/s" end}
})

if not settings.startup["Factorissimo2-space-architecture"].value then return end

add_quality_factoriopedia_info(data.raw["storage-tank"]["space-factory-1"], {
    {"interior-space",       function(entity, quality_level) return "30×30" end},
    {"connections", function(entity, quality_level)
        local connection_count
        if quality_level <= 0 then
            connection_count = 16
        elseif quality_level == 1 then
            connection_count = 18
        elseif quality_level == 2 then
            connection_count = 20
        elseif quality_level == 3 then
            connection_count = 22
        elseif quality_level == 4 then
            connection_count = 24
        else
            connection_count = 26
        end
        return connection_count
    end},
    {"fluid-transfer-speed", function(entity, quality_level) return tostring(FACTORY_PUMPING_SPEED * get_quality_buff(quality_level)) .. "/s" end}
})

add_quality_factoriopedia_info(data.raw["storage-tank"]["space-factory-2"], {
    {"interior-space",       function(entity, quality_level) return "46×46" end},
    {"connections", function(entity, quality_level)
        local connection_count
        if quality_level <= 0 then
            connection_count = 24
        elseif quality_level == 1 then
            connection_count = 26
        elseif quality_level == 2 then
            connection_count = 28
        elseif quality_level == 3 then
            connection_count = 30
        elseif quality_level == 4 then
            connection_count = 32
        else
            connection_count = 34
        end
        return connection_count
    end},
    {"fluid-transfer-speed", function(entity, quality_level) return tostring(FACTORY_PUMPING_SPEED * get_quality_buff(quality_level)) .. "/s" end}
})

add_quality_factoriopedia_info(data.raw["storage-tank"]["space-factory-3"], {
    {"interior-space",       function(entity, quality_level) return "60×60" end},
    {"connections", function(entity, quality_level)
        local connection_count
        if quality_level <= 0 then
            connection_count = 32
        elseif quality_level == 1 then
            connection_count = 34
        elseif quality_level == 2 then
            connection_count = 38
        elseif quality_level == 3 then
            connection_count = 42
        elseif quality_level == 4 then
            connection_count = 44
        else
            connection_count = 46
        end
        return connection_count
    end},
    {"fluid-transfer-speed", function(entity, quality_level) return tostring(FACTORY_PUMPING_SPEED * get_quality_buff(quality_level)) .. "/s" end}
})
