local rro = Muluna.rro
if mods["Age-of-Production"] then

    rro.deep_replace(data.raw["recipe"]["aop-quantum-computer"],"biolab","cryolab")
    rro.deep_replace(data.raw["technology"]["aop-quantum-machinery"],"biolab","cryolab")


end