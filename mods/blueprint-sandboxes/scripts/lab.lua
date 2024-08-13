-- Manage the Lab-like Surfaces
local Lab = {}

Lab.pfx = BPSB.pfx .. "lab-"
local pfxLength = string.len(Lab.pfx)

Lab.chartAllLabsTick = 300

Lab.equipmentString = "0eNqNkd1ugzAMhd/F10kF6bq2eZVqQpAaZgkMSkI1hnj3OVRC1dT95M6x/Z2TkxmqdsTBE0ewM5DrOYC9zBCo4bJNd3EaECxQxA4UcNmlClt00ZPTyOibScs++rp0CIsC4it+gM0X9SenokZvrKFvH/fN8qYAOVIkvJtai6ngsavQi8AvGAVDH2Sz56QttEzBBFabJbn6BjL/eNcPwEz8VmNdoy8CfQoiz7bzRGm/KRHXxNLS7h1DfILfHVYBszuskdyni4AxEjchTXns+hsWo/RasYnXIoUrrehHXFJ6a9j24Y8V3NCHVcWc8pfj2RxfzyY77SWXL6PBsLw="

-- A unique per-Player Lab Name
function Lab.NameFromPlayer(player)
    return Lab.pfx .. "p-" .. player.name
end

-- A unique per-Force Lab Name
function Lab.NameFromForce(force)
    return Lab.pfx .. "f-" .. force.name
end

-- Whether the Surface (or Force) is specific to a Lab
function Lab.IsLab(thingWithName)
    return string.sub(thingWithName.name, 1, pfxLength) == Lab.pfx
    -- return not not global.labSurfaces[thingWithName.name]
end

-- Create a new Lab Surface, if necessary
function Lab.GetOrCreateSurface(labName, sandboxForce)
    local surface = game.surfaces[labName]

    if not Lab.IsLab({ name = labName }) then
        log("Not a Lab, won't Create: " .. labName)
        return
    end

    if surface then
        if global.labSurfaces[labName] then
            return surface
        end
        log("Found a Lab Surface, but not the Data; recreating it for safety")
    end

    log("Creating Lab: " .. labName)
    global.labSurfaces[labName] = {
        sandboxForceName = sandboxForce.name,
        equipmentBlueprints = Equipment.Init(Lab.equipmentString),
        daytime = 0.95,
    }
    if not surface then
        surface = game.create_surface(labName, {
            default_enable_all_autoplace_controls = false,
            cliff_settings = { cliff_elevation_0 = 1024 },
        })
    end

    return surface
end

-- Set a Lab's Daytime to a specific value
function Lab.SetDayTime(player, surface, daytime)
    if Lab.IsLab(surface) then
        surface.freeze_daytime = true
        surface.daytime = daytime
        global.labSurfaces[surface.name].daytime = daytime
        Events.SendDaylightChangedEvent(player.index, surface.name, daytime)
        return true
    else
        return false
    end
end

-- Delete a Lab Surface, if present
function Lab.DeleteLab(surfaceName)
    if game.surfaces[surfaceName] and global.labSurfaces[surfaceName] then
        log("Deleting Lab: " .. surfaceName)
        local equipmentBlueprints = global.labSurfaces.equipmentBlueprints
        if equipmentBlueprints and equipmentBlueprints.valid() then
            equipmentBlueprints.destroy()
        end
        global.labSurfaces[surfaceName] = nil
        game.delete_surface(surfaceName)
        return true
    else
        log("Not a Lab, won't Delete: " .. surfaceName)
        return false
    end
end

-- Set the Lab's equipment Blueprint for a Surface
function Lab.SetEquipmentBlueprint(surface, equipmentString)
    if Lab.IsLab(surface) then
        log("Setting Lab equipment: " .. surface.name)
        Equipment.Set(
                global.labSurfaces[surface.name].equipmentBlueprints,
                equipmentString
        )
        surface.print("The equipment Blueprint for this Lab has been changed")
        return true
    else
        log("Not a Lab, won't Set equipment: " .. surface.name)
        return false
    end
end

-- Reset the Lab's equipment Blueprint for a Surface
function Lab.ResetEquipmentBlueprint(surface)
    if Lab.IsLab(surface) then
        log("Resetting Lab equipment: " .. surface.name)
        Equipment.Set(
                global.labSurfaces[surface.name].equipmentBlueprints,
                Lab.equipmentString
        )
        surface.print("The equipment Blueprint for this Lab has been reset")
        return true
    else
        log("Not a Lab, won't Reset equipment: " .. surface.name)
        return false
    end
end

-- Reset the Lab a Player is currently in
function Lab.Reset(player)
    if Lab.IsLab(player.surface) then
        log("Resetting Lab: " .. player.surface.name)
        player.teleport({ 0, 0 }, player.surface.name)
        player.surface.clear(false)
        return true
    else
        log("Not a Lab, won't Reset: " .. player.surface.name)
        return false
    end
end

-- Set some important Surface settings for a Lab
function Lab.AfterCreate(surface)
    local surfaceData = global.labSurfaces[surface.name]
    if not surfaceData then
        log("Not a Lab, won't handle Creation: " .. surface.name)
        return false
    end

    log("Handling Creation of Lab: " .. surface.name)

    if remote.interfaces["RSO"] then
        pcall(remote.call, "RSO", "ignoreSurface", surface.name)
    end

    if remote.interfaces["dangOreus"] then
        pcall(remote.call, "dangOreus", "toggle", surface.name)
    end

    if remote.interfaces["AbandonedRuins"] then
        pcall(remote.call, "AbandonedRuins", "exclude_surface", surface.name)
    end

    surface.freeze_daytime = true
    surface.daytime = 0.95
    surface.show_clouds = false
    surface.generate_with_lab_tiles = true

    return true
end

-- Add some helpful initial Entities to a Lab
function Lab.Equip(surface)
    local surfaceData = global.labSurfaces[surface.name]
    if not surfaceData then
        log("Not a Lab, won't Equip: " .. surface.name)
        return false
    end

    log("Equipping Lab: " .. surface.name)

    Equipment.Place(
            surfaceData.equipmentBlueprints[1],
            surface,
            surfaceData.sandboxForceName
    )

    return true
end

-- Update all Entities in Lab with a new Force
function Lab.AssignEntitiesToForce(surface, force)
    local surfaceData = global.labSurfaces[surface.name]
    if not surfaceData then
        log("Not a Lab, won't Reassign: " .. surface.name)
        return false
    end

    log("Reassigning Lab to: " .. surface.name .. " -> " .. force.name)

    for _, entity in pairs(surface.find_entities_filtered {
        force = surfaceData.sandboxForceName,
        invert = true,
    }) do
        entity.force = force
    end

    return true
end

return Lab
