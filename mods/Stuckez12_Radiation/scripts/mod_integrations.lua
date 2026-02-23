local mod_addons = {}


function Base_Game()
    log("Base Game - Items Included")

    return {
        item = {
            ["uranium-ore"] = {value = 1, type = "item"},
            ["uranium-238"] = {value = 2, type = "item"},
            ["uranium-235"] = {value = 5, type = "item"},
            ["uranium-fuel-cell"] = {value = 10, type = "item"},
            ["depleted-uranium-fuel-cell"] = {value = 7, type = "item"},
            ["nuclear-fuel"] = {value = 10, type = "item"},
            ["uranium-rounds-magazine"] = {value = 2, type = "ammo"},
            ["uranium-cannon-shell"] = {value = 3, type = "ammo"},
            ["explosive-uranium-cannon-shell"] = {value = 4, type = "ammo"},
            ["atomic-bomb"] = {value = 50, type = "ammo"}
        },
        fluid = {},
        unit = {
            ["big-biter"] = {value = 10, type = "unit"},
            ["behemoth-biter"] = {value = 50, type = "unit"},
            ["big-spitter"] = {value = 8, type = "unit"},
            ["behemoth-spitter"] = {value = 40, type = "unit"}
        }
    }
end


function Cerys_Compatible()
    log("Cerys Mod - Items Included")

    return {
        item = {
            ["cerys-radioactive-module-decayed"] = {value = 4, type = "module"},
            ["cerys-radioactive-module-charged"] = {value = 9, type = "module"},
            ["plutonium-rounds-magazine"] = {value = 8, type = "ammo"},
            ["plutonium-238"] = {value = 7, type = "item"},
            ["plutonium-239"] = {value = 4, type = "item"},
            ["plutonium-fuel"] = {value = 14, type = "item"},
            ["mixed-oxide-fuel-cell"] = {value = 18, type = "item"},
            ["depleted-mixed-oxide-fuel-cell"] = {value = 8, type = "item"},
            ["cerys-nuclear-scrap"] = {value = 2, type = "item"},
            ["cerysian-science-pack"] = {value = 6, type = "tool"},
            ["cerys-neutron-bomb"] = {value = 25, type = "ammo"},
            ["cerys-hydrogen-bomb"] = {value = 80, type = "ammo"}
        },
        fluid = {
            ["mixed-oxide-waste-solution"] = {value = 1, type = "fluid"}
        },
        unit = {}
    }
end


function PlutoniumEnergy_Compatible()
    log("PlutoniumEnergy Mod - Items Included")

    return {
        item = {
            ["plutonium-238"] = {value = 7, type = "item"},
            ["plutonium-239"] = {value = 4, type = "item"},
            ["plutonium-fuel-cell"] = {value = 16, type = "item"},
            ["depleted-plutonium-fuel-cell"] = {value = 10, type = "item"},
            ["MOX-fuel-cell"] = {value = 14, type = "item"},
            ["depleted-MOX-fuel-cell"] = {value = 9, type = "item"},
            ["breeder-fuel-cell"] = {value = 15, type = "item"},
            ["depleted-breeder-fuel-cell"] = {value = 11, type = "item"},
            ["plutonium-atomic-artillery-shell"] = {value = 75, type = "ammo"},
            ["plutonium-rounds-magazine"] = {value = 8, type = "ammo"},
            ["plutonium-cannon-shell"] = {value = 7, type = "ammo"},
            ["explosive-plutonium-cannon-shell"] = {value = 8, type = "ammo"},
            ["plutonium-fuel"] = {value = 14, type = "item"}
        },
        fluid = {},
        unit = {}
    }
end


function Bobs_Warfare_Compatibility()
    log("Bob's Warfare Mod - Items Included")

    return {
        item = {
            ["bob-uranium-bullet"] = {value = 2, type = "item"},
            ["bob-atomic-artillery-shell"] = {value = 60, type = "ammo"},
            ["bob-shotgun-uranium-shell"] = {value = 2, type = "ammo"},
            ["bob-uranium-bullet-projectile"] = {value = 2, type = "item"}
        },
        fluid = {},
        unit = {}
    }
end


mod_addons.compatible_mod_funcs = {
    ["base"] = Base_Game,
    ["Cerys-Moon-of-Fulgora"] = Cerys_Compatible,
    ["PlutoniumEnergy"] = PlutoniumEnergy_Compatible,
    ["bobwarfare"] = Bobs_Warfare_Compatibility
}


function BZ_Titanium_Data_Compatibility()
    local tech = data.raw.technology["radiation-protection"]

    for i, prereq in ipairs(tech.prerequisites) do
        if prereq == "uranium-mining" then
            tech.prerequisites[i] = "fluid-mining"
            break
        end
    end

    local tip_change = data.raw["tips-and-tricks-item"]["Stuckez12-radiation-entity-list"]

    tip_change.trigger.technology = "fluid-mining"
end


mod_addons.data_compatible_mod_funcs = {
    ["bztitanium"] = BZ_Titanium_Data_Compatibility
}


function mod_addons.integrate_mods()
    storage.radiation_items = {}
    storage.radiation_fluids = {}
    storage.biters = {}

    for name, version in pairs(script.active_mods) do
        if mod_addons.compatible_mod_funcs[name] then
            mod_data = mod_addons.compatible_mod_funcs[name]()

            for name, data in pairs(mod_data.item) do storage.radiation_items[name] = data.value end
            for name, data in pairs(mod_data.fluid) do storage.radiation_fluids[name] = data.value end
            for name, data in pairs(mod_data.unit) do storage.biters[name] = data.value end
        end
    end

    log("Init Func Complete")
end


return mod_addons
