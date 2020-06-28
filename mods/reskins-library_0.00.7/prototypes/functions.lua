-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Core Library
--     
-- See LICENSE.md in the project directory for license information.

-- Make our function host
if not reskins then reskins = {} end
if not reskins.lib then reskins.lib = {} end

-- Library directory
reskins.lib.directory = "__reskins-library__"

-- Most entities have a common process for reskinning, so consolidate the other functions under one superfunction for ease of use
function reskins.lib.setup_standard_entity(name, tier, inputs)
    -- Parse inputs
    reskins.lib.parse_inputs(inputs)    
    
    -- Create particles and explosions   
    if inputs.make_explosions then   
        reskins.lib.create_explosions_and_particles(name, inputs)
    end
  
    -- Create remnants
    if inputs.make_remnants then
        reskins.lib.create_remnant(name, inputs)
    end

    -- Create icons
    if inputs.make_icons then
        reskins.lib.construct_icon(name, tier, inputs)
    end
end

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
    if inputs.reassign_in_final_fixes then
        reskins.lib.store_icons(name, inputs, "technology")
    end

    reskins.lib.assign_technology_icons(name, inputs)
end

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
    if inputs.icon_background then
        table.insert(inputs.icon, 1, {
            icon = reskins.lib.directory.."/graphics/icons/backgrounds/"..inputs.icon_background.."-icon-background.png"
        })
    end

    -- Append tier labels
    reskins.lib.append_tier_labels(tier, inputs)

    -- It may be necessary to put icons back in final fixes, allow for that
    if inputs.reassign_in_final_fixes then
        reskins.lib.store_icons(name, inputs)
    end

    reskins.lib.assign_icons(name, inputs)
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
    if inputs.reassign_in_final_fixes then
        reskins.lib.store_icons(name, inputs)
    end

    reskins.lib.assign_icons(name, inputs)
end

-- Function to store icons in a table for the given mod calling the function
function reskins.lib.store_icons(name, inputs, storage)
    -- Inputs required by this function
    -- mod              - Specifies the subtable of reskins where the icons should be stored

    local storage = storage or "icons"

    reskins[inputs.mod][storage][name] = util.copy(inputs)
end

-- Parses the main inputs table of parameters
function reskins.lib.parse_inputs(inputs)
    -- Check that we have a particles table
    if not inputs.particles then
        inputs.make_explosions = false
    end
    
    -- Constructs defaults for optional input parameters.
    inputs.icon_size       = inputs.icon_size        or 64      -- Pixel size of icons
    inputs.icon_mipmaps    = inputs.icon_mipmaps     or 4       -- Number of mipmaps present in the icon image file       
    inputs.make_explosions = (inputs.make_explosions ~= false)  -- Create explosions; default true
    inputs.make_remnants   = (inputs.make_remnants   ~= false)  -- Create remnant; default true
    inputs.make_icons      = (inputs.make_icons      ~= false)  -- Create icons; default true
    inputs.tier_labels     = (inputs.tier_labels     ~= false)  -- Display tier labels; default true

    return inputs
end

-- Insert tier label icon entries to a given icon definition
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
        icon_style = settings.startup["reskins-lib-icon-tier-labeling-style"].value
        table.insert(inputs.icon, {icon = reskins.lib.directory.."/graphics/icons/tiers/"..icon_style.."/"..tier..".png"})
        table.insert(inputs.icon, {
            icon = reskins.lib.directory.."/graphics/icons/tiers/"..icon_style.."/"..tier..".png",
            tint = reskins.lib.adjust_alpha(reskins.lib.tint_index["tier-"..tier], 0.75)
        })
    end
end

function reskins.lib.assign_order(name, inputs)
    -- Inputs required by this function
    -- type
    -- sort_order
    -- sort_group
    -- sort_subgroup

    -- Initialize paths
    local entity
    if inputs.type then
        entity = data.raw[inputs.type][name]
    end
    local item = data.raw["item"][name]
    local explosion = data.raw["explosion"][name.."-explosion"]
    local remnant = data.raw["corpse"][name.."-remnants"]

    if entity then
        entity.order = inputs.sort_order
        entity.group = inputs.sort_group
        entity.subgroup = inputs.sort_subgroup
    end

    if item then
        item.order = inputs.sort_order
        item.group = inputs.sort_group
        item.subgroup = inputs.sort_subgroup
    end

    if explosion then
        explosion.order = inputs.sort_order
        explosion.group = inputs.sort_group
        explosion.subgroup = inputs.sort_subgroup
    end

    if remnant then
        remnant.order = inputs.sort_order
        remnant.group = inputs.sort_group
        remnant.subgroup = inputs.sort_subgroup
    end
end

function reskins.lib.set_icon_size(inputs)
    
end

