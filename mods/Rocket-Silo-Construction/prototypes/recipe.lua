local ICONPATH = "__Rocket-Silo-Construction__/graphics/icon/"
local mp = settings.startup["rsc-st-cost-mp"].value
local original_cost_div = 4

-- integration with bobs / angels
function CheckItem(items)
	for k,it in pairs (items) do
		if data.raw.item[it] then return it end
		end
end

function AddIfExists(item,atable,amount)
if data.raw.item[item] then 
   table.insert(atable,{type="item", name=item, amount=amount}) end
end
function iif( cond, val1, val2 )
	if cond then return val1
	else return val2
	end
end



local drill 
if mods['SeaBlock'] then
	drill = 'thermal-extractor'
	else
	drill = CheckItem({'bob-area-mining-drill-3','electric-mining-drill'})
	end
local stone = CheckItem({'sand','solid-sand','stone'})



local res_stone1,res_stone2
if stone=='stone' then
	res_stone1 = {{type="item", name="rsc-building-stage1", amount=1,probability=0}, {type="item", name="stone", amount=50} }
	res_stone2 = {{type="item", name="rsc-building-stage3", amount=1,probability=0},
		  {type="item", name="stone", amount=50}, 
		  {type="item", name="coal", amount=5,probability=0.15},
		  {type="item", name="iron-ore", amount=5,probability=0.15},
		  {type="item", name="copper-ore", amount=5,probability=0.15}}
	else
	res_stone1 = {{type="item", name="rsc-building-stage1", amount=1,probability=0}, {type="item", name="stone", amount=20,probability=0.15}, 
					{type="item", name=stone, amount=100}}
	res_stone2 =  {{type="item", name="rsc-building-stage3", amount=1,probability=0}, {type="item", name="stone", amount=20,probability=0.10}, 
					{type="item", name=stone, amount=100}}
	end
	

local build_result2 = {{type="item", name="rsc-building-stage2", amount=1,probability=0}}
local build_result4 = {{type="item", name="rsc-building-stage4", amount=1,probability=0}}

	
if data.raw.item['stone-crushed'] then 
	table.insert(res_stone1,{type="item", name="stone-crushed", amount=10})
	table.insert(res_stone2,{type="item", name="stone-crushed", amount=15})
	end

if data.raw.item['slag'] then 
	table.insert(res_stone1,{type="item", name="slag", amount=40})
	table.insert(res_stone2,{type="item", name="slag", amount=60})
	table.insert(build_result2,{type="item", name="slag", amount=40, probability=0.25})
	table.insert(build_result4,{type="item", name="slag", amount=40, probability=0.25})
elseif data.raw.item['ei_slag'] then 
	table.insert(res_stone1,{type="item", name="ei_slag", amount=40})
	table.insert(res_stone2,{type="item", name="ei_slag", amount=60})
	table.insert(build_result2,{type="item", name="ei_slag", amount=40, probability=0.25})
	table.insert(build_result4,{type="item", name="ei_slag", amount=40, probability=0.25})
	else
	table.insert(build_result2,{type="item", name="stone", amount=40, probability=0.25})
	table.insert(build_result4,{type="item", name="stone", amount=40, probability=0.25})
	end 
	


AddIfExists('angels-ore1',res_stone2,2)
AddIfExists('angels-ore2',res_stone2,2)
AddIfExists('angels-ore3',res_stone2,2)
AddIfExists('angels-ore4',res_stone2,2)
AddIfExists('angels-ore5',res_stone2,2)
AddIfExists('angels-ore6',res_stone2,2)


local brick  = CheckItem({'concrete-brick','stone-brick'})
local brick2 = CheckItem({'reinforced-concrete-brick','stone-brick'})
local stick  = CheckItem({'ei_iron-beam','chromium-rod','titanium-plate','iron-stick'})
local stick2 = CheckItem({'ei_steel-mechanical-parts','chromium-piston',stick})
local steel  = CheckItem({'steel-beam','cobalt-steel-alloy','steel-plate'})
local fluid = "water"
if mods['IndustrialRevolution3'] then fluid = "concrete-fluid" end 

