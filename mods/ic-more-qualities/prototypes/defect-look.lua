-- Look of defective buildings (user request 2026-11-03), data stage. For every building whose item can be
-- defective: a sprite per direction from the first frame of its main graphics (no shadows, lights, glows,
-- other blend modes or working visualisations); control.lua draws it over the building with a dark tint.
-- Also the soot sprites, five dark smoke prototypes and mod-data for control (scripts/defects/look.lua).
local rules = require("scripts.defects.look-rules")

local M = {}

local DIRECTIONS = {"north", "east", "south", "west"}
local EXCLUDED_FILES = {"mask", "shadow", "integration", "reflection", "empty.png"}
local EXCEPTIONS = require("prototypes.defect-look-layers")
local CONTAINERS = {container = true, ["logistic-container"] = true, ["linked-container"] = true,
    ["proxy-container"] = true}

local function size_of(layer)
    local width, height = layer.width, layer.height
    local size = layer.size
    if type(size) == "number" then
        width, height = width or size, height or size
    elseif type(size) == "table" then
        width, height = width or size[1], height or size[2]
    end
    return width, height
end

-- First frame of one sprite/animation layer as sprite parameters; `index` picks a frame of a direction sheet.
local function add_frame(layer, out, index)
    if layer.draw_as_shadow or layer.draw_as_light or layer.draw_as_glow then return end
    if layer.blend_mode and layer.blend_mode ~= "normal" then return end
    local width, height = size_of(layer)
    if not (width and height and width > 0 and height > 0) then return end
    local filename, x, y = layer.filename, layer.x, layer.y
    if x == nil and y == nil and layer.position then x, y = layer.position[1], layer.position[2] end
    x, y = x or 0, y or 0
    if not filename and layer.filenames then filename = layer.filenames[1] end
    if not filename and layer.stripes and layer.stripes[1] then
        local stripe = layer.stripes[1]
        filename, x, y = stripe.filename, stripe.x or 0, stripe.y or 0
    end
    if type(filename) ~= "string" then return end
    -- Masks recolored at runtime, shadows, ground integration, reflections and placeholders are not the body.
    if layer.apply_runtime_tint then return end
    local file = filename:lower():match("[^/]*$")
    for _, word in ipairs(EXCLUDED_FILES) do
        if file:find(word, 1, true) then return end
    end
    if width * height <= 4 then return end
    out[#out + 1] = {
        filename = filename,
        x = x + (index or 0) * width,
        y = y,
        width = width,
        height = height,
        scale = layer.scale,
        shift = layer.shift and table.deepcopy(layer.shift) or nil,
        tint = layer.tint and table.deepcopy(layer.tint) or nil,
        premul_alpha = layer.premul_alpha,
        allow_forced_downscale = layer.allow_forced_downscale,
        priority = "medium",
    }
end

local function collect(value, out, index)
    if type(value) ~= "table" then return end
    if value.layers then
        for _, layer in ipairs(value.layers) do collect(layer, out, index) end
    elseif value.filename or value.filenames or value.stripes then
        add_frame(value, out, index)
    elseif value[1] then
        -- Variations: the first one.
        collect(value[1], out, index)
    end
end

-- Layers of a 4-way (or single) sprite or animation: {north, east, south, west}.
local function four_way(value)
    if type(value) ~= "table" then return nil end
    local result = {}
    if value.north or value.east or value.south or value.west then
        -- Animation4Way: an undefined direction uses north.
        for index, key in ipairs(DIRECTIONS) do
            local layers = {}
            collect(value[key] or value.north, layers)
            result[index] = layers
        end
    elseif value.sheets or value.sheet then
        -- Sprite4Way sheet: one frame per direction; a sheet with fewer frames repeats them.
        for index = 1, 4 do
            local layers = {}
            for _, sheet in ipairs(value.sheets or {value.sheet}) do
                collect(sheet, layers, (index - 1) % (sheet.frames or 4))
            end
            result[index] = layers
        end
    else
        local layers = {}
        collect(value, layers)
        for index = 1, 4 do result[index] = layers end
    end
    return result
