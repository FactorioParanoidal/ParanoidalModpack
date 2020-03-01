data:extend({
 { -- Gunship
    type = "recipe",
    name = "gunship",
	normal = 
	 {
	enabled=false,
	energy_required=10,
    ingredients = 
      {
       {"electric-engine-unit",64},
       {"steel-plate",200},
       {"iron-plate",400},
       {"electronic-circuit",40},
	   {"submachine-gun",5},
	   {"rocket-launcher",5}
      },
    result = "gunship"
	 },
	expensive =
	 {
	enabled=false,
	energy_required=20,
	ingredients =
	  {
	   {"electric-engine-unit",128},
	   {"steel-plate",400},
	   {"iron-plate",800},
	   {"electronic-circuit",80},
	   {"submachine-gun",10},
	   {"rocket-launcher",10},
	  },
	result = "gunship"
	},
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Cargo Plane
    type = "recipe",
    name = "cargo-plane",
	normal =
	 {
	enabled=false,
	energy_required=5,
    ingredients = 
      {
       {"electric-engine-unit",128},
       {"steel-plate",400},
       {"iron-plate",500},
       {"advanced-circuit",20},
	   {"submachine-gun",1}
      },
    result = "cargo-plane"
	 },
	expensive =
	 {
	enabled=false,
	energy_required=10,
	ingredients =
	  {
	   {"electric-engine-unit",256},
	   {"steel-plate",800},
	   {"iron-plate",1000},
	   {"advanced-circuit",20},
	   {"submachine-gun",2},
	  },
	result = "cargo-plane"
	 },
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Jet
    type = "recipe",
    name = "jet",
    normal =
	 {
	enabled=false,
	energy_required=10,
    ingredients = 
      {
       {"electric-engine-unit",256},
       {"electronic-circuit",120},
	   {"advanced-circuit",50},
	   {"low-density-structure",200},
	   {"submachine-gun",3},
	   {"rocket-launcher",3}
      },
    result = "jet"
	 },
	expensive =
	 {
	enabled=false,
	energy_required=20,
	ingredients =
	  {
	   {"electric-engine-unit",512},
	   {"electronic-circuit",240},
	   {"advanced-circuit",100},
	   {"low-density-structure",400},
	   {"submachine-gun",6},
	   {"rocket-launcher",6},
	  },
	result = "jet"
	 },
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Flying Fortress
    type = "recipe",
    name = "flying-fortress",
	normal =
	 {
	enabled=false,
	energy_required=20,
    ingredients = 
      {
       {"electric-engine-unit",100},
       {"steel-plate",2000},
       {"advanced-circuit",80},
	   {"processing-unit", 40},
	   {"submachine-gun",15},
	   {"rocket-launcher",15},
      },
    result = "flying-fortress",
	 },
	expensive =
	 {
	enabled=false,
	energy_required=40,
	ingredients =
	  {
	   {"electric-engine-unit",200},
	   {"steel-plate",4000},
	   {"advanced-circuit",160},
	   {"processing-unit",80},
	   {"submachine-gun",30},
	   {"rocket-launcher",30},
	  },
	result = "flying-fortress",
	 },
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- High explosive cannon shell
    type = "recipe",
    name = "high-explosive-cannon-shell",
	normal =
	 {
	enabled=false,
	energy_required = 10,
    ingredients = 
      {
	   {"explosive-cannon-shell", 3},
	   {"explosives", 1}
      },
    result = "high-explosive-cannon-shell"
	 },
	expensive =
	 {
	enabled=false,
	energy_required = 15,
	ingredients =
	  {
	   {"explosive-cannon-shell",6},
	   {"explosives", 2},
	  },
	result = "high-explosive-cannon-shell",
	 },
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Aircraft afterburner
	type = "recipe",
	name = "aircraft-afterburner",
	category = "crafting-with-fluid",
	normal =
	 {
	enabled=false,
	energy_required=3,
	ingredients =
	  {
	   {"electric-engine-unit", 10},
	   {type="fluid", name = "lubricant", amount = 5},
	   {"solid-fuel", 5},
	  },
	result = "aircraft-afterburner",
	 },
	expensive =
	 {
	enabled=false,
	energy_required=6,
	ingredients =
	  {
	   {"electric-engine-unit",20},
	   {type="fluid", name = "lubricant", amount = 10},
	   {"solid-fuel", 10},
	  },
	result = "aircraft-afterburner",
	 },
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Aircraft energy shield
	type = "recipe",
	name = "aircraft-energy-shield",
	normal =
	 {
	enabled=false,
	energy_required=5,
	ingredients =
	  {
	   {"energy-shield-mk2-equipment", 2},
	   {"battery", 20},
	  },
	result = "aircraft-energy-shield",
	 },
	expensive =
	 {
	enabled=false,
	energy_required=10,
	ingredients =
	  {
	   {"energy-shield-mk2-equipment", 4},
	   {"battery", 40},
	  },
	result = "aircraft-energy-shield",
	 },
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Napalm
	type = "recipe",
	name = "napalm",
	normal =
	 {
	enabled=false,
	energy_required=1,
	ingredients =
	  {
	   {"flamethrower-ammo", 2},
	   {"iron-plate", 2},
	  },
	result = "napalm",
	 },
	expensive =
	 {
	enabled=false,
	energy_required=2,
	ingredients =
	  {
	   {"flamethrower-ammo", 4},
	   {"iron-plate", 4},
	  },
	result = "napalm",
	 },
  },
})