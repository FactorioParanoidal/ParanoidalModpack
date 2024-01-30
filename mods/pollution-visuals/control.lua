-------------------------------------------------------------------------
-- TO DO
-------------------------------------------------------------------------

-- INCREASE PROFORMANCE
-- FIX BUGS

-------------------------------------------------------------------------
-- variables
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- MAIN FUNCTIONS
-------------------------------------------------------------------------

-- wil set is_setup to false
local function set_is_setup()
    global.is_setup = false
end

-- returns a table with all the players that have the "show-pollution-visuals" option on
local function get_players_to_render_for()
	local result = {}

	for i, player in pairs(game.players) do
		local show_pollution_visuals = player.mod_settings["show-pollution-visuals"].value
        if show_pollution_visuals then
            table.insert(result, player)
        end
	end

	return result
end

-- sets up all the variables and populates them with initial values
local function setup()
    -- clearing all visuals juist incase there are some
    rendering.clear("pollution-visuals")

    -- defining chunk tables
    global.polluted_chunks = {}
    global.polluted_chunks_i = nil
    global.all_chunks = {}
    global.all_chunks_i = nil

    -- defining fading sprite tables
    global.sprites_fading_in = {}
    global.sprites_fading_in_i = nil
    global.sprites_fading_out = {}
    global.sprites_fading_out_i = nil

    --bool for if we need to check all_chunks or just polluted_chunks
    global.is_checking = false

    --bool for if we need to start fading the sprites
    global.is_fading = false
    
    -- bool for checking if the game is setup or not
    global.is_setup = true

    -- defining the overworld.
    for _, surface in pairs(game.surfaces) do
        --looping through all the chunks on surface
        for chunk in surface.get_chunks() do
            local x = (chunk.x)
            local y = (chunk.y)

            -- inserting chunk in all_chunks
            global.all_chunks[surface.index..":"..x..":"..y] = {position = {x=x,y=y}, surface=surface.index}

            -- inserting chunk in polluted_chunks 
            local chunk_pollution_level = surface.get_pollution(chunk.area.left_top)
            if chunk_pollution_level > 0 then
                -- if a neighboring chunk has 0 pollution add it to the polluted_chunk table anyway.
                local N = surface.get_pollution({x*32, (y-1)*32})
                local E = surface.get_pollution({(x+1)*32, y*32})
                local S = surface.get_pollution({x*32, (y+1)*32})
                local W = surface.get_pollution({(x-1)*32, y*32})
                local NE = surface.get_pollution({(x+1)*32, (y-1)*32})
                local SE = surface.get_pollution({(x+1)*32, (y+1)*32})
                local SW = surface.get_pollution({(x-1)*32, (y+1)*32})
                local NW = surface.get_pollution({(x-1)*32, (y-1)*32})

                global.polluted_chunks[surface.index..":"..x..":"..y] = {position = {x=x,y=y}, r_id={}, surface=surface.index}
                if N == 0 then 
                    global.polluted_chunks[surface.index..":"..x..":"..(y-1)] = {position = {x=x, y=y-1}, r_id={}, surface=surface.index} 
                end
                if E == 0 then 
                    global.polluted_chunks[surface.index..":"..(x+1)..":"..y] = {position = {x=x+1, y=y}, r_id={}, surface=surface.index} 
                end
                if S == 0 then 
                    global.polluted_chunks[surface.index..":"..x..":"..(y+1)] = {position = {x=x, y=y+1}, r_id={}, surface=surface.index} 
                end
                if W == 0 then 
                    global.polluted_chunks[surface.index..":"..(x-1)..":"..y] = {position = {x=x-1, y=y}, r_id={}, surface=surface.index} 
                end
                if NE == 0 then 
                    global.polluted_chunks[surface.index..":"..(x+1)..":"..(y-1)] = {position = {x=x+1,y=y-1}, r_id={}, surface=surface.index} 
                end
                if SE == 0 then 
                    global.polluted_chunks[surface.index..":"..(x+1)..":"..(y+1)] = {position = {x=x+1, y=y+1}, r_id={}, surface=surface.index} 
                end
                if SW == 0 then 
                    global.polluted_chunks[surface.index..":"..(x-1)..":"..(y+1)] = {position = {x=x-1, y=y+1}, r_id={}, surface=surface.index} 
                end
                if NW == 0 then 
                    global.polluted_chunks[surface.index..":"..(x-1)..":"..(y-1)] = {position = {x=x-1, y=y-1}, r_id={}, surface=surface.index} 
                end
            end
        end
    end
