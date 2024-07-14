local function available_for_mining_elements(entity)
    return entity.name == "puffer-nest" and entity.type == "tree"
        or entity.type == "tree" and entity.name == "swamp-tree"
        or entity.type == "tree" and entity.name == "desert-tree"
        or entity.type == "tree" and entity.name == "temperate-tree"
end
function on_player_mined_entity(e)
    local entity = e.entity
    if not entity or not entity.valid then
        return
    end
    --log(entity.type .. " " .. entity.name)
    if available_for_mining_elements(entity) then
        local player = game.players[e.player_index]
        research_technologies_for_resources_if_exists_not_researched({ { type = entity.type, name = entity.name } },
            player.force, "Произведено знакомство с новым ресурсом ", ", недобываемым из поверхности планеты")
        return
    end
    local buffer_inventory = e.buffer
    local force = game.players[e.player_index].force
    if
        not force.technologies["savlaged-automation-tech"]
        or not force.technologies["savlaged-automation-tech"].valid
        or not force.technologies["savlaged-automation-tech"].researched
    then
        if
            entity.type == "tree"
            or string.find(entity.name, "sand-rock", 1, true)
            or string.find(entity.name, "rock-", 1, true)
            or entity.name == "coal" and entity.type == "resource"
        then
            buffer_inventory.clear()
        end
        return
    end
    global.tree_count = global.tree_count or 0
    global.stone_count = global.stone_count or 0
    global.coal_count = global.coal_count or 0
    local contents = buffer_inventory.get_contents()
    if entity.type == "tree" then
        local contents = buffer_inventory.get_contents()
        _table.each(contents, function(value)
            if global.tree_count + value < 200 then
                global.tree_count = global.tree_count + value
            else
                buffer_inventory.clear()
            end
        end)
        return
    end
    if
        string.find(entity.name, "sand-rock", 1, true)
        or string.find(entity.name, "rock-", 1, true)
        or entity.name == "coal" and entity.type == "resource"
    then
        _table.each(contents, function(value, name)
            if name == "stone" then
                if global.stone_count + value < 1200 then
                    global.stone_count = global.stone_count + value
                else
                    buffer_inventory.clear()
                end
            end
            if name == "coal" then
                if global.coal_count + value < 1200 then
                    global.coal_count = global.coal_count + value
                else
                    buffer_inventory.clear()
                end
            end
        end)
    end
end

function on_player_mined_item(e)
    --log("on_player_mined_item fired")
    local item_stack = e.item_stack
    if not item_stack then
        --	log("on_player_mined_item fired, not item stack!")
        return
    end
    local item_stack_name = item_stack.name
    -- log("item " .. item_stack_name)
    local player = game.players[e.player_index]
    local force = game.players[e.player_index].force
    research_technologies_for_resources_if_exists_not_researched({ { type = "item", name = item_stack_name } }, force,
        "Произведено знакомство с новым ресурсом ", ", недобываемым из поверхности планеты")
    if
        not force.technologies["savlaged-automation-tech"]
        or not force.technologies["savlaged-automation-tech"].valid
        or not force.technologies["savlaged-automation-tech"].researched
    then
        if item_stack_name == "coal" then
            item_stack.count = 0
        end
        return
    end
    global.tree_count = global.tree_count or 0
    global.stone_count = global.stone_count or 0
    global.coal_count = global.coal_count or 0
    if item_stack == "coal" then
        if global.coal_count + item_stack.count < 1200 then
            global.coal_count = global.coal_count + item_stack.count
        else
            item_stack.count = 0
        end
        return
    end
end
