local debug_mode = false
local DT = "[NavBeacon] "
local radar_data 
local rro = Muluna.rro
local blueprint_tags = require("lib.blueprint-tags")
---Compute the radar's scan size from the configured base area, not its energy cost.
---@param navSat LuaEntity
---@return number|nil
local function get_nav_scan_area(navSat)
    if not radar_data or not navSat or not navSat.valid then return nil end
    return helpers.evaluate_expression(radar_data.scan_size_expression, {
        base = radar_data.entities[navSat.name].scan_area,
        quality_level = navSat.quality.level,
    })
end

if settings.startup["enable-nav-beacon"].value == true then
    radar_data = prototypes.mod_data["muluna-satellite-radar"].data
end

require("__core__/lualib/util.lua")

local function init_storage_nav_beacons() 
    -- storage = {
    --     ---@type table<int, LuaEntity>
    --     nav_beacons = {}, -- beacon [unit_number] = LuaEntity (nav-beacon)
    --     ---@type table<int, LuaSpacePlatform>
    --     beacon_platforms = {}, -- beacon [unit_number] = LuaSpacePlatform
    --     ---@type table<int, LuaEntity>
    --     platform_beacons = {}, -- platform [index] = LuaEntity (nav-beacon)
    --     ---@type table<int, LuaSpaceLocationPrototype>
    --     nav_surfaces = {}, -- beacon [unit_number] = LuaSpaceLocationPrototype
    --     ---@type table<int, LuaEntity>
    --     beacon_electric_interfaces = {}, -- beacon [unit_number] = LuaEntity (nav-beacon-electric-interface)
    -- }
    if storage.nav_beacons == nil then
        storage.nav_beacons = {}
    end
    if storage.beaconed_platforms == nil then
        storage.beaconed_platforms = {}
    end
    if storage.platform_beacons == nil then
        storage.platform_beacons = {}
    end
    if storage.nav_surfaces == nil then
        storage.nav_surfaces = {}
    end
    if storage.beacon_electric_interfaces == nil then
        storage.beacon_electric_interfaces = {}
    end
    if storage.nav_beacon_players == nil then
        storage.nav_beacon_players = {}
    end
    -- Rebuild the remote-view player table after a load or configuration
    -- change. Controller types survive a save, and on_player_controller_changed
    -- is not raised when a save is loaded, so a player saved in remote view has
    -- to be tracked again here.
    for player_index, player in pairs(game.players) do
        if player.controller_type == defines.controllers.remote then
            storage.nav_beacon_players[player_index] = player
        else
            storage.nav_beacon_players[player_index] = nil
        end
    end
    if rro.deep_equals(storage.nav_beacons,{}) then
        storage.has_nav_beacons = false
    else
        storage.has_nav_beacons = true
    end
    --storage.has_nav_beacons = #storage.nav_beacons > 0
    --print("has_nav_beacon " .. storage.has_nav_beacons)

    
end

local status_nav_beacon_scanning_disabled = {
    diode = defines.entity_status_diode.red,
    label = {"custom-status.muluna-satellite-radar-scanning-disabled"}
}

---Get the player-facing settings for a satellite radar, creating defaults.
---
---`gui.enabled` must always be a boolean: the radar GUI passes it straight to
---the `state` field of a checkbox, which Factorio requires to be present and
---boolean. Blueprint tags can be an empty table with no `enabled` key, so a
---missing or malformed value must never be stored.
---@param unit_number uint
---@return {gui: {enabled: boolean}}
local function get_nav_beacon_settings(unit_number)
    if not storage.nav_beacons_other then
        storage.nav_beacons_other = {}
    end
    local settings = storage.nav_beacons_other[unit_number]
    if not settings then
        settings = {}
        storage.nav_beacons_other[unit_number] = settings
    end
    if not settings.gui then
        settings.gui = {}
    end
    if type(settings.gui.enabled) ~= "boolean" then
        settings.gui.enabled = true
    end
    return settings
