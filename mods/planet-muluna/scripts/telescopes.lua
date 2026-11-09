local rro = Muluna.rro
local blueprint_tags = require("lib.blueprint-tags")

local heat_assembling_machines = Muluna.constants.telescopes


local stars_covered_during_day = {} 

for name,planet in pairs(prototypes.space_location) do
    stars_covered_during_day[name] = (planet.surface_properties and planet.surface_properties.pressure or prototypes.surface_property.pressure.default_value) > 300
end

local status_telescope_stars_not_visible_sun = {
    diode = defines.entity_status_diode.red,
    label = {"custom-status.muluna-telescopes-stars-covered-by-sun"}
}

local status_telescope_stars_not_visible_clouds = {
    diode = defines.entity_status_diode.red,
    label = {"custom-status.muluna-telescopes-stars-covered-by-clouds"}
}

local status_telescope_stars_not_visible_pollution = {
    diode = defines.entity_status_diode.red,
    label = {"custom-status.muluna-telescopes-stars-covered-by-pollution"}
}

local function obscured_sprite(entity) 
    return{
        sprite = "muluna-telescope-obscured-warning",
        target = {
            entity = entity,
            offset = entity.prototype.alert_icon_shift
        },
        surface = entity.surface_index,
        x_scale = 1.04,
        y_scale = 1.04,
        blink_interval = 30,
    }
end



local function disable_telescope(telescope,telescope_data,disp_warning)
    telescope.disabled_by_script = true
    if disp_warning then
        if not telescope_data.warning_icon then
            telescope_data.warning_icon = rendering.draw_sprite(obscured_sprite(telescope))
        end
    end
        
end

local function is_day(daytime,surface)
    return (daytime < surface.dusk or daytime > surface.dawn)

end

--Updates the telescope based on whether stars are currently visible on this planet.
function Muluna.update_telescope_daytime(telescope_data)
    local telescope = telescope_data and telescope_data["assembling-machine"]
    if not (telescope and telescope.valid) then return end
    local surface = telescope.surface
    local planet_prototype = surface.planet and surface.planet.prototype
    local daytime = surface.daytime
    local pollution = surface.get_pollution(telescope.position)
    local probability = Muluna.get_telescope_probability(pollution,telescope.quality)
    if not planet_prototype then goto continue end
    
    if probability > math.random() then
        telescope.custom_status = status_telescope_stars_not_visible_pollution
        disable_telescope(telescope,telescope_data,true)
        goto continue
    end
    if Muluna.constants.planet_has_lightning[planet_prototype.name] and Muluna.constants.planet_has_lightning[planet_prototype.name] == true then
        if stars_covered_during_day[surface.name] and not is_day(daytime,surface) then
            telescope.custom_status = status_telescope_stars_not_visible_clouds
            disable_telescope(telescope,telescope_data)
            goto continue
        end
    else
        if stars_covered_during_day[surface.name] and is_day(daytime,surface) then
            telescope.custom_status = status_telescope_stars_not_visible_sun
            disable_telescope(telescope,telescope_data)
            goto continue
        end
    end
    
    telescope.custom_status = nil
    telescope.disabled_by_script = false
    if telescope_data.warning_icon then
        telescope_data.warning_icon.destroy()
        telescope_data.warning_icon = nil
    end
    
    ::continue::
end

local function update_all_telescopes(surface)
    if not surface.valid then return end
    if not storage.telescopes_on_surface[surface.name] then return end
    for telescope_id,_ in pairs(storage.telescopes_on_surface[surface.name]) do
        local telescope = storage.telescopes[telescope_id]
        if telescope then
            Muluna.update_telescope_daytime(telescope)
        end
    end

end

Muluna.events.register_delayed_function("update_all_telescopes",update_all_telescopes)

local tolerance = 1
Muluna.events.on_event(defines.events.on_next_day_started,function(event)
    local surface = event.surface
    update_all_telescopes(surface)
    local day_length = surface.ticks_per_day
    local dusk_tick = surface.dusk*day_length
    local dawn_tick = surface.dawn*day_length
    Muluna.events.execute_later("update_all_telescopes",dusk_tick+tolerance,surface)
    Muluna.events.execute_later("update_all_telescopes",dawn_tick+tolerance,surface)

end)


