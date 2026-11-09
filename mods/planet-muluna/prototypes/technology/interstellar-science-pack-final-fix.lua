-- This section replaces the interstellar science pack technology with multiple technologies 
-- with the collective effect being that you unlock the interstellar science pack upon unlocking two planetary science packs.
-- Technologies that require at least two interplanetary science packs will have these new technologies added to their prereqs, and
-- technologies with one interplanetary science pack have their prerequisite removed.
local rro = Muluna.rro



local function dynamic_interstellar_pack_icon(pack1,pack2)
    return {
        {
            icon = "__muluna-graphics__/graphics/technology/space-science-pack.png",
            icon_size = 256,
        },
        {
            icon = data.raw["item"][pack1].icon or data.raw["item"]["interstellar-science-pack"].icon,
            icon_size = data.raw["item"][pack1].icon_size or data.raw["item"]["interstellar-science-pack"].icon_size,
            shift = {35,-35},
            scale=0.75,
        },
        {
            icon = data.raw["item"][pack2].icon or data.raw["item"]["interstellar-science-pack"].icon,
            icon_size=data.raw["item"][pack2].icon_size or data.raw["item"]["interstellar-science-pack"].icon_size,
            --scale=0.3,
            shift = {-35,-35},
            scale=0.75,
        },

    }

end

local function dynamic_interstellar_pack_tech_name(pack1,pack2)
    return "interstellar-science-pack".. "-" .. pack1 .. "-" .. pack2
end

local function dynamic_interstellar_pack_tech(pack1,pack2)
    local new_pack = table.deepcopy(data.raw["technology"]["interstellar-science-pack"])
    --new_pack.hidden = true
    new_pack = Muluna.rro.util_merge{new_pack,
    {
        name = dynamic_interstellar_pack_tech_name(pack1,pack2),
        icons = dynamic_interstellar_pack_icon(pack1,pack2),
        localised_description = {"technology-description.interstellar-science-pack"}
    },
    
    }   
    if pack1 == "slp-sun-science-pack" then pack1 = "slp-sunpack" end
    if pack2 == "slp-sun-science-pack" then pack2 = "slp-sunpack" end
    new_pack.icon = nil
    if data.raw["technology"][pack1] then
        rro.soft_insert(new_pack.prerequisites, pack1)
    end
    if data.raw["technology"][pack2] then
        rro.soft_insert(new_pack.prerequisites, pack2)
    end
    return new_pack
end

local function has_prerequisite(tech,technologies)
   return rro.contains()
    
end

local science_packs = {}
local possible_science_packs = 
{
    "metallurgic-science-pack",
    "agricultural-science-pack",
    "electromagnetic-science-pack",
    "electrochemical-science-pack",
    "cerysian-science-pack",
    "janus-time-science-pack",
    "slp-sunpack",
    "nanite-science-pack",
    --"insulation-science-pack",
    "battlefield-science-pack",
    --"igrys-mineral-science-pack",
    --"biorecycling-science-pack"
    --"craptonite-processing",
}

local special_cases = {
    ["slp-sunpack"] = "slp-sun-science-pack",
    ["igrys-mineral-science"] = "igrys-mineral-science",
    ["biorecycling-science-pack"] = "craptonite-processing"
}



for _,pack in pairs(possible_science_packs) do 
    if data.raw["item"][pack] then
        table.insert(science_packs,pack)
    elseif data.raw["item"][special_cases[pack]] then
        table.insert(science_packs,special_cases[pack])
    end
end

local endgame_techs = {
    "maraxsis-promethium-productivity",
    "research-speed-infinite",
    "science-pack-productivity",
}

for i = 1, #science_packs - 1 do
    for j = i + 1, #science_packs do
        local item1 = science_packs[i]
        local item2 = science_packs[j]
        assert(item1 ~= nil, item2 ~= nil,item1 .. item2)
        local has_as_prerequisite = false
        
        for _,tech in pairs(data.raw["technology"]) do
            if tech.unit and rro.contains(tech.unit.ingredients,{"interstellar-science-pack",1}) then
                if not rro.contains(endgame_techs,tech.name) 
                    and tech.ensure_all_packs_from_vanilla_lab == nil 
                    and rro.contains(tech.unit.ingredients,{item1,1}) 
                    and rro.contains(tech.unit.ingredients,{item2,1}) then
                    rro.soft_insert(tech.prerequisites,dynamic_interstellar_pack_tech_name(item1,item2))
                    has_as_prerequisite = true
                end
                rro.remove(tech.prerequisites,"interstellar-science-pack")
            end
            if tech.unit and rro.contains(tech.unit.ingredients,{"interstellar-science-pack",1})  and (tech.prerequisites == {} or tech.prerequisites == nil) then
                tech.prerequisites = {}
                tech.prerequisites = {"space-science-pack"}
                if rro.contains(tech.unit.ingredients,{"utility-science-pack",1}) then
                    rro.soft_insert(tech.prerequisites,"utility-science-pack")
                end
                if rro.contains(tech.unit.ingredients,{"production-science-pack",1}) then
                    rro.soft_insert(tech.prerequisites,"production-science-pack")
                end
            end
        end
        Muluna:extend{dynamic_interstellar_pack_tech(item1,item2)}
    end
end

data.raw["technology"]["interstellar-science-pack"] = nil