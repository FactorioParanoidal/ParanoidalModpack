require("prototypes.miniloaders")
require("prototypes.generators")
require("prototypes.fluid-void")
require("prototypes.gas-void")
require("prototypes.ThickerLines")

if mods.bobequipment then
	data.raw.item["personal-roboport-mk3-equipment"].subgroup = "misc1"
	data.raw.item["personal-roboport-mk4-equipment"].subgroup = "misc1"
end

-- Uniform recipe mod
for _,r in pairs(data.raw["recipe"]) do
		r.always_show_products=true;
    r.show_amount_in_title=false;
end
-- Uniform recipe end