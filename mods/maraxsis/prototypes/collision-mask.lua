local collision_mask_util = require "__core__/lualib/collision-mask-util"

data:extend {{
    name = maraxsis_underwater_collision_mask,
    type = "collision-layer",
}}

data:extend {{
    name = maraxsis_dome_collision_mask,
    type = "collision-layer",
}}

data:extend {{
    name = maraxsis_lava_collision_mask,
    type = "collision-layer",
}}

data:extend {{
    name = maraxsis_coral_collision_mask,
    type = "collision-layer",
}}

data:extend {{
    name = maraxsis_trench_entrance_collision_mask,
    type = "collision-layer",
}}

local cant_be_placed_on_water = {water = false, dome = true, coral = false, trench = true, trench_entrance = false, trench_lava = false}
local cant_be_placed_in_a_dome = {water = true, dome = false, coral = true, trench = true, trench_entrance = false, trench_lava = false}
local cant_be_placed_anywhere = {water = false, dome = false, coral = false, trench = false, trench_entrance = false, trench_lava = false}

local default_maraxsis_buildability_rules = {
    ["lab"] = cant_be_placed_on_water,
    ["assembling-machine"] = cant_be_placed_on_water,
    ["boiler"] = cant_be_placed_on_water,
    ["fire"] = cant_be_placed_on_water,
    ["furnace"] = cant_be_placed_on_water,
    ["beacon"] = cant_be_placed_on_water,
    ["generator"] = cant_be_placed_on_water,
    ["market"] = cant_be_placed_on_water,
    ["reactor"] = cant_be_placed_on_water,
    ["simple-entity-with-force"] = cant_be_placed_on_water,
    ["simple-entity-with-owner"] = cant_be_placed_on_water,
    ["fusion-reactor"] = cant_be_placed_on_water,
    ["fusion-generator"] = cant_be_placed_on_water,

    ["turret"] = cant_be_placed_in_a_dome,
    ["ammo-turret"] = cant_be_placed_in_a_dome,
    ["electric-turret"] = cant_be_placed_in_a_dome,
    ["land-mine"] = cant_be_placed_in_a_dome,
    ["agricultural-tower"] = cant_be_placed_in_a_dome,
    ["mining-drill"] = cant_be_placed_in_a_dome,

    ["rocket-silo"] = {water = true, dome = false, coral = true, trench = false, trench_entrance = false, trench_lava = false},
    ["cargo-landing-pad"] = {water = true, dome = true, coral = true, trench = false, trench_entrance = false, trench_lava = false},
    ["cargo-bay"] = {water = true, dome = true, coral = true, trench = false, trench_entrance = false, trench_lava = false},
    ["electric-energy-interface"] = {water = true, dome = false, coral = true, trench = false, trench_entrance = false, trench_lava = false}, -- chances are this is a wind turbine

    ["artillery-turret"] = cant_be_placed_anywhere,
    ["artillery-wagon"] = cant_be_placed_anywhere,
    ["car"] = cant_be_placed_anywhere,
    ["fluid-turret"] = cant_be_placed_anywhere,
    ["spider-leg"] = cant_be_placed_anywhere,
    ["spider-vehicle"] = cant_be_placed_anywhere,
    ["roboport"] = cant_be_placed_anywhere,
    ["radar"] = cant_be_placed_anywhere,
    ["plant"] = cant_be_placed_anywhere,

    ["straight-rail"] = {water = false, dome = true, coral = false, trench = false, trench_entrance = false, trench_lava = false},
    ["curved-rail-a"] = {water = false, dome = true, coral = false, trench = false, trench_entrance = false, trench_lava = false},
    ["curved-rail-b"] = {water = false, dome = true, coral = false, trench = false, trench_entrance = false, trench_lava = false},
    ["half-diagonal-rail"] = {water = false, dome = true, coral = false, trench = false, trench_entrance = false, trench_lava = false},
    ["legacy-curved-rail"] = {water = false, dome = true, coral = false, trench = false, trench_entrance = false, trench_lava = false},
    ["legacy-straight-rail"] = {water = false, dome = true, coral = false, trench = false, trench_entrance = false, trench_lava = false},

    ["rail-ramp"] = {water = true, dome = true, coral = true, trench = false, trench_entrance = false, trench_lava = false},
    ["rail-support"] = {water = true, dome = true, coral = true, trench = false, trench_entrance = false, trench_lava = false},
    ["elevated-straight-rail"] = {water = true, dome = true, coral = true, trench = false, trench_entrance = false, trench_lava = false},
    ["elevated-curved-rail-a"] = {water = true, dome = true, coral = true, trench = false, trench_entrance = false, trench_lava = false},
    ["elevated-curved-rail-b"] = {water = true, dome = true, coral = true, trench = false, trench_entrance = false, trench_lava = false},
    ["elevated-half-diagonal-rail"] = {water = true, dome = true, coral = true, trench = false, trench_entrance = false, trench_lava = false},
}

local function blacklist_via_surface_condition(entity, max_pressure)
    if entity.hidden then return end
    PlanetsLib.restrict_surface_conditions(entity, {property = "pressure", max = max_pressure})
