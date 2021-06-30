-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

----------------------------------------------------------------------------------------------------
-- TECHNOLOGY ICON FUNCTIONS
----------------------------------------------------------------------------------------------------
function reskins.lib.construct_technology_icon(name, inputs)
    -- Inputs required by this function
    -- mod                      - String; Originating mod calling the function, used to determine the subtable to store icon information for later processing
    -- group                    - String; Mod/category folder within the graphics/icons folder

    -- One of the following inputs must be specified; icon_filename being set assumes a flat icon with 1 layer
    -- icon_filename            - String; Used to provide direct reference to source icon outside of the regular format
    -- icon_name                - String; Folder containing the icon files, and the assumed icon file prefix

    -- Optional inputs, used when each entity being fed to this function has unique base or mask images
    -- subgroup                 - String; Folder nested within group, e.g. group/subgroup
    -- icon_base                - String; Prefix for the icon-base.png file
    -- icon_mask                - String; Prefix for the icon-mask.png file
    -- icon_highlights          - String; Prefix for the icon-highlights.png file
    -- icon_layers              - Integer, 1-3; Specify the number of layers to make; 3 by defualt
    -- untinted_icon_mask       - Boolean; determine whether to apply a tint
    -- technology_icon_extras   - Table of additional icon layers to add

    -- Handle compatibility defaults
    local folder_path = inputs.group
    if inputs.subgroup then
        folder_path = inputs.group.."/"..inputs.subgroup
    end

    -- Handle mask tinting defaults
    local icon_tint = inputs.tint
    if inputs.untinted_icon_mask then
        icon_tint = nil
    end

    -- Handle icon_layers defaults
    local icon_layers
    if inputs.technology_icon_filename then
        icon_layers = inputs.technology_icon_layers or 1
    else
        icon_layers = inputs.technology_icon_layers or 3
    end

    -- Some entities have variable bases and masks
    local icon_base = inputs.icon_base or inputs.icon_name
    local icon_mask = inputs.icon_mask or inputs.icon_name
    local icon_highlights = inputs.icon_highlights or inputs.icon_name

    -- Setup icon layers
    local icon_base_layer = {
        icon = inputs.technology_icon_filename or reskins[inputs.mod].directory.."/graphics/technology/"..folder_path.."/"..inputs.icon_name.."/"..icon_base.."-technology-base.png"
    }

    local icon_mask_layer, icon_highlights_layer
    if icon_layers > 1 then
        icon_mask_layer = {
            icon = reskins[inputs.mod].directory.."/graphics/technology/"..folder_path.."/"..inputs.icon_name.."/"..icon_mask.."-technology-mask.png",
            tint = icon_tint
        }

        icon_highlights_layer = {
            icon = reskins[inputs.mod].directory.."/graphics/technology/"..folder_path.."/"..inputs.icon_name.."/"..icon_highlights.."-technology-highlights.png",
            tint = {1, 1, 1, 0}
        }
    end

    -- Construct single-layer icons (flat)
    if icon_layers == 1 then
        inputs.technology_icon = icon_base_layer.icon
    end

    -- Construct double-layer icons
    if icon_layers > 1 then
        inputs.technology_icon = {
            icon_base_layer,
            icon_mask_layer,
        }
    end

    -- Construct triple-layer icons
    if icon_layers > 2 then
        table.insert(inputs.technology_icon, icon_highlights_layer)
    end

    -- Append icon extras as needed
    if inputs.technology_icon_extras then
        -- If we have one layer, we need to convert to an icons table format
        if icon_layers == 1 then
            inputs.technology_icon = {
                { icon = inputs.technology_icon }
            }
        end

        -- Append icon_extras
        for n = 1, #inputs.technology_icon_extras do
            table.insert(inputs.technology_icon, inputs.technology_icon_extras[n])
        end
    end

    -- It may be necessary to put icons back in final fixes, allow for that
    if inputs.defer_to_data_final_fixes or inputs.defer_to_data_updates then
        reskins.lib.store_icons(name, inputs, "technology")
        return
    end

    reskins.lib.assign_technology_icons(name, inputs)
end

