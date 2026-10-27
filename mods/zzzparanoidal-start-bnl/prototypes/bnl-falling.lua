-- Falling ship debris and BnL supply pods: artillery projectiles flying in from the
-- west-south-west. The impact damages the area, leaves a scorch mark, shakes the camera and raises
-- a script trigger: scripts/falling.lua creates the wreck (burning or not, config.falling.
-- ignite_chance: no ground fire of the impact decides it instead) or the supply chest there.
local falling = "__zzzparanoidal-start-bnl__/graphics/entity/falling/"

local kinds = {
    -- picture size, area radius, damage, explosion, scorch mark, camera shake; blast: extra explosions
    -- spread over the impact area {entity, count}; boom: the full-volume impact sound (scripts/falling.lua)
    small = {size = 187, radius = 2.5, damage = 40, explosion = "medium-explosion", scorch = "small-scorchmark-tintable", shake = 20, strength = 1.5,
        blast = {"explosion", 3}},
    medium = {size = 289, radius = 3.5, damage = 100, explosion = "big-explosion", scorch = "medium-scorchmark-tintable", shake = 30, strength = 2.5,
        blast = {"medium-explosion", 4}},
    big = {size = 408, radius = 5, damage = 220, explosion = "massive-explosion", scorch = "big-scorchmark-tintable", shake = 45, strength = 4,
        blast = {"big-explosion", 6}},
}

local chart_picture = {
    filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
    flags = {"icon"},
    width = 64,
    height = 64,
    priority = "high",
    scale = 0.25,
}

local function impact(kind, effect_id)
    local effects = {
        {type = "create-entity", entity_name = kind.explosion},
        {type = "create-entity", entity_name = kind.scorch, check_buildability = true},
        {type = "invoke-tile-trigger", repeat_count = 1},
        {
            type = "destroy-decoratives",
            from_render_layer = "decorative",
            to_render_layer = "object",
            include_soft_decoratives = true,
            include_decals = false,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = kind.radius,
        },
        {
            type = "camera-effect",
            duration = kind.shake,
            ease_in_duration = 4,
            ease_out_duration = kind.shake,
            delay = 0,
            strength = kind.strength,
            full_strength_max_distance = 12,
            max_distance = 70,
        },
        {type = "show-explosion-on-chart", scale = kind.radius / 32},
        {type = "script", effect_id = effect_id},
    }
    if kind.damage > 0 then
        table.insert(effects, 1, {
            type = "nested-result",
            action = {
                type = "area",
                radius = kind.radius,
                action_delivery = {
                    type = "instant",
                    target_effects = {{type = "damage", damage = {amount = kind.damage, type = "explosion"}}},
                },
            },
        })
    end
    if kind.blast then
        local r = kind.radius * 0.8
        table.insert(effects, 2, {type = "create-entity", entity_name = kind.blast[1], repeat_count = kind.blast[2],
            offset_deviation = {{-r, -r}, {r, r}}})
    end
    return {type = "direct", action_delivery = {type = "instant", target_effects = effects}}
end

local projectiles = {}
for name, kind in pairs(kinds) do
    projectiles[#projectiles + 1] = {
        type = "artillery-projectile",
        name = "bnl-falling-debris-" .. name,
        flags = {"not-on-map"},
        hidden = true,
        reveal_map = false,
        map_color = {r = 1, g = 0.5, b = 0},
        rotatable = false,
        -- the piece itself, its flame tail and smoke are drawn by scripts/flight.lua along its path
        picture = {filename = "__core__/graphics/empty.png", width = 1, height = 1, priority = "high"},
        shadow = {
            filename = falling .. "debris-" .. name .. "-shadow.png",
            width = kind.size,
            height = kind.size,
            scale = 0.5,
            priority = "high",
        },
        chart_picture = chart_picture,
        action = impact(kind, "bnl-impact-" .. name),
    }
end

