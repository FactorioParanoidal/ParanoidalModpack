local bp_base_name = "Belt Brush"

local bp_format = "^" .. bp_base_name .. " %((%a+)%) %[(%d+)%]"

local bp_name_only_format = "^" .. bp_base_name .. " %((%a+)%)"
local bp_balancer_format = "^" .. bp_base_name .. " %(Balancer%) %[(%d+)->(%d+)%]"

local bp_line_name = "Line"
local bp_corner_rh_name = "Right"
local bp_corner_lh_name = "Left"
local bp_balancer_name = "Balancer"

local bb_kind = {
    line = 'line',
    corner_rh = 'corner_rh',
    corner_lh = 'corner_lh',
    balancer = 'balancer',
}

local bbkind_name_rev = {
    [bp_line_name] = bb_kind.line,
    [bp_corner_lh_name] = bb_kind.corner_lh,
    [bp_corner_rh_name] = bb_kind.corner_rh,
    [bp_balancer_name] = bb_kind.balancer,
}

local bbkind_name = {
    [bb_kind.line] = bp_line_name,
    [bb_kind.corner_lh] = bp_corner_lh_name,
    [bb_kind.corner_rh] = bp_corner_rh_name,
    [bb_kind.balancer] = bp_balancer_name,
}

local balancers = require("balancers")

--[[

example bb_settings table

bb_settings = {
    entity_name = 'transport-belt',
    width = 8,
    kind = 'line'
}

--]]

local function decode_bb_settings(bpstack)
    local label = bpstack.label
    local _, _, kind = string.find(label, bp_name_only_format)
    
    local bpes = bpstack.get_blueprint_entities()

    local belt = nil
    for i = 1,#bpes do
        local bpe = bpes[i]
        if prototypes.entity[bpe.name] ~= nil and prototypes.entity[bpe.name].type == 'transport-belt' then
            belt = prototypes.entity[bpe.name]
            break
        end
    end

    if belt == nil then return nil end

    local bbs = {
        entity_name = belt.name,
        kind = bbkind_name_rev[kind],
    }

    if bbs.kind == bb_kind.balancer then
        local _, _, input_width, output_width = string.find(label, bp_balancer_format)
        bbs.input_width = tonumber(input_width)
        bbs.output_width = tonumber(output_width)
        bbs.width = input_width
    else
        local _, _, _, width = string.find(label, bp_format);
        bbs.width = tonumber(width)
    end

    if bpstack.get_blueprint_entities()[1].quality ~= nil then
        bbs.quality = bpstack.get_blueprint_entities()[1].quality
    else
        bbs.quality = nil
    end

    return bbs
end

local function write_label(bb_settings)
    return string.format(bp_base_name .. " (%s) [%d]", bbkind_name[bb_settings.kind], bb_settings.width)
end

local function is_blueprint_bb(label)
    if label ~= nil and string.find(label, '^' .. bp_base_name) then
        return true
    else
        return false
    end
end

local function is_player_holding_bbbp(player)
    if player.cursor_stack.valid_for_read and player.cursor_stack.is_blueprint then
        if is_blueprint_bb(player.cursor_stack.label) then
            return true
        end
    end

    return false
end

local function isturn(x, y)
    return y <= x
end

local function genblueprintstring(blueprint_table)
    local json = helpers.table_to_json(blueprint_table)
    log(json)
    return '0'..helpers.encode_string(json)
end

local function generate_entity_bp(entity_name, number, position, direction, quality)
    local ebp = {
        entity_number = number,
        name = entity_name,
        position = position,
    }

    if direction ~= nil then
        ebp.direction = direction
    end

    log(quality)
    if quality ~= nil then
        ebp.quality = quality
    end

    return ebp
end

local function generate_entities_line(entity_name, width, quality)
    local tbl = {}
    for x = 1, width do
        table.insert(tbl, generate_entity_bp(entity_name, x, {
            x = x,
            y = 0
        }, nil, quality));
    end
    return tbl
end