function reskins.lib.assign_technology_icons(name, inputs)
    -- Inputs required by this function
    -- technology_icon  - Table or string defining technology icon

    -- Initialize paths
    technology = data.raw["technology"][name]

    -- Ensure the technology in question exists
    if technology then
        -- Check whether icon or icons, ensure the key we're not using is erased
        if type(inputs.technology_icon) == "table" then
            -- Set icon_size and icon_mipmaps per icons specification
            for n = 1, #inputs.technology_icon do
                if not inputs.technology_icon[n].icon_size then
                    inputs.technology_icon[n].icon_size = 128
                end
            end

            technology.icon = nil
            technology.icons = inputs.technology_icon
        else
            technology.icon = inputs.technology_icon
            technology.icons = nil
        end

        -- Set top-level icon_size
        technology.icon_size = 128
    end
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
            if inputs.make_entity_pictures then
                entity.pictures = inputs.icon_picture
            end
        end

        if item then
            item.icon = nil
            item.icons = inputs.icon
            if inputs.icon_picture then
                item.pictures = inputs.icon_picture
            end
        end

        if item_with_data then
            item_with_data.icon = nil
            item_with_data.icons = inputs.icon
            if inputs.icon_picture then
                item_with_data.pictures = inputs.icon_picture
            end
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
        end

        if item then
            item.icons = nil        
            item.icon = inputs.icon
            if inputs.icon_picture then
                item.pictures = inputs.icon_picture
            end
        end

        if item_with_data then
            item_with_data.icons = nil        
            item_with_data.icon = inputs.icon
            if inputs.icon_picture then
                item_with_data.pictures = inputs.icon_picture
            end
        end

        if explosion then
            explosion.icons = nil        
            explosion.icon = inputs.icon
        end

        if remnant then
            remnant.icons = nil
            remnant.icon = inputs.icon
        end
    end

    -- Set top-level icon_size and icon_mipmaps
    if entity then
        entity.icon_size = inputs.icon_size
        entity.icon_mipmaps = inputs.icon_mipmaps          
    end

    if item then
        item.icon_size = inputs.icon_size
        item.icon_mipmaps = inputs.icon_mipmaps 
    end

    if item_with_data then
        item_with_data.icon_size = inputs.icon_size
        item_with_data.icon_mipmaps = inputs.icon_mipmaps 
    end

    if explosion then
        explosion.icon_size = inputs.icon_size
        explosion.icon_mipmaps = inputs.icon_mipmaps
    end
    
    if remnant then
        remnant.icon_size = inputs.icon_size
        remnant.icon_mipmaps = inputs.icon_mipmaps
    end
end

-- Create remnant entity; reskin the remnant after calling this function
function reskins.lib.create_remnant(name, inputs)
    -- Inputs required by this function:
    -- base_entity - Entity to copy remnant prototype from
    -- type        - Entity type

    -- Copy remnant prototype
    local remnant = util.copy(data.raw["corpse"][inputs.base_entity.."-remnants"])
    remnant.name = name.."-remnants"
    data:extend({remnant})      

    -- Assign corpse to originating entity
    data.raw[inputs.type][name]["corpse"] = remnant.name
end

-- Create explosion entity; create particles after calling this function
function reskins.lib.create_explosion(name, inputs)
    -- Inputs required by this function:
    -- base_entity - Entity to copy explosion prototype from
    -- type        - Entity type

    local explosion = util.copy(data.raw["explosion"][inputs.base_entity.."-explosion"])
    explosion.name = name.."-explosion"
    data:extend({explosion})

    -- Assign explosion to originating entity
    data.raw[inputs.type][name]["dying_explosion"] = explosion.name
end

-- Create tinted particle
function reskins.lib.create_particle(name, base_entity, base_particle, key, tint)
    -- Copy the particle prototype
    local particle = util.copy(data.raw["optimized-particle"][base_entity.."-"..base_particle])
    particle.name = name.."-"..base_particle.."-tinted"
    particle.pictures.sheet.tint = tint
    particle.pictures.sheet.hr_version.tint = tint
    data:extend({particle})

    -- Assign particle to originating explosion
    data.raw["explosion"][name.."-explosion"]["created_effect"]["action_delivery"]["target_effects"][key].particle_name = particle.name
end

-- Batch the explosion and particle function together for ease of use
function reskins.lib.create_explosions_and_particles(name, inputs)
    -- Inputs required by this function:
    -- base_entity - Entity to copy explosion prototype from
    -- type        - Entity type
    -- tint        - Particle color

    -- Create explosions and related particles
    reskins.lib.create_explosion(name, inputs)
        
    -- Create and assign needed particles with appropriate tints
    for particle, key in pairs(inputs.particles) do 
        -- Create and assign the particle
        reskins.lib.create_particle(name, inputs.base_entity, reskins.lib.particle_index[particle], key, inputs.tint)
    end
end

-- Adjust the alpha value of a given tint
function reskins.lib.adjust_alpha(tint, alpha)
    adjusted_tint = {r = tint.r, g = tint.g, b = tint.b, a = alpha}
    return adjusted_tint
end

