weaponTypes["se-delivery-cannon-weapon"]= {
  type = "none",
  max_size = "huge",
  min_size = "tiny",
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
    results = {{type="item", name="se-delivery-cannon-weapon-package-"..warheadWeapon.appendName, amount = 1}}
    for _,r in pairs(warheadWeapon.recipe.additional_results) do
      table.insert(results, r)
    end


    return {
      valid = true,
      item = {
        type = "item",
        name = "se-delivery-cannon-weapon-package-" .. warheadWeapon.appendName,
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
 