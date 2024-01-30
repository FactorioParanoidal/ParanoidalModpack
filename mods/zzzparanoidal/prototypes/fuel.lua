-- 5 solid fuel -> 4 coke pellets, 5*12MJ -> 4*15MJ
data.raw.recipe["bi-pellet-coke"].result_count = 4
data.raw.recipe["bi-pellet-coke"].energy_required = 4
-- 1MJ*16 pulp -> 20MJ*1 brick
data.raw.recipe["bi-wood-fuel-brick"].ingredients = 
    {{type = "item", name = "bi-woodpulp", amount=40}}
