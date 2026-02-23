-------------------------------------------------------------------------------
--[[Bottleneck]]--
-------------------------------------------------------------------------------

local bn_signals_per_tick = settings.global["bottleneck-signals-per-tick"].value

local LIGHT = { off = 1 }
local colors = { "white", "blue", "red", "green", "yellow" }
local icons = {
  "none",
  "none small",
  "alert",
  "alert small",
  "cross",
  "cross small",
  "minus",
  "minus small",
  "pause",
  "pause small",
  "stop",
  "stop small",
  "alert3D",
  "alert3D small",
  "cross3D",
  "cross3D small",
  "minus3D",
  "minus3D small",
  "pause3D",
  "pause3D small",
  "stop3D",
  "stop3D small"
}

local icon_count = table_size(icons)

for color_index, color in pairs(colors) do
  for icon_index, icon  in pairs(icons) do
    --log("LIGHT[" .. color .. " " .. icon .. "] = " .. ( (color_index - 1) * icon_count ) + icon_index + 2)
    LIGHT[color .. " " .. icon] = ( (color_index - 1) * icon_count ) + icon_index + 1
  end
end

local STYLE = {}

local SUPPORTED_TYPES = {
    ["assembling-machine"] = true,
    ["lab"] = true,
    ["furnace"] = true,
    ["mining-drill"] = true,
    ["rocket-silo"] = true,
}

local BLACKLIST_NAMES = {
    ["factory-port-marker"] = true,
}

--Faster to just change the color than it is to check it first.
local function change_signal(data, status)
  data.signal.graphics_variation = STYLE[status] or 1
end

--[[ Remove the LIGHT]]
local function remove_signal(event)
    local entity = event.entity
    local index = entity.unit_number
    local overlays = storage.overlays
    local data = overlays[index]
    if data then
        local signal = data.signal
        if signal and signal.valid then
            signal.destroy()
        end
        overlays[index] = nil
        storage.update_index = nil
    end
end

--[[ Calculates bottom center of the entity to place bottleneck there ]]
local function get_signal_position_from(entity)
    local left_top = entity.selection_box.left_top
    local right_bottom = entity.selection_box.right_bottom
    --Calculating center of the selection box
    local center = (left_top.x + right_bottom.x) / 2
    local width = right_bottom.x - left_top.x
    -- Set Shift here if needed, The offset looks better as it doesn't cover up fluid input information
    -- Ignore shift for 1 tile entities
    local x = (width > 1.25 and center - 0.5) or center
    local y = right_bottom.y
    --Calculating bottom center of the selection box
    return {x = x, y = y - 0.23}
end

local function new_signal(entity, variation)
    local signal = entity.surface.create_entity{name = "bottleneck-stoplight", position = get_signal_position_from(entity), force = entity.force}
    signal.graphics_variation = (storage.show_bottlenecks < 1 and LIGHT["off"]) or variation or STYLE[entity.status] or LIGHT["off"]
    signal.destructible = false
    return signal
end

local function entity_moved(event, data)
    data = data or storage.overlays[event.moved_entity.unit_number]
    if data then
        if data.signal and data.signal.valid then
            local position = get_signal_position_from(event.moved_entity)
            data.signal.teleport(position)
        end
    end
end

--[[ A function that is called whenever an entity is built (both by player and by robots) ]]--
local function built(event)
    local entity = event.created_entity or event.entity

    -- If the entity that's been built is an assembly machine or a furnace...
    if (SUPPORTED_TYPES[entity.type] and not BLACKLIST_NAMES[entity.name]) then
        local data = {}
        if not storage.overlays[entity.unit_number] then
            data.entity = entity
            data.signal = new_signal(entity)

            --update[data.update](data)
            storage.overlays[entity.unit_number] = data
            -- if we are in the process of removing LIGHTs, we need to restart
            -- that, since inserting into the overlays table may mess up the
            -- iteration order.
            if storage.show_bottlenecks == -1 then
                storage.update_index = nil
            end
        end
    end
end

local function rebuild_overlays()
    --[[Setup the global overlays table This table contains the machine entity, the signal entity and the freeze variable]]--
    storage.overlays = {}
    storage.update_index = nil
    --game.print("Bottleneck: Rebuilding data from scratch")

    --[[Find all assembling machines on the map. Check each surface]]--
    for _, surface in pairs(game.surfaces) do
        --find-entities-filtered with no area argument scans for all entities in loaded chunks and should
        --be more effiecent then scanning through all chunks like in previous version

        --[[destroy any existing bottleneck-signals]]--
        for _, stoplight in pairs(surface.find_entities_filtered{name="bottleneck-stoplight"}) do
            stoplight.destroy()
        end

        --[[rebuild signals for all supported entity types]]
        for type in pairs(SUPPORTED_TYPES) do
          for _, entity in pairs(surface.find_entities_filtered{type=type}) do
            built({created_entity = entity})
          end
        end
    end
end