local function generate_bp_entities(entities, icon_signal, label, quality)
    local signal_struct = {
        name = icon_signal
    }

    if quality ~= nil then
        signal_struct.quality = quality
    end

    return {
        blueprint = {
            icons = {
                {
                    signal = signal_struct,
                    index = 1
                }
            },
            entities = entities,
            item = 'blueprint',
            label = label,
            version = 562949955256321, -- i dont know if this is actually what I want here but I don't know what this is for and this is the same in all my blueprints
        }
    }
end

local function generate_line_brush_bp(entity_name, width, quality)
    return generate_bp_entities(generate_entities_line(entity_name, width, quality), entity_name, write_label({
        kind = bb_kind.line,
        width = width
    }), quality)
end

local function generate_corner_rh_brush_bp(entity_name, width, quality)
    local entities = {}
    for x = 1, width do
        for y = 1, width do
            if isturn(x, y) then
                table.insert(entities, generate_entity_bp(entity_name, (x - 1) * width + y, {
                    x = x,
                    y = y,
                }, defines.direction.east, quality))
            else
                table.insert(entities, generate_entity_bp(entity_name, (x - 1) * width + y, {
                    x = x,
                    y = y,
                }, nil, quality))
            end
        end
    end

    return generate_bp_entities(entities, entity_name, write_label({
        kind = bb_kind.corner_rh,
        width = width,
    }), quality)
end

local function generate_corner_lh_brush_bp(entity_name, width, quality)
    local entities = {}
    for x = 1, width do
        for y = 1, width do
            if isturn(1 + width - x, y) then
                table.insert(entities, generate_entity_bp(entity_name, (x - 1) * width + y, {
                    x = x,
                    y = y,
                }, defines.direction.west, quality))
            else
                table.insert(entities, generate_entity_bp(entity_name, (x - 1) * width + y, {
                    x = x,
                    y = y,
                }, nil, quality))
            end
        end
    end

    return generate_bp_entities(entities, entity_name, write_label({
        kind = bb_kind.corner_lh,
        width = width,
    }), quality)
end

local function set_player_cursor_bp(player, bptable)
    player.clear_cursor()
    local bpstr = genblueprintstring(bptable)
    player.cursor_stack.import_stack(bpstr)
    player.cursor_stack_temporary = true
end

local function set_player_cursor_bp_stack(player, bpstack)
    player.clear_cursor()
    player.cursor_stack.set_stack(bpstack)
    player.cursor_stack_temporary = true
end

local function is_player_holding_belt(player)
    return player.cursor_stack.valid_for_read and player.cursor_stack.prototype.place_result ~= nil and player.cursor_stack.prototype.place_result.type == 'transport-belt'
end

local function is_player_holding_belt_ghost(player)
    return player.cursor_ghost ~= nil and player.cursor_ghost.name.place_result ~= nil and player.cursor_ghost.name.place_result.type == 'transport-belt'
end


local function upgrade_to_belttype(bpe, belttype, bquality)    
    local bpe_entity = prototypes.entity[bpe.name]
    if bpe_entity ~= nil then
        if bpe_entity.type == "transport-belt" then
            bpe.name = belttype.name
        elseif bpe_entity.type == "underground-belt" then
            bpe.name = belttype.related_underground_belt.name
        elseif bpe_entity.type == "splitter" then
            if balancers.splitter_mapping[belttype.name] ~= nil then
                bpe.name = balancers.splitter_mapping[belttype.name]
            end
        end
    end

    bpe.quality = bquality

    return bpe
end

local function make_balancer_bp_from(bpsettings, bpstr)
    local dummy_inv = game.create_inventory(1)
    dummy_inv[1].import_stack(bpstr)
    local bpes = dummy_inv[1].get_blueprint_entities()
    if bpes == nil then dummy_inv.destroy(); return false, nil, nil end

    local belt = prototypes.entity[bpsettings.entity_name]
    if belt == nil then dummy_inv.destroy(); return false, nil, nil end

    for i = 1,#bpes do
        bpes[i] = upgrade_to_belttype(bpes[i], belt, bpsettings.quality)
    end

    dummy_inv[1].set_blueprint_entities(bpes)

    local splitter = balancers.splitter_mapping[bpsettings.entity_name]

    dummy_inv[1].preview_icons = { { index = 1, signal = { name = splitter or bpsettings.entity_name }} }

    return true, dummy_inv[1], dummy_inv
