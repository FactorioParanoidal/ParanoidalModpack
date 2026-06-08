
function create_a_loot_chest(surface,position)
local cname = "crash-site-chest-"..math.random(2)
position = surface.find_non_colliding_position(cname, position, 5, 2)
local chest
if position then 
	chest = surface.create_entity {name=cname, force=game.forces.neutral, position=position}
	end
return chest
end




function add_good_loot(chest,n)
local loot = {
	'efficiency-module-3',
	'quality-module-3',
	'speed-module-3',
	'productivity-module-3',
	'utility-science-pack',
	'space-science-pack',
	'power-armor-mk2',
	'battery-mk2-equipment',
	'fission-reactor-equipment',
	'fusion-reactor-equipment',
	'nuclear-reactor',
	'battery-mk3-equipment',
	'big-mining-drill',
	'foundry',
	'rocket-turret',
	'tesla-turret',
	}
if script.active_mods['RPGsystem'] then 
	local potions = remote.call("RPG", "get_potions_list")
	concat_lists(loot, potions)
	end
local r = math.random(#loot)
local randloot = loot[r]
while not prototypes.item[randloot] do 
	r = math.random(#loot)
	randloot = loot[r]
	end
local mp=1
if r<=6 then mp=5 end
local item = {name=randloot, count=math.random(n)*mp}
chest.insert(item)
end



function add_quality_loot(chest,n, max_level)
local sgroups = {"transport", "gun", "armor", "equipment", "military-equipment", "utility-equipment", "turret"}
local items = {}
for name, proto in pairs (prototypes.item) do
    if proto.group.name=="production" or in_list(sgroups,proto.subgroup.name) then
        if not (proto.hidden or string.find(name,"blueprint") or string.find(name,"planner") or string.find(name,"repair")  or string.find(name,"pipe") or string.find(name,"pistol") ) then 
            table.insert(items,name)
            end
        end
    end
local quality_names=get_quality_names(max_level)
for x=1,n do
    local quality, quality_name
    if #quality_names>0 then
		local rand_limit = math.random(#quality_names)
        quality = quality_names[math.random(rand_limit)]
        quality_name=quality.name
        end
    local item = {name=items[math.random(#items)], count=math.random(n), quality=quality_name}
    chest.insert(item) 
    end
end



-- add this to on chunk generated
function create_random_loot_on_chunk(event,dif,exclude_items)
local surface = event.surface
local area = event.area
local PosX = area.left_top.x + math.random(0,32)
local PosY = area.left_top.y + math.random(0,32)
local chest = create_a_loot_chest(surface,{x=PosX,y=PosY})
if chest then AddSomeRandomLoot(chest,dif,exclude_items) end
end



function create_random_loot_on_position(surface,position,dif,exclude_items)
local chest = create_a_loot_chest(surface,position)
if chest then AddSomeRandomLoot(chest,dif,exclude_items) end
end


function AddSomeRandomLoot(chest,dif,exclude_items)
if not dif then dif=0 end
local loot_1 = {"transport-belt","splitter","underground-belt","solid-fuel","copper-plate","iron-plate","steel-plate","iron-gear-wheel","electronic-circuit",
				"logistic-science-pack","logistic-science-pack","automation-science-pack","piercing-rounds-magazine"}
local loot_2 = {"fast-splitter","fast-underground-belt","accumulator","steel-furnace","electric-mining-drill","speed-module","efficiency-module","productivity-module","advanced-circuit","construction-robot","logistic-robot","electric-engine-unit","chemical-science-pack",
				"utility-science-pack","production-science-pack","processing-unit","substation","roboport","solar-panel","bulk-inserter","rocket-fuel","electric-furnace","gun-turret","light-oil-barrel","crude-oil-barrel","petroleum-gas-barrel"}
local loot_3 = {"rocket-launcher", "rocket","explosive-rocket", "cluster-grenade","cannon-shell","explosive-cannon-shell","artillery-turret","artillery-shell","flamethrower-turret","flamethrower-ammo","laser-turret","poison-capsule"}

if exclude_items then
	for e=1,#exclude_items do 
		del_list(loot_1, exclude_items[e])
		del_list(loot_2, exclude_items[e])
		del_list(loot_3, exclude_items[e])
		end 
	end

local loot_4 = {}
if script.active_mods['RPGsystem'] then loot_4 = remote.call("RPG", "get_potions_list")	end
for x=1,math.random(2) do chest.insert{name=loot_1[math.random(#loot_1)], count=math.random(20-dif,100-dif)} end
if math.random(2+dif)==1 then chest.insert{name=loot_2[math.random(#loot_2)], count=math.random(2,20-dif)} end
if math.random(3+dif)==1 then  chest.insert{name=loot_3[math.random(#loot_3)], count=math.random(4)} end

if #loot_4>0 then 
	for x=1,math.random(4) do
	if math.random(3+dif)==1 then chest.insert{name=loot_3[math.random(#loot_3)], count=1} end
	end end

add_quality_loot(chest,1)
end
