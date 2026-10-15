local find_surrounding_factory = remote_api.find_surrounding_factory

factorissimo.on_event(factorissimo.events.on_init(), function()
    storage.fancy_preview_active = storage.fancy_preview_active or {}
end)

local PREVIEW_MODE_SETTING = "Factorissimo2-factory-preview-mode"

-- Per-player preview mode. Derived only from the map settings and dropped when the setting changes,
-- so it is the same on every client.
local preview_mode_cache = {}
local function preview_mode(player)
    local index = player.index
    local mode = preview_mode_cache[index]
    if not mode then
        mode = settings.get_player_settings(player)[PREVIEW_MODE_SETTING].value
        preview_mode_cache[index] = mode
    end
    return mode
end

factorissimo.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == PREVIEW_MODE_SETTING then
        if event.player_index then
            preview_mode_cache[event.player_index] = nil
        else
            preview_mode_cache = {}
        end
    end
end)

local function new_frame(player, name)
    local frame = player.gui.screen.add {type = "frame", name = name, style = "invisible_frame", auto_center = false}
    frame.style.padding = 0
    frame.style.margin = 0
    frame.ignored_by_interaction = true
    frame.style.horizontal_align = "center"
    frame.style.vertical_align = "center"
    frame.visible = false
    return frame
end

local function get_camera_frame(player)
    return player.gui.screen.factory_camera_frame or new_frame(player, "factory_camera_frame")
end

local function get_minimap_frame(player)
    return player.gui.screen.factory_minimap_frame or new_frame(player, "factory_minimap_frame")
end

local function show_frame(frame)
    if not frame.visible then
        frame.visible = true
        frame.bring_to_front()
    end
end

local function minimap_dimensions(player)
    local size = 240

    if player.controller_type == defines.controllers.remote then
        return {
            size = size,
            x = player.display_resolution.width - (8 + size + 12) * player.display_scale,
            y = (40 + 144) * player.display_scale
        }
    end

    return {
        size = size,
        x = player.display_resolution.width - (8 + size) * player.display_scale,
        y = 144 * player.display_scale
    }
end

local function update_camera(player)
    local camera_frame = player.gui.screen.factory_camera_frame
    if not camera_frame or not camera_frame.visible then return end
    local selected = player.selected
    if not selected or not selected.valid then return end
    if not has_layout(selected.name) then return end

    local factory = storage.factories_by_entity[selected.unit_number]
    if not factory or not factory.layout then return end
    local zoom = player.zoom
    local display_resolution = player.display_resolution
    local display_scale = player.display_scale

    local selected_position = selected.position
    local render_position = player.render_position
    local left_margin = (selected_position.x - render_position.x) * zoom * 32
    local top_margin = (selected_position.y - render_position.y) * zoom * 32
    local preview_size_world = (factory.layout.outside_size * 32 - 32)
    local preview_size_screen = preview_size_world * zoom

    camera_frame.location = {
        left_margin + display_resolution.width / 2 - preview_size_screen / 2,
        top_margin + display_resolution.height / 2 - preview_size_screen / 2
    }

    local camera = camera_frame.factory_camera
    if not camera then return end
    camera.style.width = preview_size_screen / display_scale
    camera.style.height = preview_size_screen / display_scale
    camera.zoom = preview_size_world / (factory.layout.inside_size + 2) * zoom / 32 / player.display_density_scale
end

local function set_camera(player, factory)
    local has_tech = player.force.technologies["factory-interior-upgrade-lights"].researched
    if not has_tech then return false end

    if not factory or factory.inactive then return false end
    local inside_surface = factory.inside_surface
    if not (inside_surface and inside_surface.valid) then return false end
    storage.fancy_preview_active[player.index] = true

    local position = {x = factory.inside_x, y = factory.inside_y}

    local camera_frame = get_camera_frame(player)
    local camera = camera_frame.factory_camera
    if not camera then
        camera = camera_frame.add {type = "camera", name = "factory_camera", position = position}
        camera.style.margin = 0
        camera.style.padding = 0
        camera.style.horizontally_stretchable = false
        camera.style.vertically_stretchable = false
        camera.ignored_by_interaction = true
    end

    camera.position = position
    camera.surface_index = inside_surface.index
    show_frame(camera_frame)

    update_camera(player)
    return true
end

factorissimo.on_event(defines.events.on_player_changed_position, function(event)
    -- the normal on_tick check does not run in editor mode. check for game paused
    if game.tick_paused then
        local player = game.get_player(event.player_index)
        update_camera(player)
    end
end)

factorissimo.on_event(defines.events.on_tick, function()
    local active = storage.fancy_preview_active
    if not next(active) then return end
    for player_index in pairs(active) do
        local player = game.get_player(player_index)
        if player and player.connected then
            update_camera(player)
        else
            active[player_index] = nil
        end
    end
end)