local function move_entity_to_bottom_layer(entity)
    local direction = entity.direction
    local mirroring = entity.mirroring
    entity.rotate{reverse=false}
    entity.rotate{reverse=true}
    if entity.direction ~= direction then entity.direction = direction end
    if entity.mirroring ~= mirroring then entity.mirroring = mirroring end
end

local function get_telescope_build_limit(entity)
    if entity.surface.platform then
        return nil
    else
        return 1
    end

end

local function same_surface_properties(surface1,planet)
    if not planet.surface_properties then return false end
    for _,property in pairs({"pressure","gravity","temperature","magnetic-field"}) do
        
        if (surface1.get_property(property) or prototypes.surface_property[property].default_value) ~= (planet.surface_properties[property] or prototypes.surface_property[property].default_value) then
            --game.print(property .. " " .. planet.name or "nil" .. " " .. tostring(planet.surface_properties[property]) .. tostring(surface1.get_property(property)))
            --game.print(tostring(planet.surface_properties[property]))
            --game.print(tostring(surface1.get_property(property)))
            return false
        end
    end
    return true
end
local telescope_filters = {}
for entity_name,machine in pairs(heat_assembling_machines) do
    table.insert(telescope_filters,{filter = "name", name = entity_name})
    table.insert(telescope_filters,{filter = "ghost_name", name = entity_name})
    table.insert(telescope_filters,{filter = "name", name = machine["constant-combinator"]})
    table.insert(telescope_filters,{filter = "ghost_name", name = machine["constant-combinator"]})
