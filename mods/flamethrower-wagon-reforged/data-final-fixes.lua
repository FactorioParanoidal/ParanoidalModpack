-- The wagon turret uses the fuels of the build's flamethrower turret (Bob's and Angels add and
-- remove them in data/data-updates, after this mod copied the turret).
local turret = data.raw["fluid-turret"]["flamethrower-wagon-turret"]
local source = data.raw["fluid-turret"]["flamethrower-turret"]
if source and source.attack_parameters and source.attack_parameters.fluids then
    turret.attack_parameters.fluids = table.deepcopy(source.attack_parameters.fluids)
end

-- The script moves only these fluids from the wagon tank into the turrets.
local fuels = {}
for _, fluid in pairs(turret.attack_parameters.fluids or {}) do
    if data.raw.fluid[fluid.type] then fuels[fluid.type] = true end
end

data:extend({
    {
        type = "mod-data",
        name = "flamethrower-wagon-reforged",
        data = { fuels = fuels },
    },
})
