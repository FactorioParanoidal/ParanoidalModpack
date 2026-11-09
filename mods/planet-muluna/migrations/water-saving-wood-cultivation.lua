for _,force in pairs(game.forces) do
    if force.technologies["muluna-wood-cultivation"] and force.technologies["muluna-wood-cultivation"].researched == true then
        force.technologies["muluna-water-saving-wood-cultivation"].researched = true
    end
end