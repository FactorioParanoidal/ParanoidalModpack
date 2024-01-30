data:extend(
{
  {
    type = "fluid",
    name = "fluid-tetraethyllead",
	subgroup = "petrochem-basic-fluids",
    default_temperature = 25,
    heat_capacity = "0.1KJ",
    base_color = {r=0.3, g=0.05, b=0.4},
    flow_color = {r=0.3, g=0.05, b=0.4},
    max_temperature = 250,
    icon = "__more-petrochem-hell__/graphics/fluid-tetraethyllead.png",
    icon_size = 32,
    pressure_to_speed_ratio = 0.2,
    flow_to_energy_ratio = 0.70,
    order = "i"
  },
   {
    type = "fluid",
    name = "gas-chloroethane",
    icon = "__more-petrochem-hell__/graphics/gas-chloroethane.png",
    icon_size = 32,
    subgroup = "petrochem-basic-fluids",
    default_temperature = 25,
    heat_capacity = "0.1KJ",
    base_color = {r = 0.35, g = 0.35, b = 0.35},
    flow_color = {r = 0.35, g = 0.35, b = 0.35},
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
  },
  {
    type = "item",
    name = "ingot-sodium-lead-alloy",
    icon = "__more-petrochem-hell__/graphics/ingot-sodium-lead-alloy.png",
	icon_size = 32,
    subgroup = "angels-lead",
    order = "f",
    stack_size = 200
  },
  {
    type = "item",
    name = "high-octane-enriched-fuel",
    icon = "__more-petrochem-hell__/graphics/high-octane-enriched-fuel.png",
    icon_size = 32,
    fuel_category = "chemical",
    fuel_value = "40MJ",
    fuel_acceleration_multiplier = 1.9,
    fuel_top_speed_multiplier = 1.3,
    fuel_emissions_multiplier = 1.8,
    subgroup = "bob-resource",
    order = "e[enriched-fuel]",
    stack_size = 20
  },
  
 
  }
  )