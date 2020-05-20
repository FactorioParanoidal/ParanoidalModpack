local function check_tank_recipe(e)
  if e.setting == "tankplatoon-tank-to-recipe-force-enable" then
    local setvalue = settings.global[e.setting].value or settings.startup["tankplatoon-tank-to-recipe-keep"].value
    for index, force in pairs(game.forces) do
      local tech_tank = force.technologies["tanks"]
      if setvalue then
        -- table.insert(tech_tank.effects, 1, {type="unlock-recipe", recipe="tank"})
        force.recipes["tank"].enabled = force.technologies["tanks"].researched
      else
        -- for i, v in pairs(tech_tank.effects) do
        --   if (v.recipe=="tank") then table.remove(tech_tank.effects, i) end
        -- end
        force.recipes["tank"].enabled = false
      end
    end
  end
end


local function pre_craft_unload_equipment(e)
  local player = game.players[e.player_index]
  -- local recipe = e.recipe
  local items = e.items
  local surface = player.surface
	-- player.print(" # Items : " .. #e.items )
	-- player.print("Product : " .. recipe.name)
  local position = player.position
  local itemproto = game.item_prototypes
  local item_cnt = {}
  local count = 0
  for i = 1,#items do
  	-- player.print(items[i].name .. " ×" .. items[i].count)
  	if items[i].grid then
  		-- player.print("=== has Grid ===")
  		for _,v in pairs(items[i].grid.equipment) do
        local returnname = v.prototype.take_result.name
  			-- player.print(v.name)
  			if player.insert{ name=returnname } == 0 then
  				surface.spill_item_stack(position,{name = returnname},true)
  			end
  			items[i].grid.take(v)
        count = count + 1
        item_cnt[returnname] = (item_cnt[returnname] or 0) + 1
  		end
  	end
  end
  position.y = position.y - 0.5
  for k,v in pairs(item_cnt) do
    surface.create_entity{name = "flying-text", position = position, text = {"description.Schall-flying-text-item",itemproto[k].localised_name,"+",v,player.get_item_count(itemproto[k].name)}}
    position.y = position.y - 0.5
  end
  if count > 0 then player.print({"description.precraft-take-equipment-msg", count}) end
end


local function runtime_mod_setting_changed(e)
  check_tank_recipe(e)
end

local function pre_player_crafted_item(e)
	pre_craft_unload_equipment(e)
end


script.on_event(defines.events.on_runtime_mod_setting_changed,      runtime_mod_setting_changed)
script.on_event(defines.events.on_pre_player_crafted_item,          pre_player_crafted_item)