end

local function player_cycle_bp(player)
    if is_player_holding_bbbp(player) then
        local bb_settings = decode_bb_settings(player.cursor_stack)
        if bb_settings == nil then return end
        if bb_settings.kind == bb_kind.line then
            local bptable = generate_corner_rh_brush_bp(bb_settings.entity_name, bb_settings.width, bb_settings.quality)
            set_player_cursor_bp(player, bptable)
        elseif bb_settings.kind == bb_kind.corner_rh then
            local bptable = generate_corner_lh_brush_bp(bb_settings.entity_name, bb_settings.width, bb_settings.quality)
            set_player_cursor_bp(player, bptable)
        else
            local bptable = generate_line_brush_bp(bb_settings.entity_name, bb_settings.width, bb_settings.quality)
            set_player_cursor_bp(player, bptable)
        end
    end
end

local function player_cycle_bp_rev(player)
    if is_player_holding_bbbp(player) then
        local bb_settings = decode_bb_settings(player.cursor_stack)
        if bb_settings == nil then return end
        if bb_settings.kind == bb_kind.corner_lh then
            local bptable = generate_corner_rh_brush_bp(bb_settings.entity_name, bb_settings.width, bb_settings.quality)
            set_player_cursor_bp(player, bptable)
        elseif bb_settings.kind == bb_kind.line then
            local bptable = generate_corner_lh_brush_bp(bb_settings.entity_name, bb_settings.width, bb_settings.quality)
            set_player_cursor_bp(player, bptable)
        else
            local bptable = generate_line_brush_bp(bb_settings.entity_name, bb_settings.width, bb_settings.quality)
            set_player_cursor_bp(player, bptable)
        end
    end
end

local function player_set_balancer_bp(player, bb_settings)
    local bbpstr = balancers.get_balancer_bpstr(bb_settings.input_width, bb_settings.output_width)
    if bbpstr == nil then
    else
        success, bbps, dinv = make_balancer_bp_from({
            entity_name = bb_settings.entity_name,
            quality = bb_settings.quality
        }, bbpstr)

        if success then
            set_player_cursor_bp_stack(player, bbps);
            dinv.destroy()
        else
        end
    end
end

local function player_cycle_down_beltbrush(player)
    if is_player_holding_bbbp(player) then
        local bb_settings = decode_bb_settings(player.cursor_stack)
        if bb_settings == nil then return end
        
        if bb_settings.kind == bb_kind.balancer then
            if bb_settings.input_width == 1 and bb_settings.output_width > 1 then
                -- noop
            elseif (bb_settings.input_width == 2 and bb_settings.output_width == 1) and bb_settings.output_width > 1 then
                player.clear_cursor()
                player.cursor_stack_temporary = false
                player.pipette_entity({name=bb_settings.entity_name, quality=bb_settings.quality})
            elseif bb_settings.output_width < 1 or (bb_settings.input_width < 2 and bb_settings.output_width < 1) then
                player.clear_cursor()
            else
                -- local bbpstr = balancers.get_balancer_bpstr(bb_settings.input_width - 1, bb_settings.output_width)
                -- if bbpstr == nil then
                -- else
                --     success, bbps, dinv = make_balancer_bp_from({
                --         entity_name = bb_settings.entity_name,
                --         quality = bb_settings.quality
                --     }, bbpstr)
    
                --     if success then
                --         set_player_cursor_bp_stack(player, bbps);
                --         dinv.destroy()
                --     else
                --     end
                -- end

                player_set_balancer_bp(player, {input_width = bb_settings.input_width - 1, output_width = bb_settings.output_width, entity_name = bb_settings.entity_name, quality = bb_settings.quality})
            end
        else

            if bb_settings.width > 2 then
                if bb_settings.kind == bb_kind.line then
                    set_player_cursor_bp(player, generate_line_brush_bp(bb_settings.entity_name, bb_settings.width - 1, bb_settings.quality))
                elseif bb_settings.kind == bb_kind.corner_lh then
                    set_player_cursor_bp(player, generate_corner_lh_brush_bp(bb_settings.entity_name, bb_settings.width - 1, bb_settings.quality))
                else
                    set_player_cursor_bp(player, generate_corner_rh_brush_bp(bb_settings.entity_name, bb_settings.width - 1, bb_settings.quality))
                end
            elseif bb_settings.width == 2 then -- become belt
                player.clear_cursor()
                player.cursor_stack_temporary = false
                player.pipette_entity({name=bb_settings.entity_name, quality=bb_settings.quality})
            else
                player.clear_cursor()
            end
        end
    end
