script.on_init(function()
    storage.train_loaders = storage.train_loaders or {}
    storage.train_stop_gaps = storage.train_stop_gaps or {}
    storage.loader_ui_count = storage.loader_ui_count or 5
end)

script.on_configuration_changed(function()
    storage.train_loaders = storage.train_loaders or {}
    storage.train_stop_gaps = storage.train_stop_gaps or {}
    storage.loader_ui_count = storage.loader_ui_count or 5
end)

local function balance_loaders_in_group(train_stop_id, surface)
    local group_loaders = {}
    local loader_inventories = {}
    local total_items = {}

    for loader_id, data in pairs(storage.train_loaders) do
        if data.train_stop_id == train_stop_id and not data.loader_state then
            local loader = game.get_entity_by_unit_number(loader_id)
            local loader_inv = loader.get_inventory(defines.inventory.chest)
            if loader and loader.valid then
                local inventory = loader.get_inventory(defines.inventory.chest)
                table.insert(group_loaders, loader)
                loader_inventories[loader] = inventory
                
                -- Count items in this loader
                for item_name, name in pairs(inventory.get_contents()) do
                    total_items[name.name] = (total_items[name.name] or 0) + name.count
                    loader_inv.remove{name = name.name, count = name.count}
                end
            end
        end
    end

    if #group_loaders == 0 then return end
    -- game.print("going to balance this many items: " .. table_size(total_items) .. " with this many loaders: " .. #group_loaders)

    local items_per_loader = {} -- figure out how much each loader should get
    for item_name, count in pairs(total_items) do
        items_per_loader[item_name] = math.floor(count / #group_loaders)
    end

    if items_per_loader then end
    for _, loader in pairs(group_loaders) do
        local inventory = loader_inventories[loader]
        for item_name, count in pairs(items_per_loader) do
            if count == 0 then 
                break
            else 
            local inserted_count = inventory.insert{name = item_name, count = count}
            if inserted_count > 0 then
                total_items[item_name] = total_items[item_name] - inserted_count
            end
            end
        end
    end
end
local function process_loader(loader_id, loader)
    if not loader.valid then
        storage.train_loaders[loader_id] = nil
        return
    end

    local MAX_STACKS_PER_TICK = settings.startup["load-speed-experimental-limit"].value and 4 or nil

    local wagon = loader.surface.find_entities_filtered{
        position = loader.position,
        type = "cargo-wagon",
        radius = 1,
        limit = 1
    }[1]

    if wagon and (wagon.train.state == defines.train_state.wait_station or 
                  wagon.train.state == defines.train_state.manual_control_stop) then
        local loader_inventory = loader.get_inventory(defines.inventory.chest)
        local wagon_inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
        
        -- Check the checkbox state for this specific loader
        local is_checked = storage.train_loaders[loader_id] and storage.train_loaders[loader_id].loader_state
        local stacks_moved = 0

        local source_inventory = is_checked and wagon_inventory or loader_inventory
        local target_inventory = is_checked and loader_inventory or wagon_inventory

        for _, item in pairs(source_inventory.get_contents()) do
            -- Only break if MAX_STACKS_PER_TICK is specified and reached
            if MAX_STACKS_PER_TICK and stacks_moved >= MAX_STACKS_PER_TICK then 
                break 
            end
            
            -- Only calculate stacks if MAX_STACKS_PER_TICK is specified
            local stacks_to_move, items_to_move
            if MAX_STACKS_PER_TICK then
                local remaining_stacks = MAX_STACKS_PER_TICK - stacks_moved
                local stack_size = prototypes.item[item.name].stack_size
                stacks_to_move = math.min(math.ceil(item.count / stack_size), remaining_stacks)
                items_to_move = stacks_to_move * stack_size
            else
                -- If no stack limit, move all items
                stacks_to_move = math.ceil(item.count / prototypes.item[item.name].stack_size)
                items_to_move = item.count
            end
            
            local inserted_count = target_inventory.insert({
                name = item.name, 
                count = math.min(items_to_move, item.count),
                quality = item.quality
            })
            
            if inserted_count > 0 then 
                source_inventory.remove({name = item.name, count = inserted_count, quality = item.quality})
                
                -- Only update stacks_moved if MAX_STACKS_PER_TICK is specified
                if MAX_STACKS_PER_TICK then
                    stacks_moved = stacks_moved + math.ceil(inserted_count / prototypes.item[item.name].stack_size)
                end
            end
        end
    end
end

script.on_nth_tick(60, function(event) -- this is not terrible on performance because of get_entity_by_unit_number(?)
    for loader_id, data in pairs(storage.train_loaders) do
        local loader = game.get_entity_by_unit_number(loader_id)
        if loader and loader.name == 'train-loader' then
            process_loader(loader_id, loader)
        end
    end
end)

local experimental_balancing = settings.startup["experimental-balancing"].value

script.on_event(defines.events.on_train_changed_state, function(event)
    local train = event.train
    
    if train.state == defines.train_state.wait_station or train.state == defines.train_state.manual_control_stop then
        -- Ensure train has a valid station
        if not (train.station and train.station.valid) then return end
        
        local current_stop_id = train.station.unit_number
        
        -- Single pass through loaders, only processing relevant ones
        for loader_id, data in pairs(storage.train_loaders) do
            -- Only process loaders matching current stop
            if data.train_stop_id == current_stop_id then
                local loader = game.get_entity_by_unit_number(loader_id)
                if loader and loader.name == 'train-loader' then
                    if experimental_balancing then
                        balance_loaders_in_group(data.train_stop_id, loader.surface)
                    end
                    -- process_loader(loader_id, loader)
                end
            end
        end
    end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    local element = event.element
    if not element or not element.valid then return end

    -- Handle global loader checkboxes (train stop GUI)
    if element.name:match("^loader%-checkbox%-%d+$") then
        local loader_count = element.tags.loader_count
        
        -- Ensure global storage exists and update state
        storage.global_loader_states = storage.global_loader_states or {}
        storage.global_loader_states[loader_count] = element.state

        -- Update all matching checkboxes in any open GUIs to maintain sync
        for _, player in pairs(game.players) do
            local frame = player.gui.relative["loader-buttons-frame"]
            if frame then
                local checkbox = frame["loader-row-" .. loader_count]
                if checkbox and checkbox.valid then
                    local target_checkbox = checkbox["loader-checkbox-" .. loader_count]
                    if target_checkbox and target_checkbox.valid and target_checkbox ~= element then
                        target_checkbox.state = element.state
                    end
                end
            end
        end
        return
    end

    -- Handle individual loader state toggles
    if element.name == "loader-state" then
        local player = game.players[event.player_index]
        local loader_id = player.opened and player.opened.unit_number

        if loader_id and storage.train_loaders[loader_id] then
            storage.train_loaders[loader_id].loader_state = element.state
        end
    end
end)


local function create_train_stop_gui(player, train_stop_id)
    local gui = player.gui.relative

    if gui["loader-buttons-frame"] then -- clean up existing GUI elements
        gui["loader-buttons-frame"].destroy()
    end

    local frame = gui.add{ -- create a frame to hold loader buttons
        type = "frame",
        name = "loader-buttons-frame",
        direction = "vertical",
        anchor = {
            gui = defines.relative_gui_type.train_stop_gui,
            position = defines.relative_gui_position.left
        }
    }
    frame.style.left_padding = 10

    local title = frame.add{type = "label", caption = "Loader control" }
    title.style.font = "heading-2"
    title.style.font_color = {r = 0.98, g = 0.9, b = 0.75}
    title.style.top_margin = -1
    local button_frame = frame.add{
        type = "flow",
        direction = "horizontal",
    }
    local minus = button_frame.add{type = "button", caption = "-", name = "minus"}
    local plus = button_frame.add{type = "button", caption = "+", name = "plus"}
    minus.style.maximal_width = 52
    plus.style.maximal_width = 52

    frame.add{type = "button", name = "set-all-to-load", caption = "All Load"}
    frame.add{type = "button", name = "set-all-to-unload", caption = "All Unload"}

    -- load.style.maximal_width = 52
    -- load.style.font = "default"
    -- add to the frame a label that says "check for loader"
    -- frame.add{
    --     type = "line",
    --     name = "example_line",
    --     direction = "horizontal" -- Can also be "vertical"
    -- }
    frame.add{type = "label", caption = "Check for loader"}.style.font = "default-bold"

    -- Initialize loader_checked_states[train_stop_id] if not already set
    storage.loader_checked_states = storage.loader_checked_states or {}
    storage.loader_checked_states[train_stop_id] = storage.loader_checked_states[train_stop_id] or {}

    for i = 1, storage.loader_ui_count do
        local row = frame.add{type = "flow", direction = "horizontal", name = "loader-row-" .. i}

        -- Numbered button
        row.add{
            type = "label",
            
            name = "loader-button-" .. i,
            caption = i .. "",
            tags = {train_stop_id = train_stop_id, loader_count = i}
        }.style.font = "default-bold"

        function get_loader_state(i)
            if not storage.global_loader_states then
                storage.global_loader_states = {}
            end
            if storage.global_loader_states[i] == nil then
                -- if i equals 1, state is false, else it's true
                if i == 1 then
                    storage.global_loader_states[i] = false
                else
                    storage.global_loader_states[i] = true
                end
            end
            return storage.global_loader_states[i]
        end
        row.add{
            type = "checkbox",
        name = "loader-checkbox-" .. i,
            -- state equals whatever is in storage, else true 
            state = get_loader_state(i),
            tags = {train_stop_id = train_stop_id, loader_count = i},
            -- style = {type = "checkbox_style", margin_top = "5"}
        }.style.top_margin = "3"
        -- if i equals one, add a label after the checkbox that says "station"
        if i == 1 then
            -- row.add{type = "label", caption = "(train station)"}
            -- add a small image of the train station icon
            row.add{type = "sprite", sprite = "entity/train-stop"}
        else
            row.add{type = "sprite", sprite = "entity/cargo-wagon"}
        end
    end
    local button = frame.add{
        type = "button",
        name = "loader-button-" .. storage.loader_ui_count,
        caption =  "Place loaders", -- .. storage.loader_ui_count,
        tags = {train_stop_id = train_stop_id, loader_count = storage.loader_ui_count}
    }
    -- if train_loader_recipe_enabled, show "place ghosts" button too
    if settings.startup["train_loader_recipe_enabled"].value then
        frame.add{
            type = "button",
            name = "ghost-button-" .. storage.loader_ui_count,
            caption =  "Place ghosts", -- .. storage.loader_ui_count,
            tags = {train_stop_id = train_stop_id, loader_count = storage.loader_ui_count}
        }
    end
end


script.on_event(defines.events.on_gui_opened, function(event)
    if event.gui_type == defines.gui_type.entity and event.entity.name == "train-stop" then
        local player = game.players[event.player_index]
        create_train_stop_gui(player, event.entity.unit_number)
    end

    -- this might not be efficient, could update later 
    if event.gui_type == defines.gui_type.entity and event.entity.type == "container" then
        local player = game.players[event.player_index]
        local gui = player.gui.relative
        if gui["toggle-frame"] then gui["toggle-frame"].destroy() end
    end

    if event.gui_type == defines.gui_type.entity and event.entity.name == "train-loader" then
        local player = game.players[event.player_index]
        local gui = player.gui.relative
        local loader_id = event.entity.unit_number
        if gui["toggle-frame"] then gui["toggle-frame"].destroy() end -- Clear any existing GUI elements

        -- ensure data exists for this loader
        storage.train_loaders[loader_id] = storage.train_loaders[loader_id] or { loader_state = false }


        local frame = gui.add{
            type = "frame",
            name = "toggle-frame",
            direction = "vertical",
            anchor = {
                gui = defines.relative_gui_type.container_gui,
                position = defines.relative_gui_position.right
            }
        }

        frame.add{type = "label",caption = "Switch Loader Modes (unchecked is loader)"}
        
        local loader_state = frame.add{
            type = "checkbox",
            name = "loader-state",
            caption = "Check for unloader mode",
            state = storage.train_loaders[loader_id].loader_state,
        }

    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.gui_type == defines.gui_type.entity then
        local player = game.players[event.player_index]
        local gui = player.gui.relative
        if gui["toggle-frame"] then gui["toggle-frame"].destroy() end
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "gap-style-normal" or event.element.name == "gap-style-compact" or event.element.name == "gap-style-extra" then
        local train_stop_id = event.element.tags.train_stop_id
        local gap_style = event.element.tags.gap_style
        storage.train_stop_gaps[train_stop_id] = gap_style
    -- handle loader count buttons
    elseif string.match(event.element.name, "loader%-button%-") then
        local player = game.players[event.player_index]
        local train_stop_id = event.element.tags.train_stop_id
        local loader_count = event.element.tags.loader_count
        local surface = player.surface

        for _, entity in pairs(surface.find_entities_filtered{type = "train-stop"}) do
            if entity.unit_number == train_stop_id then
                clear_train_stop_loaders(train_stop_id, surface, entity)
                if loader_count == 0 then 
                    if remote.interfaces["cybersyn"] then 
                        local cyber_combinators = surface.find_entities_filtered{name = "cybersyn-combinator", position = entity.position, radius = 2.2}
                        if cyber_combinators[1] then 
                            local stop_id = remote.call("cybersyn", "get_id_from_stop", entity)
                            if stop_id then 
                                remote.call("cybersyn", "reset_stop_layout", stop_id, nil, true)
                            end
                        end
                    end
                    return -- if loader count is 0, we're done
                end 
                local gap_style = storage.train_stop_gaps[train_stop_id] or "normal"
                local loader_positions = calculate_loader_positions(entity, loader_count, gap_style)
                
                local real_count = 0
                local ghost_count = 0
                
                -- if we couldn't find enough valid positions
                if #loader_positions < loader_count then
                    game.print("Warning: Only found " .. #loader_positions .. " valid positions out of " .. loader_count .. " requested due to missing rails or filled loaders")
                end
                
                for _, pos_data in pairs(loader_positions) do
                    local created_entity
                    if not pos_data.checked_for_skipping then
                        -- Skip entirely if position marked for skipping
                        goto continue
                    end
                    
                    if pos_data.can_place_real then
                        -- Can place real loader here
                        -- if train_loader_recipe_enabled is true, create a ghost entity, else create a real entity
                        
                        created_entity = surface.create_entity{
                            name = "train-loader", 
                            position = pos_data.position, 
                            force = entity.force
                        }
                        real_count = real_count + 1
                        
                        storage.train_loaders[created_entity.unit_number] = {
                            loader_state = false, 
                            train_stop_id = train_stop_id
                        }
                
                        rendering.draw_sprite{
                            sprite = "custom-silo-sprite",
                            target = created_entity,
                            surface = surface,
                            render_layer = "object"
                        }
                
                        if remote.interfaces["cybersyn"] then 
                            local my_inserter = surface.create_entity{
                                name = "invisible-inserter", 
                                position = {x = pos_data.position.x, y = pos_data.position.y - 2}, 
                                force = entity.force
                            }
                        end
                    else
                        -- Position is obstructed, place ghost
                        created_entity = surface.create_entity{
                            name = "entity-ghost", 
                            inner_name = "train-loader", 
                            position = pos_data.position, 
                            force = entity.force, 
                            expires = false
                        }
                        ghost_count = ghost_count + 1
                    end
                    
                    ::continue:: -- ???
                end
                
                if ghost_count > 0 then
                    game.print(string.format(
                        "Placed %d loader(s) and %d ghost(s). Clear obstructions to upgrade ghosts to real loaders.", 
                        real_count, 
                        ghost_count
                    ))
                end
                
                if remote.interfaces["cybersyn"] then 
                    local cyber_combinators = surface.find_entities_filtered{
                        name = "cybersyn-combinator", 
                        position = entity.position, 
                        radius = 2.2
                    }
                    if cyber_combinators[1] then
                        local stop_id = remote.call("cybersyn", "get_id_from_stop", entity)
                        if stop_id then 
                            remote.call("cybersyn", "reset_stop_layout", stop_id, nil, true)
                        end
                    end
                end
                break
            end
        end
    
    elseif string.match(event.element.name, "ghost%-button%-") then 
        local player = game.players[event.player_index]
        local train_stop_id = event.element.tags.train_stop_id
        local loader_count = event.element.tags.loader_count
        local surface = player.surface
    
        for _, entity in pairs(surface.find_entities_filtered{type = "train-stop"}) do
            if entity.unit_number == train_stop_id then
                local gap_style = storage.train_stop_gaps[train_stop_id] or "normal"
                local loader_positions = calculate_loader_positions(entity, loader_count, gap_style)
                
                local ghost_count = 0
                
                -- if we couldn't find enough valid positions
                if #loader_positions < loader_count then
                    game.print("Warning: Only found " .. #loader_positions .. " valid positions out of " .. loader_count .. " requested due to missing rails or filled loaders")
                end
                
                for _, pos_data in pairs(loader_positions) do
                    if not pos_data.checked_for_skipping then
                        -- Skip entirely if position marked for skipping
                        goto continue
                    end
                    
                    -- Position is obstructed, place ghost
                    surface.create_entity{
                        name = "entity-ghost", 
                        inner_name = "train-loader", 
                        position = pos_data.position, 
                        force = entity.force, 
                        expires = false
                    }
                    ghost_count = ghost_count + 1
                    
                    ::continue::
                end
                
                if ghost_count > 0 then
                    game.print(string.format(
                        "Placed %d ghost loader(s). Clear obstructions to upgrade ghosts to real loaders.", 
                        ghost_count
                    ))
                end
                break
            end
        end

    elseif event.element.name == "set-all-to-unload" then -- handle "Set All to unload" button click
        local player = game.players[event.player_index]
        local train_stop_id = player.opened.unit_number

        for loader_id, data in pairs(storage.train_loaders) do -- set all related loaders to true
            if data.train_stop_id == train_stop_id then
                storage.train_loaders[loader_id].loader_state = true
            end
        end
    elseif event.element.name == "set-all-to-load" then -- handle "Set All to load" button click
        local player = game.players[event.player_index] 
        local train_stop_id = player.opened.unit_number

        for loader_id, data in pairs(storage.train_loaders) do -- set all related loaders to false
            if data.train_stop_id == train_stop_id then
                storage.train_loaders[loader_id].loader_state = false
            end
        end
    elseif event.element.name == "plus" or event.element.name == "minus" then
        -- get train stop id based on what the player has open
        local train_stop_id = game.players[event.player_index].opened.unit_number
        -- adjust the count, ensuring it doesn't go below 0
        if event.element.name == "plus" then
            storage.loader_ui_count = math.min(26, storage.loader_ui_count + 1)
        else
            storage.loader_ui_count = math.max(1, storage.loader_ui_count - 1)
        end

        -- rebuild the UI dynamically
        local player = game.players[event.player_index]
        local gui = player.gui.relative
        local frame = gui["loader-buttons-frame"]
        
        if frame then
            -- update the label
            -- local label = frame.children[1]
            -- label.caption = "Loaders: " .. storage.loader_ui_count
            
            -- remove existing loader buttons
            for i = 0, #frame.children do
                local row = frame["loader-row-" .. i]
                if row then row.destroy() end
            end
            if frame["gap-label"] then
                frame["gap-label"].destroy()
            end
            -- if any loader-button- exists, destroy all of them in a loop
            for i = 0, storage.loader_ui_count + 1 do
                local button = frame["loader-button-" .. i]
                if button then button.destroy() end
            end
            
            -- recreate loader buttons
            for i = 1, storage.loader_ui_count do
                local row = frame.add{type = "flow", direction = "horizontal", name = "loader-row-" .. i}
        
                -- Numbered button
                row.add{
                    type = "label",
                    
                    name = "loader-button-" .. i,
                    caption = i .. "",
                    tags = {train_stop_id = train_stop_id, loader_count = i}
                }.style.font = "default-bold"
        
                function get_loader_state(i)
                    if not storage.global_loader_states then
                        storage.global_loader_states = {}
                    end
                    if storage.global_loader_states[i] == nil then
                        -- if i equals 1, state is false, else it's true
                        if i == 1 then
                            storage.global_loader_states[i] = false
                        else
                            storage.global_loader_states[i] = true
                        end
                    end
                    return storage.global_loader_states[i]
                end
                row.add{
                    type = "checkbox",
                name = "loader-checkbox-" .. i,
                    -- state equals whatever is in storage, else true 
                    state = get_loader_state(i),
                    tags = {train_stop_id = train_stop_id, loader_count = i},
                    -- style = {type = "checkbox_style", margin_top = "5"}
                }.style.top_margin = "3"
                -- if i equals one, add a label after the checkbox that says "station"
                if i == 1 then
                    -- row.add{type = "label", caption = "(train station)"}
                    -- add a small image of the train station icon
                    row.add{type = "sprite", sprite = "entity/train-stop"}
                else
                    row.add{type = "sprite", sprite = "entity/cargo-wagon"}
                end
            end
            local button = frame.add{
                type = "button",
                name = "loader-button-" .. storage.loader_ui_count,
                caption =  "Place loaders", -- .. storage.loader_ui_count,
                tags = {train_stop_id = train_stop_id, loader_count = storage.loader_ui_count}
            }
            if settings.startup["train_loader_recipe_enabled"].value then
                frame.add{
                    type = "button",
                    name = "ghost-button-" .. storage.loader_ui_count,
                    caption =  "Place ghosts", -- .. storage.loader_ui_count,
                    tags = {train_stop_id = train_stop_id, loader_count = storage.loader_ui_count}
                }
            end
        end
    end
end)

function calculate_loader_positions(entity, count, gap_style)
    local positions = {}
    local base_spacing = 7  -- distance between each loader/wagon center
    local surface = entity.surface

    -- Get the train stop ID directly from the entity
    local train_stop_id = entity.unit_number

    -- Get checked states for the current train stop
    local checked_states = storage.global_loader_states or {}

    local direction_offsets = {
        [defines.direction.north] = {dx = -2, dy = 1},  -- x is fixed offset, y gets spacing
        [defines.direction.east]  = {dx = -1, dy = -2}, -- x gets spacing, y is fixed offset
        [defines.direction.south] = {dx = 2,  dy = -1}, -- x is fixed offset, y gets spacing
        [defines.direction.west]  = {dx = 1,  dy = 2}   -- x gets spacing, y is fixed offset
    }

    local valid_position_index = 1 -- Track which valid positions to use dynamically
    for i = 1, count do
            local offset
            -- this isn't ideal but I have to account for tables of older versions being updated
            if gap_style then
                offset = (valid_position_index > 1 and (valid_position_index - 1) * base_spacing or 0) + 3
            end

            local dir = direction_offsets[entity.direction]
            local potential_position = {
                x = entity.position.x + (math.abs(dir.dx) == 1 and dir.dx * offset or dir.dx),
                y = entity.position.y + (math.abs(dir.dy) == 1 and dir.dy * offset or dir.dy)
            }

            local area = {
                {potential_position.x - 2, potential_position.y - 2},
                {potential_position.x + 2, potential_position.y + 2}
            }

            local conflicting_entities = surface.find_entities_filtered{area = area}

            local non_rail_conflicts = {} -- filter out straight-rails from the conflicting entities
            local has_non_empty_loader = false
            local ignored_types = {
                ["corpse"] = true,
                ["cargo-wagon"] = true,
                ["locomotive"] = true,
                ["resource"] = true,
                ["construction-robot"] = true
            }

            for _, conflicting_entity in pairs(conflicting_entities) do
                if conflicting_entity.name == "train-loader" then
                    local inventory = conflicting_entity.get_inventory(defines.inventory.chest)
                    if not inventory.is_empty() then
                        has_non_empty_loader = true
                        break
                    end
                elseif conflicting_entity.name ~= "straight-rail" and not ignored_types[conflicting_entity.type] then
                    table.insert(non_rail_conflicts, conflicting_entity)
                end
            end

            -- check for rails specifically under the potential position
            local rails = surface.find_entities_filtered{name = "straight-rail", position = potential_position, radius = 1}

            -- Only add the position if there's no non-empty loader
            if not has_non_empty_loader then
                table.insert(positions, {
                    position = potential_position,
                    can_place_real = #rails > 0 and #non_rail_conflicts == 0,
                    -- checked equals checked_states[i] (if it's true) or false
                    checked_for_skipping = checked_states[i] or false
                })
            end

            valid_position_index = valid_position_index + 1
        -- end
    end

    -- Reverse positions if direction is south
    if entity.direction == defines.direction.south then
        local reversed_loader_positions = {}
        for i = #positions, 1, -1 do
            table.insert(reversed_loader_positions, positions[i])
        end
        positions = reversed_loader_positions
    end

    return positions
end


function clear_train_stop_loaders(train_stop_id, surface, entity)
    if not entity or not entity.valid then return end
    
    local position = entity.position
    local radius = 93  -- not great?

    for loader_id, data in pairs(storage.train_loaders) do
        if data.train_stop_id == train_stop_id then
            local loaders = surface.find_entities_filtered{
                name = "train-loader",
                area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
            }

            for _, loader in pairs(loaders) do
                if loader.valid and loader.unit_number == loader_id then
                    local inventory = loader.get_inventory(defines.inventory.chest)
                    
                    if inventory.is_empty() then
                        local inserters = surface.find_entities_filtered{ -- clean up associated inserters
                            name = "invisible-inserter",
                            area = {
                                {x = loader.position.x - 0.5, y = loader.position.y - 1.5},
                                {x = loader.position.x + 0.5, y = loader.position.y - 0.5}
                            }
                        }
                        for _, inserter in pairs(inserters) do
                            if inserter.valid then
                                inserter.destroy()
                            end
                        end
                        loader.destroy()
                        storage.train_loaders[loader_id] = nil
                        break
                    else
                        game.print("Can't remove 1 or more loaders because they contain items")
                        -- game.print("Cannot remove loader at {" .. loader.position.x .. ", " .. loader.position.y .. "} because it contains items")
                    end
                end
            end
        end
    end

    local ghosts = surface.find_entities_filtered{ -- clean up ghosts
        name = "entity-ghost",
        ghost_name = "train-loader",
        area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
    }

    for _, ghost in pairs(ghosts) do
        if ghost.valid then -- Clean up associated inserter ghosts if they exist
            local inserter_ghosts = surface.find_entities_filtered{
                name = "entity-ghost",
                ghost_name = "invisible-inserter",
                area = {
                    {x = ghost.position.x - 0.5, y = ghost.position.y - 1.5},
                    {x = ghost.position.x + 0.5, y = ghost.position.y - 0.5}
                }
            }
            for _, inserter_ghost in pairs(inserter_ghosts) do
                if inserter_ghost.valid then
                    inserter_ghost.destroy()
                end
            end
            ghost.destroy()
        end
    end
end

local function clean_up_destroyed_train_loader(event)
    local entity = event.entity
    if entity.name == "train-loader" and storage.train_loaders[entity.unit_number] then
        storage.train_loaders[entity.unit_number] = nil
        local inserters = event.entity.surface.find_entities_filtered{
            name = "invisible-inserter",
            area = {
                {x = event.entity.position.x - 0.5, y = event.entity.position.y - 1.5},
                {x = event.entity.position.x + 0.5, y = event.entity.position.y - 0.5}
            }
        }
        for _, inserter in pairs(inserters) do
            if inserter.valid then
                inserter.destroy()
            end
        end
    end
end

-- on bot placed item
-- if the ghost position is invalid (no straight rail underneat), cancel the build
local function handle_train_loader_placement(entity, surface, position)
    -- Check for straight rail underneath
    local rails = surface.find_entities_filtered{
        name = "straight-rail",
        position = position,
        radius = 2
    }

    local loader_collision = {{position.x - 2, position.y - 2}, {position.x + 2, position.y + 2}}
    local obstructions = surface.find_entities_filtered{
        area = loader_collision,
        -- instead of a radius, the position is of a 4x4 entity
        -- area = {{position.x - 3, position.y - 3}, {position.x + 3, position.y + 3}}
    }
    
    local obstructed = false
        for _, entity in pairs(obstructions) do
            if entity.name ~= "straight-rail" 
                and entity.name ~= "cargo-wagon"
                and entity.name ~= "locomotive"
                and entity.name ~= "train-loader" 
                and entity.type ~= "resource"
                and entity.type ~= "construction-robot" then
                obstructed = true
                break
            end
        end
    
    -- If no straight rail found or obstructed, cancel the build
    if #rails == 0 or obstructed then
        entity.destroy()
        -- if obstruction, renderdraw text obstruction message, else give rail message
        if obstructed then
            rendering.draw_text{
                text = 'Loader is obstructed',
                surface = surface,
                target = position,
                color = {r = 1, g = 1, b = 1, a = 1},
                time_to_live = 180,
                scale = 1.5,
                alignment = "center",
                vertical_alignment = "middle"
            }
        else 
            rendering.draw_text{
                text = 'straight rail is required',
                surface = surface,
                target = position,
                color = {r = 1, g = 1, b = 1, a = 1},
                time_to_live = 180,
                scale = 1.5,
                alignment = "center",
                vertical_alignment = "middle"
            }
        end
        return false
    end
    
    -- Initialize storage for the new loader
    local loader_id = entity.unit_number
    storage.train_loaders[loader_id] = {
        loader_state = false,  -- default to loader mode
        train_stop_id = nil
    }
    return true
end

-- Robot build handler
script.on_event(defines.events.on_robot_built_entity, function(event)
    if event.entity.name == "train-loader" then
        handle_train_loader_placement(event.entity, event.entity.surface, event.entity.position)
    end
end)

-- Player build handler
script.on_event(defines.events.on_built_entity, function(event)
    if event.entity.name == "train-loader" then
        game.print('trying to handle train loader player placement')
        handle_train_loader_placement(event.entity, event.entity.surface, event.entity.position)
    end
end)

script.on_event({defines.events.on_entity_died, defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, clean_up_destroyed_train_loader)