function reskins.lib.assign_technology_icons(name, inputs)
    -- Inputs required by this function
    -- technology_icon          - Table or string defining technology icon

    -- Optional inputs (required if making a flat icon)
    -- technology_icon_size     - Pixel size of icons
    -- technology_icon_mipmaps  - Number of mipmaps present in the icon image file

    -- Initialize paths
    local technology = data.raw["technology"][name]

    -- Ensure the technology in question exists
    if technology then
        -- Check whether icon or icons, ensure the key we're not using is erased
        if type(inputs.technology_icon) == "table" then
            -- Set icon_size and icon_mipmaps per icons specification
            for n = 1, #inputs.technology_icon do
                if not inputs.technology_icon[n].icon_size then
                    inputs.technology_icon[n].icon_size = inputs.technology_icon_size
                end

                if not inputs.technology_icon[n].icon_mipmaps then
                    inputs.technology_icon[n].icon_mipmaps = inputs.technology_icon_mipmaps
                end
            end

            technology.icon = nil
            technology.icons = inputs.technology_icon
        else
            technology.icon = inputs.technology_icon
            technology.icons = nil
            technology.icon_size = inputs.technology_icon_size
            technology.icon_mipmaps = inputs.technology_icon_mipmaps
        end
    end
end

function reskins.lib.technology_equipment_overlay(parameters)
    local equipment = "personal"
    local scale = 0.5
    if parameters then
        if parameters.is_vehicle then equipment = "vehicle" end
        if parameters.scale then scale = parameters.scale end
    end

    return
    {
        icon = reskins.lib.directory.."/graphics/technology/"..equipment.."-equipment-overlay.png",
        icon_size = 128,
        icon_mipmaps = 3,
        shift = {64*scale, 100*scale},
        scale = scale,
    }
end

