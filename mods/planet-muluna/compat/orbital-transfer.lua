local rro = Muluna.rro
if data.raw["recipe"]["orbital-transfer-provider"] then
    rro.replace(data.raw["recipe"]["orbital-transfer-provider"].ingredients,
        {type = "item", name = "passive-provider-chest", amount = 1},
        {type = "item", name = "space-chest-muluna", amount = 1}
    )
end

if data.raw["recipe"]["orbital-transfer-requester"] then
    rro.replace(data.raw["recipe"]["orbital-transfer-requester"].ingredients,
        {type = "item", name = "requester-chest", amount = 1},
        {type = "item", name = "space-chest-muluna", amount = 1}
    )
end

if data.raw["technology"]["orbital-transfer"] then
    rro.soft_insert(data.raw["technology"]["orbital-transfer"].prerequisites,"space-chest-muluna")
    rro.soft_insert(data.raw["technology"]["orbital-transfer"].unit.ingredients, {"production-science-pack" , 1})
    rro.soft_insert(data.raw["technology"]["orbital-transfer"].unit.ingredients, {"utility-science-pack" , 1})
end