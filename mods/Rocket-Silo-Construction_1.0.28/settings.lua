data:extend({

  {
    type = "int-setting",
    name = "rsc-st-work-for-remove-stone",
    setting_type = "startup",
	default_value = 500,
	minimum_value = 10,
	maximum_value = 99999,
  },

  {
    type = "int-setting",
    name = "rsc-st-work-for-insert-material",
    setting_type = "startup",
	default_value = 100,
	minimum_value = 10,
	maximum_value = 99999,
  },

  {
    type = "int-setting",
    name = "rsc-st-cost-mp",
    setting_type = "startup",
	default_value = 1,
	minimum_value = 1,
	maximum_value = 100,
  },


 {
    type = "bool-setting",
    name = "rsc-st-not-removable-silo",
    setting_type =  "startup",
    default_value = false,
 },

 {
    type = "bool-setting",
    name = "rsc-st-not-removable-site",
    setting_type =  "startup",
    default_value = false,
 },
 
 {
    type = "bool-setting",
    name = "rsc-st-dont-place-tiles",
    setting_type =  "startup",
    default_value = false,
 },




})


if mods['space-exploration'] then
data:extend({
 {
    type = "bool-setting",
    name = "rsc-st-enable-se-cargo-silo",
    setting_type =  "startup",
    default_value = true,
 },
 {
    type = "bool-setting",
    name = "rsc-st-enable-se-probe-silo",
    setting_type =  "startup",
    default_value = true,
 }, 

})
end