----------------------------------------------------------------------------------------------------
-- STANDARD ICON FUNCTIONS
----------------------------------------------------------------------------------------------------
function reskins.lib.construct_icon(name, tier, inputs)
    -- Inputs required by this function
    -- mod                      - String; Originating mod calling the function, used to determine the subtable to store icon information for later processing
    -- group                    - String; Mod/category folder within the graphics/icons folder

    -- One of the following inputs must be specified; technology_icon_filename being set assumes a flat icon with 1 layer
    -- icon_filename            - String; Used to provide direct reference to source icon outside of the regular format
    -- icon_name                - String; Folder containing the icon files, and the assumed icon file prefix

    -- Optional inputs, used when each entity being fed to this function has unique base or mask images
    -- subgroup                 - String; Folder nested within group, e.g. group/subgroup
    -- tier_labels              - Boolean; Used to override appending tier labels
    -- icon_base                - String; Prefix for the icon-base.png file
    -- icon_mask                - String; Prefix for the icon-mask.png file
    -- icon_highlights          - String; Prefix for the icon-highlights.png file
    -- icon_layers              - Integer, 1-3; Specify the number of layers to make; 3 by defualt
    -- untinted_icon_mask       - Boolean; determine whether to apply a tint
    -- icon_extras              - Table of additional icon layers to add
    -- icon_picture_extras      - Table of additional icon layers to add for on-the-ground items

    local function equipment_background(category)
        local tints = {
            ["offense"] = util.color("e62c2c"),
            ["defense"] = util.color("3282d1"),
            ["energy"] = util.color("32d167"),
            ["utility"] = util.color("cccccc"),
        }

        return
        {
            icon = reskins.lib.directory.."/graphics/icons/backgrounds/equipment-background.png",
            icon_size = 64,
            icon_mipmaps = 4,
            tint = tints[category],
        }
    end

    -- Handle compatibility defaults
    local folder_path = inputs.group
    if inputs.subgroup then
        folder_path = inputs.group.."/"..inputs.subgroup
    end

    -- Handle mask tinting defaults
    local icon_tint = inputs.tint
    if inputs.untinted_icon_mask then
        icon_tint = nil
    end

    -- Handle inputs defaults
    reskins.lib.parse_inputs(inputs)

    -- Handle icon_layers defaults
    local icon_layers
    if inputs.icon_filename then
        icon_layers = inputs.icon_layers or 1
    else
        icon_layers = inputs.icon_layers or 3
    end

    -- Some entities have variable bases and masks
    local icon_base = inputs.icon_base or inputs.icon_name
    local icon_mask = inputs.icon_mask or inputs.icon_name
    local icon_highlights = inputs.icon_highlights or inputs.icon_name

    -- Setup icon layers
    local icon_base_layer = {
        icon = inputs.icon_filename or reskins[inputs.mod].directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_base.."-icon-base.png"
    }

    local icon_mask_layer, icon_highlights_layer
    if icon_layers > 1 then
        icon_mask_layer = {
            icon = reskins[inputs.mod].directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_mask.."-icon-mask.png",
            tint = icon_tint
        }

        icon_highlights_layer = {
            icon = reskins[inputs.mod].directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_highlights.."-icon-highlights.png",
            tint = {1, 1, 1, 0}
        }
    end

    -- Setup picture layers
    local picture_base_layer = {
        filename = inputs.icon_filename or reskins[inputs.mod].directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_base.."-icon-base.png",
        size = inputs.icon_size,
        mipmaps = inputs.icon_mipmaps,
        scale = 0.25
    }

    local picture_mask_layer, picture_highlights_layer
    if icon_layers > 1 then
        picture_mask_layer = {
            filename = reskins[inputs.mod].directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_mask.."-icon-mask.png",
            size = inputs.icon_size,
            mipmaps = inputs.icon_mipmaps,
            scale = 0.25,
            tint = icon_tint
        }

        picture_highlights_layer = {
            filename = reskins[inputs.mod].directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_highlights.."-icon-highlights.png",
            size = inputs.icon_size,
            mipmaps = inputs.icon_mipmaps,
            scale = 0.25,
            blend_mode = "additive"
        }
    end

    -- Construct single-layer icons (flat)
    if icon_layers == 1 then
        inputs.icon = icon_base_layer.icon
        inputs.icon_picture = {
            picture_base_layer
        }
    end

    -- Construct double-layer icons
    if icon_layers > 1 then
        inputs.icon = {
            icon_base_layer,
            icon_mask_layer,
        }
        inputs.icon_picture = {
            layers = {
                picture_base_layer,
                picture_mask_layer,
            }
        }
    end

    -- Construct triple-layer icons
    if icon_layers > 2 then
        table.insert(inputs.icon, icon_highlights_layer)
        table.insert(inputs.icon_picture.layers, picture_highlights_layer)
    end

    -- Append icon extras as needed
    if inputs.icon_extras then
        -- If we have one layer, we need to convert to an icons table format
        if icon_layers == 1 then
            inputs.icon = {
                { icon = inputs.icon }
            }
        end

        -- Append icon_extras
        for n = 1, #inputs.icon_extras do
            table.insert(inputs.icon, inputs.icon_extras[n])
        end
    end

    if inputs.icon_picture_extras then
        -- If we have one layer, we need to convert to an icons table format
        if icon_layers == 1 then
            inputs.icon_picture = {
                layers = inputs.icon_picture
            }
        end

        for n = 1, #inputs.icon_picture_extras do
            table.insert(inputs.icon_picture.layers, inputs.icon_picture_extras[n])
        end
    end

    -- Insert icon background if necessary
    if inputs.equipment_category then
        -- If we have one layer, we need to convert to an icons table format
        if icon_layers == 1 then
            inputs.icon = {
                { icon = inputs.icon }
            }
        end

        -- Insert the equipment background
        table.insert(inputs.icon, 1, equipment_background(inputs.equipment_category))
    end

    -- Append tier labels
    reskins.lib.append_tier_labels(tier, inputs)

    -- It may be necessary to put icons back in final fixes, allow for that
    if inputs.defer_to_data_final_fixes or inputs.defer_to_data_updates then
        reskins.lib.store_icons(name, inputs)
        return
    end

    reskins.lib.assign_icons(name, inputs)
end

function reskins.lib.store_icons(name, inputs, storage)
    -- Inputs required by this function
    -- mod              - Specifies the subtable of reskins where the icons should be stored

    local storage = storage or "icons"

    -- Which stage are we deferring to
    local data_stage
    if inputs.defer_to_data_final_fixes then
        data_stage = "data-final-fixes"
    elseif inputs.defer_to_data_updates then
        data_stage = "data-updates"
    else
        log("[Reskins] "..name.." was improperly stored for deferred icon assignment.")
        return -- Fail quietly; should never get here
    end

    -- Initialize the arrays
    if not reskins[inputs.mod][storage] then
        reskins[inputs.mod][storage] = {}
    end

    if not reskins[inputs.mod][storage][data_stage] then
        reskins[inputs.mod][storage][data_stage] = {}
    end

    -- Store the icon
    reskins[inputs.mod][storage][data_stage][name] = util.copy(inputs)
