local data_util = require("__flib__.data-util")
local rro = Muluna.rro
Muluna.constants.vacuum_roboports = {}
local vacuum_roboports = Muluna.constants.vacuum_roboports 

local function parse_energy_string(s) --ChatGPT
		-- Match: number part, optional prefix, and unit
		-- %d+ matches digits, %.? allows decimal point,
		-- ([%a]?) captures single optional letter (prefix),
		-- ([%a]+) captures remaining letters (unit).
		local number, prefix, unit = string.match(s, "^(%d+%.?%d*)([%a]?)([%a])$")

		if not number then
			error("Invalid format: " .. s)
		end

		return number, prefix, unit
	end

local function localise_energy(energy)
		local symbols = {
			k = "si-prefix-symbol-kilo",
			M = "si-prefix-symbol-mega",
			G = "si-prefix-symbol-giga",
			T = "si-prefix-symbol-tera",
			P = "si-prefix-symbol-peta",
			E = "si-prefix-symbol-exa",
			Z = "si-prefix-symbol-zetta",
			Y = "si-prefix-symbol-yotta",
			R = "si-prefix-symbol-ronna",
			Q = "si-prefix-symbol-quetta",
			W = "si-unit-symbol-watt",
			J = "si-unit-symbol-joule",
			N = "si-unit-symbol-newton",
		}

		if type(energy) == "string" then
			--local j_index = string.find(energy,"J")
			--local prefix_index = j_index - 1
			local number, prefix, unit = parse_energy_string(energy)
			return { "", tostring(number), " ", { symbols[prefix] or "" }, { symbols[unit] } }
		else
			return "?"
		end
	end
local refueler_shift = 0.4
Muluna:extend{
    {
        type="recipe-category",
        name="muluna-burner-roboport",
    }
}    
local connection_categories = {"default"}
if mods["Krastorio2"] then
    table.insert(connection_categories,"kr-steel-pipe")