end

local function player_cycle_up_beltbrush(player)
    if is_player_holding_bbbp(player) then
        local bb_settings = decode_bb_settings(player.cursor_stack)
        if bb_settings == nil then return end

        if bb_settings.kind == bb_kind.line then
            set_player_cursor_bp(player, generate_line_brush_bp(bb_settings.entity_name, bb_settings.width + 1, bb_settings.quality))
        elseif bb_settings.kind == bb_kind.corner_lh then
            set_player_cursor_bp(player, generate_corner_lh_brush_bp(bb_settings.entity_name, bb_settings.width + 1, bb_settings.quality))
        elseif bb_settings.kind == bb_kind.balancer then
            -- local bbpstr = balancers.get_balancer_bpstr(bb_settings.input_width + 1, bb_settings.output_width)
            -- if bbpstr == nil then
            -- else
            --     success, bbps, dinv = make_balancer_bp_from({
            --         entity_name = bb_settings.entity_name,
            --         quality = bb_settings.quality
            --     }, bbpstr)

            --     if success then
            --         set_player_cursor_bp_stack(player, bbps);
            --         dinv.destroy()
            --     else
            --     end
            -- end

            player_set_balancer_bp(player, {input_width = bb_settings.input_width + 1, output_width = bb_settings.output_width, entity_name = bb_settings.entity_name, quality = bb_settings.quality})
        else
            set_player_cursor_bp(player, generate_corner_rh_brush_bp(bb_settings.entity_name, bb_settings.width + 1, bb_settings.quality))
        end
    elseif is_player_holding_belt(player) then
        set_player_cursor_bp(player, generate_line_brush_bp(player.cursor_stack.prototype.place_result.name, 2, player.cursor_stack.quality.name))
    elseif is_player_holding_belt_ghost(player) then
        set_player_cursor_bp(player, generate_line_brush_bp(player.cursor_ghost.name.name, 2, player.cursor_ghost.quality.name))
    else
    end
end

local function player_cycle_balancers(player)
    if is_player_holding_bbbp(player) then
        local bb_settings = decode_bb_settings(player.cursor_stack)
        if bb_settings == nil then return end

        if bb_settings.kind == bb_kind.balancer then
            local next_ow = balancers.next_ow(bb_settings.input_width, bb_settings.output_width)
            if next_ow == 0 then
                if bb_settings.input_width == 1 then
                    player.clear_cursor()
                    player.cursor_stack_temporary = false
                    player.pipette_entity({name=bb_settings.entity_name, quality=bb_settings.quality})
                else
                    set_player_cursor_bp(player, generate_line_brush_bp(bb_settings.entity_name, bb_settings.width, bb_settings.quality))
                end
            else
                player_set_balancer_bp(player, {input_width = bb_settings.input_width, output_width = next_ow, entity_name = bb_settings.entity_name, quality = bb_settings.quality})
            end
        else
            if balancers.balancer_availability[bb_settings.width] ~= nil then
                player_set_balancer_bp(player, {input_width = bb_settings.width, output_width = balancers.balancer_availability[bb_settings.width][1], entity_name = bb_settings.entity_name, quality = bb_settings.quality})
            end
        end
    elseif is_player_holding_belt(player) then
        if balancers.balancer_availability[1] ~= nil then
            player_set_balancer_bp(player, {input_width = 1, output_width = balancers.balancer_availability[1][1], entity_name = player.cursor_stack.prototype.place_result.name, quality = player.cursor_stack.quality.name})
        end
    elseif is_player_holding_belt_ghost(player) then
        player_set_balancer_bp(player, {input_width = 1, output_width = balancers.balancer_availability[1][1], entity_name = player.cursor_ghost.name.name, quality = player.cursor_ghost.quality.name})
    end
