-- Space Exploration related functionality
local SpaceExploration = {}

SpaceExploration.name = "space-exploration"
SpaceExploration.enabled = not not remote.interfaces[SpaceExploration.name]

SpaceExploration.orbitalEquipmentString = "0eNqllt2OgyAQhd9lrqEB2m5bX6XZGLWjS4JoAJt1G999wW5M07T7N94hzDfDzDkJFyjNgL3TNkB2AV111kN2vIDXjS1M+hfGHiEDHbAFBrZo0woNVsHpiqNF14w8xqOriwphYqDtCd8hkxP7kVPqhi+svjO38Wp6ZYA26KDxWtS8GHM7tCW6mOAbDIO+8zGysyl3pAkGI2RcTamqO5D6xb2eAEWstxzqGl3u9UdESLF8DzKtl0za1trGLV69oQ8P8KvtnECttnNLrqdzjyFo2/h0ymHbnTEf4p6JZeIpT82NW8ENOKXuBW2+WndH5+rajs20FOSR+z7elPemCHXnWu6roq47c4J0kSeANRWgqABJBAhiPDU/tQH/n4CkakBSNSCpGpBUDUiiBiRRA5KoAUnTgCBKQBAVIIgCEMT5C9r4BW36gjZ8QZs91f5U91PNT/U+0fpE5xON/yffx5fA/OzKbl57DM7o/AxUe7nZHdTu5aDEfh1fSJ/ZLl9g"

-- Whether the Surface has been taken as a Space Sandbox
function SpaceExploration.IsSandbox(surface)
    return SpaceExploration.enabled
            and global.seSurfaces[surface.name]
end

-- Whether the Surface has been taken as a Planetary Lab Sandbox
function SpaceExploration.IsPlanetarySandbox(surface)
    return SpaceExploration.enabled
            and global.seSurfaces[surface.name]
            and not global.seSurfaces[surface.name].orbital
end

-- Whether the Zone is Star
function SpaceExploration.IsStar(zoneName)
    if not SpaceExploration.enabled then
        return false
    end
    return remote.call(SpaceExploration.name, "get_zone_from_name", {
        zone_name = zoneName,
    }).type == "star"
end

-- Ask Space Exploration for the Player's current Character
function SpaceExploration.GetPlayerCharacter(player)
    if not SpaceExploration.enabled then
        return
    end
    return remote.call(SpaceExploration.name, "get_player_character", {
        player = player,
    })
end

-- Whether the Sandbox might have Biters falling
function SpaceExploration.IsZoneThreatening(zone)
    return (zone.type == "planet" or zone.type == "moon")
            and zone.controls
            and zone.controls["se-vitamelange"]
            and zone.controls["se-vitamelange"].richness > 0
end

-- Walk Parent Indexes to find the Root Zone (Star)
function SpaceExploration.GetRootZone(zoneIndex, zone)
    local rootZone = zone
    while rootZone.parent_index do
        rootZone = zoneIndex[rootZone.parent_index]
    end
    return rootZone
end

-- Chooses a non-home-system Star or Moon for a Force's Space Sandbox, if necessary
-- Notably, Star _Orbits_ are "usable" Zones, but not Stars themselves
-- In other words, these should be completely safe and invisible outside of this mod!
-- Moons, on the other hand, will take a valuable resource away from the player
-- We also carefully choose Moons in order to not take away too much from them,
-- and to not be too dangerous.
function SpaceExploration.ChooseZoneForForce(player, sandboxForce, type)
    if not SpaceExploration.enabled then
        return
    end

    local zoneIndex = remote.call(SpaceExploration.name, "get_zone_index", {})
    for _, zone in pairs(zoneIndex) do
        if zone.type == type
                and not zone.is_homeworld
                and not zone.ruins
                and not zone.glyph
                and zone.special_type ~= "homesystem"
                and not global.seSurfaces[zone.name]
        then
            local rootZone = SpaceExploration.GetRootZone(zoneIndex, zone)
            if not SpaceExploration.IsZoneThreatening(zone)
                    and rootZone.special_type ~= "homesystem"
            then
                log("Choosing SE Zone " .. zone.name .. " as Sandbox for " .. sandboxForce.name)
                return zone.name
            end
        end
    end
