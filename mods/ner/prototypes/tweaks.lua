local done = false
local verbose = false

function tweaklimitations(modstring)
    local target = {}
    if verbose then log("tweaklimitations() called;") end
    
    if modstring == "angels" then
        target = nit_angelsproductivity
    elseif modstring == "bobs" then
        target = nit_bobsproductivity
    elseif modstring == "base" or modstring == "vanilla" then
        target = nit_vanillaproductivity
    elseif not modstring then
        if verbose then log("No target.") end
        return
    end
    
    if verbose then log("Target: " .. modstring) end
    
    local pronounced = false
    
    for i in ipairs(target) do
        for k,v in pairs(data.raw.module) do
            if v.limitation == target[i] and v.effect.productivity then
                if verbose then log(v.limitation .. " already exists in limitations.") end
            elseif v.effect.productivity then
                if not pronounced then 
                    if verbose then log("Inserting " .. target[i] .. " into limitations.") end
                    pronounced = true
                end
                table.insert(v.limitation,target[i])
            end
        end
        pronounced = false
    end

    if verbose then log("tweaklimitations() end;") end
end

if not done then
    if verbose then log("Now tweaking productivity limitations;") end
    if angelsmods then
        if verbose then log("Angel's Mods present") end
        --tweaklimitations("angels")
    end

    if bobslibrary then
        log("Bob's Mods present")
        --tweaklimitations("bobs")
    end

    if verbose then log("Tweaking base game mod productivity limitations.") end
    tweaklimitations("base")
    
    done = true
    if verbose then log("Done tweaking.") end
end