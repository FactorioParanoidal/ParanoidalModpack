--data.raw.technology["electrolysis-1"].enabled = false
--data.raw.technology["electrolysis-2"].enabled = false
--data.raw.technology["electrolysis-3"].enabled = false
--data.raw.technology["electrolysis-4"].enabled = false


if settings.startup["science-oberhaul"].value == true then
    require('prototypes.scienceoberhaul')
end
if settings.startup["belt-speed-change"].value == true then
    require('prototypes.beltentities')
    require('prototypes.beltrecipes')
end
if settings.startup["petrochem-change"].value == true then
    require('prototypes.petrochemchange')
end
if not mods.CircuitProcessing then
    if mods.bobmodules then
        if settings.startup["bobs-module-nerf"].value == true then
            require('prototypes.moduleeffects')
        end
        if settings.startup["module-cost-multiply"].value == true then
            require('prototypes.modulecosts')
        end
        if settings.startup["module-slot-nerf"].value == true then
            require('prototypes.moduleslots')
        end
        if settings.startup["beacon-removal-mk2"].value == true then
            data.raw.recipe['beacon-2'].hidden = true
            data.raw.technology["effect-transmission-2"].enabled = false
            data.raw.recipe['beacon-3'].hidden = true
            data.raw.technology["effect-transmission-3"].enabled = false
	else 
            if settings.startup["beacon-removal-mk3"].value == true then
                data.raw.recipe['beacon-3'].hidden = true
                data.raw.technology["effect-transmission-3"].enabled = false
            end
        end
    end
end
if settings.startup["bobs-solar-multiply"].value == true then
    require('prototypes.bobssolar')
end
if settings.startup["train-wagon-nerf"].value == true then
    require('prototypes.trains')
end
if mods.bobwarfare then
    if settings.startup["bobs-military-simplify"].value == true then
        require('prototypes.bobwarfare')
    end
    if settings.startup["simple-cordite"].value == true then
        if mods.angelspetrochem then
            require('prototypes.simplecordite')
        end
    end
end
if settings.startup["bob-simple-logistics"] == false then
    require('prototypes.logistics')
end
if settings.startup["gem-liquifaction"].value == true then
    require('prototypes.gems')
end
if settings.startup["electrolyser-merge"].value == true then
    require('prototypes.electrolyser')
end
if mods.CompactPower then
    require('prototypes.compactpower')
end

require('prototypes.angelsconcrete')
require('prototypes.misc')
require('prototypes.angelsrefining')

