data:extend({{
    type = "recipe-category",
    name = "biofarm-mod-farm-2"
}, {
    type = "recipe-category",
    name = "biofarm-mod-farm-3"
}, {
    type = "recipe-category",
    name = "biofarm-mod-greenhouse-2"
}, {
    type = "recipe-category",
    name = "biofarm-mod-greenhouse-3"
}, {
    type = "recipe-category",
    name = "biofarm-mod-bioreactor-2"
}, {
    type = "recipe-category",
    name = "biofarm-mod-bioreactor-3"
}})

data:extend({ -- Greenhouse
{
    type = "recipe",
    name = "bi-bio-greenhouse-2",
    ingredients = {{"steel-plate", 10}, {"concrete", 10}, {"deadlock-large-lamp", 5}, {"bi-bio-greenhouse", 2} },
    enabled = false,
    energy_required = 5,
    result = "bi-bio-greenhouse-2",
    subgroup = "bio-bio-farm-fluid-entity",
    order = "aa[bi]"
}, {
    type = "recipe",
    name = "bi-bio-greenhouse-3",
    ingredients = {{"plastic-bar", 10}, {"refined-concrete", 10}, {"deadlock-large-lamp", 5}, {"bi-bio-greenhouse-2", 2}},
    enabled = false,
    energy_required = 5,
    result = "bi-bio-greenhouse-3",
    subgroup = "bio-bio-farm-fluid-entity",
    order = "aaa[bi]"
}, -- BioFarm
{
    type = "recipe",
    name = "bi-bio-farm-2",
    ingredients = {{"bi-bio-farm", 2}, {"bi-bio-greenhouse-2", 4}, {"concrete", 40}, {"wood", 50}, {"steel-pipe", 30}},
    enabled = false,
    energy_required = 5,
    result = "bi-bio-farm-2",
    subgroup = "bio-bio-farm-fluid-entity",
    order = "bb[bi]"
}, {
    type = "recipe",
    name = "bi-bio-farm-3",
    ingredients = {{"bi-bio-farm-2", 2}, {"bi-bio-greenhouse-3", 4}, {"refined-concrete", 40}, {"wood", 100},
                   {"brass-pipe", 30}},
    enabled = false,
    energy_required = 5,
    result = "bi-bio-farm-3",
    subgroup = "bio-bio-farm-fluid-entity",
    order = "bbb[bi]"
}, -- BIOREACTOR
{
    type = "recipe",
    name = "bi-bio-reactor-2",
    ingredients = {{"bi-bio-reactor", 2}, {"aluminium-plate", 20}, {"electronic-circuit", 5}},
    enabled = false,
    energy_required = 5,
    result = "bi-bio-reactor-2",
    subgroup = "bio-bio-fuel-fluid",
    order = "aa"
}, {
    type = "recipe",
    name = "bi-bio-reactor-3",
    ingredients = {{"bi-bio-reactor-2", 2}, {"plastic-bar", 20}, {"advanced-circuit", 5}},
    enabled = false,
    energy_required = 5,
    result = "bi-bio-reactor-3",
    subgroup = "bio-bio-fuel-fluid",
    order = "aaa"
}})

