-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Icon switching function
local function switch_icon_to_mini(name, source_name, pattern, replacement, inputs)
    -- Initialize paths
    local destination = data.raw["item"][name]
    local source = data.raw["item"][source_name]

    -- Check to make sure this entity is valid
    if not destination then return end -- Minimachine isn't there
    if not source then return end -- Source isn't there

    -- Find and copy the active icon field, ensure it's ours
    if source.icon then
        inputs.icon = util.copy(source.icon)
        if not string.find(source.icon, "reskin") then return end -- Not our icon
    elseif source.icons then
        inputs.icon = util.copy(source.icons)
        if not string.find(source.icons[1].icon, "reskin") then return end -- Not our icon
    else
        return
    end

    -- Transcribe icons and pictures
    inputs.icon_picture = util.copy(source.pictures)

    -- Switch to miniatures
    if type(inputs.icon) == "table" then
        for n = 1, #inputs.icon do
            inputs.icon[n].icon = string.gsub(inputs.icon[n].icon, "/"..pattern.."/", "/"..replacement.."/mini-")
        end
    else
        inputs.icon = string.gsub(inputs.icon, "/"..pattern.."/", "/"..replacement.."/mini-")
    end


    if inputs.icon_picture.layers then
        for n = 1, #inputs.icon_picture.layers do
            inputs.icon_picture.layers[n].filename = string.gsub(inputs.icon_picture.layers[n].filename, "/"..pattern.."/", "/"..replacement.."/mini-")
        end
    else
        inputs.icon_picture[1].filename = string.gsub(inputs.icon_picture[1].filename, "/"..pattern.."/", "/"..replacement.."/mini-")
    end

    -- Assign icons
    reskins.lib.assign_icons(name, inputs)
end

-- Rescale a given machine added by Mini Machines mod
function reskins.lib.rescale_minimachine(table, type, pattern, replacement, scale)
    -- Prepare a basic inputs table
    local inputs = {
        icon_size = 64,
        icon_mipmaps = 4,
        type = type,
        make_icon_pictures = true,
    }

    -- Shrink the icon
    for name, source in pairs(table) do
        switch_icon_to_mini(name, source, pattern, replacement, inputs)
        reskins.lib.rescale_remnant(data.raw[type][name], scale)
    end
end

-- Rescale a given technology added by Mini Machines mod
function reskins.lib.rescale_minimachine_technology(name, source_name)
    -- Setup source and destination locals
    local source = data.raw["technology"][source_name]
    local destination = data.raw["technology"][name]

    -- Ensure work is possible
    if not destination then return end
    if not source then return end

    -- Setup inputs
    local technology_icon = {
        {
            icon = reskins.lib.directory.."/graphics/technology/mini-machine-underlay.png",
            icon_size = 256,
            icon_mipmaps = 1,
            scale = 1,
        }
    }

    -- Transcribe icon or icons
    if source.icons then
        local source_technology_icon = util.copy(source.icons)

        -- Iterate and ensure icon_size/icon_mipmaps/scale are set
        for n = 1, #source_technology_icon do
            source_technology_icon[n].icon_size = source_technology_icon[n].icon_size or source.icon_size or 128
            source_technology_icon[n].icon_mipmaps = source_technology_icon[n].icon_mipmaps or source.icon_mipmaps or 1

            -- Normalize scale to 80%
            if source_technology_icon[n].scale then
                source_technology_icon[n].scale = 0.8 * source_technology_icon[n].scale
            else
                source_technology_icon[n].scale = 0.8 * (256 / source_technology_icon[n].icon_size)
            end

            -- Insert each entry into the mini tech icon table
            table.insert(technology_icon, source_technology_icon[n])
        end
    else
        table.insert(technology_icon, {
            icon = source.icon,
            icon_size = source.icon_size,
            icon_mipmaps = source.icon_mipmaps,
            scale = 0.8 * (256 / source.icon_size),
        })
    end

    -- Add the mini machine icon
    table.insert(technology_icon, {
        icon = reskins.lib.directory.."/graphics/technology/mini-machine-overlay.png",
        icon_size = 256,
        icon_mipmaps = 3,
        scale = 1,
    })

    -- Assign icon
    reskins.lib.assign_technology_icons(name, {technology_icon = technology_icon})
end

-- Filtering tables for rescale_entity
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

-- Rescale a given table
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

-- Rescale entities
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

-- Rescale remnants
function reskins.lib.rescale_remnant(entity, scale)
    -- Check the entity exists
    if not entity then return end

    -- Fetch remnant
    local remnant_name = entity.corpse

    -- Create, rescale, and assign rescaled remnant
    if remnant_name then
        local remnant = data.raw.corpse[remnant_name]

        if remnant then
            local rescaled_remnant = util.copy(remnant)
            rescaled_remnant.name = "rescaled-"..rescaled_remnant.name
            reskins.lib.rescale_entity(rescaled_remnant, scale)
            data:extend({rescaled_remnant})
            entity.corpse = rescaled_remnant.name
        end
    end
end