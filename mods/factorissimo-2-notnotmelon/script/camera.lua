local mod_gui = require "mod-gui"
local get_factory_by_entity = remote_api.get_factory_by_entity
local find_surrounding_factory = remote_api.find_surrounding_factory

factorissimo.on_event(factorissimo.events.on_init(), function()
    storage.fancy_preview_active = storage.fancy_preview_active or {}
end)

local function get_camera_frame(player)
    local camera_frame = player.gui.screen.factory_camera_frame
    if not camera_frame then
        camera_frame = player.gui.screen.add {type = "frame", name = "factory_camera_frame", style = "invisible_frame", auto_center = false}
        camera_frame.style.padding = 0
        camera_frame.style.margin = 0
        camera_frame.ignored_by_interaction = true
        camera_frame.style.horizontal_align = "center"
        camera_frame.style.vertical_align = "center"
    end
    camera_frame.bring_to_front()
    return camera_frame
end

local function get_minimap_frame(player)
    local camera_frame = player.gui.screen.factory_minimap_frame
    if not camera_frame then
        camera_frame = player.gui.screen.add {type = "frame", name = "factory_minimap_frame", style = "invisible_frame", auto_center = false}
        camera_frame.style.padding = 0
        camera_frame.style.margin = 0
        camera_frame.ignored_by_interaction = true
        camera_frame.style.horizontal_align = "center"
        camera_frame.style.vertical_align = "center"
    end
    camera_frame.bring_to_front()
    return camera_frame
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
    local camera_frame = get_camera_frame(player)
    if not camera_frame.visible then return end
    local selected = player.selected
    if not selected or not selected.valid then return end
    if not has_layout(selected.name) then return end

    local factory = get_factory_by_entity(selected)
    local zoom = player.zoom
    local display_resolution = player.display_resolution
    local display_scale = player.display_scale

    local left_margin = (selected.position.x - player.render_position.x) * zoom * 32
    local top_margin = (selected.position.y - player.render_position.y) * zoom * 32
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
    if not has_tech then return end

    if not factory or factory.inactive then return end
    local inside_surface = factory.inside_surface
    if not inside_surface.valid then return end
    storage.fancy_preview_active[player.index] = true

    position = {x = factory.inside_x, y = factory.inside_y}
    surface_index = inside_surface.index

    local camera_frame = get_camera_frame(player)
    local camera = camera_frame.factory_camera
    if not camera then
        camera = camera_frame.add {type = "camera", name = "factory_camera", position = position}
    end

    camera.position = position
    camera.surface_index = surface_index
    camera.style.margin = 0
    camera.style.padding = 0
    camera.style.horizontally_stretchable = false
    camera.style.vertically_stretchable = false
    camera.ignored_by_interaction = true
    camera_frame.visible = true

    update_camera(player)
end

factorissimo.on_event(defines.events.on_player_changed_position, function(event)
    -- the normal on_tick check does not run in editor mode. check for game paused
    if game.tick_paused then
        local player = game.get_player(event.player_index)
        update_camera(player)
    end
end)

factorissimo.on_event(defines.events.on_tick, function()
    for player_index in pairs(storage.fancy_preview_active) do
        local player = game.get_player(player_index)
        if player and player.connected then
            update_camera(player)
        else
            storage.fancy_preview_active[player_index] = nil
            return
        end
    end
end)