end

local function player_cycle_balancers_rev(player)
    if is_player_holding_bbbp(player) then
        local bb_settings = decode_bb_settings(player.cursor_stack)
        if bb_settings == nil then return end

        if bb_settings.kind == bb_kind.balancer then
            local prev_ow = balancers.prev_ow(bb_settings.input_width, bb_settings.output_width)
            if prev_ow == 0 then
                if bb_settings.input_width == 1 then
                    player.clear_cursor()
                    player.cursor_stack_temporary = false
                    player.pipette_entity({name=bb_settings.entity_name, quality=bb_settings.quality})
                else
                    set_player_cursor_bp(player, generate_line_brush_bp(bb_settings.entity_name, bb_settings.width, bb_settings.quality))
                end
            else
                player_set_balancer_bp(player, {input_width = bb_settings.input_width, output_width = prev_ow, entity_name = bb_settings.entity_name, quality = bb_settings.quality})
            end
        else
            if balancers.balancer_availability[bb_settings.width] ~= nil then
                player_set_balancer_bp(player, {input_width = bb_settings.width, output_width = balancers.balancer_availability[bb_settings.width][#balancers.balancer_availability[bb_settings.width]-1], entity_name = bb_settings.entity_name, quality = bb_settings.quality})
            end
        end
    elseif is_player_holding_belt(player) then
        if balancers.balancer_availability[1] ~= nil then
            player_set_balancer_bp(player, {input_width = 1, output_width = balancers.balancer_availability[1][#balancers.balancer_availability[1]-1], entity_name = player.cursor_stack.prototype.place_result.name, quality = player.cursor_stack.quality.name})
        end
    elseif is_player_holding_belt_ghost(player) then
        player_set_balancer_bp(player, {input_width = 1, output_width = balancers.balancer_availability[1][#balancers.balancer_availability[1]-1], entity_name = player.cursor_ghost.name.name, quality = player.cursor_ghost.quality.name})
    end
end

script.on_event("beltbrush-cycle-corners", function(event)
    player_cycle_bp(game.players[event.player_index])
end)

script.on_event("beltbrush-cycle-corners-rev", function(event)
    player_cycle_bp_rev(game.players[event.player_index])
end)

script.on_event("beltbrush-line-longer", function(event)
    player_cycle_up_beltbrush(game.players[event.player_index])
end)

script.on_event("beltbrush-line-shorter", function(event)
    player_cycle_down_beltbrush(game.players[event.player_index])
end)

script.on_event("beltbrush-cycle-balancers", function(event)
    player_cycle_balancers(game.players[event.player_index])
end)

script.on_event("beltbrush-cycle-balancers-rev", function(event)
    player_cycle_balancers_rev(game.players[event.player_index])
end)

local function in_build_range(player, entity)
    local build_range2 = player.build_distance * player.build_distance
    local bx = player.physical_position.x - entity.position.x
    local by = player.physical_position.y - entity.position.y
    local entity_distance2 = bx * bx + by * by
    return entity_distance2 <= build_range2
end

script.on_event(defines.events.on_built_entity, function(event)
    local player = game.players[event.player_index]
    if player == nil then return end
    if event.entity ~= nil and event.entity.surface == player.physical_surface and event.entity.type == "entity-ghost" and is_player_holding_bbbp(player) and in_build_range(player, event.entity) then
        if event.entity.ghost_prototype ~= nil and event.entity.ghost_prototype.items_to_place_this ~= nil then
            local place = event.entity.ghost_prototype.items_to_place_this[1]
            if event.entity.quality ~= nil then
                place.quality = event.entity.quality.name
            end
            if place ~= nil then
                if player.get_main_inventory() ~= nil and player.get_main_inventory().get_item_count({name=place.name, quality=place.quality}) >= place.count then
                    player.get_main_inventory().remove(place)
                    event.entity.silent_revive()
                end
            end
        end
    end
end)


