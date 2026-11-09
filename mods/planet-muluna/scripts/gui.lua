local rro = Muluna.rro
local gui_lib = require("lib.guis")
local telescopes = rro.keys(Muluna.constants.telescopes)
local heat_assembling_machine_keys = rro.keys(Muluna.constants.heat_assembling_machines)
local telescope_combinator_keys = {}
local heat_element_keys = {}

for i,tab in pairs({telescopes,heat_assembling_machine_keys}) do
    local element_table
    local table_write
    local field
    if i == 1 then
        element_table = Muluna.constants.telescopes
        field = "constant-combinator"
        table_write = telescope_combinator_keys
    elseif i == 2 then
        element_table = Muluna.constants.heat_assembling_machines
        field = "reactor"
        table_write = heat_element_keys
    end
    for j,key in pairs(element_table) do
        table_write[j] = key[field]
        
    end
end

---Resolve a compound storage entry from a child entity's unit number.
---
---The reverse index is maintained by each compound entity's build handler.
---Entries registered before the index existed (an older save) fall back to the
---original linear scan.
---@param storage_table table
---@param reverse_table table|nil
---@param child_key string
---@param child_unit_number uint
local function child_entry(storage_table, reverse_table, child_key, child_unit_number)
    if not child_unit_number then return nil end
    local parent_unit_number = reverse_table and reverse_table[child_unit_number]
    local entry = parent_unit_number and storage_table[parent_unit_number]
    if entry then return entry end
    return rro.find_contains(storage_table or {}, function(candidate)
        local child = candidate[child_key]
        return child and child.unit_number == child_unit_number
    end)
end