end

Muluna.get_nav_beacon_settings = get_nav_beacon_settings

---Update the satellite radar's custom status and animation state.
---@param nav LuaEntity
local function update_nav_beacon_status(nav)
    if not (nav and nav.valid) then return end
    local beacon_settings = storage.nav_beacons_other and storage.nav_beacons_other[nav.unit_number]
    local enabled = not (beacon_settings and beacon_settings.gui and beacon_settings.gui.enabled == false)
    if enabled then
        nav.custom_status = nil
        nav.disabled_by_script = false
    else
        nav.custom_status = status_nav_beacon_scanning_disabled
        nav.disabled_by_script = true
    end
end

Muluna.update_nav_beacon_status = update_nav_beacon_status

---Record an existing satellite radar as the nav beacon of a space platform.
---@param nav LuaEntity
---@param platform LuaSpacePlatform
---@param enabled boolean|nil
local function register_platform_beacon(nav, platform, enabled)
    storage.beaconed_platforms[platform.index] = nav
    storage.nav_surfaces[nav.unit_number] = platform.space_location
    storage.nav_beacons[nav.unit_number] = nav
    storage.has_nav_beacons = true
    local settings = get_nav_beacon_settings(nav.unit_number)
    if enabled == false then
        settings.gui.enabled = false
    end
    update_nav_beacon_status(nav)
end

local function update_space_platform_beacon(platformBeacon,platform)
    if platformBeacon.valid == true then
            storage.nav_surfaces[platformBeacon.unit_number] = platform.space_location --this can be nil, which is acceptable
            update_nav_beacon_status(platformBeacon)
        else
            storage.beaconed_platforms[platform.index] = nil
        end


end

local function update_space_platform(platform)
    --only track platforms with a nav beacon
    local platformBeacon = storage.beaconed_platforms[platform.index]
    if platformBeacon ~= nil then
        update_space_platform_beacon(platformBeacon,platform)
        
    end


end

local function reset_storage_nav_beacons() 
    -- storage = {
    --     ---@type table<int, LuaEntity>
    --     nav_beacons = {}, -- beacon [unit_number] = LuaEntity (nav-beacon)
    --     ---@type table<int, LuaSpacePlatform>
    --     beacon_platforms = {}, -- beacon [unit_number] = LuaSpacePlatform
    --     ---@type table<int, LuaEntity>
    --     platform_beacons = {}, -- platform [index] = LuaEntity (nav-beacon)
    --     ---@type table<int, LuaSpaceLocationPrototype>
    --     nav_surfaces = {}, -- beacon [unit_number] = LuaSpaceLocationPrototype
    --     ---@type table<int, LuaEntity>
    --     beacon_electric_interfaces = {}, -- beacon [unit_number] = LuaEntity (nav-beacon-electric-interface)
    -- }
    
        storage.nav_beacons = {}
    
    
        storage.beaconed_platforms = {}
    
    
        storage.platform_beacons = {}
   
    
        storage.nav_surfaces = {}
    
    
        storage.beacon_electric_interfaces = {}

        storage.nav_beacons_other = {}

        storage.has_nav_beacons = false

        -- Search space platforms for satellite radars that are already placed
        -- and register those so players do not have to rebuild them.
        for _,force in pairs(game.forces) do
            
            for _,platform in pairs(force.platforms) do
                local surface = platform.surface
                if surface and surface.valid then
                    local radars = surface.find_entities_filtered({ name = "muluna-satellite-radar" })
                    local nav = radars and radars[1]
                    if nav and nav.valid then
                        register_platform_beacon(nav, platform)
                    end
                end
            end
        end
end

