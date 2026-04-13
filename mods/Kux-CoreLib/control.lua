if true then return end --NOTE: diabled

require("mod")
require("lib/@")
if mods["gvv"] then require("__gvv__.gvv")() end

-- print("ModInfo.current_stage: "..ModInfo.current_stage)
-- print("ModInfo.name   "..ModInfo.name)
-- print("ModInfo.prefix "..ModInfo.prefix)
-- print("ModInfo.path   "..ModInfo.path)

---@class KuxCoreLibInternal
KuxCoreLibInternal={}

LuaPlayerInfo={
    fieldNames={}
}

--TODO adapt for Factorio 2.0
LuaEntityInfo={
    fields={
        "name","ghost_name","localised_name","localised_description","ghost_localised_name","ghost_localised_description","type","ghost_type","active","destructible","minable","rotatable","operable","health","direction","supports_direction","orientation","cliff_orientation","relative_turret_orientation","torso_orientation","amount","initial_amount","effectivity_modifier","consumption_modifier","friction_modifier","driver_is_gunner","vehicle_automatic_targeting_parameters","speed","effective_speed","stack","prototype","ghost_prototype","drop_position","pickup_position","drop_target","pickup_target","selected_gun_index","energy","temperature","previous_recipe","held_stack","held_stack_position","train","neighbours","belt_neighbours","fluidbox","backer_name","entity_label","time_to_live","color","text","signal_state","chain_signal_state","to_be_looted","crafting_speed","crafting_progress","bonus_progress","productivity_bonus","pollution_bonus","speed_bonus","consumption_bonus","belt_to_ground_type","loader_type","rocket_parts","logistic_network","logistic_cell","item_requests","player","unit_group","damage_dealt","kills","last_user","electric_buffer_size","electric_input_flow_limit","electric_output_flow_limit","electric_drain","electric_emissions","unit_number","ghost_unit_number","mining_progress","bonus_mining_progress","power_production","power_usage","bounding_box","secondary_bounding_box","selection_box","secondary_selection_box","mining_target","circuit_connected_entities","circuit_connection_definitions","request_slot_count","filter_slot_count","loader_container","grid","graphics_variation","tree_color_index","tree_color_index_max","tree_stage_index","tree_stage_index_max","tree_gray_stage_index","tree_gray_stage_index_max","burner","shooting_target","proxy_target","stickers","sticked_to","parameters","alert_parameters","electric_network_statistics","inserter_target_pickup_count","inserter_stack_size_override","products_finished","spawner","units","power_switch_state","effects","beacons_count","infinity_container_filters","remove_unfiltered_items","character_corpse_player_index","character_corpse_tick_of_death","character_corpse_death_cause","associated_player","tick_of_last_attack","tick_of_last_damage","splitter_filter","inserter_filter_mode","splitter_input_priority","splitter_output_priority","armed","recipe_locked","connected_rail","connected_rail_direction","trains_in_block","timeout","neighbour_bonus","ai_settings","highlight_box_type","highlight_box_blink_interval","status","enable_logistics_while_moving","render_player","render_to_forces","pump_rail_target","moving","electric_network_id","allow_dispatching_robots","auto_launch","energy_generated_last_tick","storage_filter","request_from_buffers","corpse_expires","corpse_immune_to_entity_placement","tags","command","distraction_command","time_to_next_effect","autopilot_destination","autopilot_destinations","trains_count","trains_limit","is_entity_with_force","is_military_target","is_entity_with_owner","is_entity_with_health","combat_robot_owner","link_id","follow_target","follow_offset","linked_belt_type","linked_belt_neighbour","radar_scan_progress","rocket_silo_status","tile_width","tile_height","valid","object_name",
    }
}
--TODO adapt for Factorio 2.0
LuaControl={
    fields={"build_distance", "character_additional_mining_categories", "character_build_distance_bonus", "character_crafting_speed_modifier", "character_health_bonus", "character_inventory_slots_bonus", "character_item_drop_distance_bonus", "character_item_pickup_distance_bonus", "character_loot_pickup_distance_bonus", "character_maximum_following_robot_count_bonus", "character_mining_progress", "character_mining_speed_modifier", "character_personal_logistic_requests_enabled", "character_reach_distance_bonus", "character_resource_reach_distance_bonus", "character_running_speed", "character_running_speed_modifier", "character_trash_slot_count_bonus", "cheat_mode", "crafting_queue", "crafting_queue_progress", "crafting_queue_size", "cursor_ghost", "cursor_stack", "driving", "drop_item_distance", "following_robots", "force", "force_index", "in_combat", "item_pickup_distance", "loot_pickup_distance", "mining_state", "opened", "opened_gui_type", "picking_state", "position", "reach_distance", "repair_state", "resource_reach_distance", "riding_state", "selected", "shooting_state", "surface", "surface_index", "vehicle", "vehicle_logistic_requests_enabled", "walking_state"}
}

--Events.on_loaded(function ()
	--[[
	local entity_types = {}
	for _, entity in pairs(prototypes.entity) do
		entity_types[entity.type] = true
	end
	local entity_types_list = {}
	for entity_type, _ in pairs(entity_types) do
		table.insert(entity_types_list, entity_type)
	end
	table.sort(entity_types_list)
	print("Entity types: ".. serpent.line(entity_types_list))
	--]]

	--[[
	local item_types = {}
	for _, item in pairs(prototypes.item) do
		item_types[item.type] = true
	end
	local item_types_list = {}
	for item_type, _ in pairs(item_types) do
		table.insert(item_types_list, item_type)
	end
	table.sort(item_types_list)
	print("Item types: ".. serpent.line(item_types_list))
	--]]
--end)