local ing_stage2 = 
		{
		  {type="item", name="concrete", amount=math.ceil(50*mp)},
		  {type="item", name=brick, amount=math.ceil(10*mp)},
		  {type="item", name=steel, amount=math.ceil(iif(steel=='steel-plate',20,5)*mp)},
		  {type="item", name=stick, amount=math.ceil(iif(stick=='iron-stick',30,5)*mp)},
		  {type="fluid", name=fluid, amount=math.ceil(500*mp)},
		}

local ing_stage4 = 
		{
		  {type="item", name="concrete", amount=math.ceil(50*mp)},
		  {type="item", name=brick, amount=math.ceil(10*mp)},
		  {type="item", name=steel, amount=math.ceil(iif(steel=='steel-plate',20,10)*mp)},
		  {type="item", name=stick2, amount=math.ceil(iif(stick=='iron-stick',30,15)*mp)},
		}

local pipe  = 'pipe'           --CheckItem('copper-tungsten-pipe','pipe')   --tungsten not compatible with SE
local pipe2 = 'pipe-to-ground' --CheckItem('copper-tungsten-pipe-to-ground','pipe-to-ground')
table.insert(ing_stage4,{type="item", name=pipe,  amount=math.ceil(20*mp)})
table.insert(ing_stage4,{type="item", name=pipe2, amount=math.ceil(10*mp)})

local copper = CheckItem({'ei_lead-plate','chromium-plate-heavy','angels-wire-coil-copper','copper-plate'}) --seok   algels smelting
local cable  = CheckItem({'ei_insulated-wire','copper-cable-heavy','gilded-copper-cable','copper-cable'}) --seok

local ing_stage5 = 
		{
		  {type="item", name=brick2, amount=math.ceil(10*mp)},
		  {type="item", name=cable, amount=math.ceil(100*mp)},
		  {type="item", name="electronic-circuit", amount=math.ceil(20*mp)},
		  {type="item", name=copper, amount=math.ceil(40*mp)},
		  {type="item", name=steel, amount=math.ceil(10*mp)},
		}
if mods["Warp-Drive-Machine"] then table.insert(ing_stage5, {type="item", name="warponium-plate", amount=math.ceil(10*mp)}) end 


local ing = table.deepcopy(data.raw.recipe['rocket-silo'].ingredients)
for i=1,#ing do 
	if ing[i].amount then 
		ing[i].amount = math.ceil(ing[i].amount/original_cost_div)
		end
	end
table.insert (ing, {type = "item", name = drill,amount=100})
	
