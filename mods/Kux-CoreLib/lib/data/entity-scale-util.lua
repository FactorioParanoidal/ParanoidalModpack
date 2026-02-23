---@class EntityData.scale_util
local scale_util = {}

local EntityData = KuxCoreLib.EntityData
local pipe_util = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/data/pipe-connection-util") --[[@as EntityData.PipeConnectionUtil]]
scale_util.pipes = pipe_util

local function scale_point(point, scale)
	if not point then return nil end
	if point.x then
		local x = point.x or error("Invalid point")
		local y = point.y or error("Invalid point")
		return {x = x * scale,y =  y * scale}
	elseif point[1] then
		local x = point[1] or error("Invalid point")
		local y = point[2] or error("Invalid point")
		return {x * scale, y * scale}
	else error("Invalid point") end
end

---Vector :: struct or {double, double}
---@param vector Vector
---@param scale double
local function scale_Vector(vector, scale) return scale_point(vector, scale) end

local function scale_rect(rect, scale)
	if not rect then return nil end
	if rect.left_top then
		local tl = rect.left_top or error("Invalid rect")
		local br = rect.right_bottom or error("Invalid rect")
		return { left_top =  scale_point(tl, scale), right_bottom = scale_point(br, scale)}
	elseif rect[1] then
		local tl = rect[1] or error("Invalid rect")
		local br = rect[2] or error("Invalid rect")
		return {scale_point(tl, scale), scale_point(br, scale)}
	else error("Invalid rect") end
end

---@param rect data.SimpleBoundingBox
---@return data.SimpleBoundingBox
---[View Documentation](https://lua-api.factorio.com/latest/types/SimpleBoundingBox.html)
local function scale_SimpleBoundingBox(rect, scale) return scale_rect(rect, scale) --[[@as data.SimpleBoundingBox]] end

---@param obj data.FogMaskShapeDefinition
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/FogMaskShapeDefinition.html)
local function scale_FogMaskShapeDefinition(obj, scale)
	if not obj then return end
	obj.rect = scale_SimpleBoundingBox(obj.rect)
end

---@param sprite data.SpriteParameters
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/SpriteParameters.html)
local function scale_SpriteParameters(sprite, scale)
	if not sprite then return end

	sprite.scale = (sprite.scale or 1) * scale
	sprite.shift = scale_point(sprite.shift, scale)
end

---@param animation data.AnimationParameters
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/AnimationParameters.html)
local function scale_AnimationParameters(animation, scale)
	if not animation then return end
	scale_SpriteParameters(animation, scale) -- base
end

---@param animation data.Animation
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/Animation.html)
local function scale_Animation(animation, scale)
	if not animation then return end
	for _, layer in ipairs(animation.layers or {}) do
		scale_Animation(layer, scale)
	end
	animation.scale = (animation.scale or 1) * scale
	animation.shift = scale_point(animation.shift, scale)
end

---@param animation data.Animation|data.Animation4Way.struct
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/Animation4Way.html)
local function scale_Animation4Way(animation, scale)
	if not animation then return end
	if not animation.north then return scale_Animation(animation --[[@as data.Animation]], scale) end
	scale_Animation(animation.north, scale)
	scale_Animation(animation.east, scale)
	scale_Animation(animation.south, scale)
	scale_Animation(animation.west, scale)
	scale_Animation(animation.north_east, scale)
	scale_Animation(animation.north_west, scale)
	scale_Animation(animation.south_east, scale)
	scale_Animation(animation.south_west, scale)
end

---@param animation data.RotatedAnimation
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/RotatedAnimation.html)
local function scale_RotatedAnimation(animation, scale)
	if not animation then return end
	scale_AnimationParameters(animation, scale) -- base
	for _, value in ipairs(animation.layers or {}) do
		scale_RotatedAnimation(value, scale)
	end
end

