local rro = Muluna.rro
if data.raw["item"]["electrochemical-science-pack"] then
    local electrochemical_techs = {
        
        --infinite = {"thruster-fuel-productivity"}
    }

    for _,group in pairs(electrochemical_techs) do
        for _,tech in pairs(group) do
            if data.raw["technology"][tech] then
                rro.soft_insert(data.raw["technology"][tech].unit.ingredients,{"electrochemical-science-pack",1}) --Add science pack if it doesn't already exist.
                rro.soft_insert(data.raw["technology"][tech].prerequisites,"electrochemical-science-pack") --Add science pack if it doesn't already exist.
            end
        end

    end

end