end

-- will check if chunks are polluted and put them in polluted_chunks if they are
local function check_all_chunks()
    for i = 1, settings.global["chunks-per-tick-pollution-visuals"].value do
        local index ,chunk_data = next(global.all_chunks, global.all_chunks_i)
        if index == nil then global.all_chunks_i = nil global.is_checking = false break 
        else global.all_chunks_i = index end

        local surface_i = chunk_data.surface
        local surface = game.surfaces[surface_i]
        local x = chunk_data.position.x
        local y = chunk_data.position.y
        local r_id = chunk_data.r_id
        local chunk_pollution_level = surface.get_pollution({x*32,y*32})

        --inserting chunk into polluted_chunks
        if chunk_pollution_level > 0 then
            local N = surface.get_pollution({x*32, (y-1)*32})
            local E = surface.get_pollution({(x+1)*32, y*32})
            local S = surface.get_pollution({x*32, (y+1)*32})
            local W = surface.get_pollution({(x-1)*32, y*32})
            local NE = surface.get_pollution({(x+1)*32, (y-1)*32})
            local SE = surface.get_pollution({(x+1)*32, (y+1)*32})
            local SW = surface.get_pollution({(x-1)*32, (y+1)*32})
            local NW = surface.get_pollution({(x-1)*32, (y-1)*32})

            --adding chunk or neighboring chunks to the polluted_chunks table
            if global.polluted_chunks[surface_i..":"..x..":"..y] == nil then
                global.polluted_chunks[surface_i..":"..x..":"..y] = {position = {x=x,y=y}, r_id={}, surface=surface_i}
            end
            if N == 0 and global.polluted_chunks[surface_i..":"..x..":"..(y-1)] == nil and global.all_chunks[surface_i..":"..x..":"..(y-1)] ~= nil then
                global.polluted_chunks[surface_i..":"..x..":"..(y-1)] = {position = {x=x, y=y-1}, r_id={}, surface=surface_i}
            end
            if E == 0 and global.polluted_chunks[surface_i..":"..(x+1)..":"..y] == nil and global.all_chunks[surface_i..":"..(x+1)..":"..y] ~= nil then
                global.polluted_chunks[surface_i..":"..(x+1)..":"..y] = {position = {x=x+1, y=y}, r_id={}, surface=surface_i}
            end
            if S == 0 and global.polluted_chunks[surface_i..":"..x..":"..(y+1)] == nil and global.all_chunks[surface_i..":"..x..":"..(y+1)] ~= nil then
                global.polluted_chunks[surface_i..":"..x..":"..(y+1)] = {position = {x=x, y=y+1}, r_id={}, surface=surface_i}
            end
            if W == 0 and global.polluted_chunks[surface_i..":"..(x-1)..":"..y] == nil and global.all_chunks[surface_i..":"..(x-1)..":"..y] ~= nil then
                global.polluted_chunks[surface_i..":"..(x-1)..":"..y] = {position = {x=x-1, y=y}, r_id={}, surface=surface_i}
            end
            if NE == 0 and global.polluted_chunks[surface_i..":"..(x+1)..":"..(y-1)] == nil and global.all_chunks[surface_i..":"..(x+1)..":"..(y-1)] ~= nil then
                global.polluted_chunks[surface_i..":"..(x+1)..":"..(y-1)] = {position = {x=x+1,y=y-1}, r_id={}, surface=surface_i}
            end
            if SE == 0 and global.polluted_chunks[surface_i..":"..(x+1)..":"..(y+1)] == nil and global.all_chunks[surface_i..":"..(x+1)..":"..(y+1)] ~= nil then
                global.polluted_chunks[surface_i..":"..(x+1)..":"..(y+1)] = {position = {x=x+1, y=y+1}, r_id={}, surface=surface_i}
            end
            if SW == 0 and global.polluted_chunks[surface_i..":"..(x-1)..":"..(y+1)] == nil and global.all_chunks[surface_i..":"..(x-1)..":"..(y+1)] ~= nil then
                global.polluted_chunks[surface_i..":"..(x-1)..":"..(y+1)] = {position = {x=x-1, y=y+1}, r_id={}, surface=surface_i}
            end
            if NW == 0 and global.polluted_chunks[surface_i..":"..(x-1)..":"..(y-1)] == nil and global.all_chunks[surface_i..":"..(x-1)..":"..(y-1)] ~= nil then
                global.polluted_chunks[surface_i..":"..(x-1)..":"..(y-1)] = {position = {x=x-1, y=y-1}, r_id={}, surface=surface_i}
            end
        end
    end
