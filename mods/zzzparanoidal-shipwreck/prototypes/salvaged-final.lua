local config = require("shipwreck-config")

-- Salvaged generator: the engine does not scale an electric-energy-interface by quality, so
-- scripts/generator.lua sets production and buffer per built entity. Here: base values from the
-- config, an output limit for the best start quality and tooltip lines with the values per quality.
local spec = config.generator
local generator = data.raw["electric-energy-interface"][spec.name]
if not generator then return end

local function multiplier(quality, field)
    return quality[field] or quality.default_multiplier or (1 + 0.3 * (quality.level or 0))
end

local best = 1
local quality = data.raw.quality and data.raw.quality.normal
for _ = 1, config.quality_steps do
    quality = quality and quality.next and data.raw.quality[quality.next]
    if quality then best = math.max(best, multiplier(quality, "default_multiplier")) end
end

generator.energy_production = spec.production_kw .. "kW"
generator.energy_source.buffer_capacity = spec.buffer_mj .. "MJ"
generator.energy_source.output_flow_limit = (spec.production_kw * spec.output_ratio * best) .. "kW"

local function number(value)
    return string.format("%.4g", value)
end
local function power(kw)
    if kw >= 1000 then return {"", number(kw / 1000), " ", {"si-prefix-symbol-mega"}, {"si-unit-symbol-watt"}} end
    return {"", number(kw), " ", {"si-prefix-symbol-kilo"}, {"si-unit-symbol-watt"}}
end
local function energy(mj)
    return {"", number(mj), " ", {"si-prefix-symbol-mega"}, {"si-unit-symbol-joule"}}
end

local function field(key, base, scale, format, factoriopedia)
    local values = {}
    for name, prototype in pairs(data.raw.quality or {}) do
        if not prototype.hidden then values[name] = format(base * multiplier(prototype, scale)) end
    end
    return {
        name = {"zzzparanoidal-shipwreck." .. key},
        value = format(base),
        quality_values = values,
        show_in_factoriopedia = factoriopedia,
    }
end

local function add_fields(prototype, factoriopedia)
    prototype.custom_tooltip_fields = prototype.custom_tooltip_fields or {}
    table.insert(prototype.custom_tooltip_fields,
        field("generator-production", spec.production_kw, "default_multiplier", power, factoriopedia))
    table.insert(prototype.custom_tooltip_fields,
        field("generator-buffer", spec.buffer_mj, "accumulator_capacity_multiplier", energy, factoriopedia))
end

-- One Factoriopedia block: the item shows it, the entity only in its tooltip.
add_fields(generator, false)
local item = data.raw.item[spec.name]
if item then add_fields(item, true) end