end

local function slightly_shrink_collision_box(collision_box)
    local left_top = collision_box.left_top or collision_box[1]
    local x1, y1 = left_top.x or left_top[1], left_top.y or left_top[2]
    local right_bottom = collision_box.right_bottom or collision_box[2]
    local x2, y2 = right_bottom.x or right_bottom[1], right_bottom.y or right_bottom[2]

    -- Pull the edge in by 0.1 tiles, towards the entity's center. Handles negative
    -- coordinates too, otherwise the rule area would only cover one quadrant of
    -- the entity (the collision box is centered on the origin).
    local function slightly_shrink(val)
        local magnitude = math.abs(val)
        local nearest_half_tile = math.ceil(magnitude * 2) / 2
        magnitude = math.max(0, math.min(magnitude, nearest_half_tile - 0.1))
        if val < 0 then return -magnitude end
        return magnitude
    end

    return {
        {slightly_shrink(x1), slightly_shrink(y1)},
        {slightly_shrink(x2), slightly_shrink(y2)},
    }
end

local function blacklist_via_tile_buildability_rule(entity, required_tile)
    if entity.tile_buildability_rules and table_size(entity.tile_buildability_rules) > 0 then
        for _, rule in pairs(entity.tile_buildability_rules) do
            if rule.is_maraxsis_rule then
                rule.colliding_tiles = rule.colliding_tiles or {layers = {}}
                rule.colliding_tiles.layers[required_tile] = true
                return
            end
        end
    end

    entity.tile_buildability_rules = entity.tile_buildability_rules or {}

    table.insert(entity.tile_buildability_rules, {
        is_maraxsis_rule = true,
        area = slightly_shrink_collision_box(entity.collision_box),
        required_tiles = {
            -- there's no way to disable the "required_tiles" property. just throw all the layers and hope something collides
            layers = {
                object = true,
                player = true,
                ground_tile = true,
                water_tile = true,
                [maraxsis_coral_collision_mask] = true,
                [maraxsis_dome_collision_mask] = true,
                [maraxsis_lava_collision_mask] = true,
                [maraxsis_trench_entrance_collision_mask] = true,
                [maraxsis_underwater_collision_mask] = true,
            }
        },
        colliding_tiles = {layers = {[required_tile] = true}}
    })
end

for prototype in pairs(defines.prototypes.entity) do
    for _, entity in pairs(data.raw[prototype] or {}) do
        if entity.hidden or not entity.collision_box then goto continue end
        if entity.collision_mask and table_size(entity.collision_mask.layers or {}) == 0 then goto continue end

        local rules = entity.maraxsis_buildability_rules or default_maraxsis_buildability_rules[entity.type]
        if not rules then goto continue end

        assert(table_size(rules) == 6, "ERROR: Entity " .. entity.name .. " has incorrect definitions for maraxsis_buildability_rules. Requires 6 rule entries, instead had " .. serpent.line(rules))

        if rules.water == false and rules.dome == false and rules.coral == false and rules.trench_entrance == false and rules.trench == false and rules.trench_lava == false then
            blacklist_via_surface_condition(entity, 50000)
            goto continue
        elseif rules.trench == false and rules.trench_lava == false then
            blacklist_via_surface_condition(entity, 300000)
        end

        if rules.water == false then
            local needs_dome = rules.dome and maraxsis_constants.DOME_DISABLEABLE_TYPES[entity.type]
            if needs_dome then
                -- only set this when `true` so the table is as small as it can be
                maraxsis_constants.NEEDS_DOME[entity.name] = true
            else
                blacklist_via_tile_buildability_rule(entity, maraxsis_underwater_collision_mask)
            end
        end

        if rules.dome == false then
            blacklist_via_tile_buildability_rule(entity, maraxsis_dome_collision_mask)
        end

        if rules.coral == false then
            blacklist_via_tile_buildability_rule(entity, maraxsis_coral_collision_mask)
        end

        if rules.trench_entrance == false then
            blacklist_via_tile_buildability_rule(entity, maraxsis_trench_entrance_collision_mask)
        end

        if rules.trench_lava == false then
            blacklist_via_tile_buildability_rule(entity, maraxsis_lava_collision_mask)
        end

        ::continue::
    end
end

-- add doodad layer to decals
for _, decorative in pairs {
    "crater-large",
    "light-mud-decal",
    "vulcanus-dune-decal",
    "pink-lichen-decal",
    "nuclear-ground-patch", -- the dust nukes scatter, which would otherwise float over the trench entrance
} do
    decorative = data.raw["optimized-decorative"][decorative]
    if not decorative then error("decorative not found " .. decorative) end
    decorative.collision_mask.layers["doodad"] = true
end

-- add doodad layer to doodads
for _, decorative in pairs {
    "crater-small",
    "urchin-cactus",
} do
    decorative = data.raw["optimized-decorative"][decorative]
    if not decorative then error("decorative not found " .. decorative) end
    decorative.collision_mask.layers["doodad"] = true
end
