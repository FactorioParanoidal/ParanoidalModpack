weaponTypes["se-delivery-cannon-weapon"]= {
  type = "none",
  max_size = "huge",
  min_size = "tiny",
  ignore = not settings.startup["enable-delivery-cannon-weapon"].value,
  baseName = "se-delivery-cannon-weapon-pack-",
  baseOrder = "d[cannon-shell]-d[atomic]-1",
  base_item = "se-delivery-cannon-weapon-capsule",
  
  override = function (weapontype, warheadWeapon)
    local ingredients = {{name = "se-delivery-cannon-weapon-capsule", amount = 1}}

    if(warheadWeapon.recipe.build_up_ingredient) then
      log("Complicated: built up explosion flattened for SE-delivery cannon...")
      for _, ing in pairs(data.raw.recipe["se-delivery-cannon-weapon-pack-" .. "warhead-util-projectile" .. warheadWeapon.recipe.build_up_ingredient.name].ingredients) do
        if ing.name ~= "se-delivery-cannon-weapon-capsule" and ing[1] ~= "se-delivery-cannon-weapon-capsule" then
          table.insert(ingredients, {name = ing.name or ing[1], amount = (ing.amount or ing[2])*warheadWeapon.recipe.build_up_ingredient.amount})
        end
      end
    else
      table.insert(ingredients, {name = warheadWeapon.recipe.warhead_name, amount = 1})
    end
    for _,i in pairs(warheadWeapon.recipe.additional_ingedients) do
      table.insert(ingredients, i)
    end
    local results = {}
    results = {{type="item", name="se-delivery-cannon-weapon-package-".."warhead-util-projectile"..warheadWeapon.appendName, amount = 1}}
    for _,r in pairs(warheadWeapon.recipe.additional_results) do
      table.insert(results, r)
    end
    local artillery_icons = table.deepcopy(warheadWeapon.appearance.icons);
    table.insert(artillery_icons, 1, {
          icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-artillery-targeter.png",
          icon_size = 64
        })
    data:extend{
      {
        -- capsule w/ capsule_action="equipment-remote" gives us the activate hotkey tooltip w/o it actually having to do anything outside of our script
        type = "capsule",
        name = "se-delivery-cannon-artillery-targeter-".."warhead-util-projectile"..warheadWeapon.appendName,
        icons = artillery_icons,
        capsule_action =
        {
          type = "equipment-remote",
          equipment = "dummy-defense-equipment"
        },
        -- order and subgroup match the vanilla artillery targeting remote such that all the artillery targeting remotes stay organized together
        order = "b[turret]-d[artillery-turret]-b[remote]-wh"..warheadWeapon.appendOrder,
        subgroup = "defensive-structure",
        stack_size = 1,
        localised_name = {"item-name.se-delivery-cannon-artillery-targeter", {"warhead-name." .. warheadWeapon.appendName}},
        localised_description = {"item-description.se-delivery-cannon-artillery-targeter", {"warhead-description." .. warheadWeapon.appendName}},
        flags = {}
      },
      {
        -- this dummy artillery flare will not take any shots from the artillery because its shots_per_flare is 0
        -- its life_time has been set to 0 and has the early_death_ticks replaced with the lifetime since because of
        -- the 0 shots_per_flare the flare is immediately considered in need of being dead upon spawning
        -- if the dummy artillery flare needs to be removed before its early_death_ticks worth of lifetime expires, it
        -- must be manually destroyed by script
        type = "artillery-flare",
        name = "se-dummy-artillery-flare-".."warhead-util-projectile"..warheadWeapon.appendName,
        icon = "__base__/graphics/icons/artillery-targeting-remote.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-off-grid", "not-on-map"},
        map_color = warheadWeapon.chart_tint or {r=1, g=0.5, b=0},
        life_time = 0 * 60,
        initial_height = 0,
        initial_vertical_speed = 0,
        initial_frame_speed = 1,
        shots_per_flare = 0,
         -- + 60 seconds to the value in the settings so the flare always lasts long enough to either be fired upon or be expired by script
        early_death_ticks = 60 * (settings.startup["se-delivery-cannon-artillery-timeout"].value + 60),
        pictures =
        {
          {
            filename = "__core__/graphics/shoot-cursor-red.png",
            priority = "low",
            width = 258,
            height = 183,
            frame_count = 1,
            scale = 1,
            flags = {"icon"}
          }
        }
      },
      {
        type = "recipe",
        name = "se-delivery-cannon-artillery-targeter-"..warheadWeapon.appendName,
        result = "se-delivery-cannon-artillery-targeter-".."warhead-util-projectile"..warheadWeapon.appendName,
        enabled = false,
        energy_required = 0.5,
        ingredients = {
          { "processing-unit", 1 },
          { "radar", 1 },
        },
        requester_paste_multiplier = 1,
        always_show_made_in = false,
      }
    }
    local tech = warheadWeapon.tech
    if weaponNoTech[weapontype.name] then
      tech = nil
    end
    if specialTechForWarheadWeapon[weapontype.name .. warheadWeapon.appendName] ~= nil then
      tech = specialTechForWarheadWeapon[weapontype.name .. warheadWeapon.appendName]
    end
    if tech and data.raw.technology[tech] then
      if not data.raw.technology[tech].effects then
        data.raw.technology[tech].effects = {}
      end
      table.insert(data.raw.technology[tech].effects,
        {
          type = "unlock-recipe",
          recipe = "se-delivery-cannon-artillery-targeter-"..warheadWeapon.appendName
        })
    end

    return {
      valid = true,
      item = {
        type = "item",
        name = "se-delivery-cannon-weapon-package-" .. "warhead-util-projectile"..warheadWeapon.appendName,
        icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-weapon-capsule.png",
        icon_size = 64,
        order = "" .. warheadWeapon.appendOrder,
        flags = {"hidden"},
        subgroup = "delivery-cannon-capsules",
        stack_size = 1,
        localised_name = {"weapontype-name.weapon-delivery-capsule", {"warhead-name." .. warheadWeapon.appendName}},
        localised_description= {"weapontype-description.weapon-delivery-capsule", {"warhead-description." .. warheadWeapon.appendName}}
      },
      recipe = {
        type = "recipe",
        name = "se-delivery-cannon-weapon-pack-" .. "warhead-util-projectile" .. warheadWeapon.appendName,
        icons = warheadWeapon.appearance.icons,
        results = results,
        enabled = false,
        energy_required = 10,
        ingredients = ingredients,
        requester_paste_multiplier = 1,
        always_show_made_in = false,
        category = "delivery-cannon-weapon",
        hide_from_player_crafting = true,
        localised_name = {"weapontype-name.weapon-delivery-capsule", {"warhead-name." .. warheadWeapon.appendName}},
        localised_description= {"weapontype-description.weapon-delivery-capsule", {"warhead-description." .. warheadWeapon.appendName}},
        allow_decomposition = false
      }
    }
  end
}
 
