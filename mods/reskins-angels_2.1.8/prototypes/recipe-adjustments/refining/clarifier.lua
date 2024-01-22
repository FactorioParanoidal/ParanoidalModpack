-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

local water_tint = util.color("005799") -- Water void recipe tint for water
local mud_tint = util.color("6a492c") -- AR:Angel's tint for mud

-- Ensure a tint is formatted as expected by reskins.lib functions
---@param color table [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table tint [Types/Color](https://wiki.factorio.com/Types/Color) with fields r, g, b, a
local function format_tint(color)
	local tint = {
		r = color.r or color[1],
		g = color.g or color[2],
		b = color.b or color[3],
		a = color.a or color[4] or 1,
	}

	return tint
end

-- Takes two input tints and blends them in the following manner: `A*w + B*(1-w)`
---@param tint_A table [Types/Color](https://wiki.factorio.com/Types/Color)
---@param tint_B table [Types/Color](https://wiki.factorio.com/Types/Color)
---@param weighting? number In the range 0:1, default 0.5
---@param alpha? number In the range 0:1, default 1
---@return table tint [Types/Color](https://wiki.factorio.com/Types/Color)
local function blend_colors(tint_A, tint_B, weighting, alpha)
    local A = format_tint(tint_A)
    local B = format_tint(tint_B)
    local w = weighting or 0.5

    local tint = {
        r = A.r*w + B.r*(1-w),
        g = A.g*w + B.g*(1-w),
        b = A.b*w + B.b*(1-w),
        a = alpha or 1,
    }

    return tint
end


-- Adjust mud water fluid colors
local fluids = {
    ["water-viscous-mud"] = mud_tint,
    ["water-heavy-mud"] = blend_colors(mud_tint, water_tint, 0.8),
    ["water-concentrated-mud"] = blend_colors(mud_tint, water_tint, 0.6),
    ["water-light-mud"] = blend_colors(mud_tint, water_tint, 0.4),
    ["water-thin-mud"] = blend_colors(mud_tint, water_tint, 0.2),
}

-- Revise fluid tints
for name, tint in pairs(fluids) do
    -- Set fluid tints
    local fluid = data.raw.fluid[name]
    if fluid then
        fluid.base_color = tint
        fluid.flow_color = {0.7, 0.7, 0.7}
    end
end

-- Setup clarifier recipes
-- for _, recipe_data in pairs(data.raw.recipe) do
--     if recipe_data.category == "angels-water-void" then
--         -- Fetch recipe data
--         local ingredient = data.raw.fluid[(recipe_data.ingredients and recipe_data.ingredients[1]) and recipe_data.ingredients[1].name]

--         if ingredient then
--             -- Check it's a mud fluid
--             for name, _ in pairs(fluids) do
--                 if ingredient.name == name then
--                     recipe_data.crafting_machine_tint = {primary = reskins.lib.adjust_alpha(ingredient.base_color, 0.72549)}
--                 end
--             end

--             -- Fix the localisation, hnng...
--             -- recipe_data.localised_name = {"", ingredient.localised_name, " void"}
--         end
--     end
-- end

-- Setup clarifier recipes
for _, recipe_data in pairs(data.raw.recipe) do
    if recipe_data.category == "angels-water-void" then
        local ingredient = data.raw.fluid[(recipe_data.ingredients and recipe_data.ingredients[1]) and recipe_data.ingredients[1].name]

        if ingredient then
            recipe_data.crafting_machine_tint = {primary = ingredient.base_color}
        end
    end
end