-- generate a surface prototype for the personal roboport travel surface. see travel.lua for more information
data:extend {{
    type = "planet",
    name = "factory-travel-surface",
    localised_name = "",
    hidden = true,
    icon = "__base__/graphics/icons/space-science-pack.png",
    icon_size = 64,
    gravity_pull = 0,
    distance = 0,
    orientation = 0,
    map_gen_settings = {
        height = 1,
        width = 1,
        property_expression_names = {},
        autoplace_settings = {
            ["decorative"] = {treat_missing_as_default = false, settings = {}},
            ["entity"] = {treat_missing_as_default = false, settings = {}},
            ["tile"] = {treat_missing_as_default = false, settings = {}},
        }
    },
    surface_properties = mods["space-age"] and {
        gravity = -1,
        pressure = 10000,
        ["solar-power"] = 0,
    },
}}

data:extend {{
    type = "sprite",
    name = "factory-floor-space",
    filename = "__factorissimo-2-notnotmelon__/graphics/icon/factory-floor-space.png",
    width = 64,
    height = 64,
    scale = 1,
    flags = {"gui-icon"},
}}

local function generate_factory_floor_planet_icons(planet)
    if not planet.icons and not planet.icon then
        error("Planet " .. planet.name .. " has no icon or icons")
    end

    local icons = table.deepcopy(planet.icons or {})
    if planet.icon then
        table.insert(icons, {icon = planet.icon, icon_size = planet.icon_size or 64})
    end

    -- shift all planet icons to the top left corner
    for _, icon in pairs(icons) do
        local old_shift = icon.shift or {0, 0}
        local x = old_shift.x or old_shift[1] or 0
        local y = old_shift.y or old_shift[2] or 0

        icon.icon_size = icon.icon_size or planet.icon_size or 64
        icon.scale = 64 / (icon.icon_size or 64) or 1
        icon.scale = (icon.scale or 1) * 0.75
        icon.shift = {x - 4, y - 4}
    end

    -- add a factory icon to the bottom right corner
    table.insert(icons, {
        icon = "__factorissimo-2-notnotmelon__/graphics/icon/factory-subicon.png",
        icon_size = 64,
        scale = 1
    })

    return icons
end

local function fog_color(planet)
    if planet == "nauvis" then return {0.3, 0.3, 0.3}, {0.3, 0.3, 0.3} end
    if planet == "gleba" then return {1, 1, 0.3}, {1, 0, 1} end
    if planet == "vulcanus" then return {1.0, 0.8706, 0.302}, {1.0, 0.8706, 0.2902} end
    if planet == "fulgora" then return {0, 0, 0.6}, {0.6, 0.1, 0.6} end
    if planet == "aquilo" then return {0.9, 0.9, 0.9}, {0.6, 0.6, 1} end

    return {0.3, 0.3, 0.3}, {0.3, 0.3, 0.3}
end

local function update_surface_render_parameters(planet, factory_floor)
    if not feature_flags.expansion_shaders then return end

    local color1, color2 = fog_color(planet.name)

    local fog = {
        shape_noise_texture = {
            filename = "__core__/graphics/clouds-noise.png",
            size = 2048
        },
        detail_noise_texture = {
            filename = "__core__/graphics/clouds-detail-noise.png",
            size = 2048
        },
        color1 = color1,
        color2 = color2,
        fog_type = "vulcanus",
    }

    factory_floor.surface_render_parameters = factory_floor.surface_render_parameters or {}
    local srp = factory_floor.surface_render_parameters
    srp.fog = fog
    srp.draw_sprite_clouds = false
    srp.clouds = nil

    if planet.name == "gleba" then -- No rain indoors
        factory_floor.player_effects = nil
    end
end

local function add_music(planet, factory_floor)
    for _, music in pairs(data.raw["ambient-sound"]) do
        if music.planet == planet.name or (music.track_type == "hero-track" and music.name:find(planet.name)) then
            local new_music = table.deepcopy(music)
            new_music.name = music.name .. "-" .. factory_floor.name
            new_music.planet = factory_floor.name
            if new_music.track_type == "hero-track" then
                new_music.track_type = "main-track"
                new_music.weight = 10
            end
            data:extend {new_music}
        end
    end
end

-- we need to copy all existing planets in order to create factory floors for them
local factory_floors = {}
for _, planet in pairs(data.raw.planet) do
    if planet.hidden and planet.name ~= "neo-nauvis" then goto continue end
    if planet.ignored_for_factorissimo then goto continue end

    local factory_floor = table.deepcopy(planet)
    local original_localised_name = planet.localised_name or {"space-location-name." .. planet.name}
    factory_floor.name = planet.name .. "-factory-floor"
    factory_floor.localised_name = {"space-location-description.factory-floor-in-list", original_localised_name}
    factory_floor.localised_description = {"space-location-description.factory-floor", original_localised_name, planet.name}
    factory_floor.lightning_properties = nil
    factory_floor.distance = factory_floor.distance - (1.25 * (factory_floor.magnitude or 1))
    factory_floor.draw_orbit = false
    factory_floor.solar_power_in_space = 0
    factory_floor.fly_condition = true
    factory_floor.auto_save_on_first_trip = false
    factory_floor.asteroid_spawn_definitions = nil
    factory_floor.order = "z-[factory-floor]" .. (planet.order or planet.name)
    factory_floor.map_gen_settings = nil
    factory_floor.surface_properties = factory_floor.surface_properties or {}
    factory_floor.surface_properties["solar-power"] = 0
    factory_floor.surface_properties["day-night-cycle"] = 0
    factory_floor.surface_properties["ceiling"] = 0
    factory_floor.magnitude = (factory_floor.magnitude or 1) / 2
    factory_floor.starmap_icons = nil
    factory_floor.starmap_icon = nil
    factory_floor.icon = nil
    factory_floor.icon_size = 64
    factory_floor.icons = generate_factory_floor_planet_icons(planet)
    factory_floor.starmap_icon_size = 115
    factory_floor.factoriopedia_alternative = planet.name
    factory_floor.hidden = true
    factory_floor.hidden_in_factoriopedia = true
    update_surface_render_parameters(planet, factory_floor)
    add_music(planet, factory_floor)
    table.insert(factory_floors, factory_floor)

    ::continue::
end
data:extend(factory_floors)

-- ensure that the factorissimo planets are unlocked when the original planets are unlocked
for _, technology in pairs(data.raw.technology) do
    if technology.effects and type(technology.effects) == "table" then
        local new_effects = {}
        for _, effect in pairs(technology.effects) do
            table.insert(new_effects, effect)
            local planet, factory_floor

            if type(effect) ~= "table" then goto continue end
            if effect.type ~= "unlock-space-location" then goto continue end
            if not effect.space_location then goto continue end
            local planet = data.raw.planet[effect.space_location]
            if not planet or not planet.name then goto continue end
            local factory_floor = data.raw.planet[planet.name .. "-factory-floor"]
            if not factory_floor then goto continue end

            table.insert(new_effects, {
                type = "unlock-space-location",
                space_location = factory_floor.name,
                use_icon_overlay_constant = false,
            })

            ::continue::
        end
        technology.effects = new_effects
    end
end
