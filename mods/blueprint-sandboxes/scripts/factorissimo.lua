-- Factorissimo related functionality
local Factorissimo = {}

Factorissimo.name = "factorissimo"
function Factorissimo.enabled()
    return not not remote.interfaces[Factorissimo.name]
end

-- Whether the Surface is a Factory
function Factorissimo.IsFactory(thingWithName)
    if not Factorissimo.enabled() then
        return false
    end

    return remote.call(Factorissimo.name, "is_factorissimo_surface", thingWithName)
end

-- Whether the Surface is a Factory inside of a Sandbox
---@param surface LuaSurface
---@param position MapPosition
function Factorissimo.IsFactoryInsideSandbox(surface, position)
    if not Factorissimo.enabled() then
        return false
    end

    local outsideSurface = Factorissimo.GetOutsideSurfaceForFactory(surface, position)
    if not outsideSurface then
        return false
    end

    return Sandbox.IsSandbox(outsideSurface)
end

-- Find a Factory given a Surface and Position (if possible)
---@param surface LuaSurface
---@param position MapPosition
function Factorissimo.GetFactory(surface, position)
    return remote.call(Factorissimo.name, "find_surrounding_factory", surface, position)
end

-- Find a Factory's Outside Surface recursively
---@param surface LuaSurface
---@param position MapPosition
function Factorissimo.GetOutsideSurfaceForFactory(surface, position, recursion_depth)
    if recursion_depth and recursion_depth > 100 then -- its possible for a factory to contain itself.
        return nil
    end

    if not Factorissimo.IsFactory(surface) then
        return nil
    end

    local factory = Factorissimo.GetFactory(surface, position)
    if not factory then
        return nil
    end

    if Factorissimo.IsFactory(factory.outside_surface) then
        return Factorissimo.GetOutsideSurfaceForFactory(factory.outside_surface, {
            x = factory.outside_door_x,
            y = factory.outside_door_y,
        }, (recursion_depth or 0) + 1)
    else
        return factory.outside_surface
    end
    return nil
end

return Factorissimo
