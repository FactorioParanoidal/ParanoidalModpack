data:extend({
--камень из блоков
{
    type = "recipe",
    name = "stone-crushed-2",
    category = "biofarm-mod-crushing",
    energy_required = 5,
    enabled = false,
    ingredients = {{ type = "item", name = "stone-brick", amount = 5}},
    results = {
        -- 2, а не 7: кирпич делается с продуктивностью, цикл камень-кирпич не должен множить камень
        {type = "item", name = "stone", amount = 2}
    }
}
})