---Update or discard a nav beacon whose recorded space location disappeared.
---
---A stored LuaEntity can be invalid (for example after a prototype change or a
---scripted platform removal), so never read `surface` before checking `valid`.
---@param beacon_id uint
---@return boolean rebuilt true when the nav beacon tracking was rebuilt
local function handle_invalid_nav_surface(beacon_id)
    local beacon = storage.nav_beacons[beacon_id]
    if beacon and beacon.valid then
        local platform = beacon.surface and beacon.surface.platform
        if platform then
            update_space_platform_beacon(beacon, platform)
            return false
        end
    end

    game.print("[Muluna] ERROR: Satellite Radar data storage invalid, deleting storage to prevent crash. You might need to place your radars again.")
    log("ERROR: Navigation beacon storage invalidated to prevent crash.")
    log("planet-muluna storage contents:")
    log(serpent.block(storage))
    log("End planet-muluna storage")
    reset_storage_nav_beacons()
    return true
end

Muluna.events.on_event(Muluna.events.events.on_init(), function(event)

    init_storage_nav_beacons()


end)

script.on_configuration_changed(function()
    if debug_mode then
        log(DT .. "initialized storage")
        log(serpent.block(storage))
    end
    
    init_storage_nav_beacons()

    -- Satellite radars used to be accumulator prototypes. Changing the
    -- prototype type assigns new unit numbers to existing entities, so the
    -- LuaEntity references saved in storage become invalid. Rebuild the
    -- tracking data from the radars still on platforms rather than leaving
    -- stale storage for the update tick to report to players.
    local has_invalid_beacon = false
    for _, beacon in pairs(storage.nav_beacons or {}) do
        if beacon and beacon.valid then
            update_nav_beacon_status(beacon)
        else
            has_invalid_beacon = true
            break
        end
    end
    if has_invalid_beacon then
        reset_storage_nav_beacons()
    end
end)

---@param entity LuaEntity
local function built_nav_beacon(entity,tags)
    if debug_mode then
        game.print(DT .. "built nav beacon @ " .. entity.gps_tag)
    end

    local surface = entity.surface
    local platform = surface.platform
    local position = entity.position
    local force = entity.force
    local quality = entity.quality
    

    if platform == nil then
        -- entity.destroy({
        --     raise_destroy = false
        -- })
        -- surface.create_entity({
        --     name = "nav-beacon-planet",
        --     position = position,
        --     force = force,
        --     raise_built = false,
        --     fast_replace = true,
        --     quality = quality
        -- })
    else
        if storage.beaconed_platforms[platform.index] ~= nil then
            game.print({"", DT, {"nav-beacon.single-per-platform"}, " @ ",entity.gps_tag})
            entity.mine({
                inventory = platform.hub.get_inventory(defines.inventory.hub_main),
                force = true,
                raise_destroyed = false,
                ignore_minable = true
            })
            return
        end
        entity.destroy({
            raise_destroy = false
        })
        local nav = surface.create_entity({
            name = "muluna-satellite-radar",
            position = position,
            force = force,
            raise_built = false,
            fast_replace = true,
            quality = quality
        })
        storage.beaconed_platforms[platform.index] = nav
        storage.nav_surfaces[nav.unit_number] = platform.space_location
        storage.nav_beacons[nav.unit_number] = nav
        storage.has_nav_beacons = true

        -- Blueprint tags can be an empty table when the source radar had no
        -- settings, so only an explicit boolean may override the default.
        local settings = get_nav_beacon_settings(nav.unit_number)
        if tags and type(tags.enabled) == "boolean" then
            settings.gui.enabled = tags.enabled
        end
        update_nav_beacon_status(nav)
    end
    --if #storage.nav_beacons > 0 then
        
    --end
end

---@param entity LuaEntity
local function destroyed_nav_beacon(entity)
    if debug_mode then
        game.print(DT .. "destroyed nav beacon @ " .. entity.gps_tag)
    end

    local platform = entity.surface.platform
    if platform == nil then return end --if not destroyed on a space platform, then we don't care about it

    storage.beaconed_platforms[platform.index] = nil
    storage.nav_surfaces[entity.unit_number] = nil
    storage.nav_beacons[entity.unit_number] = nil
    storage.nav_beacons_other[entity.unit_number] = nil
    if next(storage.nav_beacons) == nil then
        storage.has_nav_beacons = false
    end