end

local function merge(...)
    local result
    for position = 1, select("#", ...) do
        local part = select(position, ...)
        if part then
            result = result or {{}, {}, {}, {}}
            for index = 1, 4 do
                for _, layer in ipairs(part[index]) do table.insert(result[index], layer) end
            end
        end
    end
    return result
end

-- Idle and working animations together: the layer selection merges their identical frames.
local function crafter_graphics(set)
    return set and merge(four_way(set.idle_animation), four_way(set.animation))
end

-- Main graphics of a building by type and, for a crafting machine with flipped graphics, the flipped set.
local function graphics_of(entity)
    local kind = entity.type
    if kind == "assembling-machine" or kind == "furnace" then
        return crafter_graphics(entity.graphics_set), crafter_graphics(entity.graphics_set_flipped)
    elseif kind == "mining-drill" then
        return merge(four_way(entity.base_picture), crafter_graphics(entity.graphics_set))
    elseif kind == "offshore-pump" then
        local set = entity.graphics_set
        return set and merge(four_way(set.base_pictures), four_way(set.animation))
    elseif kind == "pump" then
        return four_way(entity.animations)
    elseif kind == "boiler" then
        local pictures = entity.pictures
        if not pictures then return nil end
        local result = {}
        for index, key in ipairs(DIRECTIONS) do
            local layers = {}
            collect(pictures[key] and pictures[key].structure, layers)
            result[index] = layers
        end
        return result
    elseif kind == "generator" then
        local vertical, horizontal = {}, {}
        collect(entity.vertical_animation, vertical)
        collect(entity.horizontal_animation, horizontal)
        return {vertical, horizontal, vertical, horizontal}
    elseif kind == "burner-generator" then
        return merge(four_way(entity.idle_animation), four_way(entity.animation))
    elseif kind == "lab" then
        return merge(four_way(entity.off_animation), four_way(entity.on_animation))
    elseif kind == "lamp" then
        return four_way(entity.picture_off)
    elseif CONTAINERS[kind] then
        return four_way(entity.picture or entity.animation)
    elseif kind == "electric-pole" then
        return four_way(entity.pictures)
    elseif kind == "electric-energy-interface" then
        return four_way(entity.picture or entity.animation or entity.pictures or entity.animations)
    elseif kind == "accumulator" then
        return four_way(entity.chargable_graphics and entity.chargable_graphics.picture or entity.picture)
    elseif kind == "storage-tank" then
        return four_way(entity.pictures and entity.pictures.picture)
    elseif kind == "inserter" then
        return four_way(entity.platform_picture)
    elseif kind == "solar-panel" or kind == "simple-entity-with-owner" or kind == "simple-entity-with-force" then
        return four_way(entity.picture)
    end
end

local function vector(value)
    if type(value) ~= "table" then return nil end
    return {value.x or value[1] or 0, value.y or value[2] or 0}
end

-- Offset turned from north to direction index 1-4 (clockwise, y down).
local function rotate(offset, index)
    local x, y = offset[1], offset[2]
    if index == 2 then return {-y, x} elseif index == 3 then return {-x, -y} elseif index == 4 then return {y, -x} end
    return {x, y}
end

-- Smoke source offsets per direction of the first smoke of the building's energy source (or generator).
local function smoke_offsets(entity)
    local source = entity.energy_source and entity.energy_source.smoke and entity.energy_source.smoke[1]
        or entity.smoke and entity.smoke[1]
    if not source then return nil end
    local base = vector(source.position) or {0, 0}
    local result = {}
    for index, key in ipairs(DIRECTIONS) do
        result[index] = vector(source[key .. "_position"]) or rotate(base, index)
    end
    return result
end