end

function reskins.lib.assign_icons(name, inputs)
    -- Inputs required by this function
    -- type            - Entity type
    -- icon            - Table or string defining icon
    -- icon_size       - Pixel size of icons
    -- icon_mipmaps    - Number of mipmaps present in the icon image file

    -- Initialize paths
    local entity
    if inputs.type then
        entity = data.raw[inputs.type][name]
    end

    -- Recipes are exceptions to the usual pattern
    local item, item_with_data, explosion, remnant
    if inputs.type ~= "recipe" then
        item = data.raw["item"][name]
        item_with_data = data.raw["item-with-entity-data"][name]
        explosion = data.raw["explosion"][name.."-explosion"]
        remnant = data.raw["corpse"][name.."-remnants"]
    end

    -- Check whether icon or icons, ensure the key we're not using is erased
    if type(inputs.icon) == "table" then
        -- Set icon_size and icon_mipmaps per icons specification
        for n = 1, #inputs.icon do
            if not inputs.icon[n].icon_size then
                inputs.icon[n].icon_size = inputs.icon_size
            end

            if not inputs.icon[n].icon_mipmaps then
                inputs.icon[n].icon_mipmaps = inputs.icon_mipmaps or 1
            end
        end

        -- Create icons that have multiple layers
        if entity then
            entity.icon = nil
            entity.icons = inputs.icon
        end

        if item then
            item.icon = nil
            item.icons = inputs.icon
        end

        if item_with_data then
            item_with_data.icon = nil
            item_with_data.icons = inputs.icon
        end

        if explosion then
            explosion.icon = nil
            explosion.icons = inputs.icon
        end

        if remnant then
            remnant.icon = nil
            remnant.icons = inputs.icon
        end
    else
        -- Create icons that do not have multiple layers
        if entity then
            entity.icons = nil
            entity.icon = inputs.icon
            entity.icon_size = inputs.icon_size
            entity.icon_mipmaps = inputs.icon_mipmaps
        end

        if item then
            item.icons = nil
            item.icon = inputs.icon
            item.icon_size = inputs.icon_size
            item.icon_mipmaps = inputs.icon_mipmaps
        end

        if item_with_data then
            item_with_data.icons = nil
            item_with_data.icon = inputs.icon
            item_with_data.icon_size = inputs.icon_size
            item_with_data.icon_mipmaps = inputs.icon_mipmaps
        end

        if explosion then
            explosion.icons = nil
            explosion.icon = inputs.icon
            explosion.icon_size = inputs.icon_size
            explosion.icon_mipmaps = inputs.icon_mipmaps
        end

        if remnant then
            remnant.icons = nil
            remnant.icon = inputs.icon
            remnant.icon_size = inputs.icon_size
            remnant.icon_mipmaps = inputs.icon_mipmaps
        end
    end

    -- Handle picture definitions
    if entity then
        if inputs.icon_picture and inputs.make_entity_pictures then
            entity.pictures = inputs.icon_picture
        end
    end

    if item then
        if inputs.icon_picture and inputs.make_icon_pictures then
            item.pictures = inputs.icon_picture
        end
    end

    -- item-with-entity-data prototypes ignore pictures field as of 1.0
    -- this has been left active in the hopes the default behavior is adjusted
    if item_with_data then
        if inputs.icon_picture and inputs.make_icon_pictures then
            item_with_data.pictures = inputs.icon_picture
        end
    end

    -- Clear out recipe so that icon is inherited properly
    if inputs.type ~= "recipe" then
        reskins.lib.clear_icon_specification(name, "recipe")
    end
end

