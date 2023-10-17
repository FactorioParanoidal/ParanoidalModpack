local TPlib = require("lib.TPlib")
local TPcp = require("lib.TPcp")


local function counts_add(t, k, amtadd, processzero)
  if processzero or amtadd > 0 then
    t[k] = (t[k] or 0) + amtadd
  end
end



local function check_tank_recipe(e)
  if e.setting == "tankplatoon-tank-to-recipe-force-enable" then
    local setvalue = settings.global[e.setting].value or settings.startup["tankplatoon-tank-to-recipe-keep"].value
    for index, force in pairs(game.forces) do
      local recipe = force.recipes["tank"]
      if not recipe or not recipe.valid then return end
      local tech_tank = force.technologies["tank"]
      if setvalue then
        -- table.insert(tech_tank.effects, 1, {type="unlock-recipe", recipe="tank"})
        recipe.enabled = force.technologies["tank"].researched
      else
        -- for i, v in pairs(tech_tank.effects) do
        --   if (v.recipe=="tank") then table.remove(tech_tank.effects, i) end
        -- end
        recipe.enabled = false
      end
    end
  end
end


local function pre_craft_unload_equipment(e)
  local player = game.players[e.player_index]
  -- local recipe = e.recipe
  local items = e.items
  local surface = player.surface
	-- TPlib.debugprint(" # Items : " .. #e.items )
	-- TPlib.debugprint("Product : " .. recipe.name)
  local position = player.position
  local itemproto = game.item_prototypes
  local item_cnt = {}
  local count = 0
  for i = 1, #items do
  	-- TPlib.debugprint(items[i].name .. " ×" .. items[i].count)
    local grid = items[i].grid
  	if grid and grid.valid then
  		-- TPlib.debugprint("=== has Grid ===")
  		for _, v in pairs(grid.equipment) do
        if v.valid then
          local returnname = v.prototype.take_result.name
    			-- TPlib.debugprint(v.name)
    			if player.insert{name = returnname} == 0 then
    				surface.spill_item_stack( position, {name = returnname}, true )
    			end
          grid.take{equipment = v}
          count = count + 1
          counts_add(item_cnt, returnname, 1)
        end
  		end
  	end
  end
  position.y = position.y - 0.5
  for k, v in pairs(item_cnt) do
    TPlib.create_flying_text_item(surface, position, itemproto[k], v, player)
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

local function built_entity(e)
  local player = game.players[e.player_index]
  if not player.mod_settings["tankplatoon-vehicle-clone-placement-built-enable"].value then return end
  local source = player.vehicle
  local target = e.created_entity
  if not source then return end
  if source.name ~= target.name then return end
  TPcp.vehicle_clone_placement(source, target, player)
end

local function entity_settings_pasted(e)
  local player = game.players[e.player_index]
  if not player.mod_settings["tankplatoon-vehicle-clone-placement-pasted-enable"].value then return end
  local source = e.source
  local target = e.destination
  TPcp.vehicle_clone_placement(source, target, player)
end


script.on_event(defines.events.on_runtime_mod_setting_changed,      runtime_mod_setting_changed)
script.on_event(defines.events.on_pre_player_crafted_item,          pre_player_crafted_item)
script.on_event(defines.events.on_built_entity,                     built_entity)
script.on_event(defines.events.on_entity_settings_pasted,           entity_settings_pasted)
