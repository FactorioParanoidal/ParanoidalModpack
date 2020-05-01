
local util = require("util")

script.on_init(function() init_table() end)
script.on_configuration_changed(function() init_table() end)

script.on_event(defines.events.on_player_selected_area, function(event)
    if event.item == "filter-drills" and #event.entities > 0 then
        local player = game.get_player(event.player_index)
        global.fmd.players[player.name] = event.entities
        open_gui(player)
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    local element = event.element
	local player = game.players[event.player_index]
    local splitName = util.split(event.element.name,";")
    if splitName[1] == "fmd" then
        local entities = global.fmd.players[player.name]
        local realName = splitName[2]
        if (not entities) or #entities == 0 or (not realName) or realName == "" then remove_gui(player) return end-- remote.call("fui","close_gui",{mod_name="fmd", player=player, view_name="filter"}) return end
        if realName == "NO_FILTER" then
            for _, entity in ipairs(entities) do
                if entity.valid then
                    changeEntity(entity,"")
                end
            end
            remove_gui(player)
            -- remote.call("fui","close_gui",{mod_name="fmd", player=player, view_name="filter"})
        else
            for _, entity in ipairs(entities) do
                if entity.valid then
                    changeEntity(entity,realName)
                end
            end
            remove_gui(player)
            -- remote.call("fui","close_gui",{mod_name="fmd", player=player, view_name="filter"})
        end
    end

end)

function changeEntity(entity1, newSufix)
    local splitName = util.split(entity1.name,";")
    local newEnt
    if newSufix == "" then
        if not splitName[2] then
        else
            local tmpHealth = entity1.health
            newEnt = entity1.surface.create_entity({name=splitName[1], position=entity1.position, force=entity1.force, direction=entity1.direction, fast_replace=true, spill=false, create_build_effect_smoke=false })
            newEnt.health = tmpHealth
            
        end
    else
        if splitName[2] and splitName[2] == newSufix then
        else
            if game.entity_prototypes[splitName[1]..";"..newSufix] then
                local tmpHealth = entity1.health
                newEnt = entity1.surface.create_entity({name=splitName[1]..";"..newSufix, position=entity1.position, force=entity1.force, direction=entity1.direction, fast_replace=true, spill=false, create_build_effect_smoke=false })
                newEnt.health = tmpHealth
            end
        end
    end
    if newEnt and string.sub(newEnt.name,1,25) == "cursed-resource-displacer" and remote.interfaces["cursed-rd"] then
        remote.call("cursed-rd", "add_miner", newEnt)
    end
end

function open_gui(player)
    
    remove_gui(player)
    local entities = global.fmd.players[player.name]
    
    local cont = {}
    local possiblesCats = {}
    local actualCat = {}
    for n, ent in ipairs(entities) do
        local minerArr = util.split(ent.name, ";")
        local minerName = minerArr[1]
        local minerProto = game.entity_prototypes[minerName]
        if minerProto then
            cont[minerName] = (cont[minerName] or 0) + 1
            if minerArr[2] and minerArr[2] ~= "" then actualCat[minerArr[2]] = (actualCat[minerArr[2]] or 0) + 1 end
            if minerProto.resource_categories then
                for cat, boolCat in pairs(minerProto.resource_categories) do
                    if boolCat then
                        possiblesCats[cat] = (possiblesCats[cat] or 0) + 1
                    end
                end
            end
        end
    end
    local countAll = 0 for _,count in pairs(cont) do countAll = countAll + count end
    if countAll == 0 then return end
    local countCat = 0 for _,count in pairs(actualCat) do countCat = countCat + count end
    local countAllCat = 0 for _,count in pairs(possiblesCats) do countAllCat = countAllCat + 1 end
    
    -- local panelMid = remote.call("fui","make_window",({ mod_name="fmd", view_name="filter", player=player, subheader={"gui-blueprint-library.shelf-choice"}, reload=true, root="screen", close={active=true} }))
    -- panelMid = panelMid.element

    local spend_frame = player.gui.screen.add{
        type = "frame",
        name = "cursed-filter-drills-frame",
        direction = "vertical",
        style = "dialog_frame"
    }
    spend_frame.force_auto_center()
    
    local frameAll = spend_frame.add({ type = "frame", direction = "vertical", style = "b_inner_frame_for_subheader_with_paddings" })
    frameAll.style.top_margin = 6
    
    local frameHead = frameAll.add({ type = "frame", style = "subheader_frame" })
    frameHead.style.left_margin = -4
    frameHead.style.right_margin = -4
    local flowHead = frameHead.add({ type = "flow", name = "flowHead", style = "horizontal_flow" })
    local fIn = frameHead.flowHead.add({ type="flow" })
    fIn.style.horizontally_stretchable = true
    local lblCant = fIn.add({ type = "label", caption = {"", {"gui-blueprint-library.shelf-choice"}}, style = "label_with_left_padding" })
    lblCant.style.top_padding = 5
    lblCant.style.left_padding = 5
    local drawFlow = fIn.add({ type = "flow" }) 
    drawFlow.style.horizontally_stretchable = true
    drawFlow.style.vertically_stretchable = true
    local wid = drawFlow.add({ type = "empty-widget", style = "draggable_space_header" })
    wid.style.horizontally_stretchable = true
    wid.style.vertically_stretchable = true
    wid.drag_target = spend_frame
    
    local panelMid = frameAll.add({ type = "flow" })
    panelMid.style.horizontally_stretchable = true
    panelMid.style.horizontal_align = "center"
    
    
    local flowButtons = frameAll.add({ type="flow" })
    flowButtons.style.top_padding = 7
    flowButtons.add({ type="button", name="fmd;btnCancelUpgrade", caption = {"gui.close"}, style = "red_back_button" })
    -- flowButtons.add({ type="flow" }).style.horizontally_stretchable = true
    -- flowButtons.add({ type="button", name="fmd;btnAcceptUpgrade", caption = {"gui.ok"}, style = "confirm_button" })
    
    
    local tableAll = panelMid.add({ type="table", column_count = math.ceil(math.sqrt(countAllCat+1)) }) -- , style="bordered_table"
    tableAll.vertical_centering = true

    
    tableAll.add({ type="sprite-button", name="fmd;NO_FILTER", number=(countAll-countCat), sprite="utility/missing_icon", style="slot_button", tooltip={"gui.reset-production-filters"} })
    
    for resName, res in pairs(global.fmd.resources) do
        if possiblesCats[resName] then
            local proto = game.entity_prototypes[resName]
            tableAll.add({ type="sprite-button", name="fmd;"..resName, number=(actualCat[resName] or 0), sprite="entity/"..resName, style="slot_button", tooltip=proto.localised_name })
        end
    end

    
end

function remove_gui(player)
    if player.gui.center["cursed-filter-drills-frame"] then
        player.gui.center["cursed-filter-drills-frame"].destroy()
    end
    if player.gui.screen["cursed-filter-drills-frame"] then
        player.gui.screen["cursed-filter-drills-frame"].destroy()
    end
end

function init_table()
    if not global.fmd then
        global.fmd = {}
    end
    if not global.fmd.players then
        global.fmd.players = {}
    end
    local resources = {}
    for resourceName, res in pairs(game.get_filtered_entity_prototypes({ {filter = "type", type = "resource"} })) do
        if res.resource_category == resourceName then
            resources[resourceName] = true
        end
    end
    global.fmd.resources = resources
    -- init fui
    -- remote.call("fui","add_mod",{ mod_name="fmd" })
end