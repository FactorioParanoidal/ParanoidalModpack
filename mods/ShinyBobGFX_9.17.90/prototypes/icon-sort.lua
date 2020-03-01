-- if data.raw["item"]["storage-tank-2"] then
-- data.raw["item"]["storage-tank"].subgroup = "bob-storage"
-- data.raw["item"]["storage-tank"].order = "b[fluid]-a[storage-tank-1]"
-- end

-- if data.raw["item"]["nitinol-gear-wheel"] then
-- data.raw["item"]["iron-gear-wheel"].subgroup = "bob-gears"
-- data.raw["item"]["iron-gear-wheel"].order = "a"
-- end

-- if data.raw["item"]["lithium-ion-battery"] then
-- data.raw["item"]["battery"].subgroup = "bob-intermediates"
-- data.raw["item"]["battery"].order = "f-c"
-- end

-- if data.raw["item"]["gilded-copper-cable"] then
-- data.raw["item"]["copper-cable"].subgroup = "bob-electronic-components"
-- data.raw["item"]["copper-cable"].order = "0"
-- end

-- if data.raw["item-with-entity-data"]["bob-locomotive-2"] then
-- data.raw["item-with-entity-data"]["locomotive"].subgroup = "bob-transport"
-- data.raw["item-with-entity-data"]["locomotive"].order = "a[train-system]-e[locomotive-1]"
-- end

-- if data.raw["item-with-entity-data"]["bob-cargo-wagon-2"] then
-- data.raw["item-with-entity-data"]["cargo-wagon"].subgroup = "bob-transport"
-- data.raw["item-with-entity-data"]["cargo-wagon"].order = "a[train-system]-f[cargo-wagon-1]"
-- end

-- if data.raw["item-with-entity-data"]["bob-fluid-wagon-2"] then
-- data.raw["item-with-entity-data"]["fluid-wagon"].subgroup = "bob-transport"
-- data.raw["item-with-entity-data"]["fluid-wagon"].order = "a[train-system]-h[fluid-wagon-1]"
-- end

