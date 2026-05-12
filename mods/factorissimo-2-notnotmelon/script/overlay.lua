local function build_display_upgrade(factory)
    if not factory.force.technologies["factory-interior-upgrade-display"].researched then return end
    if factory.inside_overlay_controller and factory.inside_overlay_controller.valid then return end
    if not factory.inside_surface or not factory.inside_surface.valid then return end

    local pos = factory.layout.overlays
    local controller = factory.inside_surface.create_entity {
        name = "factory-overlay-controller",
        position = {
            factory.inside_x + pos.inside_x,
            factory.inside_y + pos.inside_y
        },
        force = factory.force,
        quality = factory.quality
    }
    controller.minable = false
    controller.destructible = false
    controller.rotatable = false
    factory.inside_overlay_controller = controller
end
factorissimo.build_display_upgrade = build_display_upgrade

local sprite_path_translation = {
    virtual = "virtual-signal",
}
local function draw_overlay_sprite(signal, target_entity, offset, scale, id_table)
    local sprite_name = (sprite_path_translation[signal.type] or signal.type) .. "/" .. signal.name
    if target_entity.valid then
        local sprite_data = {
            sprite = sprite_name,
            x_scale = scale,
            y_scale = scale,
            target = {
                entity = target_entity,
                offset = offset,
            },
            surface = target_entity.surface,
            only_in_alt_mode = true,
            render_layer = "entity-info-icon",
        }
        -- Fake shadows
        local shadow_radius = 0.07 * scale
        for _, shadow_offset in pairs {{0, shadow_radius}, {0, -shadow_radius}, {shadow_radius, 0}, {-shadow_radius, 0}} do
            sprite_data.tint = {0, 0, 0, 0.5} -- Transparent black
            sprite_data.target.offset = {offset[1] + shadow_offset[1], offset[2] + shadow_offset[2]}
            table.insert(id_table, rendering.draw_sprite(sprite_data).id)
        end
        -- Proper sprite
        sprite_data.tint = nil
        sprite_data.target.offset = offset
        table.insert(id_table, rendering.draw_sprite(sprite_data).id)

        local quality = signal.quality and prototypes.quality[signal.quality]
        if quality and not quality.hidden and quality.level > 0 then
            table.insert(id_table, rendering.draw_sprite {
                sprite = "quality/" .. quality.name,
                target = {
                    entity = target_entity,
                    offset = {offset[1] - 0.25 * scale, offset[2] + 0.25 * scale},
                },
                surface = target_entity.surface,
                only_in_alt_mode = true,
                render_layer = "entity-info-icon",
                x_scale = scale * 0.4,
                y_scale = scale * 0.4,
            }.id)
        end
    end
end

local function get_nice_overlay_arrangement(width, height, amount)
    -- Computes a nice arrangement of square sprites within a rectangle of given size
    -- Returned coordinates are relative to the center of the rectangle
    if amount <= 0 then return {} end
    local opt_rows = 1
    local opt_cols = 1
    local opt_scale = 0
    -- Determine the optimal number of rows to use
    -- This assumes width >= height
    for rows = 1, math.ceil(math.sqrt(amount)) do
        local cols = math.ceil(amount / rows)
        local scale = math.min(width / cols, height / rows)
        if scale > opt_scale then
            opt_rows = rows
            opt_cols = cols
            opt_scale = scale
        end
    end
    -- Adjust scale to ensure that sprites do not become too big
    opt_scale = (opt_scale ^ 0.8) * (1.5 ^ (0.8 - 1))
    -- Create evenly spaced coordinates
    local result = {}
    for i = 0, amount - 1 do
        local col = i % opt_cols
        local row = math.floor(i / opt_cols)
        local cols_in_row = (row < opt_rows - 1 and opt_cols or (amount - 1) % opt_cols + 1)
        table.insert(result, {
            x = (2 * col + 1 - cols_in_row) * width / (2 * opt_cols),
            y = (2 * row + 1 - opt_rows) * height / (2 * opt_rows),
            scale = opt_scale
        })
    end
    return result
end

local function convert_logistic_sections_into_overlay_icons(control_behavior)
    local overlay_icons = {}
    for _, section in pairs(control_behavior.sections) do
        if section.active then
            for _, filter in pairs(section.filters) do
                if filter.value then
                    table.insert(overlay_icons, filter.value)
                end
            end
        end
    end
    return overlay_icons
end

local function update_overlay(factory, draw_onto)
    if not draw_onto then
        for _, id in pairs(factory.outside_overlay_displays) do
            local object = rendering.get_object_by_id(id)
            if object then object.destroy() end
        end
        factory.outside_overlay_displays = {}
    end

    if not factory.built then return end
    if not factory.building.valid then return end
    local controller = factory.inside_overlay_controller
    if not controller then return end
    if not controller.valid then return end
    local control_behavior = controller.get_or_create_control_behavior()
    if not control_behavior.enabled then return end

    local overlay_icons = convert_logistic_sections_into_overlay_icons(control_behavior)

    local sprite_positions = get_nice_overlay_arrangement(
        factory.layout.overlays.outside_w,
        factory.layout.overlays.outside_h,
        #overlay_icons
    )
    local i = 0
    for _, param in pairs(overlay_icons) do
        i = i + 1
        draw_overlay_sprite(
            param,
            draw_onto or factory.building,
            {sprite_positions[i].x + factory.layout.overlays.outside_x, sprite_positions[i].y + factory.layout.overlays.outside_y},
            sprite_positions[i].scale,
            factory.outside_overlay_displays
        )
    end
end
factorissimo.update_overlay = update_overlay

local function copy_overlay_between_factory_buildings(source, destination)
    local source_controller = source.inside_overlay_controller
    local destination_controller = destination.inside_overlay_controller

    if not source_controller or not destination_controller then return end
    if not source_controller.valid or not destination_controller.valid then return end

    local source_control_behavior = source_controller.get_or_create_control_behavior()
    local destination_control_behavior = destination_controller.get_or_create_control_behavior()

    destination_control_behavior.enabled = source_control_behavior.enabled

    -- Remove all sections from the destination controller
    for i = #destination_control_behavior.sections, 1, -1 do
        destination_control_behavior.remove_section(i)
    end

    -- Copy all sections from the source controller
    for _, section in pairs(source_control_behavior.sections) do
        local new_section = destination_control_behavior.add_section(section.group)
        new_section.active = section.active
        new_section.multiplier = section.multiplier
        new_section.filters = section.filters
    end

    factorissimo.update_overlay(destination)
end
factorissimo.copy_overlay_between_factory_buildings = copy_overlay_between_factory_buildings

factorissimo.on_event(defines.events.on_player_changed_surface, function(event)
    for _, factory in pairs(storage.factories) do
        factorissimo.update_overlay(factory)
    end
end)