---@param animation data.RotatedAnimation|data.RotatedAnimation8Way.struct
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/RotatedAnimation8Way.html)
local function scale_RotatedAnimation8Way(animation, scale)
	if not animation then return end
	if not animation.north then return scale_RotatedAnimation(animation --[[@as data.RotatedAnimation]], scale)
	else
		scale_RotatedAnimation(animation.north, scale)
		scale_RotatedAnimation(animation.east, scale)
		scale_RotatedAnimation(animation.south, scale)
		scale_RotatedAnimation(animation.west, scale)
		scale_RotatedAnimation(animation.north_east, scale)
		scale_RotatedAnimation(animation.north_west, scale)
		scale_RotatedAnimation(animation.south_east, scale)
		scale_RotatedAnimation(animation.south_west, scale)
	end
end

---@param sprite data.Sprite
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/Sprite.html)
local function scale_Sprite(sprite, scale)
	if not sprite then return end

	sprite.scale = (sprite.scale or 1) * scale
	sprite.shift = scale_point(sprite.shift, scale)
end

---@param sheet data.SpriteNWaySheet
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/SpriteNWaySheet.html)
local function scale_SpriteNWaySheet(sheet, scale)
	if not sheet then return end

	sheet.scale = (sheet.scale or 1) * scale
	sheet.shift = scale_point(sheet.shift, scale)
end

---@param sprite data.Sprite|data.Sprite4Way.struct
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/Sprite4Way.html)
local function scale_Sprite4Way(sprite, scale)
	if not sprite then return end
	if not sprite.north then return scale_Sprite(sprite --[[@as data.Sprite]], scale) end
	scale_Sprite(sprite.north, scale)
	scale_Sprite(sprite.east, scale)
	scale_Sprite(sprite.south, scale)
	scale_Sprite(sprite.west, scale)
	scale_SpriteNWaySheet(sprite.sheet, scale)
	for _, value in ipairs(sprite.sheets) do
		scale_SpriteNWaySheet(value, scale)
	end
end

---@param sprite data.RotatedSprite
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/RotatedSprite.html)
local function scale_RotatedSprite(sprite, scale)
	if sprite.layers then
		for _, layer in ipairs(sprite.layers) do
			scale_RotatedSprite(layer, scale)
		end
	else
		scale_SpriteParameters(sprite, scale) -- base
	end
	--TODO: frames :: array[RotatedSpriteFrame]
end

local function scale_SpriteSheet(sheet, scale)
	if not sheet then return end
	scale_SpriteParameters(sheet, scale) -- base

	for _, value in ipairs(sheet.layers or {}) do
		scale_SpriteSheet(value, scale)
	end
end

---@param sprite data.SpriteVariations
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/SpriteVariations.html)
local function scale_SpriteVariations(sprite, scale)
	if sprite.sheet then
		scale_SpriteSheet(sprite.sheet, scale)
	elseif #sprite>0 then
		for _, value in ipairs(sprite) do
			scale_Sprite(value, scale)
		end
	else
		scale_Sprite(sprite --[[@as data.Sprite]], scale)
	end
	--TODO: frames :: array[RotatedSpriteFrame]
end

---@param value data.WorkingVisualisation
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/WorkingVisualisation.html)
local function scale_WorkingVisualisation(value, scale)
	if not value then return end

	scale_Animation(value.animation, scale)

	scale_Animation(value.east_animation, scale)
	scale_Animation(value.north_animation, scale)
	scale_Animation(value.south_animation, scale)
	scale_Animation(value.west_animation, scale)

	value.north_position = scale_Vector(value.north_position, scale)
	value.east_position = scale_Vector(value.east_position, scale)
	value.south_position = scale_Vector(value.south_position, scale)
	value.west_position = scale_Vector(value.west_position, scale)

	value.north_fog_mask = scale_FogMaskShapeDefinition(value.north_fog_mask, scale)
	value.east_fog_mask = scale_FogMaskShapeDefinition(value.east_fog_mask, scale)
	value.south_fog_mask = scale_FogMaskShapeDefinition(value.south_fog_mask, scale)
	value.west_fog_mask = scale_FogMaskShapeDefinition(value.west_fog_mask, scale)
end

---@param value data.TurretBaseVisualisation|data.TurretBaseVisualisation[]
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/WorkingVisualisation.html)
local function scale_TurretBaseVisualisation(value, scale)
	if not value then return end
	if #value>0 then
		for _, v in ipairs(value) do scale_TurretBaseVisualisation(v, scale) end
	else
		scale_Animation4Way(value.animation, scale)
	end
