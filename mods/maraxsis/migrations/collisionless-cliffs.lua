local surface = game.get_surface("maraxsis")
if not surface then return end

for _, cliff in pairs(surface.find_entities_filtered {name = "cliff-maraxsis"}) do
    cliff.destructible = true
    cliff.minable_flag = true
end
