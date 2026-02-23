require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides array functions
---@class KuxCoreLib.SurfacesMod
local SurfacesMod = {
	__class  = "SurfacesMod",
	__guid   = "e71cea3a-405c-4bd4-bb24-74b5a216b16e",
	__origin = "Kux-CoreLib/lib/mods/SurfacesMod.lua",
}
if not KuxCoreLib.__classUtils.ctor(SurfacesMod) then return self end
---------------------------------------------------------------------------------------------------
---Provides SurfacesMod in the global namespace
---@return KuxCoreLib.SurfacesMod
function SurfacesMod.asGlobal() return KuxCoreLib.__classUtils.asGlobal(SurfacesMod) end
---------------------------------------------------------------------------------------------------

---@class KuxCoreLib.SurfacesMod.API
local api = {}
SurfacesMod.api = api

---@param surface LuaSurface|string
---@return string # The name of the main surface
function api.get_main_surface(surface)
	return remote.call("SurfacesAPI", "get_main_surface", surface) --[[@as string]]
end

---@param surface LuaSurface|string
---@return integer # The level of the surface, relativ to the main surface
function api.get_surface_layer(surface)
	return remote.call("SurfacesAPI", "get_surface_layer", surface) --[[@as integer]]
end

---@param main_surface LuaSurface|string # The main surface
---@param level integer # The level of the surface, relativ to the main surface
function api.get_surface(main_surface, level)
	return remote.call("SurfacesAPI", "get_surface", main_surface, level)
end

---@param surface LuaSurface
---@return LuaSurface? # The main surface
function SurfacesMod.getMainSurface(surface)
	-- local surface_name = surface.name
	-- local match_cave = surface_name:match("(.-)%-caves:%-?%d+")
	-- local match_sky = surface_name:match("(.-)%-sky:%-?%d+")
	-- if(match_cave) then	return game.surfaces[match_cave] end
	-- if(match_sky) then	return game.surfaces[match_cave] end
	-- return nil

	if(not remote.interfaces["SurfacesAPI"]) then return nil end

	local surface_name = api.get_main_surface(surface)
	return game.surfaces[surface_name]
end

function SurfacesMod.getInfo(player)
    local surface = player.surface
    print("Current surface: "..surface.name)
    local main_surface = api.get_main_surface(surface)
    print("Main surface: "..main_surface)
    local layer = api.get_surface_layer(surface)
    print("Surface layer: "..layer)
    local below_surface = api.get_surface(main_surface, layer - 1)
    if below_surface then
        print("Surface below current: "..below_surface.name)
    end
    local above_surface = api.get_surface(main_surface, layer + 1)
    if above_surface then
        print("Surface above current: "..above_surface.name)
    end
end

return SurfacesMod