end

---
---@param graphics_set data.CraftingMachineGraphicsSet
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/CraftingMachineGraphicsSet.html)
local function scale_CraftingMachineGraphicsSet(graphics_set, scale)
	if not graphics_set then return end
	scale_Animation4Way(graphics_set.animation, scale)
	scale_Animation4Way(graphics_set.idle_animation, scale)
	for _, value in ipairs(graphics_set.working_visualisations or {}) do
		scale_WorkingVisualisation(value, scale)
	end
end

---
---@param graphics_set data.TurretGraphicsSet
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/TurretGraphicsSet.html)
local function scale_TurretGraphicsSet(graphics_set, scale)
	if not graphics_set then return end
	scale_TurretBaseVisualisation(graphics_set.base_visualisation, scale)
end

---@param graphics data.ChargableGraphics
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/ChargableGraphics.html)
local function scale_ChargableGraphics(graphics, scale)
	if not graphics then return end

	scale_Sprite(graphics.picture, scale)
	scale_Animation(graphics.charge_animation, scale)
	scale_Animation(graphics.discharge_animation, scale)
end

---@param ccd data.CircuitConnectorDefinition
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/CircuitConnectorDefinition.html)
local function scale_CircuitConnectorDefinition(ccd, scale)
	--TODO: scale_CircuitConnectorDefinition
end

---@param ccd data.CircuitConnectorDefinition[]
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/CircuitConnectorDefinition.html)
local function scale_CircuitConnectorDefinitions(ccd, scale)
	for _, value in ipairs(ccd) do
		scale_CircuitConnectorDefinition(value, scale)
	end
end
-----------------------------------------------------------------------------------------------------------------------

local function calculate_fraction(decimal)
    local denominator = 1
    local numerator = decimal
    while math.floor(numerator) ~= numerator do numerator = numerator * 10; denominator = denominator * 10 end
    local function gcd(a, b) while b ~= 0 do a, b = b, a % b end return a end
    local divisor = gcd(numerator, denominator)
    return numerator / divisor, denominator / divisor
end

local function f(a, b)
    local numerator, denominator = calculate_fraction(b)
    return a * (numerator - 1 / denominator - 1)
end


---
---@param pt data.CraftingMachinePrototype
local function scale_pipe_connections(pt, original_size, target_size)
	error("Not implemented")
	--       5                   4                3            2        1
	-- -2 -1 0 1 2  ->  -1.5 -0.5 0.5 1.5  ->  -1 0 1  ->  -0.5 0.5  ->
	--  O    O   O                              O O O        O   O      O
	--                                          O   O        O   O      O
	--                                            O          O          O

end

-----------------------------------------------------------------------------------------------------------------------
local function scale_EntityPrototype(pt, scale)
	pt.collision_box = scale_rect(pt.collision_box, scale)
	pt.selection_box = scale_rect(pt.selection_box, scale)
	pt.hit_visualization_box = scale_rect(pt.hit_visualization_box, scale)
end

local function scale_EntityWithHealthPrototype(pt, scale)
	scale_EntityPrototype(pt, scale) --base

	scale_Sprite4Way(pt.integration_patch, scale)
end

local function scale_EntityWithOwnerPrototype(pt, scale)
	scale_EntityWithHealthPrototype(pt, scale) --base
end

local function scale_CraftingMachinePrototype(pt, scale)
	scale_EntityWithOwnerPrototype(pt, scale) --base

	scale_CraftingMachineGraphicsSet(pt.graphics_set, scale)
	scale_CraftingMachineGraphicsSet(pt.graphics_set_flipped, scale)
end