end
Muluna.events.on_event(Muluna.events.events.on_built(), function(event)
    if not storage.telescopes then storage.telescopes = {} end
    local entity = event.entity
    
    local is_heat_assembling_machine = false
    local heat_assembling_machine_data = {}
    if entity.valid and heat_assembling_machines[entity.name] then
        is_heat_assembling_machine = true
        heat_assembling_machine_data = heat_assembling_machines[entity.name]
    end
    -- for _,machine in pairs(heat_assembling_machines) do
    --     if entity.name == machine["assembling-machine"] then
    --         is_heat_assembling_machine = true
    --         heat_assembling_machine_data = machine
    --         break
    --     end
    -- end
    local reactor = nil
    if is_heat_assembling_machine then
        local blueprint_direction, blueprint_mirroring
        if Muluna.compound_entities then
            blueprint_direction, blueprint_mirroring = Muluna.compound_entities.restore_blueprint_direction(entity, event.tags)
        end
        local telescope_build_limit = get_telescope_build_limit(entity)
        local builder
        if event.player_index then
            builder = game.players[event.player_index]
        elseif event.robot then
            builder = event.robot
        elseif event.platform then
            builder = event.platform
        else
            builder = {force = entity.force}
            --error("Ghost telescope placed by entity that is neither a player nor robot.")
        end
        
        local builder_force_index = builder.force.index
        local count = rro.count(
                storage.telescopes,function(entry) 
                return entry["assembling-machine"].valid and 
                entry["assembling-machine"].surface == entity.surface and 
                entry["assembling-machine"].force.index == builder_force_index end)
        if telescope_build_limit and count >= telescope_build_limit then --Forbid building if count exceeded.
            local position = entity.position
            local surface = entity.surface
            local refund_force = entity.force
            local gps_tag = entity.gps_tag
            
            local player
            if event.player_index then
                player = game.players[event.player_index]
            else
                player = event.robot
            end
            local stack = {name=entity.prototype.mineable_properties.products[1].name, count=1,quality=entity.quality.name}

            --if event.consumed_items then
                --for i = 1,#event.consumed_items do --Return telescope to player inventory
                    --local item = event.consumed_items[i]
                    local inventory_define
                    local entity_destroyed = false
                    if event.name == defines.events.on_built_entity then
                        inventory_define = defines.inventory.character_main
                        player.get_inventory(inventory_define).insert(stack)
                    else
                        -- The refused entity still occupies its own position, so
                        -- it must be removed before the refund item can be placed
                        -- there. Creating the item first returns nil and silently
                        -- loses the refund for robot and script builds.
                        entity.destroy{}
                        entity_destroyed = true
                        local item = surface.create_entity{
                            name = "item-on-ground",
                            position = position,
                            stack = stack
                        }
                        if item then
                            item.order_deconstruction(refund_force)
                        end
                        
                            
                    end
                    
                    
                --end
            
            --end
            
            local text
            if telescope_build_limit == 1 then
                text = {"console.can-not-place-more-telescopes-1",tostring(telescope_build_limit)}
            else
                text = {"console.can-not-place-more-telescopes-X",tostring(telescope_build_limit)}
            end
            if event.name == defines.events.on_built_entity then
                player.create_local_flying_text{
                    text = text,
                    --position = position,
                    surface = surface,
                    create_at_cursor = true,
                    speed = 0.01,
                }
            else
                refund_force.print({"",text," ",gps_tag})
            end
            if not entity_destroyed then entity.destroy{} end
            return 
        end

        local recipe_name
        local lock = true
        local saved_direction = blueprint_direction or entity.direction
        local saved_mirroring = blueprint_mirroring
        if saved_mirroring == nil then saved_mirroring = entity.mirroring end
        if entity.surface.platform then
            --recipe_name = "muluna-telescope-observation-space-platform"
            lock = false
        elseif string.find(entity.surface.name,"bpsb") then --If surface is a blueprint sandbox
            for _,planet in pairs(prototypes.space_location) do
                if planet.type == "planet" and same_surface_properties(entity.surface,planet) then
                    recipe_name = "muluna-telescope-observation-" .. planet.name
                end
            end

        elseif prototypes.recipe["muluna-telescope-observation-" .. entity.surface.name] then
            recipe_name = "muluna-telescope-observation-" .. entity.surface.name
        end
        if recipe_name and prototypes.recipe[recipe_name] then
            entity.set_recipe(recipe_name,"normal")
        end
        if entity.direction ~= saved_direction then entity.direction = saved_direction end
        if entity.mirroring ~= saved_mirroring then entity.mirroring = saved_mirroring end
        
        entity.recipe_locked = lock
        reactor = entity.surface.create_entity{
            name = heat_assembling_machine_data["constant-combinator"],
            position = entity.position,
            direction = entity.direction,
            mirror = entity.mirroring,
            quality = entity.quality,
            force = entity.force,
            source = entity,
            target= entity,
            cause = entity,
            --snap_to_grid = true,
        }
        local control_behavior = reactor.get_control_behavior()
        control_behavior.enabled = false
        move_entity_to_bottom_layer(entity) --Ensures that assembler entity, which has a smaller selection box, is always on top of the reactor entity, which unlike the assembler, can't be rotated.
        reactor.add_fluid_box_linked_connection(1,entity,1) 
        --rendering.draw_sprite{sprite = "item.heat-pipe", target = {entity=reactor,offset = {0,-1}},surface = reactor.surface,only_in_alt_mode = true}
        local telescope_data = {["assembling-machine"]=entity,["constant-combinator"] = reactor,["constant-combinator-control-behavior"] = control_behavior,output_asteroid_signals = false, combinator_unit_number = reactor.unit_number}
        if event.tags then
            if event.tags.output_asteroid_signals then
                telescope_data.output_asteroid_signals = event.tags.output_asteroid_signals
            end
            if event.tags.combinator_enabled then
                control_behavior.enabled = event.tags.combinator_enabled
            end
        end
        storage.telescopes[entity.unit_number] = telescope_data
        -- Reverse index: a destroyed combinator finds its telescope in O(1)
        -- instead of scanning every registered telescope.
        if not storage.telescope_children then storage.telescope_children = {} end
        storage.telescope_children[reactor.unit_number] = entity.unit_number
        if not storage.telescopes_on_surface[entity.surface.name] then storage.telescopes_on_surface[entity.surface.name] = {} end
        storage.telescopes_on_surface[entity.surface.name][entity.unit_number] = true
        Muluna.update_telescope_daytime(telescope_data)
    end


end,
telescope_filters
)