-- Selection box per direction as {center x, center y, width, height} (soot and smoke of non-smoking machines).
local function boxes(entity)
    local box = entity.selection_box or entity.collision_box
    if not box then return nil end
    local left_top = vector(box.left_top or box[1])
    local right_bottom = vector(box.right_bottom or box[2])
    if not (left_top and right_bottom) then return nil end
    local cx, cy = (left_top[1] + right_bottom[1]) / 2, (left_top[2] + right_bottom[2]) / 2
    local width, height = right_bottom[1] - left_top[1], right_bottom[2] - left_top[2]
    if width <= 0 or height <= 0 then return nil end
    local result = {}
    for index = 1, 4 do
        local center = rotate({cx, cy}, index)
        local turned = index == 2 or index == 4
        result[index] = {center[1], center[2], turned and height or width, turned and width or height}
    end
    return result
end

local entity_cache = {}
local function find_entity(raw, name)
    local cached = entity_cache[name]
    if cached ~= nil then return cached or nil end
    for type_name in pairs(defines.prototypes.entity) do
        local group = raw[type_name]
        if group and group[name] then
            entity_cache[name] = group[name]
            return group[name]
        end
    end
    entity_cache[name] = false
end

local SUPPORTED = {}
for _, kind in ipairs(rules.types) do SUPPORTED[kind] = true end