---@param pt data.TurretPrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/TurretPrototype.html)
local function scale_TurretPrototype(pt, scale)
	scale_EntityWithOwnerPrototype(pt, scale) --base

	scale_TurretGraphicsSet(pt.graphics_set, scale)
	scale_RotatedAnimation8Way(pt.folded_animation, scale)
	scale_RotatedAnimation8Way(pt.preparing_animation, scale)
	scale_RotatedAnimation8Way(pt.prepared_animation, scale)
	scale_RotatedAnimation8Way(pt.prepared_alternative_animation, scale)
	scale_RotatedAnimation8Way(pt.starting_attack_animation, scale)
	scale_RotatedAnimation8Way(pt.attacking_animation, scale)
	scale_RotatedAnimation8Way(pt.energy_glow_animation, scale)
	scale_RotatedAnimation8Way(pt.resource_indicator_animation, scale)
	scale_RotatedAnimation8Way(pt.ending_attack_animation, scale)
	scale_RotatedAnimation8Way(pt.folding_animation, scale)

	scale_CircuitConnectorDefinitions(pt.circuit_connector, scale)

end

-----------------------------------------------------------------------------------------------------------------------

---@param pt data.FurnacePrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/FurnacePrototype.html)
local function scale_Furnace(pt, scale)
	scale_CraftingMachinePrototype(pt, scale) -- base
end

---@param pt data.AssemblingMachinePrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/AssemblingMachinePrototype.html)
local function scale_AssemblingMachine(pt, scale)
	scale_CraftingMachinePrototype(pt, scale) -- base
end

---@param pt data.RadarPrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/RadarPrototype.html)
local function scale_Radar(pt, scale)
	scale_EntityWithOwnerPrototype(pt, scale) -- base

	scale_RotatedSprite(pt.pictures, scale)
	scale_CircuitConnectorDefinition(pt.circuit_connector, scale)
end


---@param pt data.ElectricTurretPrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/ElectricTurretPrototype.html)
local function scale_ElectricTurret(pt, scale)
	scale_TurretPrototype(pt, scale) -- base
end

---@param pt data.AmmoTurretPrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/AmmoTurretPrototype.html)
local function scale_AmmoTurret(pt, scale)
	scale_TurretPrototype(pt, scale) -- base
end

---@param pt data.FluidTurretPrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/FluidTurretPrototype.html)
local function scale_FluidTurret(pt, scale)
	scale_TurretPrototype(pt, scale) -- base
	scale_Animation(pt.muzzle_animation, scale)
end

---@param pt data.SolarPanelPrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/SolarPanelPrototype.html)
local function scale_SolarPanel(pt, scale)
	scale_EntityWithOwnerPrototype(pt, scale) -- base
	scale_SpriteVariations(pt.picture, scale)
	scale_SpriteVariations(pt.overlay, scale)
end

---@param pt data.AccumulatorPrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/AccumulatorPrototype.html)
local function scale_Accumulator(pt, scale)
	scale_EntityWithOwnerPrototype(pt, scale) -- base

	scale_ChargableGraphics(pt.chargable_graphics, scale)
	scale_CircuitConnectorDefinition(pt.circuit_connector, scale)
end


-----------------------------------------------------------------------------------------------------------------------

---@param entity data.EntityPrototype
---@param scale number
local function scale(entity, scale)
	if not entity then return end
	if scale == 1 then return end
	assert(type(scale) == "number", "scale must be a number")

	---@diagnostic disable: param-type-mismatch
	if     entity.type == "furnace"            then scale_Furnace(entity, scale)
	elseif entity.type == "assembling-machine" then scale_AssemblingMachine(entity, scale)
	elseif entity.type == "radar"              then scale_Radar(entity, scale)
	elseif entity.type == "electric-turret"    then scale_ElectricTurret(entity, scale)
	elseif entity.type == "ammo-turret"        then scale_AmmoTurret(entity, scale)
	elseif entity.type == "fluid-turret"       then scale_FluidTurret(entity, scale)
	-- elseif entity.type == "mining-drill"        then scale_MiningDrill(entity, scale)
	elseif entity.type == "solar-pane"         then scale_SolarPanel(entity, scale)
	elseif entity.type == "accumulator"        then scale_Accumulator(entity, scale)


	else error("Unsupported entity type: " .. entity.type)
	end
	---@diagnostic enable: param-type-mismatch
end

scale_util.scale = scale
-----------------------------------------------------------------------------------------------------------------------
return scale_util
