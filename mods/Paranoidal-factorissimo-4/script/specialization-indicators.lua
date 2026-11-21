local M = {}
local prefix = "factory-specialization-"
local locale = "factory-specialization."
local green = "[color=0.63,0.89,0.53]"
local red = "[color=1,0.57,0.51]"
local max_groups = 6
local rows = {"speed", "efficiency"}
local background = {{0.075, 0.09, 0.105}, {0.064, 0.088, 0.07}}
local font_color = {0.94, 0.94, 0.94}
local muted = {0.60, 0.63, 0.64}
local tier_name = {"I", "II", "III"}
local tooltip_schema = "v3\0"
local inactive_icon_color = {0.5, 0.5, 0.5, 0.65}
-- At the reference Full HD view (~26 px/tile), world scale 1.38 matches the old screen scale 1.13.
local label_scale = 1.38

local function destroy(row)
    local marker = row.marker
    storage.factory_specialization_markers[row.unit] = nil
    -- Render objects are attached to the marker and disappear with it.
    if marker.valid then marker.destroy() end
end

function M.clear(state)
    for _, row in pairs(state.rows or {}) do destroy(row) end
    state.rows = nil
end

local function create(factory, i)
    local surface, force = factory.inside_surface, factory.force
    local marker = surface.create_entity {
        name = prefix .. rows[i], force = force, position = {factory.inside_door_x, factory.inside_door_y + 3.4 + (i - 1) * 2.1},
    }
    if not marker then return end
    marker.destructible = false
    marker.operable = false
    local unit = marker.unit_number
    storage.factory_specialization_markers[unit] = factory.id
    rendering.draw_rectangle {
        surface = surface, forces = {force}, color = background[i], filled = true, draw_on_ground = true,
        left_top = {entity = marker, offset = {-9, -1}}, right_bottom = {entity = marker, offset = {9, 1}},
    }
    local icon = rendering.draw_sprite {
        sprite = prefix .. rows[i] .. "-0", tint = inactive_icon_color, surface = surface, forces = {force},
        target = {entity = marker, offset = {-7.85, 0}}, x_scale = 0.83, y_scale = 0.83, render_layer = "entity-info-icon",
    }
    local text = rendering.draw_text {
        text = "", color = muted, surface = surface, forces = {force}, target = {entity = marker, offset = {-6.7, 0}},
        scale = label_scale, scale_with_zoom = false, vertical_alignment = "middle", font = "default-bold",
    }
    return {marker = marker, unit = unit, icon = icon, text = text}
end

local function colored(value, passes)
    return {"", passes and green or red, value, "[/color]"}
end

local function pct(n, total)
    local per_mille = math.floor(1000 * n / total + 0.5)
    return {locale .. "percent", math.floor(per_mille / 10), per_mille % 10}
end

local function field(row, id, name, value)
    row.marker.set_tooltip_field {id = id, order = id, name = name, value = value}
end

local function tooltip(row, groups, total, tier, thresholds)
    local shown = math.min(#groups, max_groups)
    local required = thresholds[math.max(1, tier)]
    local next_target = thresholds[tier + 1]
    field(row, 1, {locale .. "park"}, {locale .. "summary", total, tier_name[tier] or {locale .. "inactive"}})
    field(row, 11, {locale .. "inspect"}, {locale .. "inspect-toggle"})
    field(row, 12, {locale .. "inspect-colors"}, {locale .. (tier > 0 and "inspect-active" or "inspect-candidate")})
    for i = 1, shown do
        local group = groups[i]
        local model = prototypes.entity[group.model]
        local name = model and model.localised_name or group.model
        if group.recipe then
            local recipe = prototypes.recipe[group.recipe]
            local label = group.recipe == "" and {locale .. "no-recipe"} or (recipe and recipe.localised_name or group.recipe)
            name = {locale .. "series-group", name, label}
        end
        local matching = group.count * 10 >= total * 9
        field(row, i + 1, name, {locale .. "group-size",
            colored(group.count, group.count >= required), colored(pct(group.count, total), matching)})
    end
    for i = shown + 2, (row.shown or 0) + 1 do row.marker.clear_tooltip_field(i) end
    row.shown = shown
    if #groups > shown then
        field(row, 8, {locale .. "other-groups"}, #groups - shown)
    else
        row.marker.clear_tooltip_field(8)
    end
    if next_target then
        field(row, 9, {locale .. "next-tier", tier_name[tier + 1]}, {locale .. "requirements", next_target})
    else
        row.marker.clear_tooltip_field(9)
    end
end

local function update_row(row, index, groups, total, tier, thresholds)
    -- Update saved screen-sized labels in place, even when the tier and tooltip are unchanged.
    if row.text.scale_with_zoom then
        row.text.scale = label_scale
        row.text.scale_with_zoom = false
    end
    local sprite = prefix .. rows[index] .. "-" .. tier
    -- A saved inactive row can still show the old tier-I sprite.
    if row.tier ~= tier or (tier == 0 and row.icon.sprite ~= sprite) then
        local active = tier > 0
        row.icon.sprite = sprite
        row.icon.color = active and {1, 1, 1, 1} or inactive_icon_color
        row.text.color = active and font_color or muted
        row.text.text = {locale .. (active and rows[index] .. "-active" or rows[index] .. "-inactive"), tier * 5}
        row.tier = tier
    end
    local key = {total, #groups, tier}
    for i = 1, math.min(#groups, max_groups) do
        local group = groups[i]
        key[#key + 1] = group.model
        key[#key + 1] = group.recipe or ""
        key[#key + 1] = group.count
    end
    local signature = tooltip_schema .. table.concat(key, "\0")
    if row.signature ~= signature then
        -- Saved markers can still carry the old advice field even when the park is unchanged.
        if row.signature and row.signature:sub(1, #tooltip_schema) ~= tooltip_schema then
            row.marker.clear_tooltip_field(10)
        end
        tooltip(row, groups, total, tier, thresholds)
        row.signature = signature
    end
end

function M.update(factory, state, series, park, total, speed, efficiency, thresholds)
    state.rows = state.rows or {}
    for i = 1, #rows do
        local row = state.rows[i]
        if not (row and row.marker.valid and row.marker.force == factory.force and row.icon.valid and row.text.valid) then
            if row then destroy(row) end
            row = create(factory, i)
            state.rows[i] = row
        end
        if row then
            update_row(row, i, i == 1 and series or park, total, i == 1 and speed or efficiency, thresholds)
        end
    end
end

return M