end

-- draws a sprite for a specified chunk
local function check_polluted_chunk(chunk_data)
    local surface = game.surfaces[chunk_data.surface]
    local x = chunk_data.position.x
    local y = chunk_data.position.y
    local chunk_pollution_level = surface.get_pollution({x*32,y*32})
    local sprite_target = {(x*32)+16, (y*32)+16}
    local remove_chunk = false
    local players = get_players_to_render_for()
    local max_layers = settings.global["layers-pollution-visuals"].value
    local offset = settings.global["x-offset-pollution-visuals"].value
    local a = settings.global["y-intercept-pollution-visuals"].value
    local b = settings.global["base-pollution-visuals"].value
    local r_id = chunk_data.r_id

    for i = 1, max_layers do
        local level = a*b^i + offset
        local current_sprite = ""
        local next_sprite = ""

        -- setting the current sprite
        if r_id[i] ~= nil then current_sprite = rendering.get_sprite(r_id[i]) end

        -- setting the next sprite
        if chunk_pollution_level > level then
            next_sprite = "smog_middle"
        else
            -- variables of neighboring chunks
            local N = surface.get_pollution({x*32, (y-1)*32})
            local E = surface.get_pollution({(x+1)*32, y*32})
            local S = surface.get_pollution({x*32, (y+1)*32})
            local W = surface.get_pollution({(x-1)*32, y*32})
            local NE = surface.get_pollution({(x+1)*32, (y-1)*32})
            local SE = surface.get_pollution({(x+1)*32, (y+1)*32})
            local SW = surface.get_pollution({(x-1)*32, (y+1)*32})
            local NW = surface.get_pollution({(x-1)*32, (y-1)*32})
            
            --selecting the right sprite depending on neighboring chunks pollution values
            if (N > level and S > level) or (W > level and E > level) then next_sprite="smog_middle"
            elseif S > level and W <= level and E <= level then next_sprite="smog_top"
            elseif N > level and W <= level and E <= level then next_sprite="smog_bottom"
            elseif (W > level or (NW > level and SW > level)) and (N <= level and S <= level and NE <= level and SE <= level) then next_sprite="smog_left"
            elseif (E > level or (NE > level and SE > level)) and (N <= level and S <= level and NW <= level and SW <= level) then next_sprite="smog_right"
            elseif SW > level and N <= level and NE <= level and E <= level and SE <= level and S <= level and W <= level and NW <= level then next_sprite="smog_corner_left_top"
            elseif SE > level and N <= level and NE <= level and E <= level and SW <= level and S <= level and W <= level and NW <= level then next_sprite="smog_corner_right_top"
            elseif NW > level and N <= level and NE <= level and E <= level and SW <= level and S <= level and W <= level and SE <= level then next_sprite="smog_corner_left_bottom"
            elseif NE > level and E <= level and SE <= level and S <= level and SW <= level and W <= level and NW <= level and N <= level then next_sprite="smog_corner_right_bottom"
            elseif S > level and E > level and W <= level and N <= level and NW <= level then next_sprite="smog_corner_inv_left_top"
            elseif S > level and W > level and E <= level and N <= level and NE <= level then next_sprite="smog_corner_inv_right_top"
            elseif N > level and E > level and W <= level and S <= level and SW <= level then next_sprite="smog_corner_inv_left_bottom"
            elseif N > level and W > level and E <= level and S <= level and SE <= level then next_sprite="smog_corner_inv_right_bottom"
            elseif N == 0 and E == 0 and S == 0 and W == 0 and NE == 0 and NW == 0 and SE == 0 and SW == 0 and chunk_pollution_level == 0 and r_id == {} then
                remove_chunk = true
            end
        end

        -- marking sprite for fade in/out
        if r_id[i] ~= nil then
            if next_sprite == "" then
                --mark for fade out
                global.sprites_fading_out[r_id[i]] = {tint = {r=1, g=1, b=1, a=1}, position={x=x,y=y}}
                r_id[i] = nil
            elseif next_sprite ~= current_sprite then
                --mark for fade out
                global.sprites_fading_out[r_id[i]] = {tint = {r=1, g=1, b=1, a=1}, position={x=x,y=y}}
                --mark for fade in 
                r_id[i] = rendering.draw_sprite{sprite=next_sprite, surface=surface,target=sprite_target, y_scale=2, x_scale=2, tint={r=0, g=0, b=0, a=0}, players=players}
                if #players == 0 then 
                    rendering.set_visible(r_id[i], false)
                end
                global.sprites_fading_in[r_id[i]] = {tint = {r=0, g=0, b=0, a=0}, position={x=x,y=y}}
            end
        elseif next_sprite ~= "" then
            --mark for fade in
            r_id[i] = rendering.draw_sprite{sprite=next_sprite, surface=surface,target=sprite_target, y_scale=2, x_scale=2, tint={r=0, g=0,b=0, a=0}, players=players}
            if #players == 0 then rendering.set_visible(r_id[i], false) end
            global.sprites_fading_in[r_id[i]] = {tint = {r=0, g=0, b=0, a=0}, position={x=x,y=y}}
        end

        --update global tables with new values
        global.polluted_chunks[chunk_data.surface..":"..x..":"..y].r_id[i] = r_id[i]
    end

    -- delete chunk from polluted_chunks
    if remove_chunk then 
        global.polluted_chunks[chunk_data.surface..":"..x..":"..y] = nil
    end
