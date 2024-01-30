
local util = require("util")

script.on_init(function() init_table() end)
script.on_configuration_changed(function() init_table() end)

script.on_event(defines.events.on_built_entity, function(event) des_building(event.created_entity, false) end)
script.on_event(defines.events.on_robot_built_entity, function(event) des_building(event.created_entity, false) end)

script.on_event(defines.events.on_player_mined_entity, function(event) des_building(event.entity, true) end)
script.on_event(defines.events.on_robot_mined_entity, function(event) des_building(event.entity, true) end)
script.on_event(defines.events.on_entity_died, function(event) des_building(event.entity, true) end)


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
        if (not entities) or #entities == 0 or (not realName) or realName == "" then remove_gui(player) return end
        if realName == "NO_FILTER" then
            for _, entity in ipairs(entities) do
                if entity.valid then
                    changeEntity(entity,"")
                end
            end
            remove_gui(player)
        else
            for _, entity in ipairs(entities) do
                if entity.valid then
                    changeEntity(entity,realName)
                end
            end
            remove_gui(player)
        end
    end

end)

function changeEntity(entity1, newSufix)
    local splitName = util.split(entity1.name,";")
    local newEnt
    if newSufix == "" then
        if not splitName[2] then
        else
            update_resources(entity1, splitName[2], newSufix)
            local tmpHealth = entity1.health
            newEnt = entity1.surface.create_entity({name=splitName[1], position=entity1.position, force=entity1.force, direction=entity1.direction, fast_replace=true, spill=false, create_build_effect_smoke=false })
            newEnt.health = tmpHealth
        end
    else
        if splitName[2] and splitName[2] == newSufix then
        else
            if game.entity_prototypes[splitName[1]..";"..newSufix] then
                if splitName[2] then
                    update_resources(entity1, splitName[2], newSufix)
                else
                    update_resources(entity1, "", newSufix)
                end
                local tmpHealth = entity1.health
                newEnt = entity1.surface.create_entity({name=splitName[1]..";"..newSufix, position=entity1.position, force=entity1.force, direction=entity1.direction, fast_replace=true, spill=false, create_build_effect_smoke=false })
                local resProto = game.entity_prototypes[newSufix]
                rendering.draw_sprite{ sprite = "utility/entity_info_dark_background", target = newEnt, surface = newEnt.surface, only_in_alt_mode = true}
                rendering.draw_sprite{ sprite = "entity."..newSufix, target = newEnt, surface = newEnt.surface, only_in_alt_mode = true}
                newEnt.health = tmpHealth
            end
        end
    end
    if newEnt then
        if string.sub(newEnt.name,1,25) == "cursed-resource-displacer" and remote.interfaces["cursed-rd"] then
            remote.call("cursed-rd", "add_miner", newEnt)
        end
    end
end

-- casos:
-- - no tiene sufix pasa a tener : Solo cambiar este recurso
-- - Tiene sufix, pasa a otro    : Cambiar los 2 recursos
-- - tiene sufix pasa a no tener : Solo cambiar el recurso viejo

function update_resources(entity, oldSufix, newSufix)
    if remote.interfaces["Cursed-DB"] and oldSufix ~= newSufix and (oldSufix ~= "" or newSufix ~= "") then
        remote.call("Cursed-DB", "change_drill", { entity = entity, resource = newSufix, old_resource = oldSufix })
        local surface = entity.surface
        
        local area = get_area(entity.position, entity.prototype.mining_drill_radius)
        local drills = surface.find_entities_filtered{ area = area, type = "mining-drill", force = entity.force }
        for i, drill in ipairs(drills) do
            if drill ~= entity then
                local splitName = util.split(drill.name,";")
                if splitName[2] then
                    remote.call("Cursed-DB", "change_drill", { entity = drill, resource = splitName[2], old_resource = "" })
                end
            end
        end
    end
end