projectiles[#projectiles + 1] = {
    type = "artillery-projectile",
    name = "bnl-supply-pod",
    flags = {"not-on-map"},
    hidden = true,
    reveal_map = false,
    map_color = {r = 1, g = 0.6, b = 0.2},
    rotatable = false,
    picture = {filename = falling .. "supply-pod.png", width = 220, height = 300, scale = 0.5, priority = "high"},
    shadow = {filename = falling .. "supply-pod-shadow.png", width = 220, height = 300, scale = 0.5, priority = "high"},
    chart_picture = chart_picture,
    action = impact({explosion = "explosion", scorch = "small-scorchmark-tintable", radius = 1.5, damage = 0,
        shake = 10, strength = 0.8}, "bnl-impact-pod"),
}

data:extend(projectiles)

-- The falling pieces as drawn in the air (scripts/flight.lua) and their black smoke trail.
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")
local pieces = {}
for name, kind in pairs(kinds) do
    pieces[#pieces + 1] = {type = "sprite", name = "bnl-falling-piece-" .. name, filename = falling .. "debris-" .. name .. ".png",
        width = kind.size, height = kind.size, scale = 0.5, priority = "high", draw_as_glow = true}
end
pieces[#pieces + 1] = smoke_animations.trivial_smoke({name = "bnl-trail-smoke", color = {r = 0.06, g = 0.05, b = 0.05, a = 0.8},
    duration = 300, fade_in_duration = 4, spread_duration = 300, start_scale = 0.45, end_scale = 2.4})
data:extend(pieces)

-- Torches over burning wrecks with fuel inside (scripts/fire.lua draws them): the flame of the oil
-- refinery stacks (also the flame of the Angels flare stack) and the vanilla fire flame.
data:extend({
    {
        type = "animation",
        name = "bnl-torch-refinery",
        filename = "__base__/graphics/entity/oil-refinery/oil-refinery-fire.png",
        line_length = 10,
        width = 40,
        height = 81,
        frame_count = 60,
        animation_speed = 0.75,
        scale = 0.5,
        draw_as_glow = true,
    },
    {
        type = "animation",
        name = "bnl-torch-blaze",
        filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
        line_length = 10,
        width = 84,
        height = 130,
        frame_count = 90,
        animation_speed = 1,
        scale = 0.5,
        blend_mode = "normal",
        draw_as_glow = true,
    },
})

-- A gas cylinder burst in a burning wreck (scripts/fire.lua) flies off and falls burning: a small
-- blast and a fire where it lands, on whatever is there (wrecks, trees, player buildings).
local barrel_icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png"
data:extend({{
    type = "artillery-projectile",
    name = "bnl-flying-cylinder",
    flags = {"not-on-map"},
    hidden = true,
    reveal_map = false,
    map_color = {r = 1, g = 0.4, b = 0},
    rotatable = false,
    picture = {filename = barrel_icon, width = 64, height = 64, scale = 0.4, priority = "high"},
    shadow = {filename = barrel_icon, width = 64, height = 64, scale = 0.4, priority = "high", draw_as_shadow = true},
    chart_picture = chart_picture,
    action = {type = "direct", action_delivery = {type = "instant", target_effects = {
        {type = "nested-result", action = {type = "area", radius = 2.5, action_delivery = {type = "instant",
            target_effects = {{type = "damage", damage = {amount = 40, type = "explosion"}}}}}},
        {type = "create-entity", entity_name = "explosion"},
        {type = "create-fire", entity_name = "fire-flame", initial_ground_flame_count = 4},
        {type = "create-entity", entity_name = "small-scorchmark-tintable", check_buildability = true},
        {type = "show-explosion-on-chart", scale = 0.05},
    }}},
}})

-- Shadows of the coming pieces over the impact point (scripts/falling.lua scales and fades them in).
local shadows = {}
for name, kind in pairs(kinds) do
    shadows[#shadows + 1] = {type = "sprite", name = "bnl-falling-shadow-" .. name,
        filename = falling .. "debris-" .. name .. "-shadow.png", width = kind.size, height = kind.size, scale = 0.5}
