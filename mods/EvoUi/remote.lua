if not EvoUi then EvoUi = { log = function() end } end


--
-- Rebuilds a given player's EvoUi, destroying any existing settings.
-- player_name: the name or player index of the player being reset
local function remote_rebuild(player_name)
    if not player_name then
        EvoUi.log({"err_needplayername"})
        return
    end

    if not game.players[player_name] then
        EvoUi.log({"err_nosuchplayer", tostring(player_name)})
        return
    end

    if not storage.EvoUi or not storage.EvoUi[player_name] then
        EvoUi.log({"err_noplayerdata", player_name})
        return
    end

    storage.EvoUi[player_name] = nil
    EvoUi.new_player({ player_index = player_name })
end

--
-- Creates a sensor managed by a remote interface (another mod or script)
-- sensor_data: a table with the following fields:
--     mod_name: Name of the mod registering the sensor. Sensor will be removed
--         if the mod is removed from the game.
--     name: Internal name of the sensor. Should be unique (otherwise you're
--         just redefining the existing one).
--     text: Text to display in the active gui (may be localized).
--     caption: Sensor setting name in the EvoUi settings panel (may be localized).
--     color: Font color of the text to display in the active gui, optional, may be nil.
--
-- example: remote.call("EvoUi", "create_remote_sensor", { mod_name = "my_mod",
--                                                          name = "my_mod_my_sensor_name",
--                                                          text = "Text: Lorem Ipsum",
--                                                          caption = "Lorem Ipsum Text" })
-- or, with locale:
-- remote.call("EvoUi", "create_remote_sensor", { mod_name = "my_mod",
--                                                 name = "my_mod_my_sensor_name",
--                                                 text = {"my_mod_sensor_display", 42},
--                                                 caption = {"my_mod_sensor"} })
local function create_remote_sensor(sensor_data)
    if not sensor_data then
        EvoUi.log({"err_no_sensor_data"})
        return
    end

    for _, field in pairs({ "mod_name", "name", "text", "caption" }) do
        if not sensor_data[field] then
            EvoUi.log({"err_sensor_missing_field", serpent.dump(sensor_data, {compact = false, nocode = true, indent = ' '}), field})
            return
        end
    end

    local sensor = RemoteSensor.get_by_name(sensor_data.name)
    if not sensor then
        RemoteSensor.new(sensor_data)
    end
end

--
-- Updates a sensor managed by a remote interface
-- sensor_name: internal name of the sensor. The sensor should have been previously created.
-- sensor_text: Text to display in the active gui
-- sensor_color: Font color of the text to display in the active gui, optional, may be nil
-- example: remote.call("EvoUi", "update_remote_sensor", "mymod_my_sensor_name", "Text: Lorem Ipsum")
local function update_remote_sensor(sensor_name, sensor_text, sensor_color)
    if not sensor_name then
        EvoUi.log({"err_nosensorname"})
        return
    end

    if not sensor_text then
        EvoUi.log({"err_nosensortext", sensor_name})
        return
    end

    local sensor = RemoteSensor.get_by_name(sensor_name)
    if not sensor then
        EvoUi.log({"err_nosensorfound", sensor_name})
        return
    end

    sensor["line"] = sensor_text
    if sensor_color then
        sensor["color"] = sensor_color
    end
end

--
-- Checks if a remote sensor exists, returns true if one was does
-- sensor_name: internal name of the sensor.
-- example: remote.call("EvoUi", "has_remote_sensor", "mymod_my_sensor_name")
local function has_remote_sensor(sensor_name)
    if not sensor_name then
        EvoUi.log({"err_nosensorname"})
        return
    end
    local sensor = RemoteSensor.get_by_name(sensor_name)
    return sensor ~= nil
end

--
-- Removes a sensor managed by a remote interface, returns true if one was removed
-- sensor_name: internal name of the sensor. If it does not exist, it was already removed.
-- example: remote.call("EvoUi", "remove_remote_sensor", "mymod_my_sensor_name")
local function remove_remote_sensor(sensor_name)
    if not sensor_name then
        EvoUi.log({"err_nosensorname"})
        return
    end
    local sensor = RemoteSensor.get_by_name(sensor_name)
    if not sensor then
        -- impossible to know if the sensor was removed in advance, so just return a status
        return false
    end
    EvoUi.hide_sensor(sensor)
    for idx, sensor in pairs(EvoUi.value_sensors) do
        if sensor.name == ("remote_sensor_" .. sensor_name) then
            table.remove(EvoUi.value_sensors, idx)
        end
    end
    storage.remote_sensors[sensor_name] = nil
    return true
end

interface = {
    rebuild = function(player_name)
        local status, retval = pcall(remote_rebuild, player_name)

        if status then return retval
        elseif retval then EvoUi.log({"err_generic", "remote.rebuild", retval}) end
    end,

    create_remote_sensor = function(sensor_data)
        local status, retval = pcall(create_remote_sensor, sensor_data)

        if status then return retval
        elseif retval then EvoUi.log({"err_generic", "remote.create_remote_sensor", retval}) end
    end,

    update_remote_sensor = function(sensor_name, sensor_text, sensor_color)
        local status, retval = pcall(update_remote_sensor, sensor_name, sensor_text, sensor_color)

        if status then return retval
        elseif retval then EvoUi.log({"err_generic", "remote.update_remote_sensor", retval}) end
    end,

    has_remote_sensor = function(sensor_name)
        local status, retval = pcall(has_remote_sensor, sensor_name)

        if status then return retval
        elseif retval then EvoUi.log({"err_generic", "remote.has_remote_sensor", retval}) end
    end,

    remove_remote_sensor = function(sensor_name)
        local status, retval = pcall(remove_remote_sensor, sensor_name)

        if status then return retval
        elseif retval then EvoUi.log({"err_generic", "remote.remove_remote_sensor", retval}) end
    end
}


remote.add_interface("EvoUi", interface)
