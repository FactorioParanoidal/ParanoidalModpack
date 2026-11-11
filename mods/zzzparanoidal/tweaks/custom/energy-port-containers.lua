-- Filled-container fuel owner. Keep the three policies and their call sites distinct:
-- capacity-time initialization, explicit per-fluid assignments, then reciprocal recipe discovery.
-- Their selection, parsers, category handling and emissions defaults are intentionally different.
local M = {}

local ENERGY_UNITS = { J = 1, kJ = 1e3, MJ = 1e6, GJ = 1e9, TJ = 1e12, PJ = 1e15 }
local function energy_to_j(s)
    local n, u = tostring(s):match("([%d%.]+)%s*([kMGTP]?J)")
    return n and tonumber(n) * (ENERGY_UNITS[u] or 1) or nil
end
local function rn(x) return x.name or x[1] end
local function ra(x) return x.amount or x[2] or 1 end

-- Called immediately after capacity scaling, not deferred to the late energy port.
function M.initialize_fill(raw, in_f, out_b)
    local bi = raw.item[rn(out_b)]
    if bi then
        local fl = raw.fluid[rn(in_f)]
        if fl and fl.fuel_value then
            local ev = energy_to_j(fl.fuel_value)
            if ev and ev > 0 then
                bi.fuel_categories = bi.fuel_categories or {"chemical"}
                bi.fuel_value = (ev * ra(in_f) / ra(out_b)) .. "J"
            end
        end
    end
end

-- Remains interleaved with each fluid's explicit settings; aliases need not have recipe pairs.
function M.apply_explicit(raw, barrel_names, fields, util)
    for _, barrel_name in ipairs(barrel_names or {}) do
        local barrel = assert(raw.item[barrel_name])
        barrel.fuel_categories = {"chemical"}
        barrel.fuel_value = tostring(util.parse_energy(fields.fuel_value) * 100) .. "J"
        barrel.fuel_emissions_multiplier = fields.emissions_multiplier
        -- Burning does not introduce a new return-container rule.
    end
end

local function list(recipe, key)
    local out = {}
    for _, entry in pairs(recipe[key] or {}) do
        out[#out + 1] = {type = entry.type or "item", name = entry.name or entry[1], amount = entry.amount or entry[2] or 1}
    end
    return out
end

-- Variant A: a fill has one fluid + one item -> one item, with an emptying recipe witness.
-- Energy = fluid fuel_value x fluid per item; emissions default to 1 only in this policy.
function M.apply_recipes(raw, util)
    local emptied = {}
    for _, recipe in pairs(raw.recipe) do
        local ingredients = list(recipe, "ingredients")
        if #ingredients == 1 and ingredients[1].type == "item" then
            for _, result in ipairs(list(recipe, "results")) do
                if result.type == "fluid" then emptied[ingredients[1].name .. "|" .. result.name] = true end
            end
        end
    end
    for _, recipe in pairs(raw.recipe) do
        local ingredients, results = list(recipe, "ingredients"), list(recipe, "results")
        if #ingredients == 2 and #results == 1 and results[1].type == "item" then
            local fluid_in = ingredients[1].type == "fluid" and ingredients[1] or ingredients[2].type == "fluid" and ingredients[2]
            local other = fluid_in == ingredients[1] and ingredients[2] or ingredients[1]
            local fluid = fluid_in and raw.fluid[fluid_in.name]
            local barrel = raw.item[results[1].name]
            if fluid and fluid.fuel_value and other.type == "item" and barrel
                and emptied[barrel.name .. "|" .. fluid.name] then
                local per_item = fluid_in.amount / results[1].amount
                barrel.fuel_categories = barrel.fuel_categories or {"chemical"}
                barrel.fuel_value = tostring(util.parse_energy(fluid.fuel_value) * per_item) .. "J"
                barrel.fuel_emissions_multiplier = fluid.emissions_multiplier or 1
            end
        end
    end
end

return M