Muluna.events.on_event("bplib-extract", function(event)
    for blueprint_index, entity in pairs(event.entities) do
    -- The event is raised for all mods, so you must filter for your mod's entities
    if rro.contains(heat_assembling_machines, function(entry) return entry["assembling-machine"] == entity.name end) then
        local telescope_data = storage.telescopes[entity.unit_number]
      blueprint_tags.add_tags(event.blueprint, blueprint_index, {
        output_asteroid_signals = telescope_data.output_asteroid_signals,
        combinator_enabled = telescope_data["constant-combinator-control-behavior"].enabled
    })
    end
  end
end)

local function get_telescope(entity)
    if storage.telescopes[entity.unit_number] then
        return storage.telescopes[entity.unit_number]
    else 
        local telescope = rro.find_contains(storage.telescopes,function(other)
            local combinator = other["constant-combinator"]
            return combinator and combinator.valid and entity.unit_number == combinator.unit_number
        end )
        return telescope
    end
end

Muluna.events.on_event(defines.events.on_entity_settings_pasted,function(event)
    local source = event.source
    local destination = event.destination

    local source_telescope = get_telescope(source)
    local destination_telescope = get_telescope(destination)
    if source_telescope and destination_telescope then
        destination_telescope.output_asteroid_signals = source_telescope.output_asteroid_signals
    end


end)


---Find the storage key of the telescope that owns `combinator`.
---
---The reverse index is populated when a telescope is built. Entries registered
---before the index existed (an older save) fall back to the original scan.
---@param combinator LuaEntity
---@return uint|nil
local function find_telescope_unit_number(combinator)
    local children = storage.telescope_children
    local unit_number = children and children[combinator.unit_number]
    local entry = unit_number and storage.telescopes and storage.telescopes[unit_number]
    -- Verify the entry really owns this combinator: a unit number can be
    -- reassigned when a prototype changes type, which would leave a stale
    -- index entry.
    if entry and entry["constant-combinator"] == combinator then
        return unit_number
    end
    for candidate_unit_number, entry in pairs(storage.telescopes or {}) do
        if entry["constant-combinator"] == combinator then
            return candidate_unit_number
        end
    end
end

Muluna.events.on_event(Muluna.events.events.on_destroyed(), function(event)

    local entity = event.entity
    --if not entity.valid then return end
    --game.print(entity.name)
    local is_heat_assembling_machine = false
    local heat_assembling_machine_data = {}
    if entity.valid then
        for _,machine in pairs(heat_assembling_machines) do
            --game.print(serpent.block(machine))
            if entity.name == machine["assembling-machine"] or entity.name == machine["constant-combinator"] then
                
                is_heat_assembling_machine = true
                heat_assembling_machine_data = machine
                if entity.name == machine["constant-combinator"] then
                            --game.print("combinator!")
                            local destroyed_key = find_telescope_unit_number(entity)
                            local telescope = destroyed_key and storage.telescopes[destroyed_key]
                            if not telescope then return end
                            local assembler = telescope["assembling-machine"]
                            entity = assembler
                            if not entity.valid then
                                -- The assembling machine disappeared before its
                                -- combinator. Drop the pair without reading
                                -- unit_number/surface from the invalid entity.
                                if destroyed_key then
                                    storage.telescopes[destroyed_key] = nil
                                    for _, entries in pairs(storage.telescopes_on_surface) do
                                        entries[destroyed_key] = nil
                                    end
                                end
                                return
                            end
                end
                break
            end
        end
    end

    if is_heat_assembling_machine then
        local reactor = nil
        if storage.telescopes then
            local entry = storage.telescopes[entity.unit_number]
            if entry then
                reactor = entry["constant-combinator"]
                storage.telescopes[entity.unit_number] = nil
                if storage.telescopes_on_surface[entity.surface.name] then
                    storage.telescopes_on_surface[entity.surface.name][entity.unit_number] = nil
                end
            else
                -- Entries are keyed by the assembling machine's unit number, so
                -- this only runs for an entry registered under another key.
                for i,registered_machine in pairs(storage.telescopes) do
                    if registered_machine["assembling-machine"] == entity then
                        reactor = registered_machine["constant-combinator"]
                        storage.telescopes[i] = nil
                        if storage.telescopes_on_surface[entity.surface.name] then
                            storage.telescopes_on_surface[entity.surface.name][i] = nil
                        end
                        break
                    end
                end
            end
            local children = storage.telescope_children
            if children then
                if entry and entry.combinator_unit_number then
                    children[entry.combinator_unit_number] = nil
                end
                if reactor and reactor.valid then
                    children[reactor.unit_number] = nil
                end
            end
        end
        --{entity.position[1]+0.5,entity.position[2]+0.5}
        --game.print(reactor)
        if reactor and reactor.valid then
            reactor.destroy()
        end
        if entity.valid then
            entity.destroy()
        end
        -- entity.surface.create_entity{
        --     name = heat_assembling_machine_data["reactor"],
        --     position = entity.position,
        --     direction = entity.direction,
        --     quality = entity.quality,
        --     force = entity.force,
        --     source = entity,
        --     target= entity,
        --     cause = entity,
        --     snap_to_grid = true,
        -- }
    end

end,
telescope_filters)