function des_building(entity, des)
    local splitName = util.split(entity.name,";")
    if splitName[2] then
        if des then
            update_resources(entity, splitName[2], "")
        else
            update_resources(entity, "", splitName[2])
        end
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

    local spend_frame = player.gui.screen.add{
        type = "frame",
        name = "cursed-filter-drills-frame",
        direction = "vertical",
        style = "frame", caption = {"gui.set-filter"}
    }
    spend_frame.force_auto_center()
    
    local frameAll = spend_frame.add({ type = "frame", direction = "vertical", style = "inside_deep_frame" })
    frameAll.style.top_margin = 6
    
    local panelMid = frameAll.add({ type = "flow" })
    panelMid.style.horizontally_stretchable = true
    panelMid.style.horizontal_align = "center"
    panelMid.style.top_margin = 12
    
    
    local tabs = {}
    for resName, res in pairs(global.fmd.resources) do
        if possiblesCats[resName] then
            local proto = game.entity_prototypes[resName]
            local this_tab = get_tab(resName)
            tabs[this_tab] = tabs[this_tab] or {}
            table.insert(tabs[this_tab], { name = resName, localised = proto.localised_name })
        end
    end
    
    local columns = 0
    for guiName, arr in pairs(tabs) do columns = math.max(columns, #arr+1) end
    
    local databs = global.fmd.tabs
    local tabbed = panelMid.add({ type="tabbed-pane" })
    for guiName, arr in pairs(tabs) do
        if #arr > 0 then
            local tab = tabbed.add({ type="tab", caption = databs[guiName].caption, name = "tab_"..guiName })
            local frame = tabbed.add({ type="frame", style = "naked_frame", name = "fme_"..guiName })
            frame.style.margin = 4
            tabbed.add_tab(tab, frame)
            local tableAll = frame.add({ type="table", column_count =  math.ceil(math.sqrt(columns)), name = "tableAll", style = "slot_table" })
            tableAll.add({ type="sprite-button", name="fmd;NO_FILTER", number=(countAll-countCat), sprite="utility/missing_icon", style="slot_button", tooltip={"gui.reset-production-filters"} })
            for i, res in ipairs(arr) do
                tableAll.add({ type="sprite-button", name="fmd;"..res.name, number=(actualCat[res.name] or 0), sprite="entity/"..res.name, style="slot_button", tooltip=res.localised })
            end
        end
    end
    
    spend_frame.add({ type = "flow", name = "flowButtons", direction = "horizontal", style = "dialog_buttons_horizontal_flow" })
    spend_frame.flowButtons.drag_target = spend_frame
    spend_frame.flowButtons.add({ type = "flow", name = "flowButtonsClose", direction = "horizontal" })
    spend_frame.flowButtons.flowButtonsClose.add({ type = "button", name = "fmd;btnCancelUpgrade", caption = {"gui.close"}, style = "red_back_button" })
    local tmp = spend_frame.flowButtons.add({ type = "empty-widget", style = "draggable_space" })
    tmp.style.horizontally_stretchable = true
    tmp.style.vertically_stretchable = true
    tmp.drag_target = spend_frame
    
end

function remove_gui(player)
    if player.gui.screen["cursed-filter-drills-frame"] then
        if player.opened_self then player.opened = nil end
        player.gui.screen["cursed-filter-drills-frame"].destroy()
    end
end

function get_tab(resName)
    local dats = global.fmd.tabs
    for guiName, dat in pairs(dats) do
        if dat.prefix and resName:sub(1, dat.prefix:len()) == dat.prefix then
            return guiName
        elseif dat.sufix and resName:sub(-1 * dat.sufix:len()) == dat.sufix then
            return guiName
        elseif dat.match and resName:match(dat.match) then
            return guiName
        end
    end
    return "no_tab"
end

function get_area(center, distance)
    return { 
        left_top = 
            { x = center.x - distance,
              y = center.y - distance
            },
        right_bottom = 
            { x = center.x + distance,
              y = center.y + distance
            }
           }
end

function init_table()
    if not global.fmd then
        global.fmd = {}
    end
    if not global.fmd.players then
        global.fmd.players = {}
    end
    if not global.fmd.tabs then
        global.fmd.tabs = { }
        global.fmd.tabs["no_tab"] = { caption = "[item=iron-ore]" }
    end
    local resources = {}
    for resourceName, res in pairs(game.get_filtered_entity_prototypes({ {filter = "type", type = "resource"} })) do
        if res.resource_category == resourceName then
            resources[resourceName] = true
        end
    end
    global.fmd.resources = resources
end


script.on_event(defines.events.on_gui_opened,function(event)
    local player = game.players[event.player_index]
    remove_gui(player)
end)


remote.add_interface("Cursed-FMD",
{add_tab = 
function(dats)
-- {name: tab gui name,
--  caption: text show in this tab
--  match/prefix/sufix: search this in the resource name}
    init_table()
    if type(dats) == "table" and dats.name and dats.caption and (dats.match or dats.prefix or dats.sufix) and not global.fmd.tabs[dats.name] then
        global.fmd.tabs[dats.name] = dats
        return true
    end
    return false
end,
rem_tab = 
function(name)
    init_table()
    if name and global.fmd.tabs[name] then
        global.fmd.tabs[name] = nil
        return true
    end
    return false
end
})