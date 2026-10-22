-- Prismatic Belts: one belt sheet set per tier across all belt-connectable prototypes.
-- Details and acceptance notes: zzzparanoidal/README.md, section "Prismatic Belts".
-- 1. Copies made before Prismatic (Subterranean, hidden lane-splitter/loader-1x1) still point
--    at vanilla sheets: they get the final set of the matching vanilla belt.
-- 2. Bob basic/turbo/ultimate: one pre-colored layer instead of base + overlay mask
--    (graphics/entity/prismatic-baked/bake.py). Bob basic uses the 16-frame sheet unless the
--    startup setting asks for 64 frames. A non-default reskins tint keeps two layers.
-- 3. Factorissimo factory-linked-* copies (data-updates, before final belt speeds and before
--    Prismatic) get the final speed and belt graphics of their source prototype.
-- 4. Audit: logs any remaining reference to superseded belt sheets.
if not mods["prismatic-belts"] then return end

local CONNECTABLE = { "transport-belt", "underground-belt", "splitter", "lane-splitter", "loader-1x1", "loader", "linked-belt" }
-- Same order as Factorissimo's data-updates loop: with duplicate names the last type wins there.
local FACTORISSIMO_SOURCES = { "linked-belt", "transport-belt", "underground-belt", "loader-1x1", "loader", "splitter", "lane-splitter" }
local PRISMATIC = "__prismatic-belts__/graphics/entity/standard/transport-belt-"
local BAKED = "__zzzparanoidal__/graphics/entity/prismatic-baked/"

local VANILLA_SHEETS = {
    ["__base__/graphics/entity/transport-belt/transport-belt.png"] = "transport-belt",
    ["__base__/graphics/entity/fast-transport-belt/fast-transport-belt.png"] = "fast-transport-belt",
    ["__base__/graphics/entity/express-transport-belt/express-transport-belt.png"] = "express-transport-belt",
}

-- Keep in sync with TINTS in graphics/entity/prismatic-baked/bake.py.
local BAKED_BELTS = {
    ["bob-basic-transport-belt"] = { file = "bob-basic", tint = { 0x80, 0x80, 0x80, 255 } },
    ["turbo-transport-belt"] = { file = "bob-turbo", tint = { 0xB4, 0x59, 0xFF, 255 } },
    ["bob-ultimate-transport-belt"] = { file = "bob-ultimate", tint = { 0x2E, 0xE5, 0x5C, 255 } },
}

local setting = settings.startup["paranoidal-bob-basic-belt-64-frames"]
local basic_frames = (setting and setting.value) and 64 or 16

local function layers_of(set)
    local animation = set and set.animation_set
    if not animation then return {} end
    return animation.layers or { animation }
end

local function normalize(color)
    if not color then return nil end
    local r, g, b = color.r or color[1] or 0, color.g or color[2] or 0, color.b or color[3] or 0
    local a = color.a or color[4] or 1
    if r > 1 or g > 1 or b > 1 or a > 1 then r, g, b, a = r / 255, g / 255, b / 255, a / 255 end
    return { r, g, b, a }
end

local function same_color(a, b)
    a, b = normalize(a), normalize(b)
    if not (a and b) then return false end
    for i = 1, 4 do
        if math.abs(a[i] - b[i]) > 0.5 / 255 then return false end
    end
    return true
end

