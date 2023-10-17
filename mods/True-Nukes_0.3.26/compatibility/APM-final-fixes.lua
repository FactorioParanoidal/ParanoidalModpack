local no_prod = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"utility-science-pack", 1},
  {"apm_nuclear_science_pack", 1}
}

if(settings.startup["enable-medium-atomics"].value and settings.startup["enable-nuclear-tests"].value) then
  data.raw.technology["atomic-bomb"].unit.ingredients = {{"test-pack-atomic-20t-1", 1}}
else
  data.raw.technology["atomic-bomb"].unit.ingredients = no_prod
end