function reskins.lib.append_tier_labels_to_vanilla_icon(name, tier, inputs)
    -- Inputs required by this function
    -- type            - Entity type

    -- Prevent cross-contamination
    local inputs = util.copy(inputs)
    local type = inputs.type or "item"

    -- Handle required parameters
    reskins.lib.parse_inputs(inputs)

    -- Extact the icon
    if data.raw[type][name].icons then
        inputs.icon = util.copy(data.raw[type][name].icons)

        -- Set icon_size and icon_mipmaps per icons specification, setup icon_picture
        inputs.icon_picture = {}
        for n = 1, #inputs.icon do
            if not inputs.icon[n].icon_size then
                inputs.icon[n].icon_size = data.raw[type][name].icon_size
            end

            if not inputs.icon[n].icon_mipmaps then
                inputs.icon[n].icon_mipmaps = data.raw[type][name].icon_mipmaps or 1
            end

            inputs.icon_picture[n] = {
                filename = inputs.icon[n].icon,
                size = inputs.icon[n].icon_size,
                tint = inputs.icon[n].tint,
                shift = inputs.icon[n].shift,
                scale = 0.25*(inputs.icon[n].scale or 1),
                mipmaps = inputs.icon[n].icon_mipmaps or 1,
            }
        end
    else
        inputs.icon = {
            {
                icon = data.raw[type][name].icon,
                icon_size = data.raw[type][name].icon_size,
                icon_mipmaps = data.raw[type][name].icon_mipmaps,
            }
        }

        inputs.icon_picture = {
            {
                filename = data.raw[type][name].icon,
                size = data.raw[type][name].icon_size,
                scale = 0.25,
                mipmaps = data.raw[type][name].icon_mipmaps,
            }
        }
    end

    reskins.lib.append_tier_labels(tier, inputs)

    -- It may be necessary to put icons back in final fixes, allow for that
    if inputs.defer_to_data_final_fixes or inputs.defer_to_data_updates then
        reskins.lib.store_icons(name, inputs)
        return
    end

    reskins.lib.assign_icons(name, inputs)
end

function reskins.lib.append_tier_labels(tier, inputs)
    -- Inputs required by this function
    -- icon             - Table containing an icon/icons definition
    -- tier_labels      - Determines whether tier labels are appended

    if settings.startup["reskins-lib-icon-tier-labeling"].value == true and tier > 0 and inputs.tier_labels == true then
        -- Ensure inputs.icon is the right format
        if type(inputs.icon) ~= "table" then
            inputs.icon = {{icon = inputs.icon}}
        end

        -- Append the tier labels
        local icon_style = settings.startup["reskins-lib-icon-tier-labeling-style"].value
        table.insert(inputs.icon, {
            icon = reskins.lib.directory.."/graphics/icons/tiers/"..icon_style.."/"..tier..".png",
            icon_size = 64,
            icon_mipmaps = 4,
        }
    )
        table.insert(inputs.icon, {
            icon = reskins.lib.directory.."/graphics/icons/tiers/"..icon_style.."/"..tier..".png",
            icon_size = 64,
            icon_mipmaps = 4,
            tint = reskins.lib.adjust_alpha(reskins.lib.tint_index[tier], 0.75)
        })
    end
end

----------------------------------------------------------------------------------------------------
-- UNIVERSAL ICON FUNCTIONS
----------------------------------------------------------------------------------------------------
function reskins.lib.clear_icon_specification(name, type)
    -- Inputs required by this function:
    -- type        - Entity type

    -- Fetch entity
    local entity = data.raw[type][name]

    -- If the entity exists, clear the icon specification
    if entity then
        entity.icon = nil
        entity.icons = nil
        entity.icon_size = nil
        entity.icon_mipmaps = nil
    end
end

