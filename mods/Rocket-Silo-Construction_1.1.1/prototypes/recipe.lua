local ICONPATH = "__Rocket-Silo-Construction__/graphics/icon/"

require 'utils'

local mp = settings.startup["rsc-st-cost-mp"].value
local original_cost_div = 4

-- integration with bobs / angels
function CheckItem(item1,item2)
return ifthen(data.raw.item[item1],item1,item2)
end

function AddIfExists(item,atable,amount)
if data.raw.item[item] then 
   table.insert(atable,{type="item", name=item, amount=amount}) end
end


local drill = CheckItem('bob-area-mining-drill-3','electric-mining-drill')
local stone = CheckItem('solid-sand','stone')
stone = CheckItem('sand',stone)



local res_stone1,res_stone2
if stone=='stone' then
	res_stone1 = { {type="item", name="stone", amount=100} }
	res_stone2 = {
		  {type="item", name="stone", amount=100}, 
		  {type="item", name="coal", amount=5,probability=0.15},
		  {type="item", name="iron-ore", amount=5,probability=0.15},
		  {type="item", name="copper-ore", amount=5,probability=0.15}}
	else
	res_stone1 = { {type="item", name="stone", amount=20,probability=0.15}, 
					{type="item", name=stone, amount=100}}
	res_stone2 =  { {type="item", name="stone", amount=20,probability=0.10}, 
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


local brick  = CheckItem('concrete-brick','stone-brick')
local brick2 = CheckItem('reinforced-concrete-brick','stone-brick')
local stick  = CheckItem('titanium-plate','iron-stick')
local steel  = CheckItem('cobalt-steel-alloy','steel-plate')

local ing_stage2 = 
		{
		  {"refined-concrete", 50*mp},
		  {brick, 10*mp},
		  {steel, ifthen(steel=='steel-plate',20,5)*mp},
		  {stick, ifthen(stick=='iron-stick',30,5)*mp},
		}

local ing_stage4 = table.deepcopy(ing_stage2)
local pipe  = 'pipe'           --CheckItem('copper-tungsten-pipe','pipe')   --tungsten not compatible with SE
local pipe2 = 'pipe-to-ground' --CheckItem('copper-tungsten-pipe-to-ground','pipe-to-ground')
table.insert(ing_stage4,{pipe,  20*mp})
table.insert(ing_stage4,{pipe2, 10*mp})

local copper = CheckItem('angels-wire-coil-copper','copper-plate') --seok   algels smelting
local cable  = CheckItem('gilded-copper-cable','copper-cable') --seok

local ing_stage5 = 
		{
		  {brick2, 10*mp},
		  {cable, 100*mp},
		  {"green-wire", 20*mp},
		  {"red-wire", 20*mp},
		  {copper, 40*mp},
		  {steel, 10*mp},
		}
		  		  

local ing = table.deepcopy(data.raw.recipe['rocket-silo'].ingredients)
for i=1,#ing do 
	if ing[i].amount then 
		ing[i].amount = math.ceil(ing[i].amount/original_cost_div)
		else
		ing[i][2] = math.ceil(ing[i][2]/original_cost_div)
		end
	end
table.insert (ing, {drill,100})	
	
data:extend({
	{
		type = "recipe",
		name = "rsc-excavation-site",
		icons = icons_rsc,
		order = "r-s",
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
		subgroup = "defensive-structure",
		enabled = true,   
		hidden = true,			
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
		energy_required = 5,
		ingredients =
		{
		  {"refined-concrete", 10*mp},
		  {"electric-engine-unit", 5*mp},
		  {"processing-unit", 5*mp},
		  {"advanced-circuit", 10*mp},
		  {"electronic-circuit", 50*mp},
		  {"radar", 2*mp},
		  
		},
		results=
		{
		  {type="item", name="rsc-building-stage6", amount=1,probability=0},
		},     
	},
	
 
  }
)


		  
if data.raw.item['se-rocket-launch-pad'] then
local enable_se_cargo = settings.startup["rsc-st-enable-se-cargo-silo"].value 
local enable_se_probe = settings.startup["rsc-st-enable-se-probe-silo"].value 

if enable_se_cargo then 
	local ing = table.deepcopy(data.raw.recipe['se-rocket-launch-pad'].ingredients)
	for i=1,#ing do 
		if ing[i].amount then 
			ing[i].amount = math.ceil(ing[i].amount/original_cost_div)
			else
			ing[i][2] = math.ceil(ing[i][2]/original_cost_div)
			end
		end
	table.insert (ing, {drill,100})
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
			else
			ing[i][2] = math.ceil(ing[i][2]/original_cost_div)
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
		energy_required = 5,
		ingredients =
		{
		  {"processing-unit", 10*mp},
		  {"electric-engine-unit", 10*mp},
		  {"se-heat-shielding", 10*mp},
		  {"se-holmium-cable", 10*mp},
		  {"se-heavy-girder", 5*mp},
		  {"se-aeroframe-scaffold", 5*mp},
		  
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
		energy_required = 5,
		ingredients = 		{
		  {"green-wire", 20*mp},
		  {"red-wire", 20*mp},
		  {"se-holmium-cable", 10*mp},
		  {"se-heat-shielding", 10*mp},
		  {"se-heavy-girder", 5*mp},
		  {"se-aeroframe-pole", 10*mp},
		  
		},
		results=
		{
		  {type="item", name="rsc-building-stage2", amount=1,probability=0},
		},     
	},
	})
	end
end