end




---@param e on_space_platform_changed_state
Muluna.events.on_event(defines.events.on_space_platform_changed_state, function(e)
    update_space_platform(e.platform)
end)

local filter_built = {
    {filter = "name", name = "muluna-satellite-radar"},
    --{filter = "name", name = "nav-beacon-platform"},
    --{filter = "name", name = "nav-beacon-planet"},
}

Muluna.events.on_event("bplib-extract", function(event)
    for blueprint_index, entity in pairs(event.entities) do
    -- The event is raised for all mods, so you must filter for your mod's entities
    if entity.name == "muluna-satellite-radar" then
        local settings = storage.nav_beacons_other and storage.nav_beacons_other[entity.unit_number]
        local enabled = not (settings and settings.gui and settings.gui.enabled == false)
      blueprint_tags.add_tags(event.blueprint, blueprint_index, {enabled = enabled})
    end
  end
end)




------------------------------------------------------------------------------------------------------------------------
----- HANDLE TRAVERSING THE MAP -----
-----
------------------------------------------------------------------------------------------------------------------------

---Energy cost of one scan, cached per radar name and quality level.
---
---The cost only depends on those two values, but it used to be recomputed with
---`helpers.evaluate_expression` and `util.parse_energy` for every player scan.
local nav_energy_cost_cache = {}
local nav_energy_cost_stats = { computations = 0 }

---@param navSat LuaEntity
---@return number energy
local function get_nav_energy_cost(navSat)
    local by_quality = nav_energy_cost_cache[navSat.name]
    if not by_quality then
        by_quality = {}
        nav_energy_cost_cache[navSat.name] = by_quality
    end
    local quality_level = navSat.quality.level
    local energy_cost = by_quality[quality_level]
    if energy_cost == nil then
        energy_cost = util.parse_energy(tostring(helpers.evaluate_expression(
            radar_data.energy_per_scan_expression,
            { base = radar_data.entities[navSat.name].energy_per_scan, quality_level = quality_level }
        )) .. "MJ")
        by_quality[quality_level] = energy_cost
        nav_energy_cost_stats.computations = nav_energy_cost_stats.computations + 1
    end
    return energy_cost
end

---Charge one scan and reveal the chart area, if the radar can afford it.
---@param player LuaPlayer
---@param navSat LuaEntity
local function scan_with_nav_beacon(player, navSat)
    if get_nav_beacon_settings(navSat.unit_number).gui.enabled ~= true then return end
    local energy_cost = get_nav_energy_cost(navSat)
    if navSat.energy < energy_cost then return end
    local position = player.position
    local offset = get_nav_scan_area(navSat)
    navSat.energy = navSat.energy - energy_cost
    player.force.chart(player.surface, {
        left_top = { position.x - offset / 2, position.y - offset / 2 },
        right_bottom = { position.x + offset / 2, position.y + offset / 2 },
    })
end