end
--error(serpent.block(connection_categories))
for _,roboport in pairs(data.raw["roboport"]) do
    if roboport.is_vacuum_roboport then
        vacuum_roboports[roboport.name] = {}
        local roboport_data = vacuum_roboports[roboport.name]
        if roboport.energy_source.type == "electric" then
            roboport_data.fuel_input_limit = data_util.get_energy_value(roboport.energy_source.input_flow_limit)
            
            if not roboport.custom_tooltip_fields then roboport.custom_tooltip_fields = {} end
            rro.soft_insert(roboport.custom_tooltip_fields,
        
                {
                    name = {"tooltip.muluna-burner-roboport-internal-buffer-refuel-limit"},
                    value = localise_energy(roboport.energy_source.input_flow_limit),
                    quality_header = "quality-tooltip.increases",
                    --quality_values = {}
                })

            roboport.selection_box = Muluna.flib_bounding_box.resize(roboport.selection_box,-refueler_shift)

            local refueler = { 
                type = "assembling-machine",
                name = roboport.name,
                quality_affects_energy_usage = true,
                selection_box = Muluna.flib_bounding_box.resize(roboport.selection_box,refueler_shift),
                collision_box = data.raw["assembling-machine"]["electromagnetic-plant"].collision_box,
                crafting_categories = {"muluna-burner-roboport"},
                selection_priority=48,
                use_mirroring=true,
                flags = {"player-creation","placeable-player","no-automated-item-insertion","no-automated-item-removal"},
                icon = data.raw["item"]["muluna-burner-roboport"].icon,
                allowed_effects = {},
                placeable_by = roboport.placeable_by,
                surface_conditions = {
                    {
                        property="pressure",
                        min=3,
                    },
                },
                custom_tooltip_fields = {
                    {
                        name = {"description.supply-area"},
                        value = tostring(roboport.logistics_radius*2).."x" ..tostring(roboport.logistics_radius*2),
                        order = 1,
                    },
                    {
                        name = {"description.construction-area"},
                        value = tostring(roboport.construction_radius*2).."x" ..tostring(roboport.construction_radius*2),
                        order = 2,
                    },
                    {
                        name = {"description.radar-coverage-distance"},
                        value = "4",
                        order = 3,
                    },
                    
                },
                fluid_boxes = {
                    
                    -- {
                    --     production_type = "input",
                    --     pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
                    --     pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
                    --     pipe_covers = pipecoverspictures(),
                    --     volume = 100,
                    --     secondary_draw_orders = { north = -1 },
                    --     pipe_connections = {{ flow_direction="input-output", direction = defines.direction.south, position = {0.5, 1.5} },
                    --                         { flow_direction="input-output", direction = defines.direction.west, position = {-1.5, 0.5} },
                    --                         { flow_direction="input-output", direction = defines.direction.east, position = {1.5, -0.5} },
                    --                         { flow_direction="input-output", direction = defines.direction.north, position = {-0.5, -1.5} }}
                    -- },
                    -- {
                    --     production_type = "input",
                    --     pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
                    --     pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
                    --     pipe_covers = pipecoverspictures(),
                    --     volume = 100,
                    --     secondary_draw_orders = { north = -1 },
                    --     pipe_connections = {{ flow_direction="input-output", direction = defines.direction.north, position = {-0.5, -1.5} }}
                    -- },
                    {
                        production_type = "output",
                        pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
                        pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
                        pipe_covers = pipecoverspictures(),
                        volume = 100,
                        secondary_draw_orders = { north = -1 },
                        pipe_connections = {{ connection_type = "linked", linked_connection_id = 1, flow_direction="output", direction = defines.direction.north, position = {0, 0} }}
                    }
                },
                crafting_speed = 1,
                energy_source = {
                    type = "fluid",
                    fuel_categories = {"muluna-roboport-propellant"},
                    scale_fluid_usage = true,
                    burns_fluid = true,
                    fluid_box = {
                        production_type = "input",
                        pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
                        pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
                        pipe_covers = pipecoverspictures(),
                        volume = 1000,
                        secondary_draw_orders = { north = -1 },
                        filter = "muluna-roboport-propellant",

                        pipe_connections = {
                            { flow_direction="input-output", direction = defines.direction.south, position = {0.5, 1.5},connection_category=connection_categories},
                            { flow_direction="input-output", direction = defines.direction.west, position = {-1.5, 0.5},connection_category=connection_categories},
                            { flow_direction="input-output", direction = defines.direction.east, position = {1.5, -0.5},connection_category=connection_categories},
                            { flow_direction="input-output", direction = defines.direction.north, position = {-0.5, -1.5},connection_category=connection_categories}}
                        
                    },
                    
                },
                energy_usage = roboport.energy_source.input_flow_limit,
                max_health = roboport.max_health,
                quality_indicator_shift = {refueler_shift,-refueler_shift},
                radius_visualisation_specification =
                    {
                    sprite =
                    {
                        layers = {
                            {
                                filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
                                size = 10
                            }
                        }
                        
                    },
                    distance = roboport.logistics_radius*2,
                    offset = {0, 0}
                    }
            }
            if not refueler.graphics_set then
                local graphics = table.deepcopy(roboport.base)
                graphics.frame_count = 1
                for _,frame in pairs(graphics.layers) do
                    frame.line_length = 1
                    frame.frame_count = 1
                end
                refueler.graphics_set =  {idle_animation = {north = graphics}}
            end
            local minable_result = nil
            roboport.max_health = 10000
            roboport.placeable_by = nil
            
            if roboport.minable then
                minable_result = roboport.minable.result
            end
            refueler.minable = roboport.minable
            roboport.localised_name = {"entity-name.muluna-burner-roboport"}
            --roboport.minable = nil
            -- K2 generates roboport mode variants such as `-logistic-mode` and `-construction-mode`.
            -- Those variants do not have matching item prototypes, so they must keep dropping the
            -- original burner roboport item instead of their entity name.
            if refueler.minable then
                if data.raw["item"][refueler.name] then
                    refueler.minable.result = refueler.name
                else
                    refueler.minable.result = minable_result
                end
            end
            roboport.name = roboport.name .. "-roboport"
            PlanetsLib.constants.pipette_result[roboport.name] = refueler.name
            roboport.is_vacuum_roboport = false
            Muluna:extend{roboport,refueler}
            data.raw["mod-data"]["bplib"].data.extract_entity_names[refueler.name] = true
            data.raw["mod-data"]["bplib"].data.position_entity_names[refueler.name] = true
            data.raw["mod-data"]["bplib"].data.overlap_entity_names[refueler.name] = true
            data.raw["roboport"][refueler.name] = nil
            roboport_data["refueler"] = refueler.name
            roboport_data["roboport"] = roboport.name
            roboport.energy_source.input_flow_limit = "0W"
            roboport.energy_source.render_no_power_icon = false
            roboport.energy_source.render_no_network_icon = false
            if mods["even-pickier-dollies"] then
                -- Even Pickier Dollies performs its collision checks with the entity
                -- it has selected, so the item-placed refueler must outrank the
                -- script-created roboport. The roboport shares the refueler's
                -- collision box, so make it non-colliding; the refueler keeps the
                -- real collision. scripts/even-pickier-dollies.lua then moves the
                -- roboport along with the refueler.
                refueler.selection_priority = 51
                roboport.collision_mask = {layers = {}}
            end
        
        end
        
    end
end

-- local diffs = ""

-- for field,value in pairs(data.raw["rocket-silo"]["rocket-silo"]) do 
--     local val = data.raw["rocket-silo"]["muluna-big-rocket-silo"]
--     if not rro.deep_equals(value,val) then
--          diffs = diffs .. (field .. ": " .. serpent.block(value) .. " vs. " .. (type(val) == "string" and val or serpent.block(val))) .. "\n" 
--         end 

--         end

-- error(diffs)