Muluna.events.on_event({defines.events.on_player_rotated_entity}, function(event)

    for _,telescope in pairs(storage.telescopes) do
        if event.entity == telescope["constant-combinator"] then
            move_entity_to_bottom_layer(telescope["assembling-machine"])
        end


    end
end)

local state_integer_table = {
    [defines.space_platform_state.waiting_for_starter_pack] = 1,
    [defines.space_platform_state.starter_pack_requested] = 2,
    [defines.space_platform_state.starter_pack_on_the_way] = 3,
    [defines.space_platform_state.on_the_path] = 4,
    [defines.space_platform_state.waiting_for_departure] = 5,
    [defines.space_platform_state.no_schedule] = 6,
    [defines.space_platform_state.no_path] = 7,
    [defines.space_platform_state.waiting_at_station] = 8,
    [defines.space_platform_state.paused] = 9,
}

local function get_state_integer(state)
    return state_integer_table[state]
    -- if state == defines.space_platform_state.waiting_for_starter_pack then
    --     return 1
    -- elseif state == defines.space_platform_state.starter_pack_requested then
    --     return 2
    -- elseif state == defines.space_platform_state.starter_pack_on_the_way then
    --     return 3
    -- elseif state == defines.space_platform_state.on_the_path then
    --     return 4
    -- elseif state == defines.space_platform_state.waiting_for_departure then
    --     return 5
    -- elseif state == defines.space_platform_state.no_schedule then
    --     return 6
    -- elseif state == defines.space_platform_state.no_path then
    --     return 7
    -- elseif state == defines.space_platform_state.waiting_at_station then
    --     return 8
    -- elseif state == defines.space_platform_state.paused then
    --     return 9
    -- else
    --     return nil -- or some default value if needed
    -- end
end

local bool_to_int_table = {
    [true] = 2,
    [false] = 1,
}

local function bool_to_int(state)
    return bool_to_int_table[state]

    -- if state == true then
    --     return 2
    -- else
    --     return 1
    -- end


end

local function get_time_to_next_asteroid_check(telescope)
    local platform = telescope["constant-combinator"].surface.platform
    if platform.space_location then
        return 300
    end
    if telescope.old_total_asteroid_count > 300 then
            return math.floor(telescope.old_total_asteroid_count / 5)
    end
    return 60
end


local asteroid_entity_list = {}

for _,asteroid in pairs(prototypes.get_entity_filtered{{filter="type",type="asteroid"}}) do
    table.insert(asteroid_entity_list,asteroid.name)
end

local platform_list_signals = {}

for _,signal in pairs(prototypes.virtual_signal) do
    table.insert(platform_list_signals,signal.name)
