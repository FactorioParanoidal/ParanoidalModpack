local function add(collection, list)
  for name, value in pairs(list) do
    collection[name] = (collection[name] or 0) + value
  end 
end
script.on_init(function()
  if remote.interfaces["freeplay"] then
    local created_items = remote.call("freeplay", "get_created_items")
    local ship_items    = remote.call("freeplay", "get_ship_items")
    local debris_items  = remote.call("freeplay", "get_debris_items")
    add(created_items, { 
        ["iron-plate"] = 200,
		["iron-gear-wheel"] =158,

		["inserter"]=50,
		["long-handed-inserter"]=25,
		["fast-inserter"] =25,
		--player.insert{name="filter-inserter", count=25}
		
		["basic-transport-belt"]=200,
		--player.insert{name="transport-belt", count=200}
		["medium-electric-pole"]=25,
		["big-electric-pole"]=10,
		--player.insert{name="electric-mining-drill", count=3}
		["stone-furnace"] =1,
		["assembling-machine-2"]=1,
		["pipe"]=50,
		["steel-chest"]=5,
		["wooden-chest"]=5,
		["iron-chest"] =5,
		--player.insert{name="steam-engine", count=20}
		--player.insert{name="boiler", count=10}
		--player.insert{name="offshore-pump", count=1}
		["burner-offshore-pump"]=1,
		["pipe-to-ground"]=10,
		--player.insert{name="lab", count=6}
		["basic-splitter"]=10,
		["basic-underground-belt"]=20,
		--player.insert{name="coal", count=200}
		
  --player.insert{name="iron-plate", count=8}
  --player.insert{name="pistol", count=1} --already 1
  ["firearm-magazine"]=10,
  ["burner-mining-drill"] = 1,
  --player.insert{name="burner-ore-crusher", count = 1} --inserts 1 by angelsrefining/control.lua
  --player.insert{name="stone-furnace", count = 1}

  --player.insert{name="pipe-to-ground", count = 50}
--player.insert{name="steam-engine", count = 1}
--player.insert{name="boiler", count = 1}
  --player.insert{name="small-electric-pole", count = 30}
  
  ["slag"]=14,
  ["stone-crushed"]=22,
  ["stone"] =18,
  ["wood"] =9,
  ["battery"]=7,
  ["silver-zinc-battery"]=1,
  --player.insert{name="unused-air-filter", count=10}
  ["nuclear-fuel"]=1,
  ["intelligent-io"]=1,
  ["intergrated-electronics"]=2,
  ["aluminium-plate"]=16,
  ["titanium-plate"]=1,
  ["repair-pack"]=5,
  --player.insert{name="angels-wire-platinum", count=5}
  
  ["radar"]= 1
        } )
----------------------------------
    add(ship_items, {
            ["copper-plate"] = 187,
            ["stone"] = 30
        })
------------------------------------
    add(debris_items, {    
            ["copper-plate"] = 10
         })
    --local items_to_insert = remote.call("freeplay", "get_created_items")
    --items_to_insert["burner-ore-crusher"] = (items_to_insert["burner-ore-crusher"] or 0) + 1
    remote.call("freeplay", "set_created_items", created_items)
    remote.call("freeplay", "set_ship_items", ship_items)
    remote.call("freeplay", "set_debris_items", debris_items)
  end
end)
