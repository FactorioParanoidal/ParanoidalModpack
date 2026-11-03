-- Look of defective buildings (user request 2026-11-03, variant chosen 2026-11-04): a darker silhouette with a rust
-- cast per defect grade, soot on the building and on the ground, dark smoke while working.
-- Data: prototypes/defect-look.lua; constants: scripts/defects/look-rules.lua.
-- The render objects are attached to their building, so the engine destroys them together with it; storage
-- keeps their ids only to redraw after a rotation, a flip or a change of the layer setting. No work per tick
-- except the smoke list (one look per smoking building every SMOKE_PERIOD ticks).
local rules = require("scripts.defects.look-rules")

local M = {}

-- control.lua: production mode twins use the look of their original.
M.base_name = function(name) return name end

local SMOKE_PERIOD = 20
local GRADE = {}
for grade = 1, 5 do GRADE["ic-defect-" .. grade] = grade end
local TINTS = {}
for grade = 1, 5 do TINTS[grade] = rules.tint(grade) end

local entries_cache, layer_cache, smoke_ok

function M.reset_cache() entries_cache, layer_cache, smoke_ok = nil, nil, nil end

local function entries()
    if not entries_cache then
        local mod_data = prototypes.mod_data[rules.mod_data]
        entries_cache = mod_data and mod_data.data.entities or {}
        -- Without the base smoke the data stage made no dark smoke prototypes.
        smoke_ok = prototypes.trivial_smoke[rules.smoke_prefix .. "5"] ~= nil
    end
    return entries_cache
end

-- Render layer of the silhouette and of the soot on the building (map setting for the visual check).
local function layer()
    if not layer_cache then
        local setting = settings.global[rules.layer_setting]
        layer_cache = setting and setting.value == "above" and "higher-object-under" or "object"
    end
    return layer_cache
end

function M.is_setting(name) return name == rules.layer_setting end

local function state()
    local s = storage.ic_look
    if not s then
        s = {objects = {}, smoke = {}, smoke_index = {}, cursor = 1}
        storage.ic_look = s
    end
    return s
end

local function forget_smoke(s, unit)
    local index = s.smoke_index[unit]
    if not index then return end
    local list = s.smoke
    local last = list[#list]
    list[index] = last
    s.smoke_index[last.u] = index
    list[#list] = nil
    s.smoke_index[unit] = nil
end

-- Removes the look of a building (unit number); its render objects die with it anyway.
function M.forget(unit)
    local s = storage.ic_look
    if not s then return end
    local ids = s.objects[unit]
    if ids then
        for _, id in ipairs(ids) do
            local object = rendering.get_object_by_id(id)
            if object and object.valid then object.destroy() end
        end
        s.objects[unit] = nil
    end
    forget_smoke(s, unit)
end

-- Soot stain: on the ground under and around the building, or smaller on its upper part.
local function soot(entity, box, variant, grade, over, render_layer)
    local scale = over and 0.8 or 1
    local margin = over and 0 or 2
    return rendering.draw_sprite({
        sprite = rules.soot_prefix .. variant,
        target = {entity = entity, offset = {box[1], box[2] - (over and 0.25 * box[4] or 0)}},
        surface = entity.surface,
        x_scale = box[3] * scale + margin,
        y_scale = box[4] * scale + margin,
        tint = {r = 0, g = 0, b = 0, a = rules.soot_alpha(grade)},
        render_layer = render_layer,
    }).id
end

-- Draws (or redraws) the look of a building; a building that is not defective loses its look.
function M.draw(entity)
    if not (entity and entity.valid) then return end
    local unit = entity.unit_number
    if not unit then return end
    M.forget(unit)
    local quality = entity.quality
    local grade = quality and GRADE[quality.name]
    if not grade then return end
    local entry = entries()[M.base_name(entity.name)]
    if not entry then return end
    local s = state()
    local direction = math.floor((entity.direction or 0) / 4) % 4 + 1
    local render_layer = layer()
    local box = entry.b and entry.b[direction]
    local position = entity.position
    local variant = math.floor(position.x * 7 + position.y * 13) % rules.soot_variants + 1
    local ids = {}
    if box then ids[#ids + 1] = soot(entity, box, variant, grade, false, "ground-patch-higher2") end
    local sprites = entry.f and entity.mirroring and entry.f or entry.s
    ids[#ids + 1] = rendering.draw_sprite({
        sprite = sprites[#sprites == 1 and 1 or direction],
        target = entity,
        surface = entity.surface,
        tint = TINTS[grade],
        render_layer = render_layer,
    }).id
    if box then ids[#ids + 1] = soot(entity, box, variant % rules.soot_variants + 1, grade, true, render_layer) end
    s.objects[unit] = ids
    script.register_on_object_destroyed(entity)

    -- Smoke: a building with its own smoke source adds dark smoke while working; other working machines puff
    -- from the top of their box with a chance of grade/5 per look.
    if not smoke_ok then return end
    local offset = entry.k and entry.k[direction]
    local own = offset ~= nil
    if not own and entry.w and box then offset = {box[1], box[2] - 0.3 * box[4]} end
    if not offset then return end
    local list = s.smoke
    list[#list + 1] = {u = unit, e = entity, g = grade, x = offset[1], y = offset[2], own = own,
        n = rules.smoke_count[grade]}
    s.smoke_index[unit] = #list
end

function M.on_tick()
    local s = storage.ic_look
    if not s then return end
    local list = s.smoke
    local total = #list
    if total == 0 then return end
    local working = defines.entity_status.working
    local cursor = s.cursor
    for _ = 1, math.ceil(total / SMOKE_PERIOD) do
        if cursor > #list then cursor = 1 end
        local record = list[cursor]
        if not record then break end
        local entity = record.e
        if not entity.valid then
            -- The slot now holds the last record: look at it next.
            forget_smoke(s, record.u)
            s.objects[record.u] = nil
        else
            if entity.status == working and (record.own or math.random() * 5 < record.g) then
                local position = entity.position
                local surface = entity.surface
                local name = rules.smoke_prefix .. record.g
                for _ = 1, record.n do
                    surface.create_trivial_smoke({name = name, position = {
                        position.x + record.x + (math.random() - 0.5) * 0.3,
                        position.y + record.y - math.random() * 0.5,
                    }})
                end
            end
            cursor = cursor + 1
        end
    end
    s.cursor = cursor
end

-- Removes every look object of this mod (also of buildings missing from storage).
function M.clear_all()
    M.reset_cache()
    storage.ic_look = nil
    if not rendering then return end -- test mocks
    for _, object in pairs(rendering.get_all_objects(script.mod_name)) do
        if object.valid and object.type == "sprite" then
            local sprite = object.sprite
            if type(sprite) == "string" and sprite:sub(1, #rules.prefix) == rules.prefix then object.destroy() end
        end
    end
end

-- Configuration change or a changed layer setting: every defective building is drawn again.
function M.redraw_all()
    M.clear_all()
    if not rendering then return end -- test mocks
    for _, surface in pairs(game.surfaces) do
        for grade = 1, 5 do
            for _, entity in pairs(surface.find_entities_filtered({type = rules.types, quality = "ic-defect-" .. grade})) do
                M.draw(entity)
            end
        end
    end
end

return M