end

-- will check every polluted chunk and draw visuals
local function check_polluted_chunks()
    for i = 1, settings.global["chunks-per-tick-pollution-visuals"].value do
        local index ,chunk_data = next(global.polluted_chunks, global.polluted_chunks_i)
        if index == nil then global.polluted_chunks_i = nil global.is_fading = true break
        else global.polluted_chunks_i = index end
        check_polluted_chunk(chunk_data)
    end
end

-- fade in/out sprites
local function fade()
    local is_fading_in = true
    local is_fading_out = true

    for i = 1, 1000 do
        -- fading in
        if is_fading_in and next(global.sprites_fading_in, global.sprites_fading_in_i) ~= nil then
            local r_id, value = next(global.sprites_fading_in, global.sprites_fading_in_i)
            local r = value.tint.r + 0.01
            local g = value.tint.g + 0.01
            local b = value.tint.b + 0.01
            local a = value.tint.a + 0.01

            local x = value.position.x
            local y = value.position.y
            
            if a >= 1 then
                rendering.set_color(r_id, {r=1, g=1,b=1, a=1})
                global.sprites_fading_in[r_id] = nil
            else
                rendering.set_color(r_id, {r=b, g=g,b=b, a=a})
                global.sprites_fading_in[r_id].tint = {r=b, g=g,b=b, a=a}
            end
            global.sprites_fading_in_i = r_id
        else
            is_fading_in = false
        end
        
        --fading out
        if is_fading_out and next(global.sprites_fading_out, global.sprites_fading_out_i) ~= nil then
            local r_id, value = next(global.sprites_fading_out, global.sprites_fading_out_i)
            
            local r = value.tint.r - 0.01
            local g = value.tint.g - 0.01
            local b = value.tint.b - 0.01
            local a = value.tint.a - 0.01

            local x = value.position.x
            local y = value.position.y

            if a <= 0 then
                rendering.set_color(r_id, {r=0, g=0,b=0, a=0})
                global.sprites_fading_out[r_id] = nil
                rendering.destroy(r_id)
            else
                rendering.set_color(r_id, {r=b, g=g,b=b, a=a})
                global.sprites_fading_out[r_id].tint = {r=b, g=g,b=b, a=a}
            end
            global.sprites_fading_out_i = r_id
        else
            is_fading_out = false
        end

        if is_fading_in == false and is_fading_out == false then
            break
        end
    end

    if next(global.sprites_fading_in, global.sprites_fading_in_i) == nil then global.sprites_fading_in_i = nil end
    if next(global.sprites_fading_out, global.sprites_fading_out_i) == nil then global.sprites_fading_out_i = nil end

    if next(global.sprites_fading_in, nil) == nil and next(global.sprites_fading_out, nil) == nil then
        global.is_fading = false
        global.is_checking = true
    end