---Update one player's nav-beacon alert and scan.
---
---Extracted from the update tick so the FUnit suite can drive it with a stub
---player: the headless scenario cannot create a LuaPlayer in remote view.
---
---The alert is decided once per player, after the beacon scan. It used to be
---removed for every non-matching nav surface inside the loop, which is up to
---players x radars `remove_alert` calls per update even though one call clears
---every alert with that icon.
---@param player LuaPlayer|table player-shaped table with surface, force, position, mod_settings
local function update_player_nav_beacon(player)
    if storage.has_nav_beacons ~= true then return end
    local surface_name = player.surface.name
    local force = player.force
    local display_beacon_alert = false
    local display_setting = player.mod_settings and player.mod_settings["nav-beacon-display-alert"]
    if display_setting then display_beacon_alert = display_setting.value end

    local navSat
    local storage_reset = false
    for beacon_id, nav_surface in pairs(storage.nav_surfaces) do
        if not nav_surface.valid then --If a surface is removed via mod uninstallation, update the space platform.
            if handle_invalid_nav_surface(beacon_id) then
                storage_reset = true
                break
            end
            goto continue
        end
        if nav_surface.name == surface_name then
            local beacon = storage.nav_beacons[beacon_id]
            if not beacon or beacon.valid == false then
                game.print("[Muluna] ERROR: Satellite Radar data storage invalid, deleting storage to prevent crash. You might need to place your radars again.")
                log("ERROR: Navigation beacon storage invalidated to prevent crash.")
                log("planet-muluna storage contents:")
                log(serpent.block(storage))
                log("End planet-muluna storage")
                reset_storage_nav_beacons()
                storage_reset = true
                break
            end
            if not storage.nav_beacons_other then
                storage.nav_beacons_other = {}
            end
            if beacon.force == force then
                navSat = beacon
                break
            end
        end
        ::continue::
    end

    if navSat then
        local beacon_settings = get_nav_beacon_settings(navSat.unit_number)
        if display_beacon_alert then
            player.add_custom_alert(navSat,
                {type = "item", name = "muluna-satellite-radar"},
                {beacon_settings.gui.enabled and "alert.nav-beacon-available" or "alert.nav-beacon-available-disabled",{"space-location-name."..surface_name}},
                false
            )
        end
        scan_with_nav_beacon(player, navSat)
    elseif not storage_reset then
        -- One call clears every alert with this icon, whatever the number of
        -- tracked radars.
        player.remove_alert{icon = {type = "item", name = "muluna-satellite-radar"}}
    end
end

---Keep storage.nav_beacon_players in sync with a player's current controller.
---@param player_index uint
---@param player LuaPlayer|table
local function sync_nav_beacon_player(player_index, player)
    if player.controller_type == defines.controllers.remote then
        storage.nav_beacon_players[player_index] = player
    else
        storage.nav_beacon_players[player_index] = nil
    end
end

---Apply a controller change and clean up the alert when the player leaves the
---remote view.
---
---Split from the event handler so the FUnit suite can drive it with a stub
---player; the headless scenario has no LuaPlayer.
---@param player_index uint
---@param player LuaPlayer|table
---@param old_type defines.controllers
local function apply_controller_change(player_index, player, old_type)
    sync_nav_beacon_player(player_index, player)
    if old_type == defines.controllers.remote and player.controller_type ~= defines.controllers.remote then
        -- One call clears the beacon alert whatever its message. The previous
        -- per-update cleanup filtered on the player's current surface name,
        -- which missed the alert when the player stood on another surface.
        player.remove_alert{icon = {type = "item", name = "muluna-satellite-radar"}}
    end
end

