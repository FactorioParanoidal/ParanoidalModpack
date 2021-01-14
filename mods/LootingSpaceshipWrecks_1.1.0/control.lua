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
  
  ["firearm-magazine"] = 8,
  ["silver-zinc-battery"] = 4,
  ["repair-pack"] = 5,
  ["intelligent-io"] = 1
  --player.insert["angels-wire-platinum", count=5}
        } )
----------------------------------
    add(ship_items, {
        ["salvaged-assembling-machine"] = 2,
        ["salvaged-lab"] = 1,
		
		["copper-plate"] = 100,
        ["inserter"] = 50,
        ["long-handed-inserter"] = 25,
        ["fast-inserter"] = 25,
        ["basic-transport-belt"] = 100,
        ["medium-electric-pole"] = 25,
        ["big-electric-pole"] = 5,
        ["steel-chest"] = 1,
        --["iron-chest"] = 2,
        ["assembling-machine-2"] = 1,
        ["burner-offshore-pump"] = 1,
        ["pipe-to-ground"] = 10,
        ["basic-splitter"] = 10,
        ["basic-underground-belt"] = 10,
        ["slag"] = 28,
        ["stone-crushed"] = 31,
        ["stone"] = 16,
        ["wood"] = 10,
        ["battery"] = 10,
        ["nuclear-fuel"] = 1,
        ["intergrated-electronics"] = 16,
        ["radar"] = 1,
        ["burner-mining-drill"] = 1
        --["salvaged-generator",  1
        })
----------------------------------
    add(debris_items,
		{    
            ["copper-plate"] = 20,
			["iron-plate"] = 25
        })
    remote.call("freeplay", "set_created_items", created_items)
    remote.call("freeplay", "set_ship_items", ship_items)
    remote.call("freeplay", "set_debris_items", debris_items)
  end
end)