end

-- adds chunk to all_chunks
local function add_chunk(chunk)
    local x = chunk.position.x
    local y = chunk.position.y
    local surface = chunk.surface


    -- is needed for RSO
    if global.is_setup == false then
        setup()
    end
    
    global.all_chunks[surface.index..":"..x..":"..y] = {position = {x=x,y=y}, surface=surface.index}
end

--deletes chunk from all_chunks and polluted_chunks
local function remove_chunks(data)
    local positions = data.positions
    local surface_i = data.surface_index

    for _ , position in pairs(positions) do
        local x = position.x
        local y = position.y
        local r_id = {}

        if global.polluted_chunks[surface_i..":"..x..":"..y] ~= nil then
            r_id = global.polluted_chunks[surface_i..":"..x..":"..y].r_id
        end

        for i ,v in pairs(r_id) do
            global.sprites_fading_in[r_id[i]] = nil
            global.sprites_fading_out[r_id[i]] = nil
            rendering.destroy(r_id[i])
        end

        global.all_chunks[surface_i..":"..x..":"..y] = nil
        global.polluted_chunks[surface_i..":"..x..":"..y] = nil
    end
end

-- wil call if a setting has been changed
local function setting_changed(data)
    if data.setting == "show-pollution-visuals" then
        local players = get_players_to_render_for()
        for i, chunk_data in pairs(global.polluted_chunks) do
            for x, r_id in pairs(chunk_data.r_id) do
                if #players == 0 then
                    rendering.set_visible(r_id, false)
                else
                    rendering.set_visible(r_id, true)
                    rendering.set_players(r_id, players)
                end
            end
        end
    else
        set_is_setup()
    end
end

-- function that triggers every tick
local function on_tick()
    if global.is_setup == false then
        --log("setup")
        setup()
    elseif not(global.is_checking) and not(global.is_fading) then
        --log("check polluted chunks")
        check_polluted_chunks()
    elseif global.is_checking then
        --log("check all chunks")
        check_all_chunks()
    elseif global.is_fading then
        --log("fade sprites")
        fade()
    end
end

local function remove_surface(data) 
    local remove_data = {}
    remove_data.positions = {}
    remove_data.surface_index = data.surface_index
    for i ,chunk_data in pairs(global.all_chunks) do
        if chunk_data.surface == data.surface_index then
            remove_data.positions[#remove_data.positions+1] = chunk_data.position
        end
    end
    if remove_data.positions ~= {} then
        remove_chunks(remove_data)
    end
end

-------------------------------------------------------------------------
-- EVENTS
-------------------------------------------------------------------------
script.on_event(defines.events.on_chunk_deleted, remove_chunks)
script.on_event(defines.events.on_chunk_generated, add_chunk)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_runtime_mod_setting_changed, setting_changed)
script.on_event(defines.events.on_surface_deleted, remove_surface)
script.on_configuration_changed(set_is_setup)
script.on_init(set_is_setup)