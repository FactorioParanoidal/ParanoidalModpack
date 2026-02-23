require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.AnimationData
local AnimationData = {
	__class  = "AnimationData",
	__guid   = "44b86734-4323-4071-8d0e-6e181c27c577",
	__origin = "Kux-CoreLib/lib/data/AnimationData.lua",
}
if not KuxCoreLib.__classUtils.ctor(AnimationData) then return self end
---------------------------------------------------------------------------------------------------

function AnimationData.createHrVersion(data)
	local hr = table.deepcopy(data)
	hr.filename = Path.getFolderName(data.filename).."/hr-"..Path.getFileName(data.filename)
	hr.width = data.width * 2
	hr.height = data.height * 2
	hr.scale = (data.scale or 1) / 2
	hr.hr_version = nil
	return hr
end

function AnimationData.newLayer(data, addHrVersion)
	local layer = table.deepcopy(data)
	if(addHrVersion) then layer.hr_version=AnimationData.createHrVersion(data) end
	return layer
end

function AnimationData.findFirstIndexOfShadow(layers)
	for i, layer in ipairs(layers) do
		if(layer.draw_as_shadow) then return i end
	end
	return nil
end

---comment
---@param animation_template data.Animation
---@param overlay_template data.Animation
---@param add_hr_version boolean
---@return data.Animation
function AnimationData.addOverlay(animation_template, overlay_template, add_hr_version)
	--[[
		-- https://wiki.factorio.com/Types/Animation
		entity.animation.layers = {
			animation,
			overlay,
			shadow
		}
	]]
	local animation = {}
	if(animation_template.layers) then animation.layers = table.deepcopy(animation_template.layers)
	else                               animation.layers = { table.deepcopy(animation_template) }
	end

	local firstShadowLayer = AnimationData.findFirstIndexOfShadow(animation.layers)
	local overlayLayer = AnimationData.newLayer(overlay_template, add_hr_version)
	if(firstShadowLayer) then table.insert(animation.layers, firstShadowLayer, overlayLayer)
	else table.insert(animation.layers, overlayLayer) end
	return animation
end

---------------------------------------------------------------------------------------------------
function AnimationData.asGlobal() return KuxCoreLib.__classUtils.asGlobal(AnimationData) end
return AnimationData