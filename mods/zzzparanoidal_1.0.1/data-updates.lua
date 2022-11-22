require("prototypes.miniloaders")
require("prototypes.generators")
require("prototypes.fluid-void")
require("prototypes.gas-void")
require("prototypes.ThickerLines")
require("prototypes.ColorCodedPlanners_101") -- мод ColorCodedPlanners_1.0.1

if mods.bobequipment then
	data.raw.item["personal-roboport-mk3-equipment"].subgroup = "misc1"
	data.raw.item["personal-roboport-mk4-equipment"].subgroup = "misc1"
end

-- Uniform recipe mod
for _,r in pairs(data.raw["recipe"]) do
		r.always_show_products=true;
    r.show_amount_in_title=false;
    if r.normal ~= nil then
        r.normal.always_show_products = true;
        r.normal.show_amount_in_title = false;
    end
    if r.expensive ~= nil then
        r.expensive.always_show_products = true;
        r.expensive.show_amount_in_title = false;
    end
end
-- Uniform recipe end