---Build the Muluna relative GUI for an opened entity.
---
---Split from the event handler so the FUnit suite can exercise the frame
---construction with a stub GUI root: the headless scenario has no player.
---@param player LuaPlayer|table
---@param entity LuaEntity
---@param selected LuaEntity|nil
local function build_entity_gui(player, entity, selected)
    if not (entity and rro.contains({"assembling-machine","constant-combinator","reactor","accumulator","roboport","radar"},entity.type)) then return end
    --game.print("gui opened")
    selected = selected or (player or {}).opened --The currently selected entity
    local entity_name = entity.name
    local other_entity_button
    local satradar_gui
    local localised_title
    local localised_button
    local gui_type 
    local other_entity
    local button_name
    local enabled
    local add_horizontal_flip_button = false
    local pollution
    local pollution_tooltip
    if not storage.player_focus then storage.player_focus = {} end
    --game.print(entity_name)
    --game.print(serpent.block(Muluna.constants.telescopes))
    --game.print(serpent.block(Muluna.constants.heat_assembling_machines))
    local combinator = rro.find_contains(Muluna.constants.telescopes,function(other) return entity_name == other["constant-combinator"] end )
    if entity_name == "muluna-satellite-radar" then
        satradar_gui = true
        gui_type = defines.relative_gui_type.radar_gui
        localised_button = {"muluna-gui.satellite-radar-enable-button"}
        enabled = Muluna.get_nav_beacon_settings(entity.unit_number).gui.enabled
        button_name = "satellite-radar"
    elseif rro.contains(Muluna.constants.telescopes,function(other) return entity_name == other["assembling-machine"] end ) then
        local telescope_data = storage.telescopes
        other_entity_button = true
        gui_type = defines.relative_gui_type.assembling_machine_gui
        localised_button = {"muluna-gui.telescope-goto-button"}
        other_entity = storage.telescopes
        button_name = "telescope-unit"
        if entity.surface.planet and entity.surface.planet.prototype.pollutant_type then
            pollution = entity.surface.get_pollution(entity.position)
            pollution_tooltip = entity.surface.planet.prototype.pollutant_type.localised_name
        end
        
    -- elseif not storage.telescopes[entity.unit_number] then
    --         local position = entity.position
    --         local combinators = entity.surface.find_entities_filtered{area = {{position.x-1,position.y -1}, {position.x+1,position.y + 1}}, name = "muluna-telescope-combinator"}
    --                 local combinator = combinators[1]
    --                 storage.telescopes[entity.unit_number] = {
    --                     ["assembling-machine"] = entity,
    --                     ["constant-combinator"] = combinator,
    --                     ["constant-combinator-control-behavior"] = combinator.get_control_behavior(),
    --                     output_asteroid_signals = false
    --                 }
    elseif combinator then
        local telescope_data = storage.telescopes
        --game.print(combinator)
        local telescope = rro.find_contains(storage.telescopes,function(other) return entity.unit_number == other["constant-combinator"].unit_number end )
        --local telescope = storage.telescopes[combinator["assembling-machine"].unit_number]
        --game.print(serpent.block(telescope))
        if telescope.output_asteroid_signals == nil then
            telescope.output_asteroid_signals = true
        end
        other_entity_button = true
        gui_type = defines.relative_gui_type.constant_combinator_gui
        localised_button = {"muluna-gui.telescope-combinator-goto-button"}
        button_name = "telescope-combinator"
        enabled = telescope.output_asteroid_signals
        --game.print(enabled)
    elseif rro.contains(Muluna.constants.vacuum_roboports,function(other) return entity_name == other.roboport end ) then
        local telescope_data = storage.vacuum_roboports
        other_entity_button = true
        gui_type = defines.relative_gui_type.roboport_gui
        localised_button = {"muluna-gui.vacuum-roboport-roboport-goto-button"}
        other_entity = storage.vacuum_roboports
        button_name = "burner-roboport-unit"
        
    elseif rro.contains(Muluna.constants.vacuum_roboports,function(other) return entity_name == other.refueler end ) then
        local telescope_data = storage.vacuum_roboports
        other_entity_button = true
        gui_type = defines.relative_gui_type.assembling_machine_gui
        localised_button = {"muluna-gui.vacuum-roboport-refueler-goto-button"}
        button_name = "burner-roboport-refueler"
        add_horizontal_flip_button = true
    elseif rro.contains(Muluna.constants.heat_assembling_machines,function(other) return entity_name == other["assembling-machine"] end ) then
        local assembling_machine_data = storage.heat_assembling_machines
        other_entity_button = true
        gui_type = defines.relative_gui_type.assembling_machine_gui
        localised_button = {"muluna-gui.heat-assembling-machine-goto-button"}
        button_name = "heat-assembling-machine-unit"
    elseif rro.contains(Muluna.constants.heat_assembling_machines,function(other) return entity_name == other["reactor"] end ) then
        other_entity_button = true
        local assembling_machine_data = storage.heat_assembling_machines
        gui_type = defines.relative_gui_type.reactor_gui
        localised_button = {"muluna-gui.heat-assembling-machine-reactor-goto-button"}
        button_name = "heat-assembling-machine-reactor"
    end
    if gui_type == defines.relative_gui_type.assembling_machine_gui and not entity.get_recipe() then
        gui_type = defines.relative_gui_type.assembling_machine_select_recipe_gui
    end
    if other_entity_button or satradar_gui then
        --game.print("Showing gui")
        local frame = player.gui.relative.add{type="frame", name="muluna-entity-gui", caption=localised_title, direction = "vertical",
        
        anchor = {
				gui = gui_type,
				position = satradar_gui and defines.relative_gui_position.bottom or defines.relative_gui_position.right,
				ghost_mode = "both",
				--name = "",
			},
    
            }
        local title_bar = frame.add({
            type = "flow",
            direction = "horizontal",
            drag_target = frame,

        })
        -- title_bar.add({
        --     type = "label",
        --     caption = "test",
        --     style = "frame_title",
        --     ignored_by_interaction = true,
        -- })
        local drag_handle = title_bar.add({
            type = "empty-widget",
            ignored_by_interaction = false,
            style = (not satradar_gui ) and "draggable_space_header" or nil
        })
        drag_handle.style.horizontally_stretchable = true
		drag_handle.style.height = (not satradar_gui ) and 24 or 0
		drag_handle.style.right_margin = 4
        if other_entity_button then
            print("other_entity_button")
            local goto_button = frame.add({
                type = "button",
                name = "muluna-goto-button-" .. button_name,
                caption = localised_button,
            })
            local horizontal_space = frame.add({
                type = "flow",
                name = "muluna-flow",
                direction = "horizontal",
            })
            if add_horizontal_flip_button then
                local horizontal_flip_button = horizontal_space.add({
                type = "sprite-button",
                name = "muluna-horizontal-flip",
                sprite = "virtual-signal/signal-rightwards-leftwards-arrow"
                --caption = localised_button,
                })
            end
            if button_name ==  "telescope-combinator" and entity.surface.platform then
                local enable_asteroid_switch = frame.add({
                    type = "checkbox",
                    name = "muluna-telescope-combinator-enable-asteroid-signal-checkbox",
                    caption = {"muluna-gui.telescope-combinator-enable-asteroid-signal-checkbox"},
                    state = enabled,
                })
            end
            if entity.name ~= "muluna-burner-roboport" then
                local red_wire_button = horizontal_space.add({
                type = "sprite-button",
                name = "muluna-drag-green",
                sprite = "item/green-wire"
                --caption = localised_button,
                })
                local green_wire_button = horizontal_space.add({
                    type = "sprite-button",
                    name = "muluna-drag-red",
                    sprite = "item/red-wire"
                    --caption = localised_button,
                })
            end
            if pollution then
                local pollution_info = frame.add({
                    type = "label",
                    name = "muluna-telescope-pollution-label",
                    caption = {"",pollution_tooltip,": ",tostring(math.floor(pollution))}
                })
                local probability = Muluna.get_telescope_probability(pollution,entity.quality) * 100
                if probability > 100 then
                    probability = 100
                end
                if probability < 0 then
                    probability = 0
                end
                local pollution_probability = frame.add({
                    type = "label",
                    name = "muluna-telescope-pollution-value-label",
                    caption = {"muluna-gui.telescope-pollution-obscured_percent",tostring(math.floor(probability)),pollution_tooltip}
                })
            end
            
        elseif satradar_gui then
            local enable_switch = frame.add({
                type = "checkbox",
                name = "muluna-satellite-radar-enable-checkbox",
                caption = localised_button,
                state = enabled,
            })
            if selected and storage.nav_surfaces[selected.unit_number] then
                local goto_planet_button = frame.add({
                    type = "button",
                    name = "muluna-goto-button-" .. button_name,
                    caption = {"muluna-gui.satellite-radar-look-at",{"space-location-name." .. storage.nav_surfaces[selected.unit_number].name},storage.nav_surfaces[selected.unit_number].name},
                
                })
            end
            
        end
        -- local content_frame = frame.add({
		-- 	type = "frame",
		-- 	name = "content",
		-- 	style = "inside_shallow_frame_with_padding_and_vertical_spacing",
		-- 	direction = "vertical",
		-- })
        --player.gui..relative.greeting.caption = "Hello there!"
        --player.gui.top["greeting"].caption = "Actually, never mind, I don't like your face"

    
        
    end

