local rro = Muluna.rro
local buggy = table.deepcopy(data.raw["car"]["car"])
local buggy_scale = 1.25
local gun_scale = 1/2

buggy.name = "muluna-rocket-buggy"
buggy.max_health = 750
buggy.minable.result = "muluna-rocket-buggy"
buggy.weight = buggy.weight * buggy_scale^2
buggy.consumption = "500kW"
buggy.braking_force = (750 * 1000) / 60
buggy.rotation_speed = buggy.rotation_speed * 0.9

buggy.icons = {
    {
        icon = data.raw["item-with-entity-data"]["car"].icon,
        icon_size = data.raw["item-with-entity-data"]["car"].icon_size
    },
    {
        icon = data.raw["item"]["rocket-turret"].icon,
        icon_size=data.raw["item"]["rocket-turret"].icon_size,
        --scale=0.3,
        shift = {-2,-12},
        scale=0.2,
    },
}
if mods["Krastorio2"] then
    buggy.energy_source.fuel_categories={"kr-vehicle-fuel"}
end

buggy.trash_inventory_size = data.raw["car"]["tank"].trash_inventory_size
buggy.equipment_grid = data.raw["car"]["tank"].equipment_grid
buggy.allow_remote_driving = true
buggy.collision_box = {{-0.7*buggy_scale, -1*buggy_scale}, {0.7*buggy_scale, 1*buggy_scale}}
buggy.selection_box = {{-0.7*buggy_scale, -1*buggy_scale}, {0.7*buggy_scale, 1*buggy_scale}}
buggy.resistances =
    {
      {
        type = "fire",
        percent = 60
      },
      {
        type = "impact",
        percent = 40,
        decrease = 75
      },
      {
        type = "acid",
        percent = 30,
        decrease = 10
      }
    }
buggy.friction_force = 2.5e-3
buggy.turret_animation = table.deepcopy(data.raw["ammo-turret"]["rocket-turret"].attacking_animation)

for i,layer in ipairs(buggy.turret_animation.layers) do
    if rro.contains(layer.flags,"mask") then
        --layer.apply_runtime_tint = false
        rro.remove(buggy.turret_animation.layers,layer)
        break
    end
    layer.scale = layer.scale * gun_scale
    layer.shift = util.by_pixel( 0, -32)
end

for i,layer in ipairs(buggy.animation.layers) do
    layer.scale = (layer.scale or 1) * buggy_scale
end
--buggy.minimap_representation.scale = (buggy.minimap_representation.scale or 1) * buggy_scale
for i,layer in ipairs(buggy.animation.layers) do
    layer.scale = (layer.scale or 1) * buggy_scale
end



local buggy_gun = table.deepcopy(data.raw["gun"]["spidertron-rocket-launcher-1"])

buggy_gun.name = "muluna-rocket-buggy-rocket-launcher"
buggy_gun.localised_name = nil

table.insert(buggy.guns, buggy_gun.name)
Muluna:extend{buggy,buggy_gun}