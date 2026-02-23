local surface = game.surfaces[1]
local centrifuge = surface.find_entity("centrifuge", {x=-245.5, y=-42.5})
local progress = centrifuge.crafting_progress


if progress >= 0.9 and not storage.crafted then
    centrifuge.crafting_progress = 0
    centrifuge.get_inventory(defines.inventory.assembling_machine_input).clear()
    centrifuge.get_inventory(defines.inventory.assembling_machine_output).insert{name = "uranium-235", count = 1}

    storage.crafted = true
end