end

function SpaceExploration.GetOrCreateSurface(zoneName)
    if not SpaceExploration.enabled then
        return
    end

    return remote.call(SpaceExploration.name, "zone_get_make_surface", {
        zone_index = remote.call(SpaceExploration.name, "get_zone_from_name", {
            zone_name = zoneName,
        }).index,
    })
end

-- Chooses a non-home-system Star for a Force's Space Sandbox, if necessary
function SpaceExploration.GetOrCreatePlanetarySurfaceForForce(player, sandboxForce)
    if not SpaceExploration.enabled then
        return
    end

    local zoneName = global.sandboxForces[sandboxForce.name].sePlanetaryLabZoneName
    if zoneName == nil then
        zoneName = SpaceExploration.ChooseZoneForForce(player, sandboxForce, "moon")
        global.sandboxForces[sandboxForce.name].sePlanetaryLabZoneName = zoneName
        global.seSurfaces[zoneName] = {
            sandboxForceName = sandboxForce.name,
            equipmentBlueprints = Equipment.Init(Lab.equipmentString),
            daytime = 0.95,
            orbital = false,
        }
    end

    return SpaceExploration.GetOrCreateSurface(zoneName)
end

-- Chooses a non-home-system Star for a Force's Planetary Sandbox, if necessary
function SpaceExploration.GetOrCreateOrbitalSurfaceForForce(player, sandboxForce)
    if not SpaceExploration.enabled then
        return
    end

    local zoneName = global.sandboxForces[sandboxForce.name].seOrbitalSandboxZoneName
    if zoneName == nil then
        zoneName = SpaceExploration.ChooseZoneForForce(player, sandboxForce, "star")
        global.sandboxForces[sandboxForce.name].seOrbitalSandboxZoneName = zoneName
        global.seSurfaces[zoneName] = {
            sandboxForceName = sandboxForce.name,
            equipmentBlueprints = Equipment.Init(SpaceExploration.orbitalEquipmentString),
            daytime = 0.95,
            orbital = true,
        }
    end

    return SpaceExploration.GetOrCreateSurface(zoneName)
end

-- Set a Sandbox's Daytime to a specific value
function SpaceExploration.SetDayTime(player, surface, daytime)
    if SpaceExploration.IsSandbox(surface) then
        surface.freeze_daytime = true
        surface.daytime = daytime
        global.seSurfaces[surface.name].daytime = daytime
        Events.SendDaylightChangedEvent(player.index, surface.name, daytime)
        return true
    else
        return false
    end
end

-- Reset the Sandbox's equipment Blueprint for a Surface
function SpaceExploration.ResetEquipmentBlueprint(surface)
    if not SpaceExploration.enabled then
        return
    end

    if SpaceExploration.IsSandbox(surface) then
        log("Resetting SE equipment: " .. surface.name)
        if global.seSurfaces[surface.name].orbital then
            Equipment.Set(
                    global.seSurfaces[surface.name].equipmentBlueprints,
                    SpaceExploration.orbitalEquipmentString
            )
        else
            Equipment.Set(
                    global.seSurfaces[surface.name].equipmentBlueprints,
                    Lab.equipmentString
            )
        end
        surface.print("The equipment Blueprint for this Sandbox has been reset")
        return true
    else
        log("Not a SE Sandbox, won't Reset equipment: " .. surface.name)
        return false
    end
end

-- Set the Sandbox's equipment Blueprint for a Surface
function SpaceExploration.SetEquipmentBlueprint(surface, equipmentString)
    if not SpaceExploration.enabled then
        return
    end

    if SpaceExploration.IsSandbox(surface) then
        log("Setting SE equipment: " .. surface.name)
        Equipment.Set(
                global.seSurfaces[surface.name].equipmentBlueprints,
                equipmentString
        )
        surface.print("The equipment Blueprint for this Sandbox has been changed")
        return true
    else
        log("Not a SE Sandbox, won't Set equipment: " .. surface.name)
        return false
    end