if mods["bobequipment"] then
	if data.raw["roboport-equipment"]["personal-roboport-mk4-equipment"] then
	if powerbar == 1 then
		data.raw["roboport-equipment"]["personal-roboport-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-equipment-1B.png"
		data.raw["roboport-equipment"]["personal-roboport-mk2-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-mk2-equipment-1B.png"
		data.raw["roboport-equipment"]["personal-roboport-mk3-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-mk3-equipment-1B.png"
		data.raw["roboport-equipment"]["personal-roboport-mk4-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-mk4-equipment-1B.png"
	else
		data.raw["roboport-equipment"]["personal-roboport-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-equipment-1.png"
		data.raw["roboport-equipment"]["personal-roboport-mk2-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-mk2-equipment-1.png"
		data.raw["roboport-equipment"]["personal-roboport-mk3-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-mk3-equipment-1.png"
		data.raw["roboport-equipment"]["personal-roboport-mk4-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-mk4-equipment-1.png"
	end
	end
else
	if data.raw["roboport-equipment"]["personal-roboport-mk2-equipment"] then
	if powerbar == 1 then
		data.raw["roboport-equipment"]["personal-roboport-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-equipment-1B.png"
		data.raw["roboport-equipment"]["personal-roboport-mk2-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-mk2-equipment-1B.png"
		
	else
		data.raw["roboport-equipment"]["personal-roboport-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-equipment-1.png"
		data.raw["roboport-equipment"]["personal-roboport-mk2-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/personal-roboport-mk2-equipment-1.png"
		
	end
	end
end
	
if data.raw["generator-equipment"]["fusion-reactor-equipment-4"] then
	bobicon("fusion-reactor-equipment","generator-equipment",1,4,0)
	if powerbar == 1 then
		data.raw["generator-equipment"]["fusion-reactor-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/fusion-reactor-equipment-1B.png"
		data.raw["generator-equipment"]["fusion-reactor-equipment-2"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/fusion-reactor-equipment-2B.png"
		data.raw["generator-equipment"]["fusion-reactor-equipment-3"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/fusion-reactor-equipment-3B.png"
		data.raw["generator-equipment"]["fusion-reactor-equipment-4"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/fusion-reactor-equipment-4B.png"
		log "yyyy33"
	else
		data.raw["generator-equipment"]["fusion-reactor-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/fusion-reactor-equipment-1.png"
		data.raw["generator-equipment"]["fusion-reactor-equipment-2"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/fusion-reactor-equipment-2.png"
		data.raw["generator-equipment"]["fusion-reactor-equipment-3"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/fusion-reactor-equipment-3.png"
		data.raw["generator-equipment"]["fusion-reactor-equipment-4"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/fusion-reactor-equipment-4.png"
	end
	end
	
	if data.raw["movement-bonus-equipment"]["exoskeleton-equipment-3"] then
	bobicon("exoskeleton-equipment","movement-bonus-equipment",1,3,0)
	if powerbar == 1 then
		data.raw["movement-bonus-equipment"]["exoskeleton-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/exoskeleton-equipment-1B.png"
		data.raw["movement-bonus-equipment"]["exoskeleton-equipment-2"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/exoskeleton-equipment-2B.png"
		data.raw["movement-bonus-equipment"]["exoskeleton-equipment-3"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/exoskeleton-equipment-3B.png"
	else
		data.raw["movement-bonus-equipment"]["exoskeleton-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/exoskeleton-equipment-1.png"
		data.raw["movement-bonus-equipment"]["exoskeleton-equipment-2"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/exoskeleton-equipment-2.png"
		data.raw["movement-bonus-equipment"]["exoskeleton-equipment-3"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/exoskeleton-equipment-3.png"
	end
	end

	if data.raw["night-vision-equipment"]["night-vision-equipment-3"] then
	bobicon("night-vision-equipment","roboport-equipment",1,3,0)
	if powerbar == 1 then
		data.raw["night-vision-equipment"]["night-vision-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/night-vision-equipment-1B.png"
		data.raw["night-vision-equipment"]["night-vision-equipment-2"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/night-vision-equipment-2B.png"
		data.raw["night-vision-equipment"]["night-vision-equipment-3"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/night-vision-equipment-3B.png"
	else
		data.raw["night-vision-equipment"]["night-vision-equipment"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/night-vision-equipment-1.png"
		data.raw["night-vision-equipment"]["night-vision-equipment-2"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/night-vision-equipment-2.png"
		data.raw["night-vision-equipment"]["night-vision-equipment-3"].sprite.filename = "__ShinyBobGFX__/graphics/icons/equipment/night-vision-equipment-3.png"
	end
end	


if mods["bobequipment"] then
bobicon64("personal-roboport-equipment","roboport-equipment",1,1,0)
bobicon64("personal-roboport-mk2-equipment","roboport-equipment",1,2,-1)
bobicon64("personal-roboport-mk3-equipment","roboport-equipment",1,3,-2)
bobicon64("personal-roboport-mk4-equipment","roboport-equipment",1,4,-3)
bobicon("solar-panel-equipment","solar-panel-equipment",1,4,0)

powerbaronly("personal-roboport-robot-equipment","roboport-equipment",1,4,0)
powerbaronly("personal-roboport-antenna-equipment","roboport-equipment",1,4,0)
powerbaronly("personal-roboport-chargepad-equipment","roboport-equipment",1,4,0)
else
data.raw["item"]["personal-roboport-equipment"].icon_size = 64
data.raw["item"]["personal-roboport-mk2-equipment"].icon_size = 64
bobicon64("personal-roboport-equipment","roboport-equipment",1,1,0)
bobicon64("personal-roboport-mk2-equipment","roboport-equipment",1,2,-1)
end

if mods["bobwarfare"] then
bobicon("gun-turret","ammo-turret",1,1,0)
bobicon("bob-gun-turret","ammo-turret",2,5,0)
bobicon("bob-sniper-turret","ammo-turret",1,3,0)
bobicon("laser-turret","electric-turret",1,1,0)
bobicon("bob-laser-turret","electric-turret",2,5,0)

--bobicon("solar-panel-equipment","solar-panel-equipment",1,4,0)
--bobicon("fusion-reactor-equipment","generator-equipment",1,4,0)

bobicon("artillery-turret","artillery-turret",1,1,0)
bobicon("bob-artillery-turret","artillery-turret",2,3,0)
bobiconspec("artillery-wagon","artillery-wagon",1,1,0)
bobiconspec("bob-artillery-wagon","artillery-wagon",2,3,0)

--bobicon("night-vision-equipment","night-vision-equipment",1,3,0)
--bobicon("exoskeleton-equipment","movement-bonus-equipment",1,3,0)

bobiconspec("tank","car",1,1,0)
bobiconspec("bob-tank","car",2,3,0)
end

if mods["boblogistics"] then
bobiconspec("locomotive","locomotive",1,1,0)
bobiconspec("bob-locomotive","locomotive",2,3,0)
bobiconspec("cargo-wagon","cargo-wagon",1,1,0)
bobiconspec("bob-cargo-wagon","cargo-wagon",2,3,0)
bobiconspec("fluid-wagon","fluid-wagon",1,1,0)
bobiconspec("bob-fluid-wagon","fluid-wagon",2,3,0)
bobiconspec("bob-armoured-locomotive","locomotive",1,2,0)
bobiconspec("bob-armoured-cargo-wagon","cargo-wagon",1,2,0)
bobiconspec("bob-armoured-fluid-wagon","fluid-wagon",1,2,0)
end

if mods["boblogistics"] then
bobicon("flying-robot-frame","item",1,4,0)
bobicon("robot-brain-logistic","item",1,4,0)
bobicon("robot-brain-construction","item",1,4,0)
bobicon("robot-tool-logistic","item",1,4,0)
bobicon("robot-tool-construction","item",1,4,0)
end

if mods["boblogistics"] then
if mods["bobwarfare"] then
bobicon("robot-brain-combat","item",1,4,0)
bobicon("robot-tool-combat","item",1,4,0)
end
end

if mods["bobwarfare"] then
iconfix("distractor-mine","land-mine",1,1,0)
iconfix("poison-mine","land-mine",1,1,0)
iconfix("slowdown-mine","land-mine",1,1,0)
iconfix("land-mine","land-mine",1,1,0)
end



