require "evoUI"

if not EvoUi then EvoUi = {} end

function EvoUi.log(message)
    if game then
        for i, p in pairs(game.players) do
            p.print(message)
        end
    else
        error(serpent.dump(message, {compact = false, nocode = true, indent = ' '}))
    end
end


function EvoUi.format_number(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function string.starts_with(haystack, needle)
    return string.sub(haystack, 1, string.len(needle)) == needle
end


local octant_names = {
    [0] = {"direction.east"},
    [1] = {"direction.southeast"},
    [2] = {"direction.south"},
    [3] = {"direction.southwest"},
    [4] = {"direction.west"},
    [5] = {"direction.northwest"},
    [6] = {"direction.north"},
    [7] = {"direction.northeast"},
}

function EvoUi.get_octant_name(vector)
    local radians = math.atan2(vector.y, vector.x)
    local octant = math.floor( 8 * radians / (2*math.pi) + 8.5 ) % 8

    return octant_names[octant]
end


script.on_init(EvoUi.mod_init)
script.on_configuration_changed(EvoUi.mod_update)

script.on_event(defines.events.on_player_created, function(event)
    local status, err = pcall(EvoUi.new_player, event)
    if err then EvoUi.log({"err_generic", "on_player_created", err}) end
end)

script.on_event(defines.events.on_tick, function(event)
    local status, err = pcall(RemoteSensor.initialize)
    if err then EvoUi.log({"err_generic", "on_tick:remote_initialize", err}) end
    local status, err = pcall(EvoUi.update_gui, event)
    if err then EvoUi.log({"err_generic", "on_tick:update_gui", err}) end
end)

local last_clicked = nil
local last_checked = nil

local function raise_on_click(event)
    local status, err = pcall(EvoUi.on_gui_click, event)

    if err then
        if event.element.valid then
            EvoUi.log({"err_specific", "on_gui_click", event.element.name, err})
        else
            EvoUi.log({"err_generic", "on_gui_click", err})
        end
    end
end

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    last_checked = event.element.name

    raise_on_click(event)
end)

script.on_event(defines.events.on_gui_click, function(event)
    -- prevent raising on_click twice for the same element
    if last_checked ~= nil and last_checked == event.element.name then
        return
    end
    last_clicked = event.element.name

    raise_on_click(event)
end)
