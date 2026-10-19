-- Paranoidal: factory names. A name is kept in the factory (also while it is packed) and shown:
--   * on the building under the overlay icons, in alt mode;
--   * on the map under the building;
--   * inside the factory above the door, in alt mode.
-- Render objects are attached to entities (the building, the inside power pole), so they disappear together
-- with them; they are redrawn only when the name or the building changes.

local MAX_NAME_LENGTH = 40 -- characters
local NAME_COLOR = {r = 1, g = 0.9, b = 0.6}
local SHADOW_COLOR = {r = 0, g = 0, b = 0, a = 0.85}

--- Trims the name, replaces control characters and limits it to MAX_NAME_LENGTH UTF-8 characters.
--- Returns nil for an empty name.
local function clean_name(name)
    if type(name) ~= "string" then return nil end
    name = name:gsub("%c", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return nil end
    local count, cut = 0, nil
    for position in name:gmatch("()[^\128-\191]") do
        count = count + 1
        if count > MAX_NAME_LENGTH then
            cut = position
            break
        end
    end
    if cut then name = name:sub(1, cut - 1):gsub("%s+$", "") end
    return name
end
factorissimo.clean_factory_name = clean_name

--- Caption of a factory for texts: its name, or "Factory building 2 #12" without a name.
function factorissimo.factory_caption(factory)
    if factory.name then return factory.name end
    local layout_name = factory.layout and factory.layout.name
    if layout_name and prototypes.entity[layout_name] then
        return {"factorissimo-dispatch.unnamed", prototypes.entity[layout_name].localised_name, tostring(factory.id)}
    end
    return {"factorissimo-dispatch.number", tostring(factory.id)}
end

local function destroy_labels(factory)
    for _, id in pairs(factory.name_labels or {}) do
        local object = rendering.get_object_by_id(id)
        if object then object.destroy() end
    end
    factory.name_labels = nil
end

--- Redraws all name labels of the factory.
function factorissimo.update_name_labels(factory)
    destroy_labels(factory)
    local name = factory.name
    local layout = factory.layout
    if not (name and layout) then return end

    local ids = {}
    local rich = name:find("[", 1, true) ~= nil -- names may contain rich text icons; their shadow would be a second icon

    local building = factory.building
    if factory.built and building and building.valid then
        local overlays = layout.overlays
        local y = overlays and (overlays.outside_y + overlays.outside_h / 2) or (layout.outside_size / 4)
        local scale = math.max(1, layout.outside_size / 5)
        local surface = building.surface
        if not rich then
            ids[#ids + 1] = rendering.draw_text {
                text = name,
                surface = surface,
                target = {entity = building, offset = {0.05 * scale, y + 0.05 * scale}},
                color = SHADOW_COLOR,
                scale = scale,
                alignment = "center",
                vertical_alignment = "top",
                only_in_alt_mode = true,
            }.id
        end
        ids[#ids + 1] = rendering.draw_text {
            text = name,
            surface = surface,
            target = {entity = building, offset = {0, y}},
            color = NAME_COLOR,
            scale = scale,
            alignment = "center",
            vertical_alignment = "top",
            only_in_alt_mode = true,
            use_rich_text = rich,
        }.id
        ids[#ids + 1] = rendering.draw_text {
            text = name,
            surface = surface,
            target = {entity = building, offset = {0, layout.outside_size / 2}},
            color = NAME_COLOR,
            scale = 1.2,
            scale_with_zoom = true,
            alignment = "center",
            vertical_alignment = "top",
            render_mode = "chart",
            use_rich_text = rich,
        }.id
    end

    local inside_surface = factory.inside_surface
    if inside_surface and inside_surface.valid and factory.inside_door_x then
        local pole = factorissimo.get_or_create_inside_power_pole(factory)
        local pole_position = pole.position
        ids[#ids + 1] = rendering.draw_text {
            text = name,
            surface = inside_surface,
            target = {entity = pole, offset = {factory.inside_door_x - pole_position.x, factory.inside_door_y - 4 - pole_position.y}},
            color = NAME_COLOR,
            scale = 2,
            alignment = "center",
            vertical_alignment = "middle",
            only_in_alt_mode = true,
            use_rich_text = rich,
        }.id
    end

    factory.name_labels = ids
end

--- Sets (or clears with nil/"") the name of the factory. Returns the stored name.
function factorissimo.set_factory_name(factory, name)
    name = clean_name(name)
    if factory.name == name then return name end
    factory.name = name
    factorissimo.update_name_labels(factory)
    factorissimo.dispatch_changed()
    return name
end
