-- Beta 8 port of comb 0.1.2 (BiusArt Combinator graphics): sprites, displays, wire points
-- of the vanilla arithmetic/decider/constant combinators and the circuit-network research icon.
-- Graphics only. Startup setting "paranoidal-comb-graphics":
--   all      - icons and placed buildings;
--   icons    - item/entity/research icons only;
--   entities - sprites, displays and wire points of placed buildings only;
--   none     - nothing is changed, prototypes stay as without comb (item icons from bobicons-beta8) (default).
local util = require("util")

local mode = settings.startup["paranoidal-comb-graphics"].value
local use_icons = mode == "all" or mode == "icons"
local use_entities = mode == "all" or mode == "entities"
if not (use_icons or use_entities) then return end

local root = "__zzzparanoidal__/graphics/comb-beta8/"
local directions = { "north", "east", "south", "west" }

-- Horizontal 600x129 sheet: one 150x129 frame per direction, 1.1 scale 0.5.
local function body(name)
    local result = {}
    for i, direction in ipairs(directions) do
        local x = (i - 1) * 150
        result[direction] = { layers = {
            {
                filename = root .. "entity/" .. name .. ".png",
                priority = "high", x = x, width = 150, height = 129,
                shift = { 0, 0 }, scale = 0.5,
            },
            {
                filename = root .. "entity/" .. name .. "_shadow.png",
                priority = "high", x = x, width = 150, height = 129,
                shift = util.by_pixel(21, 0), scale = 0.5, draw_as_shadow = true,
            },
        } }
    end
    return result
end

-- 40x30 cells of combinator-displays.png; Beta 8 had no glow on these displays.
local function display(x, y)
    local result = {}
    for _, direction in ipairs(directions) do
        result[direction] = {
            filename = root .. "entity/combinator-displays.png",
            x = x, y = y, width = 40, height = 30,
            shift = util.by_pixel(0, -15), scale = 0.5,
        }
    end
    return result
end

local function point(shadow_red, shadow_green, wire_red, wire_green)
    return {
        shadow = { red = util.by_pixel(shadow_red[1] / 2, shadow_red[2] / 2), green = util.by_pixel(shadow_green[1] / 2, shadow_green[2] / 2) },
        wire = { red = util.by_pixel(wire_red[1] / 2, wire_red[2] / 2), green = util.by_pixel(wire_green[1] / 2, wire_green[2] / 2) },
    }
end

-- Shared by arithmetic and decider combinators in the original mod.
local input_points = {
    point({ 35, 39 }, { 69, 39 }, { -16, 6 }, { 16, 6 }),
    point({ -26, -18 }, { -20, 9.5 }, { -45, -35 }, { -45, -12 }),
    point({ 68, -20 }, { 34, -21 }, { 15, -54 }, { -16, -54 }),
    point({ 91, 21 }, { 91, -2 }, { 45, -12 }, { 45, -35 }),
}
local output_points = {
    point({ 34, -21 }, { 68, -20 }, { -15, -54 }, { 16, -54 }),
    point({ 91, -2 }, { 91, 21 }, { 45, -35 }, { 45, -12 }),
    point({ 69, 39 }, { 35, 39 }, { 16, 6 }, { -16, 6 }),
    point({ -26, 9.5 }, { -20, -18 }, { -45, -12 }, { -45, -35 }),
}

local function set_icon(prototype, file, size)
    prototype.icons = nil
    prototype.icon = root .. "icons/" .. file
    prototype.icon_size = size
end

local arithmetic = data.raw["arithmetic-combinator"]["arithmetic-combinator"]
if arithmetic then
    if use_icons then set_icon(arithmetic, "arithmetic_combinator_icon_64.png", 64) end
    if use_entities then
        arithmetic.sprites = body("arithmetic_combinator")
        arithmetic.input_connection_points = table.deepcopy(input_points)
        arithmetic.output_connection_points = table.deepcopy(output_points)
        for key, cell in pairs({
            plus = { 40, 0 }, minus = { 80, 0 }, multiply = { 120, 0 }, divide = { 160, 0 }, modulo = { 200, 0 },
            power = { 0, 30 }, left_shift = { 40, 30 }, right_shift = { 80, 30 },
            ["and"] = { 120, 30 }, ["or"] = { 160, 30 }, xor = { 200, 30 },
        }) do
            arithmetic[key .. "_symbol_sprites"] = display(cell[1], cell[2])
        end
    end
end

local decider = data.raw["decider-combinator"]["decider-combinator"]
if decider then
    if use_icons then set_icon(decider, "decider_combinator_icon_64.png", 64) end
    if use_entities then
        decider.sprites = body("decider_combinator")
        decider.input_connection_points = table.deepcopy(input_points)
        decider.output_connection_points = table.deepcopy(output_points)
        for key, cell in pairs({
            greater = { 0, 58 }, less = { 40, 58 }, equal = { 80, 58 },
            not_equal = { 120, 58 }, less_or_equal = { 160, 58 }, greater_or_equal = { 200, 58 },
        }) do
            decider[key .. "_symbol_sprites"] = display(cell[1], cell[2])
        end
    end
end

local constant = data.raw["constant-combinator"]["constant-combinator"]
if constant then
    if use_icons then set_icon(constant, "constant_combinator_icon_64.png", 64) end
    if use_entities then
        constant.sprites = body("constant_combinator")
        constant.circuit_wire_connection_points = {
            point({ 36, -4 }, { 68, -4 }, { -16, -39 }, { 15, -39 }),
            point({ 68, -1 }, { 68, 21 }, { 22, -36 }, { 22, -12 }),
            point({ 68, 23 }, { 35, 23 }, { 15, -8 }, { -16, -8 }),
            point({ 49, 19 }, { 49, -2 }, { -22, -13 }, { -22, -36 }),
        }
    end
end

if use_icons then
    for _, name in ipairs({ "arithmetic-combinator", "decider-combinator", "constant-combinator" }) do
        local item = data.raw.item[name]
        if item then set_icon(item, (name:gsub("-", "_")) .. "_icon_64.png", 64) end
    end

    local technology = data.raw.technology["circuit-network"]
    if technology then set_icon(technology, "thumbnail_issled_256.png", 256) end
end
