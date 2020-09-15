-- Copyright (c) 2020 Kirazy
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
    local icon_layers = inputs.technology_icon_layers or 3
    if inputs.technology_icon_filename then
        icon_layers = 1
    end

    -- Some entities have variable bases and masks
    local icon_base = inputs.icon_base or inputs.icon_name
    local icon_mask = inputs.icon_mask or inputs.icon_name
    local icon_highlights = inputs.icon_highlights or inputs.icon_name

    -- Setup icon layers
    local icon_base_layer = {
        icon = inputs.technology_icon_filename or inputs.directory.."/graphics/technology/"..folder_path.."/"..inputs.icon_name.."/"..icon_base.."-technology-base.png"
    }

    local icon_mask_layer, icon_highlights_layer
    if icon_layers > 1 then
        icon_mask_layer = {
            icon = inputs.directory.."/graphics/technology/"..folder_path.."/"..inputs.icon_name.."/"..icon_mask.."-technology-mask.png",
            tint = icon_tint
        }

        icon_highlights_layer = {
            icon = inputs.directory.."/graphics/technology/"..folder_path.."/"..inputs.icon_name.."/"..icon_highlights.."-technology-highlights.png",
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
                inputs.technology_icon
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
            ["logistic"] = util.color("4d4d4d"),
        }

        return
        {
            icon = reskins.lib.directory.."/graphics/icons/backgrounds/equipment-background.png",
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
    local icon_layers = inputs.icon_layers or 3
    if inputs.icon_filename then
        icon_layers = 1
    end

    -- Some entities have variable bases and masks
    local icon_base = inputs.icon_base or inputs.icon_name
    local icon_mask = inputs.icon_mask or inputs.icon_name
    local icon_highlights = inputs.icon_highlights or inputs.icon_name

    -- Setup icon layers
    local icon_base_layer = {
        icon = inputs.icon_filename or inputs.directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_base.."-icon-base.png"
    }

    local icon_mask_layer, icon_highlights_layer
    if icon_layers > 1 then
        icon_mask_layer = {
            icon = inputs.directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_mask.."-icon-mask.png",
            tint = icon_tint
        }

        icon_highlights_layer = {
            icon = inputs.directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_highlights.."-icon-highlights.png",
            tint = {1, 1, 1, 0}
        }
    end

    -- Setup picture layers
    local picture_base_layer = {
        filename = inputs.icon_filename or inputs.directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_base.."-icon-base.png",
        size = inputs.icon_size,
        mipmaps = inputs.icon_mipmaps,
        scale = 0.25
    }

    local picture_mask_layer, picture_highlights_layer
    if icon_layers > 1 then
        picture_mask_layer = {
            filename = inputs.directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_mask.."-icon-mask.png",
            size = inputs.icon_size,
            mipmaps = inputs.icon_mipmaps,
            scale = 0.25,
            tint = icon_tint
        }

        picture_highlights_layer = {
            filename = inputs.directory.."/graphics/icons/"..folder_path.."/"..inputs.icon_name.."/"..icon_highlights.."-icon-highlights.png",
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
                inputs.icon
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
            inputs.icon = {
                inputs.icon
            }
        end

        for n = 1, #inputs.icon_picture_extras do
            table.insert(inputs.icon_picture.layers, inputs.icon_picture_extras[n])
        end
    end

    -- Insert icon background if necessary
    if inputs.equipment_category then
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
    local item = data.raw["item"][name]
    local item_with_data = data.raw["item-with-entity-data"][name]
    local explosion = data.raw["explosion"][name.."-explosion"]
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Check whether icon or icons, ensure the key we're not using is erased
    if type(inputs.icon) == "table" then
        -- Set icon_size and icon_mipmaps per icons specification
        for n = 1, #inputs.icon do
            if not inputs.icon[n].icon_size then
                inputs.icon[n].icon_size = inputs.icon_size
            end

            if not inputs.icon[n].icon_mipmaps then
                inputs.icon[n].icon_mipmaps = inputs.icon_mipmaps
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
        if inputs.icon_picture and inputs.make_icon_pictures  then
            item.pictures = inputs.icon_picture
        end
    end

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

    -- Handle required parameters
    reskins.lib.parse_inputs(inputs)

    -- Fetch the icon; vanilla icons are strictly an icon definition
    inputs.icon = {
        {
            icon = data.raw["item"][name].icon
        }
    }

    reskins.lib.append_tier_labels(tier, inputs)

    inputs.icon_picture = {
        {
            filename = data.raw["item"][name].icon,
            size = 64,
            scale = 0.25,
            mipmaps = 4
        }
    }

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
        table.insert(inputs.icon, {icon = reskins.lib.directory.."/graphics/icons/tiers/"..icon_style.."/"..tier..".png"})
        table.insert(inputs.icon, {
            icon = reskins.lib.directory.."/graphics/icons/tiers/"..icon_style.."/"..tier..".png",
            tint = reskins.lib.adjust_alpha(reskins.lib.tint_index["tier-"..tier], 0.75)
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

        -- Work on a local copy of inputs
        local inputs = util.copy(inputs)

        -- Handle input parameters
        inputs.type = map.type or inputs.type or nil
        inputs.group = map.group or inputs.group
        inputs.subgroup = map.subgroup or inputs.subgroup or nil

        -- Handle all the boolean overrides
        if map.make_icon_pictures == false then
            inputs.make_icon_pictures = false
        else
            inputs.make_icon_pictures = map.make_icon_pictures or inputs.make_icon_pictures
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
            local path
            if inputs.subgroup then
                path = inputs.group.."/"..inputs.subgroup
            else
                path = inputs.group
            end

            -- Make the icon
            if inputs.type == "technology" then
                inputs.technology_icon_filename = inputs.directory.."/graphics/technology/"..path.."/"..image..".png"
                reskins.lib.construct_technology_icon(name, inputs)
            else
                inputs.icon_filename = inputs.directory.."/graphics/icons/"..path.."/"..image..".png"
                reskins.lib.construct_icon(name, 0, inputs)
            end
        else
            -- Transcribe icon properties
            inputs.technology_icon_layers = map.technology_icon_layers or inputs.technology_icon_layers or nil
            inputs.icon_layers = map.icon_layers or inputs.icon_layers or nil
            inputs.technology_icon_extras = map.technology_icon_extras or inputs.technology_icon_extras or nil
            inputs.icon_extras = map.icon_extras or inputs.icon_extras or nil
            inputs.icon_picture_extras = map.icon_picture_extras or inputs.icon_picture_extras or nil

            -- Handle tier
            local tier = map.tier or 0
            if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
                tier = map.prog_tier or map.tier or 0
            end

            -- Handle tints
            inputs.tint = map.tint or inputs.tint or reskins.lib.tint_index["tier-"..tier]

            -- Adjust tint to belt-type if necessary
            if map.uses_belt_mask == true then
                inputs.tint = reskins.lib.belt_mask_tint(inputs.tint)
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