end

Muluna.events.on_event(defines.events.on_gui_opened, function(event)
    build_entity_gui(game.players[event.player_index], event.entity)
end)

Muluna.events.on_event(defines.events.on_gui_closed, function(event)

    local player = game.players[event.player_index]
    if player.gui.relative["muluna-entity-gui"] then
        player.gui.relative["muluna-entity-gui"].destroy()
    end
    


end)

---Handle a click on one of the Muluna relative-GUI buttons.
---
---Split from the event handler so the FUnit suite can pass a stub player; the
---headless scenario has no player, and the crash in #408 happened before any
---player method was called.
---@param player LuaPlayer|table
---@param element table
local function handle_gui_click(player, element)
    if not (element and element.name) then return end
    --game.print(serpent.block(element))
    if false then

    elseif string.find(element.name, "muluna%-goto%-button") or string.find(element.name, "muluna%-drag") or element.name == "muluna-horizontal-flip"   then 

        local selected = player and player.opened --The currently selected entity
        if not selected then return end
        local to_entity --Entity to change focus to
        local to_planet --Planet to switch view to
        local flip_rotation
        local wire_color
        --game.print(element.name)
        if string.find(element.name,"telescope%-unit") then
            --game.print(element.name)
            to_entity = storage.telescopes[selected.unit_number]["constant-combinator"]
        elseif string.find(element.name,"telescope%-combinator")  then
            --game.print(element.name)
            local to_entity_table = child_entry(storage.telescopes, storage.telescope_children, "constant-combinator", selected.unit_number)
            to_entity = to_entity_table["assembling-machine"]
        elseif string.find(element.name,"burner%-roboport%-unit")  then
            --game.print(element.name)
            local to_entity_table = child_entry(storage.burner_roboports, storage.burner_roboport_children, "roboport", selected.unit_number)
            to_entity = to_entity_table["refueler"]
        elseif string.find(element.name,"burner%-roboport%-refueler")  then
            --game.print(element.name)
            -- Entries are keyed by the refueler's unit number.
            local to_entity_table = storage.burner_roboports[selected.unit_number]
            to_entity = to_entity_table["roboport"]
        elseif string.find(element.name,"heat%-assembling%-machine%-unit")  then
            to_entity = storage.heat_assembling_machines[selected.unit_number]["reactor"]
            --game.print(element.name)
        elseif string.find(element.name,"heat%-assembling%-machine%-reactor")  then
            local to_entity_table = child_entry(storage.heat_assembling_machines, storage.heat_assembling_machine_children, "reactor", selected.unit_number)
            to_entity = to_entity_table["assembling-machine"]
            --game.print(element.name)
        elseif string.find(element.name,"satellite%-radar")  then
            to_planet = storage.nav_surfaces[selected.unit_number]
        elseif string.find(element.name,"drag%-green")  then
            wire_color = "green"
        elseif string.find(element.name,"drag%-red")  then
            wire_color = "red"
        elseif element.name == "muluna-horizontal-flip" then
            flip_rotation = true
        end
        
        if to_entity then
            player.opened = to_entity
        elseif to_planet then
            player.set_controller{type = defines.controllers.remote,surface = to_planet.name}
        elseif wire_color then
            --player.close_
            --game.print("wire color")
            player.clear_cursor()
            player.cursor_stack.set_stack(
                {
                    name = wire_color .. "-wire",
                    count = 1,
                    quality = "normal"
                }
            )
            --game.print(serpent.block(player.opened))
            local entity_position = player.opened.position
            player.selected=player.opened
            --game.print("Selected entity:"..serpent.block(player.selected))
            player.opened = nil
            --player.update_selected_entity(entity_position)
            player.drag_wire{position=entity_position}
        elseif flip_rotation then
            player.opened.flip{horizontal = true, by_player = player}
        end



    
    



    end