function reskins.lib.create_icons_from_list(table, inputs)
    -- Setup input defaults
    reskins.lib.parse_inputs(inputs)

    for name, map in pairs(table) do
        -- Fetch the icon
        local icon_type = map.type or inputs.type or "item"
        local icon = data.raw[icon_type][name]

        -- Check if icon exists, if not, skip this iteration
        if not icon then goto continue end

        -- Work with a local copy of inputs
        local inputs = util.copy(inputs)

        -- Handle input parameters
        inputs.type = map.type or inputs.type or nil
        inputs.mod = map.mod or inputs.mod
        inputs.group = map.group or inputs.group
        inputs.icon_size = map.icon_size or inputs.icon_size
        inputs.icon_mipmaps = map.icon_mipmaps or inputs.icon_mipmaps
        inputs.technology_icon_size = map.technology_icon_size or inputs.technology_icon_size
        inputs.technology_icon_mipmaps = map.technology_icon_mipmaps or inputs.technology_icon_mipmaps
        inputs.subgroup = map.subgroup or inputs.subgroup or nil

        -- Transcribe icon properties
        inputs.technology_icon_layers = map.technology_icon_layers or inputs.technology_icon_layers or nil
        inputs.icon_layers = map.icon_layers or inputs.icon_layers or nil
        inputs.technology_icon_extras = map.technology_icon_extras or inputs.technology_icon_extras or nil
        inputs.icon_extras = map.icon_extras or inputs.icon_extras or nil
        inputs.icon_picture_extras = map.icon_picture_extras or inputs.icon_picture_extras or nil

        -- Handle all the boolean overrides
        if map.make_icon_pictures == false then
            inputs.make_icon_pictures = false
        else
            inputs.make_icon_pictures = map.make_icon_pictures or inputs.make_icon_pictures
        end

        if map.make_entity_pictures == false then
            inputs.make_entity_pictures = false
        else
            inputs.make_entity_pictures = map.make_entity_pictures or inputs.make_entity_pictures
        end

        if map.defer_to_data_updates == false then
            inputs.defer_to_data_updates = false
        else
            inputs.defer_to_data_updates = map.defer_to_data_updates or inputs.defer_to_data_updates
        end

        if map.defer_to_data_final_fixes == false then
            inputs.defer_to_data_final_fixes = false
        else
            inputs.defer_to_data_final_fixes = map.defer_to_data_final_fixes or inputs.defer_to_data_final_fixes
        end

        local flat_icon
        if map.flat_icon == false then
            flat_icon = false
        else
            flat_icon = map.flat_icon or inputs.flat_icon
        end

        -- Prevent double assignment
        if inputs.defer_to_data_final_fixes then inputs.defer_to_data_updates = nil end

        -- Construct the icon
        if flat_icon then
            -- Setup filename details
            local image = map.image or name
            local path = inputs.group
            if inputs.subgroup then
                path = inputs.group.."/"..inputs.subgroup
            end

            -- Make the icon
            if inputs.type == "technology" then
                inputs.technology_icon_filename = map.technology_icon_filename or inputs.technology_icon_filename or reskins[inputs.mod].directory.."/graphics/technology/"..path.."/"..image..".png"
                reskins.lib.construct_technology_icon(name, inputs)
            else
                inputs.icon_filename = map.icon_filename or inputs.icon_filename or reskins[inputs.mod].directory.."/graphics/icons/"..path.."/"..image..".png"
                reskins.lib.construct_icon(name, 0, inputs)
            end
        else
            -- Handle tier
            local tier = map.tier or 0
            if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
                tier = map.prog_tier or map.tier or 0
            end

            -- Handle tints
            inputs.tint = map.tint or inputs.tint or reskins.lib.tint_index[tier]

            -- Adjust tint to belt-type if necessary
            if map.uses_belt_mask == true then
                inputs.tint = reskins.lib.belt_tint_index[tier]
            end

            -- Handle icon_name and related parameters
            inputs.icon_name = map.icon_name or inputs.icon_name
            inputs.icon_base = map.icon_base or inputs.icon_base or nil
            inputs.icon_mask = map.icon_mask or inputs.icon_mask or nil
            inputs.icon_highlights = map.icon_highlights or inputs.icon_highlights or nil

            -- Make the icon
            if inputs.type == "technology" then
                reskins.lib.construct_technology_icon(name, inputs)
            else
                reskins.lib.construct_icon(name, tier, inputs)
            end
        end

        -- Label to skip to next iteration
        ::continue::
    end
end

function reskins.lib.assign_deferred_icons(mod, data_stage)
    -- Item Icons
    if reskins[mod].icons and reskins[mod].icons[data_stage] then
        for name, inputs in pairs(reskins[mod].icons[data_stage]) do
            reskins.lib.assign_icons(name, inputs)
        end
    end

    -- Technology Icons
    if reskins[mod].technology and reskins[mod].technology[data_stage] then
        for name, inputs in pairs(reskins[mod].technology[data_stage]) do
            reskins.lib.assign_technology_icons(name, inputs)
        end
    end
end

