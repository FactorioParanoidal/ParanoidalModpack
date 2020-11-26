-------------------------------------------------------------------------------
--[Tape Measure]--
-------------------------------------------------------------------------------
local Event = require('__stdlib__/stdlib/event/event')
local Area = require('__stdlib__/stdlib/area/area')

local function measure_area(event)
    if event.item == 'picker-tape-measure' then
        local player = game.players[event.player_index]
        local area = Area(event.area)
        if event.name == defines.events.on_player_alt_selected_area then
            area = area:ceil()
        end
        local size, width, height = area:size()
        player.print(area .. ' Center = ' .. area:center())
        player.print('Size = ' .. size .. ' Width = ' .. width .. ' Height = ' .. height)
    end
end
Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, measure_area)

-------------------------------------------------------------------------------
--[Screenshot Camera]--
-------------------------------------------------------------------------------
--Code modified from "Screenshot camera", by "aaargha",
--[[
Take a screenshot and save it to a file.
Parameters
Table with the following fields:
player :: string or LuaPlayer or uint (optional)
by_player :: string or LuaPlayer or uint (optional): If defined, the screenshot will only be taken for this player.
position :: Position (optional)
resolution :: Position (optional): Maximum allowed resolution is 16384x16384 (resp. 8196x8196 when anti_alias is true), but maximum recommended resolution is 4096x4096 (resp. 2048x2048).
zoom :: double (optional)
path :: string (optional): Path to save the screenshot in
show_gui :: boolean (optional): Include game GUI in the screenshot?
show_entity_info :: boolean (optional): Include entity info (alt-mode)?
anti_alias :: boolean (optional): Render in double resolution and scale down (including GUI)?
--]]
local function paparazzi(event)
    if event.item == 'picker-camera' then
        local player = game.players[event.player_index]
        local opt = player.mod_settings
        local _zoom = opt['picker-camera-zoom'].value
        local _aa = opt['picker-camera-aa'].value
        local _gui = opt['picker-camera-gui'].value
        local _alt_info = event.name == defines.events.on_player_alt_selected_area
        local _path = 'Screenshots/' .. (_alt_info and 'Alt/' or '') .. event.tick .. '.png'

        local pix_per_tile = 32 * _zoom
        local max_dist = (_aa and 256 / _zoom) or 512 / _zoom

        local area = Area(event.area):ceil()
        local diffx = area.right_bottom.x - area.left_top.x
        local diffy = area.right_bottom.y - area.left_top.y

        local res = {x = diffx * pix_per_tile, y = diffy * pix_per_tile}
        local pos = {x = area.left_top.x + diffx / 2, y = area.left_top.y + diffy / 2}

        if res.x >= 1 and res.y >= 1 then
            --use another mod to handle larger screenshots if available
            if remote.interfaces['LargerScreenshots'] and remote.interfaces['LargerScreenshots']['screenshot'] then
                remote.call(
                    'LargerScreenshots',
                    'screenshot',
                    {
                        player = player,
                        by_player = player,
                        position = pos,
                        size = {x = diffx, y = diffy},
                        zoom = _zoom,
                        path_prefix = 'Picker',
                        show_gui = _gui,
                        show_entity_info = _alt_info,
                        anti_alias = _aa
                    }
                )
            else
                if diffx <= max_dist then
                    if diffy <= max_dist then
                        player.print('Taking screenshot of selected area')
                        game.take_screenshot {
                            player = player,
                            by_player = player,
                            position = pos,
                            resolution = res,
                            zoom = _zoom,
                            path = _path,
                            show_gui = _gui,
                            show_entity_info = _alt_info,
                            anti_alias = _aa
                        }
                    else
                        player.print('Area too tall, max is ' .. max_dist .. ' tiles')
                    end
                else
                    player.print('Area too wide, max is ' .. max_dist .. ' tiles')
                end
            end
        end
    end
end
Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, paparazzi)