end

-- Reset the Space Sandbox a Player is currently in
function SpaceExploration.Reset(player)
    if not SpaceExploration.enabled then
        return
    end

    if SpaceExploration.IsSandbox(player.surface) then
        log("Resetting SE Sandbox: " .. player.surface.name)
        player.teleport({ 0, 0 }, player.surface.name)
        player.surface.clear(false)
        return true
    else
        log("Not a SE Sandbox, won't Reset: " .. player.surface.name)
        return false
    end
end

-- Return a Sandbox to the available Zones
function SpaceExploration.PreDeleteSandbox(sandboxForceData, zoneName)
    if not SpaceExploration.enabled or not zoneName then
        return
    end

    if global.seSurfaces[zoneName] then
        log("Pre-Deleting SE Sandbox: " .. zoneName)
        local equipmentBlueprints = global.seSurfaces[zoneName].equipmentBlueprints
        if equipmentBlueprints and equipmentBlueprints.valid() then
            equipmentBlueprints.destroy()
        end
        global.seSurfaces[zoneName] = nil
        if sandboxForceData.sePlanetaryLabZoneName == zoneName then
            sandboxForceData.sePlanetaryLabZoneName = nil
        end
        if sandboxForceData.seOrbitalSandboxZoneName == zoneName then
            sandboxForceData.seOrbitalSandboxZoneName = nil
        end
    else
        log("Not a SE Sandbox, won't Pre-Delete: " .. zoneName)
    end
end

-- Delete a Space Sandbox and return it to the available Zones
function SpaceExploration.DeleteSandbox(sandboxForceData, zoneName)
    if not SpaceExploration.enabled or not zoneName then
        return
    end

    if global.seSurfaces[zoneName] then
        SpaceExploration.PreDeleteSandbox(sandboxForceData, zoneName)
        log("Deleting SE Sandbox: " .. zoneName)
        game.delete_surface(zoneName)
        return true
    else
        log("Not a SE Sandbox, won't Delete: " .. zoneName)
        return false
    end
end

-- Set some important Surface settings for Space Sandbox
function SpaceExploration.AfterCreate(surface)
    if not SpaceExploration.enabled then
        return
    end

    local surfaceData = global.seSurfaces[surface.name]
    if not surfaceData then
        log("Not a SE Sandbox, won't handle Creation: " .. surface.name)
        return false
    end

    log("Handling Creation of SE Sandbox: " .. surface.name)

    surface.freeze_daytime = true
    surface.daytime = surfaceData.daytime
    surface.show_clouds = false

    if (surfaceData.orbital) then
        surface.generate_with_lab_tiles = false
    else
        surface.generate_with_lab_tiles = true
    end

    return true
end

-- Add some helpful initial Entities to a Space Sandbox
function SpaceExploration.Equip(surface)
    if not SpaceExploration.enabled then
        return
    end

    local surfaceData = global.seSurfaces[surface.name]
    if not surfaceData then
        log("Not a SE Sandbox, won't Equip: " .. surface.name)
        return false
    end

    log("Equipping SE Sandbox: " .. surface.name)

    if not surfaceData.orbital then
        surface.generate_with_lab_tiles = true
    end
    Equipment.Place(
            surfaceData.equipmentBlueprints[1],
            surface,
            surfaceData.sandboxForceName
    )

    return true
end

--[[ Ensure that NavSat is not active
NOTE: This was not necessary in SE < 0.5.109 (the NavSat QoL Update)
Now, without this, the Inventory-differences after entering a Sandbox while
in the Navigation Satellite would be persisted, and without any good way
to undo that override.
--]]
function SpaceExploration.ExitRemoteView(player)
    if not SpaceExploration.enabled then
        return
    end
    remote.call(SpaceExploration.name, "remote_view_stop", { player = player })
end

return SpaceExploration
