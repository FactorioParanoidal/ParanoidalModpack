
require("prototypes.items.nuclear_action_tables")
--------------------------------------------------------------------------------------------------

--THERMONUCLEAR BOMB PROJECTILE

data:extend(
{
	{
    type = "projectile",
    name = "thermonuclear-rocket",
    flags = {"not-on-map"},
    acceleration = 0.002,
    action = clowns_actions_thermonuke,
    light = {intensity = 1, size = 90, color = {r=1.0, g=1.0, b=1.0}},--{intensity = 0.8, size = 15},
    animation = table.deepcopy(data.raw["projectile"]["atomic-rocket"].animation),
	shadow = table.deepcopy(data.raw["projectile"]["atomic-rocket"].shadow),
	smoke = table.deepcopy(data.raw["projectile"]["atomic-rocket"].smoke),
	}
}
)

--ARTILLERY SHELL PROJECTILES
if settings.startup["artillery-shells"].value == true then
	local nuke_artillery_projectile = util.table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
	nuke_artillery_projectile.name = "artillery-projectile-nuclear"
	for i,j in pairs(clowns_actions_nuke.action_delivery.target_effects) do
	table.insert(nuke_artillery_projectile.action.action_delivery.target_effects,j)
	end

	local thermonuke_artillery_projectile = util.table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
	thermonuke_artillery_projectile.name = "artillery-projectile-thermonuclear"
	thermonuke_artillery_projectile.action = clowns_actions_thermonuke
	
	data:extend(
	{
		nuke_artillery_projectile,
		thermonuke_artillery_projectile,
	}
	)
end