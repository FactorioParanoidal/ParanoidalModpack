-- modify multi fluid recipes to not be crafted in assembling machines

local liquid_recipes = {
    ['concrete-mixture-1'] = true,
    ['concrete-mixture-2'] = true,
}

for k, v in pairs (data.raw.recipe) do
    -- statements
    if liquid_recipes[k] then
        log(k)
        data.raw.recipe[k].category = 'chemistry'
    end
end

-- add multi pipe machines to black list

appmod.blacklist['ore-floatation-cell'] = true
appmod.blacklist['ore-floatation-cell-2'] = true
appmod.blacklist['ore-floatation-cell-3'] = true
appmod.blacklist['ore-leaching-plant'] = true
appmod.blacklist['ore-leaching-plant-2'] = true
appmod.blacklist['ore-leaching-plant-3'] = true
appmod.blacklist['electro-whinning-cell'] = true
appmod.blacklist['electro-whinning-cell-2'] = true
appmod.blacklist['electro-whinning-cell-3'] = true
appmod.blacklist['crystallizer'] = true
appmod.blacklist['crystallizer-2'] = true
appmod.blacklist['filtration-unit'] = true
appmod.blacklist['filtration-unit-2'] = true
appmod.blacklist['liquifier'] = true
appmod.blacklist['liquifier-2'] = true
appmod.blacklist['liquifier-3'] = true
appmod.blacklist['liquifier-4'] = true
appmod.blacklist['hydro-plant'] = true
appmod.blacklist['hydro-plant-2'] = true
appmod.blacklist['hydro-plant-3'] = true
appmod.blacklist['salination-plant'] = true
appmod.blacklist['salination-plant-2'] = true
appmod.blacklist['washing-plant'] = true
appmod.blacklist['washing-plant-2'] = true
appmod.blacklist['barreling-pump'] = true
appmod.blacklist['advanced-chemical-plant'] = true
appmod.blacklist['advanced-chemical-plant-2'] = true
appmod.blacklist['gas-refinery-small'] = true
appmod.blacklist['gas-refinery-small-2'] = true
appmod.blacklist['gas-refinery-small-3'] = true
appmod.blacklist['gas-refinery-small-4'] = true
appmod.blacklist['gas-refinery'] = true
appmod.blacklist['gas-refinery-2'] = true
appmod.blacklist['gas-refinery-3'] = true
appmod.blacklist['gas-refinery-4'] = true
appmod.blacklist['steam-cracker'] = true
appmod.blacklist['steam-cracker-2'] = true
appmod.blacklist['steam-cracker-3'] = true
appmod.blacklist['steam-cracker-4'] = true
appmod.blacklist['separator'] = true
appmod.blacklist['separator-2'] = true
appmod.blacklist['separator-3'] = true
appmod.blacklist['separator-4'] = true
appmod.blacklist['angels-electrolyser'] = true
appmod.blacklist['angels-electrolyser-2'] = true
appmod.blacklist['angels-electrolyser-3'] = true
appmod.blacklist['angels-electrolyser-4'] = true
appmod.blacklist['angels-air-filter'] = true
appmod.blacklist['angels-air-filter-2'] = true
appmod.blacklist['induction-furnace'] = true
appmod.blacklist['induction-furnace-2'] = true
appmod.blacklist['induction-furnace-3'] = true
appmod.blacklist['induction-furnace-4'] = true
appmod.blacklist['blast-furnace'] = true
appmod.blacklist['blast-furnace-2'] = true
appmod.blacklist['blast-furnace-3'] = true
appmod.blacklist['blast-furnace-4'] = true
appmod.blacklist['angels-chemical-furnace'] = true
appmod.blacklist['angels-chemical-furnace-2'] = true
appmod.blacklist['angels-chemical-furnace-3'] = true
appmod.blacklist['angels-chemical-furnace-4'] = true
appmod.blacklist['casting-machine'] = true
appmod.blacklist['casting-machine-2'] = true
appmod.blacklist['casting-machine-3'] = true
appmod.blacklist['casting-machine-4'] = true
appmod.blacklist['strand-casting-machine'] = true
appmod.blacklist['strand-casting-machine-2'] = true
appmod.blacklist['strand-casting-machine-3'] = true
appmod.blacklist['strand-casting-machine-4'] = true
appmod.blacklist['cooling-tower'] = true