if settings.startup["enable-nav-beacon"].value == true then
    -- The update tick only visits players currently in remote view, which keeps
    -- the handler body a single loop over a storage table.
    Muluna.events.on_nth_tick(settings.startup["nav-beacon-update-ticks"].value, function()
        for _,player in pairs(storage.nav_beacon_players) do
            update_player_nav_beacon(player)
        end
    end)

    Muluna.events.on_event(defines.events.on_player_controller_changed, function(event)
        local player = game.players[event.player_index]
        if player then
            apply_controller_change(event.player_index, player, event.old_type)
        end
    end)

    -- A player joining a multiplayer game keeps the controller type from the
    -- save, so sync without raising a controller change.
    Muluna.events.on_event(defines.events.on_player_joined_game, function(event)
        local player = game.players[event.player_index]
        if player then
            sync_nav_beacon_player(event.player_index, player)
        end
    end)

    -- Migrations run before on_configuration_changed initializes the storage
    -- tables, so these events can fire while storage.nav_beacon_players is
    -- still nil. There is nothing to clear in that case.
    Muluna.events.on_event(defines.events.on_player_left_game, function(event)
        if storage.nav_beacon_players then
            storage.nav_beacon_players[event.player_index] = nil
        end
    end)

    Muluna.events.on_event(defines.events.on_player_removed, function(event)
        if storage.nav_beacon_players then
            storage.nav_beacon_players[event.player_index] = nil
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------
----- BUILT RADAR -----
----- need to register all build events because of the custom energy interface
------------------------------------------------------------------------------------------------------------------------
---@param event on_space_platform_built_entity
Muluna.events.on_event(defines.events.on_space_platform_built_entity, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name ~= "muluna-satellite-radar" then return end
    built_nav_beacon(entity,event.tags)
end, filter_built)

---@param event script_raised_built
Muluna.events.on_event(defines.events.script_raised_built, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name ~= "muluna-satellite-radar" then return end
    built_nav_beacon(entity,event.tags)
end, filter_built)

-- ---@param event on_built_entity
-- Muluna.events.on_event(defines.events.on_built_entity, function(event)
--     local entity = event.entity or event.created_entity
--     if not entity or not entity.valid then return end

--     built_nav_beacon(entity)
-- end, filter_built)

---@param event on_robot_built_entity
Muluna.events.on_event(defines.events.on_robot_built_entity, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name ~= "muluna-satellite-radar" then return end
    built_nav_beacon(entity,event.tags)
end, filter_built)

------------------------------------------------------------------------------------------------------------------------
----- DESTROYED RADAR -----
----- only register destroy events from the space platform since that's the only place we care about having these
----- script raised is included, as well as on_entity_died in case one is e.g. killed by meteor
------------------------------------------------------------------------------------------------------------------------

---@param event on_space_platform_mined_entity
Muluna.events.on_event(defines.events.on_space_platform_mined_entity, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name ~= "muluna-satellite-radar" then return end
    destroyed_nav_beacon(entity)
end, filter_built)

---@param event on_entity_died
Muluna.events.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name ~= "muluna-satellite-radar" then return end
    destroyed_nav_beacon(entity)
end, filter_built)

---@param event script_raised_destroy
Muluna.events.on_event(defines.events.script_raised_destroy, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name ~= "muluna-satellite-radar" then return end
    destroyed_nav_beacon(entity)
end, filter_built)

---@param event on_player_mined_entity
Muluna.events.on_event(defines.events.on_player_mined_entity, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name ~= "muluna-satellite-radar" then return end
    destroyed_nav_beacon(entity)
end, filter_built)

---@param event on_robot_mined_entity
Muluna.events.on_event(defines.events.on_robot_mined_entity, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name ~= "muluna-satellite-radar" then return end
    destroyed_nav_beacon(entity)
end, filter_built)


Muluna.events.on_event(defines.events.on_entity_settings_pasted,function(event)
    local source = event.source
    local destination = event.destination

    local source_beacon_settings = storage.nav_beacons_other and storage.nav_beacons_other[source.unit_number]
    if source_beacon_settings and source_beacon_settings.gui and destination.unit_number then
        local destination_beacon_settings = get_nav_beacon_settings(destination.unit_number)
        destination_beacon_settings.gui.enabled = source_beacon_settings.gui.enabled ~= false
        update_nav_beacon_status(destination)
    end


end)

if script.active_mods["funit"] then
    Muluna.funit.get_nav_scan_area = get_nav_scan_area
    Muluna.funit.build_nav_beacon = built_nav_beacon
    Muluna.funit.handle_invalid_nav_surface = handle_invalid_nav_surface
    Muluna.funit.update_player_nav_beacon = update_player_nav_beacon
    Muluna.funit.apply_controller_change = apply_controller_change
    Muluna.funit.get_nav_energy_cost = get_nav_energy_cost
    Muluna.funit.get_nav_energy_cost_stats = function()
        return { computations = nav_energy_cost_stats.computations }
    end
    Muluna.funit.reset_nav_energy_cost_cache = function()
        nav_energy_cost_cache = {}
        nav_energy_cost_stats.computations = 0
    end
end