-- Shift the rgb values of a given tint by shift amount, and optionally adjust the alpha value
function reskins.lib.adjust_tint(tint, shift, alpha)
    local adjusted_tint = {}

    -- Adjust the tint
    adjusted_tint.r = tint.r + shift
    adjusted_tint.g = tint.g + shift
    adjusted_tint.b = tint.b + shift
    adjusted_tint.a = alpha or tint.a

    -- Check boundary conditions
    if adjusted_tint.r > 1 then
        adjusted_tint.r = 1
    elseif adjusted_tint.r < 0 then
        adjusted_tint.r = 0
    end

    if adjusted_tint.g > 1 then
        adjusted_tint.g = 1
    elseif adjusted_tint.g < 0 then
        adjusted_tint.g = 0
    end

    if adjusted_tint.b > 1 then
        adjusted_tint.b = 1
    elseif adjusted_tint.b < 0 then
        adjusted_tint.b = 0
    end

    return adjusted_tint
end

-- This function prepares a given tint for entities that use a base and mask layer instead of a base, mask, and highlights layer
-- Primarily this means belt-related entities
function reskins.lib.belt_mask_tint(tint)
    -- Define correction constants
    local color_shift = 40/255
    local alpha = 0.82

    -- Color correct the tint
    belt_mask_tint = reskins.lib.adjust_tint(tint, color_shift, alpha)

    return belt_mask_tint
end

if settings.startup["reskins-lib-customize-tier-colors"].value == true then
    reskins.lib.tint_index =
    {
        ["tier-0"] = util.color(settings.startup["reskins-lib-custom-colors-tier-0"].value),
        ["tier-1"] = util.color(settings.startup["reskins-lib-custom-colors-tier-1"].value),
        ["tier-2"] = util.color(settings.startup["reskins-lib-custom-colors-tier-2"].value),
        ["tier-3"] = util.color(settings.startup["reskins-lib-custom-colors-tier-3"].value),
        ["tier-4"] = util.color(settings.startup["reskins-lib-custom-colors-tier-4"].value),
        ["tier-5"] = util.color(settings.startup["reskins-lib-custom-colors-tier-5"].value),
    }
else
    reskins.lib.tint_index =
    {
        ["tier-0"] = util.color("4d4d4d"),
        ["tier-1"] = util.color("de9400"),
        ["tier-2"] = util.color("c20600"),
        ["tier-3"] = util.color("1b87c2"),
        ["tier-4"] = util.color("a600bf"),
        ["tier-5"] = util.color("23de55"),
    }
end

reskins.lib.particle_index = 
{
    ["tiny-stone"] = "stone-particle-tiny",
    ["small"] = "metal-particle-small",
    ["small-stone"] = "stone-particle-small",
    ["medium"] = "metal-particle-medium",
    ["medium-long"] = "long-metal-particle-medium",
    ["medium-stone"] = "stone-particle-medium",
    ["big"] = "metal-particle-big",
    ["big-stone"] = "stone-particle-big",
    ["big-tint"] = "metal-particle-big-tint",

}

local fields = {
    "shift", 
    "scale", 
    "collision_box",
    "selection_box",
    "north_position", 
    "south_position", 
    "east_position", 
    "west_position",
    "window_bounding_box",
    "circuit_wire_connection_points",
}

local ignored_fields ={
    "fluid_boxes",
    "fluid_box",
    "energy_source",
    "input_fluid_box",
}

function reskins.lib.scale(object, scale)
    -- Walk table and scale values contained within
    local function scale_subtable(object, scale)
        for key, value in pairs(object) do
            if type(value) == "table" then
                scale_subtable(value, scale)
            elseif type(value) == "number" then
                object[key] = value*scale
            end
        end
    end

    -- Check if we're a number
    if type(object) == "number" then
        return object*scale
    -- Object is a table
    elseif type(object) == "table" then
        -- Break reference, work on local copy
        object = util.copy(object)
        -- Recursively call scale_subtable
        scale_subtable(object, scale)
        return object
    end
end

function reskins.lib.rescale_entity(entity, scalar)
	for key, value in pairs(entity) do
		-- This section checks to see where we are, and for the existence of scale.
		-- Scale is defined if it is missing where it should be present.

		-- This checks to see if we're within an hr_version table
		if key == "hr_version" then
			entity.scale = entity.scale or 0.5
		-- If we're not, see if there's a filename, which means we're in a low-res table
		elseif entity.filename then
			entity.scale = entity.scale or 1
		end

        -- Check to see if we need to scale this key's value
        for n = 1, #fields do
            if fields[n] == key then
                entity[key] = reskins.lib.scale(value, scalar)
                -- Move to the next key rather than digging down further
                goto continue
            end
        end

        -- Check to see if we need to ignore this key
        for n = 1, #ignored_fields do
            if ignored_fields[n] == key then
                -- Move to the next key rather than digging down further
                goto continue
            end
        end

        if(type(value) == "table") then
            reskins.lib.rescale_entity(value, scalar)
        end

        -- Label to skip to next iteration
        ::continue::
    end
end

-- Check if a startup setting exists, and if it does, return its value
function reskins.lib.setting(name)
    local startup_setting
    if settings.startup[name] then
        startup_setting = settings.startup[name].value
    else
        startup_setting = nil
    end

    return startup_setting
end