end
shadows[#shadows + 1] = {type = "sprite", name = "bnl-falling-shadow-pod",
    filename = falling .. "supply-pod-shadow.png", width = 220, height = 300, scale = 0.5}
data:extend(shadows)

data:extend({
    {
        type = "sound",
        name = "bnl-falling-whistle",
        filename = "__zzzparanoidal-start-bnl__/sound/falling-flyby.ogg",
        volume = 0.9,
        audible_distance_modifier = 3,
    },
    -- Incoming shell whistle for players near the impact point (no explosion in the clips):
    -- "Incoming mortar 1-4" by Zagge28, freesound.org/s/241840, 241839, 241838, 241837, CC0 1.0.
    {
        type = "sound",
        name = "bnl-falling-incoming",
        category = "game-effect",
        variations = {
            {filename = "__zzzparanoidal-start-bnl__/sound/incoming-1.ogg", volume = 1},
            {filename = "__zzzparanoidal-start-bnl__/sound/incoming-2.ogg", volume = 1},
            {filename = "__zzzparanoidal-start-bnl__/sound/incoming-3.ogg", volume = 1},
            {filename = "__zzzparanoidal-start-bnl__/sound/incoming-4.ogg", volume = 1},
        },
    },
    -- Impact of a falling piece: played for every player at full volume, wherever the piece falls.
    {
        type = "sound",
        name = "bnl-impact-boom-small",
        category = "explosion",
        variations = {
            {filename = "__base__/sound/fight/medium-explosion-1.ogg", volume = 1},
            {filename = "__base__/sound/fight/medium-explosion-2.ogg", volume = 1},
            {filename = "__base__/sound/fight/medium-explosion-3.ogg", volume = 1},
            {filename = "__base__/sound/fight/medium-explosion-4.ogg", volume = 1},
            {filename = "__base__/sound/fight/medium-explosion-5.ogg", volume = 1},
        },
    },
    {
        type = "sound",
        name = "bnl-impact-boom-big",
        category = "explosion",
        variations = {
            {filename = "__base__/sound/fight/large-explosion-1.ogg", volume = 1},
            {filename = "__base__/sound/fight/large-explosion-2.ogg", volume = 1},
        },
    },
    {
        type = "sound",
        name = "bnl-radio",
        filename = "__zzzparanoidal-start-bnl__/sound/bnl-radio.ogg",
        volume = 0.7,
    },
    {
        type = "sprite",
        name = "bnl-journal",
        filename = "__zzzparanoidal-start-bnl__/graphics/gui/journal-button.png",
        width = 64,
        height = 64,
        flags = {"gui-icon"},
    },
    -- Buy n Large logo (redrawn, review/start-bnl-graphics/logo): chat prefix and journal title (small),
    -- the decal on the crashed starliner (weathered), the corporate seal of the BnL letters.
    {
        type = "sprite",
        name = "bnl-logo-small",
        filename = "__zzzparanoidal-start-bnl__/graphics/logo/bnl-logo-small.png",
        width = 40,
        height = 32,
        flags = {"gui-icon"},
    },
    {
        type = "sprite",
        name = "bnl-logo",
        filename = "__zzzparanoidal-start-bnl__/graphics/logo/bnl-logo.png",
        width = 256,
        height = 204,
        scale = 0.5,
    },
    {
        type = "sprite",
        name = "bnl-logo-weathered",
        filename = "__zzzparanoidal-start-bnl__/graphics/logo/bnl-logo-weathered.png",
        width = 256,
        height = 204,
        scale = 0.5,
    },
    {
        type = "sprite",
        name = "bnl-seal",
        filename = "__zzzparanoidal-start-bnl__/graphics/logo/bnl-seal.png",
        width = 128,
        height = 128,
        flags = {"gui-icon"},
    },
})