end
local experimental = helpers.compare_versions(helpers.game_version,"2.0.69") >= 0
local use_quality = script.active_mods["quality"]
local debug = false
---Build the signal list for a telescope combinator.
---
---`space_platforms` is optional: the update tick passes the list it already
---fetched (and memoized per planet+force) so a write does not call
---`get_space_platforms` a second time. The FUnit seam calls this with three
---arguments and lets it fetch the list itself.
---@param surface LuaSurface
---@param force LuaForce
---@param telescope table
---@param space_platforms LuaSpacePlatform[]|nil
---@return LogisticFilter[]
local function get_telescope_combinator_signals(surface,force,telescope,space_platforms)
    if debug then log("get_telescope_combinator_signals(" .. surface.name .. "," .. force.name .. ")") end
    local signals = {}
    local i = 1
    if surface.planet then
        local planet = surface.planet
        --return {} --Table of logistic filters/signals
        -- Produce list of space platforms (Normal quality channel provides platform id) (Uses list of virtual signals with strength equal to id)
        -- Uncommon quality: State of space platform (https://lua-api.factorio.com/latest/defines.html#defines.space_platform_state)
        -- Rare quality: Can leave_current_location (1 or 2) (https://lua-api.factorio.com/latest/classes/LuaSpacePlatform.html#can_leave_current_location)
        space_platforms = space_platforms or planet.get_space_platforms(force)
        -- if experimental then
        --     if debug then log("planet.get_space_platforms(" .. force.name .. ")") end
            
        -- else
        --     for j,platform in pairs(force.platforms) do
        --         if platform.space_location and platform.space_location.name == planet.name then
        --             space_platforms[j] = platform
        --         end
        --     end
        -- end
        
        for j,space_platform in ipairs(space_platforms) do
            local signal = platform_list_signals[j+3]
            if signal then
                signals[i]={value = {type = "virtual",name = signal,quality = "normal"},min= space_platform.index}
                i = i+1
                --if debug then log("space_platform.state") end
                if use_quality then
                    signals[i]={value = {type = "virtual",name = signal,quality = "uncommon"},min= get_state_integer(space_platform.state)}
                    i = i+1
                    signals[i]={value = {type = "virtual",name = signal,quality = "rare"},min= bool_to_int(space_platform.can_leave_current_location())}
                    i = i+1
                end

            end
        end
        -- Other signals indicating planet and total number of platforms
        local number_of_platforms = #space_platforms
        signals[i]={value = {type = "space-location",name = planet.name,quality = "normal"},min= number_of_platforms, }
        i = i+1
    elseif surface.platform then
        local platform = surface.platform
        if platform.space_connection then
            local total_length = platform.space_connection.length
            -- LuaSpacePlatform.distance is optional: it is nil when the
            -- platform is not travelling. Do not crash the combinator tick.
            local distance = platform.distance and math.floor(platform.distance * total_length) or 0
            signals[i]={value = {type = "virtual",name = "signal-X",quality = "normal"},min= distance, }
            i = i+1
            signals[i]={value = {type = "virtual",name = "signal-L",quality = "normal"},min= total_length, }
            i = i+1
            
        end
        signals[i]={value = {type = "virtual",name = "signal-I",quality = "normal"},min = platform.index} --Platform index, matched by terrestrial telescopes.
        i = i+1
        -- Also display number of asteroids on screen by type
        
        if telescope.output_asteroid_signals == nil then telescope.output_asteroid_signals = true end
        if telescope.output_asteroid_signals == true then
            local asteroid_counts = {}
            if (telescope.old_asteroid_counts_next_tick or 0) <= game.tick then
            local asteroids = surface.find_entities_filtered{type = {"asteroid"}}
            local total_asteroid_count = 0
            for _,asteroid in pairs(asteroids) do --Make list of every name and quality of 
                if asteroid_counts[asteroid.name] == nil then asteroid_counts[asteroid.name] = {} end
                if asteroid_counts[asteroid.name][asteroid.quality.name] == nil then
                    asteroid_counts[asteroid.name][asteroid.quality.name] = 1
                else
                    asteroid_counts[asteroid.name][asteroid.quality.name] = asteroid_counts[asteroid.name][asteroid.quality.name] + 1
                end
                total_asteroid_count = total_asteroid_count + 1
            end
            telescope.old_asteroid_counts = asteroid_counts
            telescope.old_total_asteroid_count = total_asteroid_count
            --game.print(total_asteroid_count)
            telescope.old_asteroid_counts_next_tick = game.tick + get_time_to_next_asteroid_check(telescope)
            -- Bump a revision instead of hashing the counts (names are strings,
            -- and the table is only rebuilt on the refresh cadence above). The
            -- update tick mixes this number into the signal signature.
            telescope.asteroid_revision = (telescope.asteroid_revision or 0) + 1
            else
                asteroid_counts = telescope.old_asteroid_counts
            end
            for asteroid,asteroid_info in pairs(asteroid_counts) do
                for quality,amount in pairs(asteroid_info) do
                    signals[i]={value = {type = "entity",name = asteroid, quality = quality},min = amount}
                    i = i+1
                end
            end
        end
        
        
        
        

        
        
    end
    return signals
end



---Platform lists fetched during the current update.
---
---`get_space_platforms` builds a fresh list on every call and several
---telescopes can share one planet and force, so the first lookup in an update is
---memoized. The cache is reset lazily from `get_platforms` on the first
---telescope that asks: keeping the reset out of the event handler leaves the
---handler body a single storage loop, and an empty storage.telescopes never
---touches this table at all.
local platform_cache = { tick = nil, by_planet = {} }

---Fetch the platform list for a planet+force once per update.
---@param planet LuaPlanet
---@param force LuaForce
---@param tick MapTick
---@return LuaSpacePlatform[]
local function get_platforms(planet, force, tick)
    if platform_cache.tick ~= tick then
        platform_cache.tick = tick
        platform_cache.by_planet = {}
    end
    local by_force = platform_cache.by_planet[planet.name]
    if not by_force then
        by_force = {}
        platform_cache.by_planet[planet.name] = by_force
    end
    local space_platforms = by_force[force.index]
    if not space_platforms then
        space_platforms = planet.get_space_platforms(force)
        by_force[force.index] = space_platforms
    end
    return space_platforms
end

local SIGNATURE_MODULUS = 2147483647 -- 2^31 - 1 keeps hash*131 below 2^53, so the math stays exact.
local SIGNATURE_BRANCH_PLANET = 1
local SIGNATURE_BRANCH_PLATFORM = 2

local function signature_mix(hash, value)
    return (hash * 131 + value) % SIGNATURE_MODULUS
end

---Numeric fingerprint of everything `get_telescope_combinator_signals` reads.
---
---Comparing the built signal list with `rro.deep_equals` costs more than the
---`section.filters` write it would avoid: the list is several nested tables per
---platform and per asteroid type, and the recursive comparison visits every
---node. The list is derived from a handful of numbers, so hash those instead and
---skip both the rebuild and the write when they are unchanged.
---
---Every branch mixes in `#platform_list_signals`: if another mod adds a virtual
---signal, the signal names change even though the platform numbers did not, and
---the stored signature must not match anymore.
---@param surface LuaSurface
---@param force LuaForce
---@param telescope table
---@param tick MapTick tick of the current update, for the per-update platform cache
---@return number signature
---@return LuaSpacePlatform[]|nil space_platforms
local function get_telescope_signal_signature(surface, force, telescope, tick)
    if surface.planet then
        local space_platforms = get_platforms(surface.planet, force, tick)
        local hash = signature_mix(SIGNATURE_BRANCH_PLANET, #platform_list_signals)
        hash = signature_mix(hash, #space_platforms)
        for j = 1, #space_platforms do
            local space_platform = space_platforms[j]
            hash = signature_mix(hash, space_platform.index)
            if use_quality then
                -- get_state_integer returns nil for a state added by a newer
                -- Factorio build; a nil would break the hash arithmetic.
                hash = signature_mix(hash, get_state_integer(space_platform.state) or 0)
                hash = signature_mix(hash, bool_to_int(space_platform.can_leave_current_location()))
            end
        end
        return hash, space_platforms
    elseif surface.platform then
        local platform = surface.platform
        local hash = signature_mix(SIGNATURE_BRANCH_PLATFORM, #platform_list_signals)
        hash = signature_mix(hash, platform.index)
        if platform.space_connection then
            local total_length = platform.space_connection.length
            hash = signature_mix(hash, total_length)
            -- Matches the emitted signal, including a nil distance (docked).
            hash = signature_mix(hash, math.floor((platform.distance or 0) * total_length))
        end
        -- Mix the switch explicitly so toggling it always changes the
        -- signature, whether or not any asteroid has been counted yet.
        hash = signature_mix(hash, telescope.output_asteroid_signals ~= false and 1 or 0)
        if telescope.output_asteroid_signals ~= false then
            -- asteroid_revision changes only when the counts are rebuilt, so the
            -- asteroid tail does not need to be hashed entry by entry.
            hash = signature_mix(hash, telescope.asteroid_revision or 0)
        end
        return hash
    end
    -- Neither a planet nor a platform surface: the signal list is always empty.
    return signature_mix(SIGNATURE_BRANCH_PLANET, 0)
end

-- Test seam: prove the update skips unchanged telescopes. Inert in normal play.
local combinator_stats = { updates = 0, rebuilds = 0, writes = 0 }

Muluna.events.on_nth_tick(settings.startup["muluna-telescope-combinator-update-ticks"].value, function(event) --Update telescope combinators
    for key,telescope in pairs(storage.telescopes) do
            local combinator = telescope["constant-combinator"]
            local assembler = telescope["assembling-machine"]
            local combinator_valid = combinator and combinator.valid
            local assembler_valid = assembler and assembler.valid
            if combinator_valid and assembler_valid and telescope["constant-combinator-control-behavior"] then
                local combinator_behavior = telescope["constant-combinator-control-behavior"]
                if combinator_behavior.enabled == true then
                    combinator_stats.updates = combinator_stats.updates + 1
                    local signature, space_platforms = get_telescope_signal_signature(combinator.surface, combinator.force, telescope, event.tick)
                    if signature ~= telescope.signal_signature then
                        local signals = get_telescope_combinator_signals(combinator.surface, combinator.force, telescope, space_platforms)
                        combinator_stats.rebuilds = combinator_stats.rebuilds + 1
                        local section = combinator_behavior.get_section(1) or combinator_behavior.add_section()
                        section.filters = signals
                        combinator_stats.writes = combinator_stats.writes + 1
                        telescope.signal_signature = signature
                    end
                end
            else
                -- Either half of the compound entity can disappear on its own
                -- (for example when a surface is deleted). Drop the entry and
                -- its surface index instead of leaving update_all_telescopes
                -- to dereference an invalid entity.
                local surface_name
                if combinator_valid then
                    surface_name = combinator.surface.name
                elseif assembler_valid then
                    surface_name = assembler.surface.name
                end
                if surface_name and storage.telescopes_on_surface[surface_name] then
                    storage.telescopes_on_surface[surface_name][key] = nil
                else
                    for _, entries in pairs(storage.telescopes_on_surface) do
                        entries[key] = nil
                    end
                end
                if storage.telescope_children and telescope.combinator_unit_number then
                    storage.telescope_children[telescope.combinator_unit_number] = nil
                end
                storage.telescopes[key] = nil
            end
    end



end)

if script.active_mods["funit"] then
    Muluna.funit.get_telescope_combinator_signals = get_telescope_combinator_signals
    Muluna.funit.get_state_integer = get_state_integer
    Muluna.funit.get_time_to_next_asteroid_check = get_time_to_next_asteroid_check
    Muluna.funit.bool_to_int = bool_to_int

    ---Flip the asteroid-signal output switch, which the GUI normally toggles.
    ---@param unit_number uint
    ---@param state boolean
    Muluna.funit.set_telescope_asteroid_signals = function(unit_number, state)
        local telescope = storage.telescopes and storage.telescopes[unit_number]
        if not telescope then return false end
        telescope.output_asteroid_signals = state and true or false
        return true
    end

    ---Snapshot of how much work the combinator update did since load.
    ---@return {updates: integer, rebuilds: integer, writes: integer}
    Muluna.funit.get_telescope_combinator_stats = function()
        return {
            updates = combinator_stats.updates,
            rebuilds = combinator_stats.rebuilds,
            writes = combinator_stats.writes,
        }
    end

end