local function on_tick()
    local show_bottlenecks = storage.show_bottlenecks
    if show_bottlenecks ~= 0 then
        local next = next --very slight perfomance improvment

        local signals_per_tick = bn_signals_per_tick

        local overlays = storage.overlays
        local index = storage.update_index
        local data

        --check for existing data at index
        if index and overlays[index] then
            data = overlays[index]
        else
            index, data = next(overlays, index)
        end

        local numiter = 0
        while index and (numiter < signals_per_tick) do
            local entity = data.entity
            if entity.valid then -- if entity is valid, update it, otherwise remove the signal and the associated data
                if data.signal.valid then
                    if show_bottlenecks > 0 then
                        --Faster to just change the color than it is to check it first.
                        data.signal.graphics_variation = STYLE[data.entity.status] or 1
                    else
                        data.signal.graphics_variation = LIGHT["off"]
                    end
                else -- Rebuild the icon something broke it!
                    data.signal = new_signal(entity)
                end
            else -- Machine is gone
                if data.signal.valid then
                    data.signal.destroy() -- Signal is there; remove it
                end
                overlays[index] = nil -- forget about the machine
            end
            numiter = numiter + 1
            index, data = next(overlays, index)
        end
        storage.update_index = index
        -- if we have reached the end of the list (i.e., have removed all LIGHTs),
        -- pause updating until enabled by hotkey next
        if not index and show_bottlenecks <= 0 then
            storage.show_bottlenecks = 0
            --We have cycled everything to off, disable the tick handler
            script.on_event(defines.events.on_tick, nil)
        end
    end
end

local function update_settings(_)
  bn_signals_per_tick = settings.global["bottleneck-signals-per-tick"].value
  for status_name, status in pairs(defines.entity_status) do
    local color = settings.global["bottleneck-show-"..status_name.."-color"].value
    if color == "off" then
      --log("Setting:" .. status_name .. " - " .. "off" .. "(" ..LIGHT["off"] ..")")
      STYLE[status] = LIGHT["off"]
    else
      local icon = settings.global["bottleneck-show-"..status_name.."-icon"].value
      --log("Setting:" .. status_name .. " - " .. color .. " " .. icon .. "(" ..LIGHT[color .. " " .. icon] ..")")
      STYLE[status] = LIGHT[color .. " " .. icon]
    end
  end
end
script.on_event(defines.events.on_runtime_mod_setting_changed, update_settings)

-------------------------------------------------------------------------------
--[[Init Events]]
local function register_conditional_events()
    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), entity_moved)
    end
    if storage.show_bottlenecks ~= 0 then
        --Register the tick handler if we are showing bottlenecks
        script.on_event(defines.events.on_tick, on_tick)
    end
end

local function init()
    storage.overlays = {}
    storage.show_bottlenecks = 1
    update_settings(nil)
    --register the tick handler if we are showing bottlenecks
    if storage.show_bottlenecks then
        script.on_event(defines.events.on_tick, on_tick)
    end
    rebuild_overlays()
    register_conditional_events()
end

local function on_load()
  if # STYLE == 0 then
    update_settings(nil)
  end
  register_conditional_events()
end

local function on_configuration_changed(event)
    --Any MOD has been changed/added/removed, including base game updates.
    if event.mod_changes then
        --This mod has changed
        local changes = event.mod_changes["Bottleneck"]
        if changes then -- THIS Mod has changed
            game.print("Bottleneck: Updated from ".. tostring(changes.old_version) .. " to " .. tostring(changes.new_version))
            update_settings(nil)
            storage.show_bottlenecks = storage.show_bottlenecks or 1
            --Clean up old variables
            storage.lights_per_tick = nil
            storage.signals_per_tick = nil
            storage.showbottlenecks = nil
            storage.output_idle_signal = nil
            storage.high_contrast = nil
        end
        storage.overlays = {}
        rebuild_overlays()
    end
end

local function on_entity_cloned(event)
    if event.destination.name == "bottleneck-stoplight" then
        event.destination.destroy()
    end
end

--[[ Hotkey ]]--

local function on_hotkey(event)
    local player = game.players[event.player_index]
    if not player.admin then
        player.print('Bottleneck: You do not have privileges to toggle bottleneck')
        return
    end
    storage.update_index = nil
    if storage.show_bottlenecks == 1 then
        storage.show_bottlenecks = -1
    else
        storage.show_bottlenecks = 1
    end
    --Toggling the setting doesn't disable right way, make sure the handler gets
    --reenabled to toggle colors to their correct values.
    script.on_event(defines.events.on_tick, on_tick)
end

--[[ Setup event handlers ]]--
script.on_init(init)
script.on_configuration_changed(on_configuration_changed)
script.on_load(on_load)

local e=defines.events
local remove_events = {e.on_player_mined_entity, e.on_robot_pre_mined, e.on_entity_died, e.script_raised_destroy}
local add_events = {e.on_built_entity, e.on_robot_built_entity, e.script_raised_revive, e.script_raised_built}

script.on_event(remove_events, remove_signal)
script.on_event(add_events, built)
script.on_event("bottleneck-hotkey", on_hotkey)
script.on_event({e.on_entity_cloned}, on_entity_cloned)

--[[ Setup remote interface]]--
local interface = {}
--is_enabled - return show_bottlenecks
interface.enabled = function() return storage.show_bottlenecks end
--print the global to a file
interface.print_global = function () game.write_file("Bottleneck/storage.lua", serpent.block(global, {nocode=true, comment=false})) end
--rebuild all icons
interface.rebuild = rebuild_overlays
--allow other mods to interact with bottleneck
interface.entity_moved = entity_moved
interface.get_lights = function() return LIGHT end
interface.new_signal = new_signal
interface.change_signal = change_signal --function(data, color) change_signal(signal, color) end
--get a place position for a signal
interface.get_position_for_signal = get_signal_position_from
--get the signal data associated with an entity
interface.get_signal_data = function(unit_number) return storage.overlays[unit_number] end

remote.add_interface("Bottleneck", interface)
