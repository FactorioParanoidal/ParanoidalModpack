local function add(collection, list)
  for name, value in pairs(list) do
    collection[name] = (collection[name] or 0) + value
  end 
end
script.on_init(function()
  if remote.interfaces["freeplay"] and settings.global["lootingspaceshipwrecks-bonus-start-items"].value then
    local created_items = remote.call("freeplay", "get_created_items")
    local ship_items    = remote.call("freeplay", "get_ship_items")
    local debris_items  = remote.call("freeplay", "get_debris_items")
    add(created_items, { 
        --["iron-plate"] = 200,
		--["iron-gear-wheel"] =158,
		--player.insert{name="filter-inserter", count=25}
		--player.insert{name="transport-belt", count=200}
		--player.insert{name="electric-mining-drill", count=3}
		--["stone-furnace"] =1,
		--player.insert{name="steam-engine", count=20}
		--player.insert{name="boiler", count=10}
		--player.insert{name="offshore-pump", count=1}
		--player.insert{name="lab", count=6}
		--player.insert{name="coal", count=200}
  --player.insert{name="iron-plate", count=8}
  --player.insert{name="pistol", count=1} --already 1
  --player.insert{name="burner-ore-crusher", count = 1} --inserts 1 by angelsrefining/control.lua
  --player.insert{name="stone-furnace", count = 1}
  --player.insert{name="pipe-to-ground", count = 50}
--player.insert{name="steam-engine", count = 1}
--player.insert{name="boiler", count = 1}
  --player.insert{name="small-electric-pole", count = 30}
  --player.insert{name="unused-air-filter", count=10}
  ["firearm-magazine"] = {type = "random", min = 5, max = 20},
  ["silver-zinc-battery"] = {type = "random", min = 1, max = 10},
  ["repair-pack"] = {type = "random", min = 2, max = 10}
  ["intelligent-io"] = 1,
  --player.insert{name="angels-wire-platinum", count=5}
        } )
----------------------------------
    add(ship_items, {
        ["salvaged-assembling-machine"] = {type = "random", min = 2, max = 4},
        ["salvaged-lab"] = {type = "random", min = 1, max = 2},
		
		["copper-plate"] = {type = "random", min = 50, max = 200},
        ["inserter"] = {type = "random", min = 15, max = 35},
        ["long-handed-inserter"] = {type = "random", min = 15, max = 35},
        ["fast-inserter"] = {type = "random", min = 15, max = 35},
        ["basic-transport-belt"] = {type = "random", min = 50, max = 150},
        ["medium-electric-pole"] = {type = "random", min = 15, max = 35},
        ["big-electric-pole"] = {type = "random", min = 2, max = 10},
        ["steel-chest"] = {type = "random", min = 1, max = 3},
        ["iron-chest"] = {type = "random", min = 1, max = 4},
        ["assembling-machine-2"] = {type = "random", min = 1, max = 3},
        ["burner-offshore-pump"] = {type = "random", min = 1, max = 3},
        ["pipe-to-ground"] = {type = "random", min = 5, max = 15},
        ["basic-splitter"] = {type = "random", min = 5, max = 15},
        ["basic-underground-belt"] = {type = "random", min = 5, max = 40},
        ["slag"] = {type = "random", min = 5, max = 60},
        ["stone-crushed"] = {type = "random", min = 5, max = 60},
        ["stone"] = {type = "random", min = 5, max = 60},
        ["wood"] = {type = "random", min = 5, max = 15},
        ["battery"] = {type = "random", min = 5, max = 15},
        ["nuclear-fuel"] = {type = "random", min = 1, max = 3},
        ["intergrated-electronics"] = {type = "random", min = 1, max = 4},
        ["radar"] = {type = "random", min = 1, max = 3},
        ["burner-mining-drill"] = {type = "random", min = 1, max = 3}
        --["salvaged-generator"] = 1
        })
----------------------------------
    add(debris_items, {    
            ["copper-plate"] = {type = "random", min = 1, max = 25},
			["iron-plate"] = {type = "random", min = 1, max = 25}
			
         })
    remote.call("freeplay", "set_created_items", created_items)
    remote.call("freeplay", "set_ship_items", ship_items)
    remote.call("freeplay", "set_debris_items", debris_items)
  end
end)