local function set_minimap(player, factory, inside)
    if not factory then return end
    local inside_surface = factory.inside_surface
    local outside_surface = factory.outside_surface
    if not inside_surface.valid or not outside_surface.valid then return end

    local minimap_dimensions = minimap_dimensions(player)

    local position, surface_index, zoom
    if inside then
        position = {x = factory.inside_x, y = factory.inside_y}
        surface_index = inside_surface.index
        zoom = (minimap_dimensions.size / 32) / (factory.layout.inside_size + 8) * player.display_scale / player.display_density_scale
    else
        position = {x = factory.outside_x, y = factory.outside_y}
        surface_index = outside_surface.index
        zoom = (minimap_dimensions.size / 32) / (factory.layout.outside_size + 8) * player.display_scale / player.display_density_scale
    end
    local minimap_frame = get_minimap_frame(player)
    minimap_frame.location = {minimap_dimensions.x, minimap_dimensions.y}

    local camera = minimap_frame.factory_camera
    if not camera then
        camera = minimap_frame.add {type = "camera", name = "factory_camera", position = position, surface_index = surface_index, zoom = zoom}
    end

    camera.position = position
    camera.surface_index = surface_index
    camera.zoom = zoom
    camera.style.margin = 0
    camera.style.padding = 0
    camera.style.width = minimap_dimensions.size
    camera.style.height = minimap_dimensions.size
    camera.style.horizontally_stretchable = false
    camera.style.vertically_stretchable = false
    camera.ignored_by_interaction = true
    minimap_frame.visible = player.minimap_enabled
end

local function unset_camera(player)
    storage.fancy_preview_active[player.index] = nil
    get_camera_frame(player).visible = false
    get_minimap_frame(player).visible = false
end

local function update_factory_preview(player)
    local preview_mode = settings.get_player_settings(player)["Factorissimo2-factory-preview-mode"].value
    
    if preview_mode == "off" then
        unset_camera(player)
        return
    end

    local cursor_stack = player.cursor_stack
    if cursor_stack and
        cursor_stack.valid_for_read and
        cursor_stack.type == "item-with-tags" and
        cursor_stack.tags and
        storage.saved_factories[cursor_stack.tags.id] then
        local factory = storage.saved_factories[cursor_stack.tags.id]
        set_minimap(player, factory, true)
        return
    end

    local selected = player.selected
    if selected then
        local factory
        local inside = true
        if selected.name == "factory-power-pole" then
            factory = find_surrounding_factory(selected.surface, selected.position)
            inside = false
        elseif selected.type == "item-entity" and selected.stack.type == "item-with-tags" and has_layout(selected.stack.name) then
            factory = storage.saved_factories[selected.stack.tags.id]
        elseif selected.type == "construction-robot" or selected.type == "logistic-robot" then
            local inventory = selected.get_inventory(defines.inventory.robot_cargo)
            if inventory and #inventory >= 1 then
                local itemstack = inventory[1]
                if itemstack.valid_for_read and itemstack.type == "item-with-tags" and has_layout(itemstack.name) then
                    factory = storage.saved_factories[itemstack.tags.id]
                end
            end
        else
            factory = get_factory_by_entity(player.selected)
            if preview_mode == "fancy" and factory then
                factorissimo.update_overlay(factory)
                set_camera(player, factory)
                return
            end
        end
        if factory then
            factorissimo.update_overlay(factory)
            set_minimap(player, factory, inside)
            return
        end
    end
    unset_camera(player)
end
factorissimo.update_factory_preview = update_factory_preview

factorissimo.on_event({
    defines.events.on_player_display_resolution_changed,
    defines.events.on_player_display_scale_changed,
    defines.events.on_player_controller_changed,
    defines.events.on_player_changed_surface
}, function(event)
    local player = game.get_player(event.player_index)
    factorissimo.update_factory_preview(player)
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
    for _, factory in pairs(storage.factories) do
        if factory.built and factory.outside_surface.valid and factorissimo.get_or_create_inside_power_pole(factory) == pole then
            local teleport_position = {x = factory.outside_x, y = factory.outside_y}

            local recursive_parent = remote_api.find_surrounding_factory(factory.outside_surface, teleport_position)
            if recursive_parent then teleport_position = {recursive_parent.inside_x, recursive_parent.inside_y} end

            factorissimo.update_overlay(factory)
            camera_teleport(player, factory.outside_surface, teleport_position)
            return
        end
    end
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
    if not factory then return end

    local teleport_position = {factory.inside_x, factory.inside_y}
    camera_teleport(player, factory.inside_surface, teleport_position)
end)