data:extend({
	{
		type = "recipe",
		name = "rsc-excavation-site",
		icons = icons_rsc,
		order = "r-s",
		--hidden=true,
		enabled = false,   
		energy_required = 100,
		ingredients = ing,
		results={
		  {type="item", name="rsc-excavation-site", amount=1},
		},     
	},

	
	
	{
		type = "recipe",
		name = "rsc-construction-stage1",
		icon = ICONPATH .. "stage1.png",
		icon_size = 64, icon_mipmaps = 3,
		order = "rsc-stage1",
		category = "rsc-stage1",
		subgroup = "defensive-structure",
		enabled = true,   
		hidden = true,	
		hidden_from_flow_stats = true,
		hidden_from_player_crafting = true,
		always_show_made_in = false,
		energy_required = 1,
		ingredients = {},
		results=res_stone1,     
	},


	{
		type = "recipe",
		name = "rsc-construction-stage2",
		icon = ICONPATH .. "stage2.png",
		icon_size = 64, icon_mipmaps = 3,
		order = "rsc-stage2",
		category = "rsc-stage2",
		subgroup = "fluid-recipes",
		enabled = true,   
		main_product= "",
		hidden = true,	
		hidden_from_flow_stats = true,
		hidden_from_player_crafting = true,
		always_show_made_in = false,		
		energy_required = 5,
		ingredients = ing_stage2,
		results=build_result2,
	},
	
	{
		type = "recipe",
		name = "rsc-construction-stage3",
		icon = ICONPATH .. "stage3.png",
		icon_size = 64, icon_mipmaps = 3,
		order = "rsc-stage3",
		category = "rsc-stage3",
		subgroup = "defensive-structure",
		enabled = true,  
		hidden = true,	
		hidden_from_flow_stats = true,
		hidden_from_player_crafting = true,
		always_show_made_in = false,		
		energy_required = 1,
		ingredients = {},
		results=res_stone2,    
	},

 
	{
		type = "recipe",
		name = "rsc-construction-stage4",
		icon = ICONPATH .. "stage4.png",
		icon_size = 64, icon_mipmaps = 3,
		order = "rsc-stage4",
		category = "rsc-stage4",
		subgroup = "defensive-structure",
		enabled = true,  
		hidden = true,	
		hidden_from_flow_stats = true,
		hidden_from_player_crafting = true,
		always_show_made_in = false,
		energy_required = 5,
		ingredients = ing_stage4,
		results=build_result4,
    
	},


	{
		type = "recipe",
		name = "rsc-construction-stage5",
		icon = ICONPATH .. "stage5.png",
		icon_size = 64, icon_mipmaps = 3,
		order = "rsc-stage5",
		category = "rsc-stage5",
		subgroup = "defensive-structure",
		enabled = true,  
		hidden = true,	
		hidden_from_flow_stats = true,
		hidden_from_player_crafting = true,
		always_show_made_in = false,	
		energy_required = 5,
		ingredients = ing_stage5,
		results=
		{
		  {type="item", name="rsc-building-stage5", amount=1,probability=0},
		},     
	},
	
	
	
	{
		type = "recipe",
		name = "rsc-construction-stage6",
		icon = ICONPATH .. "stage6.png",
		icon_size = 64, icon_mipmaps = 3,
		order = "rsc-stage6",
		category = "rsc-stage6",
		subgroup = "defensive-structure",
		enabled = true,  
		hidden = true,	
		hidden_from_flow_stats = true,
		hidden_from_player_crafting = true,
		always_show_made_in = false,	
		energy_required = 5,
		ingredients =
		{
		  {type="item", name="refined-concrete", amount=10*mp},
		  {type="item", name="electric-engine-unit", amount=5*mp},
		  {type="item", name=CheckItem({"computer-mk3","processing-unit"}), amount=math.ceil(5*mp)},
		  {type="item", name=CheckItem({"computer-mk2","advanced-circuit"}), amount=math.ceil(10*mp)},
		  {type="item", name=CheckItem({"computer-mk1","electronic-circuit"}), amount=math.ceil(30*mp)},
		  {type="item", name="radar", amount=math.ceil(2*mp)},
		},
		results=
		{
		  {type="item", name="rsc-building-stage6", amount=1,probability=0},
		},     
	},
	
 
  }
)

if mods['IndustrialRevolution3'] then 
	table.insert (data.raw.recipe["rsc-construction-stage5"].ingredients,{type="item", name="gold-cable", amount=math.ceil(20*mp)})
	--table.insert (data.raw.recipe["rsc-construction-stage6"].ingredients,{"chromium-window", 20*mp})
	end 



if data.raw.item['advanced-processing-unit'] then --bobs
	table.insert (data.raw.recipe["rsc-construction-stage6"].ingredients,{type="item", name="advanced-processing-unit", amount=math.ceil(5*mp)})
	table.insert (data.raw.recipe["rsc-excavation-site"].ingredients,{type="item", name="advanced-processing-unit", amount=math.ceil(10*mp)})
	end
		  
if data.raw.item['se-rocket-launch-pad'] then
local enable_se_cargo = settings.startup["rsc-st-enable-se-cargo-silo"].value 
local enable_se_probe = settings.startup["rsc-st-enable-se-probe-silo"].value 

