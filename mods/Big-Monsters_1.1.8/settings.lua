data:extend({

   {
    type = "int-setting",
    name = "bm-event-days",
    setting_type = "runtime-global",
	default_value = 100, --drd
	minimum_value = 0,
	maximum_value = 365, --drd
	order = "a"
  },  



{
	type = "double-setting",
	name = "bm-invasion-min_evo",
	setting_type = "runtime-global",
	default_value = 0.1,
	minimum_value = 0,
	maximum_value = 0.9,
	order = "b2"
},
{
	type = "double-setting",
	name = "bm-soldiers-min_evo",
	setting_type = "runtime-global",
	default_value = 0.05,
	minimum_value = 0,
	maximum_value = 0.9,
	order = "b3"
},
{
	type = "double-setting",
	name = "bm-brutals-min_evo",
	setting_type = "runtime-global",
	default_value = 0.2,
	minimum_value = 0,
	maximum_value = 0.9,
	order = "b4"
},
{
	type = "double-setting",
	name = "bm-worms-min_evo",
	setting_type = "runtime-global",
	default_value = 0.7,
	minimum_value = 0,
	maximum_value = 0.9,
	order = "b5"
},
{
	type = "double-setting",
	name = "bm-biterzilla-min_evo",
	setting_type = "runtime-global",
	default_value = 0.3,
	minimum_value = 0,
	maximum_value = 0.9,
	order = "b6"
},
{
	type = "double-setting",
	name = "bm-spidertron-min_evo",
	setting_type = "runtime-global",
	default_value = 0.8,
	minimum_value = 0,
	maximum_value = 0.9,
	order = "b7"
},
{
	type = "double-setting",
	name = "bm-volcano-min_evo",
	setting_type = "runtime-global",
	default_value = 0.65,
	minimum_value = 0,
	maximum_value = 0.9,
	order = "b8"
},
  



   {
    type = "int-setting",
    name = "bm-swarm-chance",
    setting_type = "runtime-global",
	default_value = 100,
	minimum_value = 0,
	maximum_value = 100,
	order = "c1"
  },
  
  {
    type = "int-setting",
    name = "bm-invasion-chance",
    setting_type = "runtime-global",
	default_value = 30,
	minimum_value = 0,
	maximum_value = 80,
	order = "c2"
  },
  
   {
    type = "int-setting",
    name = "bm-soldiers-chance",
    setting_type = "runtime-global",
	default_value = 30,
	minimum_value = 0,
	maximum_value = 80,
	order = "c3"
  }, 
  
   {
    type = "int-setting",
    name = "bm-brutals-chance",
    setting_type = "runtime-global",
	default_value = 30,
	minimum_value = 0,
	maximum_value = 80,
	order = "c3"
  }, 
   
  {
    type = "int-setting",
    name = "bm-worms-chance",
    setting_type = "runtime-global",
	default_value = 40,
	minimum_value = 0,
	maximum_value = 80,
	order = "c4"
  },
 

 
  {
    type = "int-setting",
    name = "bm-biterzilla-chance",
    setting_type = "runtime-global",
	default_value = 30,
	minimum_value = 0,
	maximum_value = 80,
	order = "c5a"
  },
 
   {
    type = "int-setting",
    name = "bm-spidertron-chance",
    setting_type = "runtime-global",
	default_value = 30,
	minimum_value = 0,
	maximum_value = 80,
	order = "c5b"
  },
 
 
   {
    type = "int-setting",
    name = "bm-volcano-chance",
    setting_type = "runtime-global",
	default_value = 20,
	minimum_value = 0,
	maximum_value = 80,
	order = "c6"
  },   
  

  {
    type = "bool-setting",
    name = "bm-enable-silo-attack",
    setting_type = "runtime-global",
    default_value = true,
	order = "d1"
  },
  

{
	type = "double-setting",
	name = "bm-enemy-hp-multiplier",
	setting_type = "startup",
	default_value = 1,
	minimum_value = 0.2,
	maximum_value = 10,
	order = "m1"
},


{
	type = "double-setting",
	name = "bm-big-enemy-hp-multiplier",
	setting_type = "startup",
	default_value = 1,
	minimum_value = 0.2,
	maximum_value = 10,
	order = "m1"
},
{
	type = "double-setting",
	name = "bm-worm-enemy-hp-multiplier",
	setting_type = "startup",
	default_value = 1,
	minimum_value = 0.2,
	maximum_value = 10,
	order = "m1"
},
{
	type = "double-setting",
	name = "bm-enemy-damage-multiplier",
	setting_type = "startup",
	default_value = 1,
	minimum_value = 0.5,
	maximum_value = 10,
	order = "m2"
},


  {
    type = "bool-setting",
    name = "bm-show-alerts",
    setting_type = "runtime-global",
    default_value = true,
	order = "s1"
  },

 
  {
    type = "bool-setting",
    name = "bm-show-cameras",
    setting_type = "runtime-global",
    default_value = true,
	order = "s2"
  },


  {
    type = "bool-setting",
    name = "bm-allow-nuker",
    setting_type = "runtime-global",
    default_value = true,
	order = "s5"
  },

  {
    type = "bool-setting",
    name = "bm-spidertron-nuke",
    setting_type = "runtime-global",
    default_value = false,
	order = "s6"
  }, 
  
   {
    type = "int-setting",
    name = "bm-difficulty-level",
    setting_type = "runtime-global",
	default_value = 1,
	minimum_value = 1,
	maximum_value = 10,
	order = "u"
  },  
  
{
	type = "double-setting",
	name = "bm-tree-events-chance",
	setting_type = "runtime-global",
	default_value = 0.0, --drd
	minimum_value = 0.0,
	maximum_value = 100,
	order = "w"
},    
})