local rro=Muluna.rro
local thruster_fuel=table.deepcopy(data.raw["recipe"]["thruster-fuel"])

rro.replace(thruster_fuel.ingredients,{type="item", name="carbon", amount=2},{type="item", name="rocket-fuel", amount=1})
rro.replace(thruster_fuel.ingredients,{type="fluid", name="water", amount=10},{type="fluid", name="water", amount=70})
thruster_fuel.energy_required=thruster_fuel.energy_required*7
thruster_fuel.results[1].amount=500
thruster_fuel.name="thruster-fuel-from-rocket-fuel"
thruster_fuel.hide_from_signal_gui = false
thruster_fuel.icons= {
    {
        icon=data.raw["fluid"]["thruster-fuel"].icon,
        icon_size=data.raw["fluid"]["thruster-fuel"].icon_size,
        scale=0.35
    },
    {
        icon=data.raw["item"]["rocket-fuel"].icon,
        icon_size=data.raw["item"]["rocket-fuel"].icon_size,
        scale=0.30,
        shift = {10,-10},
    },
    -- {
    --     icon=data.raw["item"]["rocket-fuel"].icon,
    --     icon_size=data.raw["item"]["rocket-fuel"].icon_size,
    --     scale=0.25,
    --     shift = {0,0},
    -- }
}


thruster_fuel.icon=nil
thruster_fuel.icon_size=nil
Muluna:extend{thruster_fuel}

-- table.insert(data.raw["technology"]["space-platform-thruster"].effects,{
--     type="unlock-recipe",
--     recipe="thruster-fuel-from-rocket-fuel",
-- })