end

Muluna.events.on_event(defines.events.on_gui_click, function(event)
    handle_gui_click(game.players[event.player_index], event.element)
end)

Muluna.events.on_event(defines.events.on_gui_checked_state_changed, function(event)
    local checkbox = event.element
    --game.print(checkbox.name)
    if (checkbox.name and checkbox.name == "muluna-satellite-radar-enable-checkbox") then
        local player = game.players[event.player_index]
        local radar = player.opened --The currently selected entity (Satellite Radar)
        storage.nav_beacons_other[radar.unit_number].gui.enabled = checkbox.state
        Muluna.update_nav_beacon_status(radar)
    elseif (checkbox.name and checkbox.name == "muluna-telescope-combinator-enable-asteroid-signal-checkbox") then
        local player = game.players[event.player_index]
        local combinator = player.opened --The currently selected entity (Satellite Radar)
        local telescope = child_entry(storage.telescopes, storage.telescope_children, "constant-combinator", combinator.unit_number)
        storage.telescopes[telescope["assembling-machine"].unit_number].output_asteroid_signals = checkbox.state
        --game.print(storage.telescopes[telescope["assembling-machine"].unit_number].output_asteroid_signals)
    end
    




end)

-- Test-only seams. The FUnit scenario has no player, so it cannot raise
-- on_gui_opened/on_gui_click with a real GUI. scripts/funit.lua drives these
-- functions with a stub player and records the element definitions.
if script.active_mods["funit"] then
    Muluna.funit.build_entity_gui = build_entity_gui
    Muluna.funit.handle_gui_click = handle_gui_click
end