if enable_se_cargo then 
	local ing = table.deepcopy(data.raw.recipe['se-rocket-launch-pad'].ingredients)
	for i=1,#ing do 
		if ing[i].amount then 
			ing[i].amount = math.ceil(ing[i].amount/original_cost_div)
			end
		end
	table.insert (ing, {type="item", name=drill,amount=100})
	data:extend({
		{
			type = "recipe",
			name = "rsc-serlp-excavation-site",
			icons = icons_se_crs,
			order = "e-g",
			enabled = false,   
			energy_required = 100,
			ingredients = ing,
			results=
			{
			  {type="item", name="rsc-excavation-site-serlp", amount=1},
			},     
		},
	})
	end
	
if enable_se_probe then 
	local ing = table.deepcopy(data.raw.recipe['se-space-probe-rocket-silo'].ingredients)
	for i=1,#ing do 
		if ing[i].amount then 
			ing[i].amount = math.ceil(ing[i].amount/original_cost_div)
			end
		end	
		data:extend({
	{
		type = "recipe",
		name = "rsc-sesprs-excavation-site",
		icons = icons_se_sp,
		order = "e-g",
		enabled = false,   
		energy_required = data.raw.recipe['se-space-probe-rocket-silo'].energy_required,
		ingredients = ing,
		results=
		{
		  {type="item", name="rsc-excavation-site-sesprs", amount=1},
		},     
	},	
	
	-- stage 6 of sesprs
	--[[      { "electric-engine-unit", 200 },
      { "processing-unit", 200 },
      { data_util.mod_prefix .. "heat-shielding", 200 },
      { data_util.mod_prefix .. "holmium-cable", 200 },
      { data_util.mod_prefix .. "heavy-girder", 100 },
      { data_util.mod_prefix .. "aeroframe-scaffold", 100 },]]
	  
	{
		type = "recipe",
		name = "rsc-construction-stage6-sesprs",
		icon = ICONPATH .. "stage6.png",
		icon_size = 64,
		order = "rsc-stage6",
		category = "rsc-stage6",
		subgroup = "defensive-structure",
		enabled = true,  
		hidden = true,	
		hidden_from_flow_stats = true,
		hidden_from_player_crafting = true,
		always_show_made_in = false,	
		energy_required = 5,
		ingredients =
		{
		  {type="item", name="processing-unit", amount=math.ceil(10*mp)},
		  {type="item", name="electric-engine-unit", amount=math.ceil(10*mp)},
		  {type="item", name="se-heat-shielding", amount=math.ceil(10*mp)},
		  {type="item", name="se-holmium-cable", amount=math.ceil(10*mp)},
		  {type="item", name="se-heavy-girder", amount=math.ceil(5*mp)},
		  {type="item", name="se-aeroframe-scaffold", amount=math.ceil(5*mp)},
		  
		},
		results=
		{
		  {type="item", name="rsc-building-stage2", amount=1,probability=0},
		},     
	},
	
	
	{
		type = "recipe",
		name = "rsc-construction-stage5-sesprs",
		icon = ICONPATH .. "stage5.png",
		icon_size = 64,
		order = "rsc-stage5",
		category = "rsc-stage5",
		subgroup = "defensive-structure",
		enabled = true,  
		hidden = true,	
		hidden_from_flow_stats = true,
		hidden_from_player_crafting = true,
		always_show_made_in = false,
		energy_required = 5,
		ingredients = 		{
		  {type="item", name="electronic-circuit", amount=math.ceil(20*mp)},
		  {type="item", name="se-holmium-cable", amount=math.ceil(10*mp)},
		  {type="item", name="se-heat-shielding", amount=math.ceil(10*mp)},
		  {type="item", name="se-heavy-girder", amount=math.ceil(5*mp)},
		  {type="item", name="se-aeroframe-pole", amount=math.ceil(10*mp)},
		  
		},
		results=
		{
		  {type="item", name="rsc-building-stage2", amount=1,probability=0},
		},     
	},
	})
	end
end


