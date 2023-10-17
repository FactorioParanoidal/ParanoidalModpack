local util = require("warheads")

local warhead_sanitise = require("__Warheads__.prototypes.warhead-sanitise")
local weapontype_sanitise = require("__Warheads__.prototypes.weapontype-sanitise")
local combine = require("__Warheads__.prototypes.warhead-weapontype-combination")



for _,name in pairs(warheadWeaponNameMap) do
  if(data.raw.recipe[name]) then
    data.raw.recipe[name] = nil
  end
end

for name,warhead_dirty in pairs(warheads) do
  local warhead = warhead_sanitise(name, warhead_dirty)
  local used = false;
  for _,weapon_dirty in pairs(weaponTypes) do
    if(not weapon_dirty.ignore) then
      local weapontype = weapontype_sanitise(weapon_dirty)
      for _,warheadWeapon in pairs(warhead.weapons) do
        if((warhead.preciseSize <= weapontype.size.max and warhead.preciseSize > weapontype.size.min) or warheadWeaponDoAnyway[weapontype.name .. warheadWeapon.appendName]) then
          local combination = combine(table.deepcopy(weapontype), table.deepcopy(warheadWeapon))
          if(combination.valid) then
            --          combination.recipe.enabled = true
            if(not data.raw.recipe[combination.recipe.name]) then
              used = true
              local results = {combination.item, combination.recipe}
              if(combination.projectile) then
                table.insert(results, combination.projectile)
              end
              if(combination.landmine) then
                table.insert(results, combination.landmine)
              end
              data:extend(results)

              local tech = warhead_dirty.tech
              if weaponNoTech[weapontype.name] then
                tech = nil
              end
              if specialTechForWarheadWeapon[combination.rawName] ~= nil then
                tech = specialTechForWarheadWeapon[combination.rawName]
              end
              if tech and data.raw.technology[tech] then
                if not data.raw.technology[tech].effects then
                  data.raw.technology[tech].effects = {}
                end
                table.insert(data.raw.technology[tech].effects,
                  {
                    type = "unlock-recipe",
                    recipe = combination.recipe.name
                  })
              end
            end
          end
        end
      end
    end
  end
  if(used or generateWarheadAnyway[warhead.warhead.item.name]) then
    data:extend({warhead.warhead.item, warhead.warhead.recipe})
    if(warhead_dirty.tech and data.raw.technology[warhead_dirty.tech]) then
      table.insert(data.raw.technology[warhead_dirty.tech].effects, 1,
        {
          type = "unlock-recipe",
          recipe = warhead.warhead.recipe.name
        })
    end
  end
end