local function set_minimap(player, factory, inside)
    if not factory or not factory.layout then return false end
    local inside_surface = factory.inside_surface
    local outside_surface = factory.outside_surface
    if not (inside_surface and inside_surface.valid and outside_surface and outside_surface.valid) then return false end

    local dimensions = minimap_dimensions(player)

    local position, surface_index, zoom
    if inside then
        position = {x = factory.inside_x, y = factory.inside_y}
        surface_index = inside_surface.index
        zoom = (dimensions.size / 32) / (factory.layout.inside_size + 8) * player.display_scale / player.display_density_scale
    else
        position = {x = factory.outside_x, y = factory.outside_y}
        surface_index = outside_surface.index
        zoom = (dimensions.size / 32) / (factory.layout.outside_size + 8) * player.display_scale / player.display_density_scale
    end
    local minimap_frame = get_minimap_frame(player)
    minimap_frame.location = {dimensions.x, dimensions.y}

    local camera = minimap_frame.factory_camera
    if not camera then
        camera = minimap_frame.add {type = "camera", name = "factory_camera", position = position, surface_index = surface_index, zoom = zoom}
        camera.style.margin = 0
        camera.style.padding = 0
        camera.style.horizontally_stretchable = false
        camera.style.vertically_stretchable = false
        camera.ignored_by_interaction = true
    end

    camera.position = position
    camera.surface_index = surface_index
    camera.zoom = zoom
    camera.style.width = dimensions.size
    camera.style.height = dimensions.size
    if player.minimap_enabled then
        show_frame(minimap_frame)
    else
        minimap_frame.visible = false
    end
    return true
end

local function hide_frame(frame)
    if frame and frame.visible then frame.visible = false end
end

local function unset_camera(player)
    storage.fancy_preview_active[player.index] = nil
    local screen = player.gui.screen
    hide_frame(screen.factory_camera_frame)
    hide_frame(screen.factory_minimap_frame)
end

local function saved_factory_of_stack(stack)
    if stack and stack.valid_for_read and stack.type == "item-with-tags" and has_layout(stack.name) then
        local tags = stack.tags
        return tags and tags.id and storage.saved_factories[tags.id]
    end
    return nil
end

local function update_factory_preview(player)
    local mode = preview_mode(player)

    if mode == "off" then
        unset_camera(player)
        return
    end

    local factory = saved_factory_of_stack(player.cursor_stack)
    if factory then
        if set_minimap(player, factory, true) then
            storage.fancy_preview_active[player.index] = nil
            hide_frame(player.gui.screen.factory_camera_frame)
            return
        end
    end

    local selected = player.selected
    if selected then
        local inside = true
        local fancy = false
        local selected_type = selected.type
        if selected.name == "factory-power-pole" then
            factory = find_surrounding_factory(selected.surface, selected.position)
            inside = false
        elseif selected_type == "item-entity" then
            factory = saved_factory_of_stack(selected.stack)
        elseif selected_type == "construction-robot" or selected_type == "logistic-robot" then
            local inventory = selected.get_inventory(defines.inventory.robot_cargo)
            if inventory and #inventory >= 1 then
                factory = saved_factory_of_stack(inventory[1])
            end
        elseif selected_type == BUILDING_TYPE then
            factory = storage.factories_by_entity[selected.unit_number]
            fancy = mode == "fancy"
        end

        if factory and factory.layout then
            factorissimo.update_overlay(factory)
            if fancy then
                hide_frame(player.gui.screen.factory_minimap_frame)
                if set_camera(player, factory) then return end
            elseif set_minimap(player, factory, inside) then
                storage.fancy_preview_active[player.index] = nil
                hide_frame(player.gui.screen.factory_camera_frame)
                return
            end
        end
    end
    unset_camera(player)
end
factorissimo.update_factory_preview = update_factory_preview

factorissimo.on_event({
    defines.events.on_selected_entity_changed,
    defines.events.on_player_cursor_stack_changed,
    defines.events.on_player_display_resolution_changed,
    defines.events.on_player_display_scale_changed,
    defines.events.on_player_controller_changed,
    defines.events.on_player_changed_surface
}, function(event)
    local player = game.get_player(event.player_index)
    if player then update_factory_preview(player) end
end)

local god_controllers = {
    [defines.controllers.god] = true,
    [defines.controllers.editor] = true,
    [defines.controllers.spectator] = true,
}
local function camera_teleport(player, surface, position)
    local old_controller = player.controller_type

    if god_controllers[old_controller] then
        player.teleport(position, surface, true, false)
        return
    end

    player.set_controller {
        type = defines.controllers.remote,
        position = position,
        surface = surface
    }
    player.zoom = 0.6
    player.opened = nil
end

local function open_outside_in_remote_view(player, pole)
    local factory = find_surrounding_factory(pole.surface, pole.position)
    if not (factory and factory._inside_power_pole == pole) then
        factory = nil
        for _, candidate in pairs(storage.factories) do
            if candidate._inside_power_pole == pole then
                factory = candidate
                break
            end
        end
    end
    if not (factory and factory.built and factory.outside_surface and factory.outside_surface.valid) then return end

    local teleport_position = {x = factory.outside_x, y = factory.outside_y}

    local recursive_parent = find_surrounding_factory(factory.outside_surface, teleport_position)
    if recursive_parent then teleport_position = {recursive_parent.inside_x, recursive_parent.inside_y} end

    factorissimo.update_overlay(factory)
    camera_teleport(player, factory.outside_surface, teleport_position)
end

factorissimo.on_event("factory-open-outside-surface-to-remote-view", function(event)
    local player = game.get_player(event.player_index)
    local entity = player.selected
    if not entity or not entity.valid then return end

    if entity.name == "factory-power-pole" then -- teleport the camera to the outside of the factory
        open_outside_in_remote_view(player, entity)
        return
    end

    local factory = remote_api.get_factory_by_entity(entity)
    if not factory or not (factory.inside_surface and factory.inside_surface.valid) then return end

    local teleport_position = {factory.inside_x, factory.inside_y}
    camera_teleport(player, factory.inside_surface, teleport_position)
end)
