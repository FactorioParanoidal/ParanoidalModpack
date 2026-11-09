local rro = Muluna.rro
-- Runs once during data and once during data-updates
-- This is done in each step to:
-- Data stage: To allow other mods to propogate changes from this code to their mod's technologies.
-- Data-updates stage: To add science packs to technologies that might not exist by this mod's data stage.

local old_aop = mods["Age-of-Production"] and helpers.compare_versions(mods["Age-of-Production"],"2.0.0") == -1
local new_aop = mods["Age-of-Production"] and helpers.compare_versions(mods["Age-of-Production"],"2.0.0") >= 0

local techs_interstellar = {
    ["planet-discovery"] = 
        {
            "planet-discovery-tenebris", "planet-discovery-naufulglebunusilo"
        },
    aquilo =
        {
            "planet-discovery-aquilo","fusion-reactor", "railgun", "railgun-damage-1", "railgun-shooting-speed-1",
        },
    infinite = 
        {
            "maraxsis-promethium-productivity", "research-speed-infinite"
        },
    corrundum = 
        {
            "platinum-thruster", "space-steam-production",
        },
    maraxsis =
        {
            "planet-discovery-maraxsis","maraxsis-abyssal-diving-gear",
        },
    secretas = 
    {
        "planet-discovery-secretas", "spaceship-scrap-recycling-productivity",
        "spaceship-scrap-recycling-productivity"
    },
    -- ["metal-and-stars"] = 
    --     {
    --         "planet-discovery-shipyard",
    --     },
    paracelsin = 
        {
            "planet-discovery-paracelsin",
        },
    ["orbital-ion-cannon"] =
        {
            "orbital-ion-cannon-mk2","orbital-ion-cannon-mk2-upgrade",
        },
    ["dyson-sphere"] =
        {
            "slp-dyson-sphere-grounded","ds-energy-loader-mk2","ds-energy-loader-mk3",
        },
    ["fall-of-promethea"] =
        {
            "promethium-processing",
            "isotope-processing",
            "promethium-weapons-tech",
            "promethium-space-travel",
            "promethium-power-handling"
        },
    ["vesta"] = 
        {
            "planet-discovery-vesta"
        },
    ["muria"] = 
        {
            "weapon-shooting-speed-7",
            "weapon-shooting-speed-8",
        },
    ["rigor-module"] = (not mods["planet-crucible"]) and {
            "rigor-module-3"
        } or {},
    other = 
        {
            
            
            "shield-projector",
            "orbital-transfer",
            "starsystem-discovery-nexuz",
            --"system-discovery-dea-dia",
            --"planet-discovery-prosephina",
            "planet-discovery-dea-dia",
            "planet-pyroxsis",
            --"planet-discovery-lemures",
            
        },
    -- fusion_thruster = {
    --     "fusion-thruster"
    -- }
    aop = new_aop and 
        {
            "aop-quantum-machinery",

        } 
        or nil,
}



local techs_asteroid = {"trace-oxide-processing","trace-carbonic-processing","trace-metallic-processing",
    "promethium-advanced-processing"}

local planets_nexuz = {
    "planet-discovery-janus",
    "planet-discovery-corrundum",
    "planet-discovery-naufulglebunusilo",
    "planet-discovery-arrakis"
}

local function make_interstellar(tech_name)
    if data.raw["technology"][tech_name].unit then
        rro.soft_insert(data.raw["technology"][tech_name].unit.ingredients,{"interstellar-science-pack",1}) --Add science pack if it doesn't already exist.
    end
    if not data.raw["technology"][tech_name].prerequisites then
        data.raw["technology"][tech_name].prerequisites = {}
    end
    rro.soft_insert(data.raw["technology"][tech_name].prerequisites,"interstellar-science-pack") --Add science pack if it doesn't already exist.

end


if settings.startup["muluna-easy-interstellar-science-pack-compatibility-mode"].value == false then
    for _,tech in pairs(data.raw["technology"]) do

        local interstellar = 
            ( -- If is Aquilo-tier space-related technology
                tech.unit and 
                (
                    (
                            rro.count(
                            {rro.contains(tech.unit.ingredients,{"metallurgic-science-pack","_any"}),
                            rro.contains(tech.unit.ingredients,{"electromagnetic-science-pack","_any"}),
                            rro.contains(tech.unit.ingredients,{"agricultural-science-pack","_any"})}
                        ,rro.predicates.equals(true)) >= 2
                        and
                        (
                        rro.find_many(tech.name,{"discovery","thruster","asteroid%-collector","asteroid_collector","planet","science%-pack"})
                            --string.find(tech.name,"discovery") or
                            --string.find(tech.name,"thruster")
                        )
                    ) or
                    (
                        old_aop and string.find(tech.name,"aop")
                    ) or
                    (
                    new_aop and (
                        rro.contains(tech.unit.ingredients,{"aop-quantistic-science-pack","_any"})
                    )
                    )
                )
                
                
            )  --Add additional "or" statements below
        
        if  interstellar then
            make_interstellar(tech.name)
        end

    end



    for _,group in pairs(techs_interstellar) do
        for _,tech in pairs(group) do
            if data.raw["technology"][tech] then
                make_interstellar(tech)
            end
        end
    end

    for _,tech in pairs(techs_asteroid) do
        if data.raw["technology"][tech] then
            rro.soft_insert(data.raw["technology"][tech].unit.ingredients,{"interstellar-science-pack",1}) --Add science pack if it doesn't already exist.
            rro.soft_insert(data.raw["technology"][tech].prerequisites,"muluna-crusher-2") --Add science pack if it doesn't already exist.
        end
        
    end
    
    if mods["Starmap_Nexuz"] then
        for _,tech in pairs(planets_nexuz) do
            if data.raw["technology"][tech] then
                make_interstellar(tech)
            end
            
        end
    end

end

--This one is hardcoded
rro.soft_insert(data.raw["technology"]["promethium-science-pack"].unit.ingredients,{"interstellar-science-pack",1}) --Add science pack if it doesn't already exist.
rro.soft_insert(data.raw["technology"]["research-productivity"].unit.ingredients,{"interstellar-science-pack",1}) --Add science pack if it doesn't already exist.
 