function reskins.lib.composite_existing_icons(target_name, target_type, icons)
    -- icons = table of ["name"] = {type, shift, scale} or ["name"] = {icon or icons}, where type, shift, and scale are optional, and icon/icons ignores other param values

    -- Check to ensure the target is available
    local target = data.raw[target_type][target_name]
    if not target then return end

    -- Initialize the icons table
    local composite_icon = {}

    -- Iterate through the list of icons to composite
    for name, params in pairs(icons) do
        if params.icons then
            for _, layer in pairs(params.icons) do
                table.insert(composite_icon, {
                    icon = layer.icon,
                    icon_size = layer.icon_size,
                    icon_mipmaps = layer.icon_mipmaps,
                    scale = layer.scale or (32 / layer.icon_size),
                    shift = layer.shift,
                    tint = layer.tint,
                })
            end
        elseif params.icon then
            table.insert(composite_icon, {
                icon = params.icon.icon,
                icon_size = params.icon.icon_size,
                icon_mipmaps = params.icon.icon_mipmaps,
                scale = params.icon.scale or (32 / params.icon.icon_size),
                shift = params.icon.shift,
                tint = params.icon.tint,
            })
        else
            -- Check to ensure the object is available to copy from; abort if not
            local source_type = params.type or "item"

            -- Copy the current entity, return if it doesn't exist
            if not data.raw[source_type][name] then return end
            local entity = util.copy(data.raw[source_type][name])

            -- Check for icons definition
            if entity.icons then
                -- Transcribe layers to the composite_icon table
                for _, layer in pairs(entity.icons) do
                    local icon_size = layer.icon_size or entity.icon_size
                    table.insert(composite_icon, {
                        icon = layer.icon,
                        icon_size = icon_size,
                        icon_mipmaps = layer.icon_mipmaps or entity.icon_mipmaps,
                        tint = layer.tint,
                        scale = layer.scale or (32 / icon_size) * (params.scale or 1),
                        shift = {
                            (layer.shift and (layer.shift[1] or layer.shift.x) or 0) * (params.scale or 1) + (params.shift and (params.shift[1] or params.shift.x) or 0),
                            (layer.shift and (layer.shift[2] or layer.shift.y) or 0) * (params.scale or 1) + (params.shift and (params.shift[2] or params.shift.y) or 0),
                        }
                    })
                end
            -- Standard icon
            else
                -- Fully define an icons layer
                table.insert(composite_icon, {
                    icon = entity.icon,
                    icon_size = entity.icon_size,
                    icon_mipmaps = entity.icon_mipmaps,
                    scale = params.scale and (params.scale * 32 / entity.icon_size) or (32 / entity.icon_size),
                    shift = {
                        (params.shift and (params.shift[1] or params.shift.x) or 0),
                        (params.shift and (params.shift[2] or params.shift.y) or 0),
                    }
                })
            end
        end
    end

    -- Assign the composite icon
    reskins.lib.assign_icons(target_name, {type = target_type, icon = composite_icon})
end

function reskins.lib.create_icon_variations(parameters)
    local icon_picture = {}
    local folder_path = parameters.group
    if parameters.subgroup then folder_path = parameters.group.."/"..parameters.subgroup end

    for n = 1, parameters.variations do
        local suffix = ".png"
        if n > 1 then suffix = "-"..(n-1)..".png" end

        if parameters.glows then
            table.insert(icon_picture, {
                layers = {
                    {
                        filename = reskins[parameters.mod].directory.."/graphics/icons/"..folder_path.."/"..parameters.icon.."/"..parameters.icon..suffix,
                        size = 64,
                        scale = 0.25,
                        mipmap_count = 4
                    },
                    {
                        filename = reskins[parameters.mod].directory.."/graphics/icons/"..folder_path.."/"..parameters.icon.."/"..parameters.icon..suffix,
                        blend_mode = "additive",
                        draw_as_light = true,
                        tint = {r = 0.3, g = 0.3, b = 0.3, a = 0.3},
                        size = 64,
                        scale = 0.25,
                        mipmap_count = 4
                    }
                }
            })
        else
            table.insert(icon_picture, {
                filename = reskins[parameters.mod].directory.."/graphics/icons/"..folder_path.."/"..parameters.icon.."/"..parameters.icon..suffix,
                size = 64,
                scale = 0.25,
                mipmap_count = 4
            })
        end
    end

    return icon_picture
end

function reskins.lib.lit_icon_pictures_layer(mod, light, tint)
    return {
        filename = reskins[mod].directory.."/graphics/icons/lights/"..light.."-light.png",
        draw_as_light = true,
        flags = {"light"},
        tint = tint,
        size = 64,
        scale = 0.25,
        mipmap_count = 4,
    }
end