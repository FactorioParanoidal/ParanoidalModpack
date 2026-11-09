local rro = Muluna.rro
if data.raw["technology"]["orbital-ion-cannon"] then
    rro.replace(data.raw["technology"]["orbital-ion-cannon"].prerequisites,"rocket-silo","space-science-pack")
end
