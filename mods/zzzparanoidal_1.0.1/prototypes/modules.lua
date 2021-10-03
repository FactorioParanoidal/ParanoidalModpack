if mods["Transport_Drones"] then  -- фикс совместимости с модом

    if data.raw.module["angels-bio-yield-module"] then

        data.raw["module"]["angels-bio-yield-module"].flags = {"hidden"}
        data.raw["recipe"]["angels-bio-yield-module"].hidden = true
        data.raw["technology"]["angels-bio-yield-module"] = nil

        data.raw["module"]["angels-bio-yield-module-2"].flags = {"hidden"}
        data.raw["recipe"]["angels-bio-yield-module-2"].hidden = true
        data.raw["technology"]["angels-bio-yield-module-2"] = nil

        data.raw["module"]["angels-bio-yield-module-3"].flags = {"hidden"}
        data.raw["recipe"]["angels-bio-yield-module-3"].hidden = true
        data.raw["technology"]["angels-bio-yield-module-3"] = nil
    
    if data.raw.module["angels-bio-yield-module-4"] then

        data.raw["module"]["angels-bio-yield-module-4"].flags = {"hidden"}
        data.raw["recipe"]["angels-bio-yield-module-4"].hidden = true
        data.raw["technology"]["angels-bio-yield-module-4"] = nil
        
        data.raw["module"]["angels-bio-yield-module-5"].flags = {"hidden"}
        data.raw["recipe"]["angels-bio-yield-module-5"].hidden = true
        data.raw["technology"]["angels-bio-yield-module-5"] = nil
        
        data.raw["module"]["angels-bio-yield-module-6"].flags = {"hidden"}
        data.raw["recipe"]["angels-bio-yield-module-6"].hidden = true
        data.raw["technology"]["angels-bio-yield-module-6"] = nil
        
        data.raw["module"]["angels-bio-yield-module-7"].flags = {"hidden"}
        data.raw["recipe"]["angels-bio-yield-module-7"].hidden = true
        data.raw["technology"]["angels-bio-yield-module-7"] = nil
        
        data.raw["module"]["angels-bio-yield-module-8"].flags = {"hidden"}
        data.raw["recipe"]["angels-bio-yield-module-8"].hidden = true
        data.raw["technology"]["angels-bio-yield-module-8"] = nil
    end
    end

else 

    if data.raw.module["angels-bio-yield-module"] then
        
        data.raw.module["angels-bio-yield-module"] = nil
        data.raw.recipe["angels-bio-yield-module"] = nil
        data.raw.technology["angels-bio-yield-module"] = nil
        data.raw.module["angels-bio-yield-module-2"] = nil
        data.raw.recipe["angels-bio-yield-module-2"] = nil
        data.raw.technology["angels-bio-yield-module-2"] = nil
        data.raw.module["angels-bio-yield-module-3"] = nil
        data.raw.recipe["angels-bio-yield-module-3"] = nil
        data.raw.technology["angels-bio-yield-module-3"] = nil

    if data.raw.module["angels-bio-yield-module-4"] then
    
        data.raw.module["angels-bio-yield-module-4"] = nil
        data.raw.module["angels-bio-yield-module-5"] = nil
        data.raw.module["angels-bio-yield-module-6"] = nil
        data.raw.module["angels-bio-yield-module-7"] = nil
        data.raw.module["angels-bio-yield-module-8"] = nil
        
        data.raw.recipe["angels-bio-yield-module-4"] = nil
        data.raw.recipe["angels-bio-yield-module-5"] = nil
        data.raw.recipe["angels-bio-yield-module-6"] = nil
        data.raw.recipe["angels-bio-yield-module-7"] = nil
        data.raw.recipe["angels-bio-yield-module-8"] = nil
        
        data.raw.technology["angels-bio-yield-module-4"] = nil
        data.raw.technology["angels-bio-yield-module-5"] = nil
        data.raw.technology["angels-bio-yield-module-6"] = nil
        data.raw.technology["angels-bio-yield-module-7"] = nil
        data.raw.technology["angels-bio-yield-module-8"] = nil
    end
    end
end