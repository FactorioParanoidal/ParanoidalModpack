local rro = Muluna.rro
local advanced_boiler_tiers = 5

if mods["bobpower"] then
    local function temperature(tier)
        return 15 + 150*tier
    end
    local advanced_boiler ={
        entity = table.deepcopy["assembling-machine"]["muluna-advanced-boiler"],
        item = table.deepcopy["assembling-machine"]["muluna-advanced-boiler"],
        tech = table.deepcopy["technology"]["muluna-advanced-boiler"],
        recipe = table.deepcopy["recipe"]["muluna-advanced-boiler"],
    }
    
    for i = 2,advanced_boiler_tiers do 
        local new_advanced_boiler = table.deepcopy(advanced_boiler)
        for _,object in pairs(new_advanced_boiler) do
            object.name = "muluna-advanced-boiler-" tostring(i)
        end

        Muluna:extend{new_advanced_boiler}
    end
end