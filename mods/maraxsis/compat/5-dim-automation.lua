-- https://github.com/notnotmelon/maraxsis/issues/211

if not mods["5dim_automation"] then return end

local i = 2
while true do
    local chemical_plant = data.raw["assembling-machine"]["5d-chemical-plant-0" .. i]
    if not chemical_plant then break end
    chemical_plant.maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false}
    i = i + 1
end