-- local function size(entoyt_prototype)
--     math.max(math.ceil(entity_prototype.collision_box.left_top.x),math.ceil(entity_prototype.selection_box.left_top.x))
-- end
--[[
require("lib.EventDistributor")
--FInde die Zuordung von LuaEntity Eigenschaften zu prototypen
EventDistributor.register("on_loaded",function ()
    for i = 1, 40, 1 do print("") end
    local prototypes={}
    local surface = game.players[1].surface

    local x = 0
    for name, entity_prototype in pairs(prototypes.entity) do
        print(name,entity_prototype.type)

        local pti = prototypes[entity_prototype.type]
        if(not pti) then
            pti={
                type = entity_prototype.type,
                fields={}
            }
            prototypes[entity_prototype.type]=pti
        end
        x = x + math.abs(math.max(math.ceil(entity_prototype.collision_box.left_top.x),math.ceil(entity_prototype.selection_box.left_top.x)))
        local d = {name = name, position = {x, 0}, force = "player"}

        if(entity_prototype.type=="sticker") then goto next end
        if(entity_prototype.type=="stream") then goto next end
        if(entity_prototype.type=="artillery-flare") then goto next end
        if(entity_prototype.type=="speech-bubble") then goto next end
        if(entity_prototype.type=="beam") then goto next end
        if(entity_prototype.type=="entity-ghost") then goto next end
        if(entity_prototype.type=="tile-ghost") then goto next end
        if(entity_prototype.type=="leaf-particle") then goto next end -- obsolete
        if(entity_prototype.type=="particle") then goto next end -- obsolete
        if(entity_prototype.type=="smoke") then goto next end -- obsolete
        if(entity_prototype.type=="spider-leg") then goto next end -- Spider leg can not be created manually.

        if(entity_prototype.type=="item-request-proxy") then
            local temp = surface.create_entity{name="assembling-machine-3",position = {-10, 0},force = "player"}
            d.target = temp -- Das Ziel-Entity, für das das "item-request-proxy" erstellt wird
            d.modules = {
              {name = "speed-module", amount = 1}, -- Beispielmodule, die dem Proxy hinzugefügt werden können
              {name = "productivity-module", amount = 2}
            }
            -- ERROR Unknown item name:
            goto next
        elseif(entity_prototype.type=="item-entity") then
            d.stack={name="wooden-chest",count=10}
        elseif(entity_prototype.type=="highlight-box") then
            -- highlight-box needs either a bounding_box, source or target
            d.bounding_box={{x,0},{x+5,5}}
        elseif(entity_prototype.type=="flying-text") then
            d.text="Foo"
        end
        if(entity_prototype.type=="projectile" or entity_prototype.type=="artillery-projectile" or (entity_prototype.type=="explosion" and (entity_prototype.explosion_beam or entity_prototype.explosion_rotate))) then
            d.target={x,100}
        end
        if(entity_prototype.type=="projectile" or entity_prototype.type=="artillery-projectile") then
            d.speed=1
        end

        if(entity_prototype.type=="explosion" or entity_prototype.type=="projectile") then
            d.position={x,20}
        end

        --print(serpent.line(d))
        local entity = surface.create_entity(d)
        print(x)
        x = x + math.max(math.ceil(entity_prototype.collision_box.right_bottom.x),math.ceil(entity_prototype.selection_box.right_bottom.x))

        -- local success, entity = pcall(function() return surface.create_entity(d) end)
        -- if(not success) then
        --     print(" ERROR")
        --     goto next
        -- end
        -- artillery-cannon-muzzle-flash (explosion): Oriented explosion (or beam) needs a target to be created.
        -- sticker: Can't create sticker, target not specified.
        -- stream: Can't create fluid stream, target/target_position not specified.
        -- artillery-flare: Key "frame_speed" not found in property tree at ROOT
        -- artillery-flare: Key "speed" not found in property tree at ROOT
        -- projectile: Can't create projectile, target not specified.
        -- speech-bubble: Need entity target
        -- beam: Can't create beam, target/target_position not specified.
        -- item-entity: Key "stack" not found in property tree at ROOT
        -- item-request-proxy: Entity creation of item-request-proxy failed
        -- The type leaf-particle has been obsoleted and cannot be created.
        -- The type particle has been obsoleted and cannot be created.
        -- The type smoke has been obsoleted and cannot be created.

        for _, fieldName in ipairs(LuaControl.fields) do
            local succes, value = pcall(function() return entity[fieldName] end)
            if(succes and value~=nil) then pti.fields[fieldName]=true end
        end
        ::next::
    end
    print("=========================================================")
    -- for _, pti in pairs(prototypes) do
    --     print(pti.type)
    --     for fieldName, value in pairs(pti.fields) do
    --         print("  "..fieldName)
    --     end
    -- end
    local properties={}
    for _, pti in pairs(prototypes) do
        for fieldName, value in pairs(pti.fields) do
            local p = properties[fieldName]
            if(not p) then
                p={name=fieldName, prototypes={}}
                properties[fieldName]=p
            end
            table.insert(p.prototypes, pti.type)
        end
    end

    for name, pi in pairs(properties) do
        print(name..":"..table.concat(pi.prototypes, ","))
    end

    print("=====STOP=====")
    --error("=====STOP=====")
end)
--]]