local function identity(set)
    local parts = {}
    for _, layer in ipairs(layers_of(set)) do
        local tint = normalize(layer.tint)
        parts[#parts + 1] = (layer.filename or "?") .. (tint and string.format("@%.4f,%.4f,%.4f,%.4f", tint[1], tint[2], tint[3], tint[4]) or "")
            .. (layer.tint_as_overlay and "+overlay" or "") .. (layer.blend_mode and ("+" .. layer.blend_mode) or "")
    end
    return table.concat(parts, "|")
end

local function each_connectable(callback)
    for _, type_name in ipairs(CONNECTABLE) do
        for _, entity in pairs(data.raw[type_name] or {}) do
            if entity.belt_animation_set then callback(entity) end
        end
    end
end

-- Replaces every set equal to `old_key` (all connectable types) with a copy of `new_set`.
local function replace_everywhere(old_key, new_set)
    local count = 0
    each_connectable(function(entity)
        if identity(entity.belt_animation_set) == old_key then
            entity.belt_animation_set = table.deepcopy(new_set)
            count = count + 1
        end
    end)
    return count
end

-- 1. Vanilla sheets left on copies made before Prismatic.
for file, belt_name in pairs(VANILLA_SHEETS) do
    local belt = data.raw["transport-belt"][belt_name]
    local layers = belt and layers_of(belt.belt_animation_set)
    if belt and not (#layers == 1 and layers[1].filename == file) then
        local key = identity({ animation_set = { filename = file } })
        local count = replace_everywhere(key, belt.belt_animation_set)
        log("[prismatic-sync] " .. belt_name .. ": vanilla sheet replaced on " .. count .. " prototype(s)")
    end
end

-- 2. Bob tiers: baked single layer (or the two-layer 16-frame form for a custom basic tint).
local function sheet_layer(filename, frames)
    return { filename = filename, priority = "extra-high", width = 128, height = 128, scale = 0.5,
        frame_count = frames, direction_count = 20 }
end

for belt_name, baked in pairs(BAKED_BELTS) do
    local belt = data.raw["transport-belt"][belt_name]
    local old = belt and belt.belt_animation_set
    local layers = layers_of(old)
    local is_prismatic_turbo = #layers == 2 and layers[1].filename == PRISMATIC .. "3-base.png"
        and layers[2].filename == PRISMATIC .. "3-mask.png" and layers[2].tint_as_overlay
    if not is_prismatic_turbo then
        if belt then log("[prismatic-sync] " .. belt_name .. ": unexpected animation set, left unchanged") end
        goto continue
    end

    local frames = belt_name == "bob-basic-transport-belt" and basic_frames or 64
    local new_set = { alternate = frames == 64, belt_reader = old.belt_reader, frozen_patch = old.frozen_patch }
    if same_color(layers[2].tint, baked.tint) then
        new_set.animation_set = sheet_layer(BAKED .. baked.file .. "-transport-belt-" .. frames .. ".png", frames)
    elseif frames == 16 then
        local sheet = 1
        local base = sheet_layer(PRISMATIC .. sheet .. "-base.png", frames)
        base.tint_as_overlay = false
        local mask = sheet_layer(PRISMATIC .. sheet .. "-mask.png", frames)
        mask.tint, mask.tint_as_overlay = table.deepcopy(layers[2].tint), true
        new_set.animation_set = { layers = { base, mask } }
        log("[prismatic-sync] " .. belt_name .. ": custom tint, two-layer 16-frame sheet")
    else
        log("[prismatic-sync] " .. belt_name .. ": custom tint, Prismatic two-layer sheet kept")
        goto continue
    end
    log("[prismatic-sync] " .. belt_name .. ": " .. replace_everywhere(identity(old), new_set) .. " prototype(s) updated")
    ::continue::
end

-- 3. Factorissimo linked copies: final speed and graphics of the source prototype.
local synced = 0
for name, linked in pairs(data.raw["linked-belt"] or {}) do
    local source_name = name:match("^factory%-linked%-(.+)$")
    local source
    for _, type_name in ipairs(FACTORISSIMO_SOURCES) do
        local candidate = source_name and data.raw[type_name] and data.raw[type_name][source_name]
        if candidate then source = candidate end
    end
    if source then
        linked.speed = source.speed
        linked.belt_animation_set = table.deepcopy(source.belt_animation_set)
        synced = synced + 1
    end
end
if synced > 0 then log("[prismatic-sync] factory-linked: " .. synced .. " prototype(s) synced") end

-- 4. Audit: superseded belt sheets must not stay in the atlas.
local superseded = {
    "^__base__/graphics/entity/[%w%-]*transport%-belt/[%w%-]*transport%-belt%.png$",
    "^__reskins%-library__/graphics/entity/base/transport%-belt/transport%-belt%-",
}
local uses = {}
each_connectable(function(entity)
    for _, layer in ipairs(layers_of(entity.belt_animation_set)) do
        local file = layer.filename or "?"
        uses[file] = uses[file] or {}
        table.insert(uses[file], entity.type .. "/" .. entity.name)
    end
end)
local files = {}
for file in pairs(uses) do files[#files + 1] = file end
table.sort(files)
for _, file in ipairs(files) do
    local stale = false
    for _, pattern in ipairs(superseded) do
        if file:find(pattern) then stale = true end
    end
    log("[prismatic-sync] " .. (stale and "STALE " or "") .. file .. ": " .. #uses[file]
        .. (stale and (" (" .. table.concat(uses[file], ", ") .. ")") or ""))
end