-- Every body layer once (the idle and working animation often repeat a frame). Buildings whose layers overlap
-- keep only the files listed in prototypes/defect-look-layers.lua (generated from the pixels of the layers by
-- review/defect-look/_tools/exceptions.py): an overlapping pixel would be darkened twice.
local function select_layers(layers, keep)
    local result, seen = {}, {}
    for _, layer in ipairs(layers) do
        local key = serpent.line(layer)
        if not seen[key] and (not keep or keep[layer.filename:match("[^/]*$")]) then
            seen[key] = true
            result[#result + 1] = layer
        end
    end
    return result
end

-- Sprite names for 4 direction layer lists: one name when every direction is the same.
local function add_sprites(prototypes, base, layers_by_direction, keep)
    local selected = {}
    for index = 1, 4 do
        selected[index] = select_layers(layers_by_direction[index], keep)
        if #selected[index] == 0 then return nil end
    end
    layers_by_direction = selected
    local names, seen = {}, {}
    local first = serpent.line(layers_by_direction[1])
    local all_same = true
    for index = 2, 4 do
        if serpent.line(layers_by_direction[index]) ~= first then all_same = false end
    end
    for index = 1, all_same and 1 or 4 do
        local layers = layers_by_direction[index]
        local key = serpent.line(layers)
        local name = seen[key]
        if not name then
            name = all_same and base or (base .. "-" .. index)
            seen[key] = name
            prototypes[#prototypes + 1] = {type = "sprite", name = name, layers = table.deepcopy(layers)}
        end
        names[index] = name
    end
    return names
end

function M.apply(raw, finished, no_defect)
    local prototypes, entries, skipped = {}, {}, {}
    local count = 0
    for kind in pairs(defines.prototypes.item) do
        for name, item in pairs(raw[kind] or {}) do
            local result = item.place_result
            if type(result) == "string" and finished[name] and not no_defect[name] and entries[result] == nil then
                local entity = find_entity(raw, result)
                if entity and SUPPORTED[entity.type] then
                    local main, flipped = graphics_of(entity)
                    local keep
                    if EXCEPTIONS[result] then
                        keep = {}
                        for _, file in ipairs(EXCEPTIONS[result]) do keep[file] = true end
                    end
                    local names = main and add_sprites(prototypes, rules.prefix .. result, main, keep)
                    if names then
                        if flipped and serpent.line(flipped) == serpent.line(main) then flipped = nil end
                        local flipped_names = flipped and add_sprites(prototypes, rules.prefix .. result .. "-m", flipped, keep)
                        entries[result] = {
                            s = names,
                            f = flipped_names,
                            k = smoke_offsets(entity),
                            w = rules.working_types[entity.type] or nil,
                            b = boxes(entity),
                        }
                        count = count + 1
                    else
                        entries[result] = false
                        skipped["no graphics " .. entity.type] = (skipped["no graphics " .. entity.type] or 0) + 1
                    end
                elseif entity then
                    entries[result] = false
                    skipped[entity.type] = (skipped[entity.type] or 0) + 1
                end
            end
        end
    end
    for name, entry in pairs(entries) do
        if not entry then entries[name] = nil end
    end
    local silhouettes = #prototypes

    for variant = 1, rules.soot_variants do
        prototypes[#prototypes + 1] = {
            type = "sprite",
            name = rules.soot_prefix .. variant,
            filename = "__ic-more-qualities__/graphics/defects/soot-" .. variant .. ".png",
            size = 256,
            -- 256 px = one tile at scale 1; control.lua scales it to the building.
            scale = 1 / 8,
            priority = "medium",
        }
    end
    -- Dark smoke: the base smoke blended into the train smoke by rules.smoke_mix (color in premultiplied form and
    -- the numeric timing fields present in both); -5 is a copy of the train smoke of the build.
    local smokes = raw["trivial-smoke"] or {}
    local smoke, train = smokes["smoke"], smokes["train-smoke"]
    -- Durations are uint32 in ticks: rounded. fade_in + fade_away <= duration holds for both sources and so for
    -- their blend (base 0 + 600 <= 600, train 0 + 100 <= 150). Omitted fields use the prototype defaults.
    local TIMING = {duration = true, fade_in_duration = true, fade_away_duration = true, spread_duration = true,
        start_scale = false, end_scale = false}
    local DEFAULTS = {fade_in_duration = 0, fade_away_duration = 0, spread_duration = 0, start_scale = 1, end_scale = 1}
    local function color_of(value)
        if type(value) ~= "table" then return nil end
        return {value.r or value[1] or 0, value.g or value[2] or 0, value.b or value[3] or 0, value.a or value[4] or 1}
    end
    if smoke then
        local from = color_of(smoke.color) or {0.4, 0.4, 0.4, 0.4}
        local to = train and color_of(train.color) or {0, 0, 0, 0.3}
        for grade = 1, 5 do
            local mix = rules.smoke_mix[grade]
            local copy
            if mix >= 1 and train then
                copy = table.deepcopy(train)
            else
                copy = table.deepcopy(smoke)
                local c = {}
                for index = 1, 4 do c[index] = from[index] + (to[index] - from[index]) * mix end
                copy.color = {r = c[1], g = c[2], b = c[3], a = c[4]}
                for key, ticks in pairs(TIMING) do
                    local a, b = smoke[key] or DEFAULTS[key], train and (train[key] or DEFAULTS[key])
                    if type(a) == "number" and type(b) == "number" then
                        local value = a + (b - a) * mix
                        copy[key] = ticks and math.floor(value + 0.5) or value
                    end
                end
            end
            copy.name = rules.smoke_prefix .. grade
            prototypes[#prototypes + 1] = copy
        end
    end
    prototypes[#prototypes + 1] = {
        type = "mod-data",
        name = rules.mod_data,
        data_type = "ic-more-qualities.defect-look",
        data = {entities = entries},
    }

    local parts = {}
    for reason, number in pairs(skipped) do parts[#parts + 1] = reason .. " " .. number end
    table.sort(parts)
    local report = {
        "IC defects: look of defective buildings: " .. count .. " buildings, " .. silhouettes .. " silhouette sprites"
            .. (smoke and "" or "; base smoke missing, no dark smoke") .. (train and "" or "; train smoke missing"),
        "IC defects: look skipped (types without a silhouette): " .. (#parts > 0 and table.concat(parts, ", ") or "none"),
    }
    return prototypes, report
end

return M
