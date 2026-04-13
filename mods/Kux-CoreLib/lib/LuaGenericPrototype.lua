require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides generic wrapper for all LuaXYZPrototype objects
---@class KuxCoreLib.LuaGenericPrototype.static : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.LuaGenericPrototype.static
local LuaGenericPrototype = {
	__class  = "KuxCoreLib.LuaGenericPrototype.static",
	__guid   = "c4e0734d-c035-41c4-b03f-7a3341d23739",
	__origin = "Kux-CoreLib/lib/LuaGenericPrototype.lua",
}
if not KuxCoreLib.__classUtils.ctor(LuaGenericPrototype) then return self end

-----------------------------------------------------------------------------------------------------------------------

local mt = {}

-----------------------------------------------------------------------------------------------------------------------
---#region: instance implementation
-----------------------------------------------------------------------------------------------------------------------


---A generic prototype wrapper for all LuaXYZPrototype objects. with additional properties and methods.
---@class KuxCoreLib.LuaGenericPrototype : LuaEntityPrototype, LuaItemPrototype, LuaFluidPrototype, LuaEquipmentPrototype, LuaTilePrototype, LuaDecorativePrototype, LuaVirtualSignalPrototype
---@field public __class "KuxCoreLib.LuaGenericPrototype"
---@field public tags table<string, AnyBasic> [CUSTOM PROPERTY]
---@field public category string gets the category of the prototype (e.g. "item", "entity", "fluid", etc.) [CUSTOM PROPERTY]
---@field public is_craftable boolean? gets if the prototype is craftable. [CUSTOM PROPERTY]
---@field public is_hand_craftable boolean? gets if the prototype is craftable by hand. [CUSTOM PROPERTY]
---@field private __base LuaEntityPrototype|LuaItemPrototype|LuaFluidPrototype|LuaEquipmentPrototype|LuaTilePrototype|LuaDecorativePrototype|LuaVirtualSignalPrototype
---@field private __is_prototype boolean gets if the object is a prototype (e.g. LuaEntityPrototype, LuaItemPrototype, etc.)
local instance_impl = {
	__class = "KuxCoreLib.LuaGenericPrototype",
	__base = nil,
	category = "",
}

-----------------------------------------------------------------------------------------------------------------------
---#region: meta table implementation
-----------------------------------------------------------------------------------------------------------------------

local custom_fields = Table.toFlagsDictionary{"tags", "is_craftable", "is_hand_craftable", "supertype"}
local readonly_custom_fields = Table.toFlagsDictionary{"supertype"}

mt.__index = function(t, k)
	if custom_fields[k] then return nil end
	if k == "prototype" then return rawget(t,"__is_prototype") and rawget(t,"__base") or rawget(t,"__base").prototype end
	return instance_impl[k] or rawget(t,"__base")[k]
end

mt.__newindex = function(t, k, v)
	if custom_fields[k] then rawset(t,k,v) return end
	if k == "__class" then error("Member access violation. Field '..k..' is write-protected.") end
	t.__base[k] = v -- always raises the correct error (read-only or not exist)
end

script.register_metatable("KuxCoreLib.LuaGenericPrototype.metatable", mt)

-----------------------------------------------------------------------------------------------------------------------
---#region: static implementation
-----------------------------------------------------------------------------------------------------------------------

local object_name_to_category = {
	LuaEntity = "entity",
	LuaEntityPrototype = "entity",
	LuaItem = "item",
	LuaItemPrototype = "item",
	LuaFluid = "fluid",
	LuaFluidPrototype = "fluid",
	LuaRecipe = "recipe",
	LuaRecipePrototype = "recipe",
	LuaTechnology = "technology",
	LuaTechnologyPrototype = "technology",
	LuaEquipment = "equipment",
	LuaEquipmentPrototype = "equipment",
	LuaTile = "tile",
	LuaTilePrototype = "tile",
	LuaDecorativePrototype = "decorative",
	LuaVirtualSignalPrototype = "virtual_signal",
	LuaParticlePrototype = "particle",
	LuaAutoplaceControlPrototype = "autoplace_control",
	LuaModSettingPrototype = "mod_setting",
	LuaCustomInputPrototype = "custom_input",
	LuaAmmoCategoryPrototype = "ammo_category",
	LuaNamedNoiseExpression = "named_noise_expression",
	LuaNamedNoiseFunction = "named_noise_function",
	LuaGroup = "item_group",
	LuaFuelCategoryPrototype = "fuel_category",
	LuaResourceCategoryPrototype = "resource_category",
	LuaAchievementPrototype = "achievement",
	LuaModuleCategoryPrototype = "module_category",
	LuaEquipmentCategoryPrototype = "equipment_category",
	LuaTrivialSmokePrototype = "trivial_smoke",
	LuaShortcutPrototype = "shortcut",
	LuaRecipeCategoryPrototype = "recipe_category",
	LuaQualityPrototype = "quality",
	LuaSurfacePropertyPrototype = "surface_property",
	LuaSpaceLocationPrototype = "space_location",
	LuaSpaceConnectionPrototype = "space_connection",
	LuaCustomEventPrototype = "custom_event",
	LuaActiveTriggerPrototype = "active_trigger",
	LuaAsteroidChunkPrototype = "asteroid_chunk",
	LuaCollisionLayerPrototype = "collision_layer",
	LuaAirbornePollutantPrototype = "airborne_pollutant",
	LuaBurnerUsagePrototype = "burner_usage",
	LuaSurfacePrototype = "surface",
	LuaProcessionPrototype = "procession",
	LuaProcessionLayerInheritanceGroupPrototype = "procession_layer_inheritance_group"
}


---@param pt LuaEntityPrototype|LuaItemPrototype|LuaFluidPrototype|LuaEquipmentPrototype|LuaTilePrototype|LuaDecorativePrototype|LuaVirtualSignalPrototype
---@param supertype string|nil Grouping type under which the prototype is indexed in `prototypes`; automatic recognition if not provided.
function LuaGenericPrototype.new(pt, supertype)

	local function get_supertype()
		if _G.type(pt) == "userdata" then --[[@cast pt any]]
			return object_name_to_category[pt.object_name]
					or error("Invalid argument. object_name="..pt.object_name)
		else
			error("Invalid argument. "..type(pt))
		end
	end

	local obj = {
		__base = pt,
		__is_prototype = pt.object_name:match("Prototype$") ~= nil,
		supertype = supertype or get_supertype(),
		tags = {}
	}
	setmetatable(obj, mt)
	return obj
end


---
---@param arg any
---@param expected_type string?
---@return KuxCoreLib.LuaGenericPrototype
function _G.getGenericPrototype(arg, expected_type)
	local pt,cat = getPrototypeAndCategory(arg, expected_type)
	if not pt then error("Invalid argument") end
	return LuaGenericPrototype.new(pt, cat)
end

-----------------------------------------------------------------------------------------------------------------------
return LuaGenericPrototype