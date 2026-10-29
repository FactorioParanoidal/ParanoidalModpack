local C = require("shared.config")

local refill = mods["carbon-capture2"] ~= nil

local function icon(name)
	return C.PATH .. "/graphics/icons/" .. name .. ".png"
end

local function field(name, value, order)
	return { name = { "tpr-tooltip." .. name }, value = value, order = order }
end

-- Armor-slot breathing protection. Filtration = toxin resistance; durability = filter resource.
local function mask(name, order, refillable)
	local spec = C.ARMORS[name]
	local fields = {
		field("filtration", { "tpr-tooltip.percent", tostring(spec.filtration) }, 1),
		field("poison", { "tpr-tooltip.percent", tostring(math.floor(C.POISON_SHARE * 100 + 0.5)) }, 3),
	}
	if refillable then
		fields[#fields + 1] = field("filters", refill and { "tpr-tooltip.refill", C.REFILL_ITEM, tostring(C.REFILL_AMOUNT) }
			or { "tpr-tooltip.no-refill" }, 2)
	else
		fields[#fields + 1] = field("filters", { "tpr-tooltip.disposable" }, 2)
	end
	return {
		type = "armor",
		name = name,
		icon = icon(name),
		icon_size = 64,
		resistances = {
			{ type = C.RESIST_TYPE, decrease = 0, percent = spec.filtration },
			{ type = "poison", decrease = 0, percent = math.floor(C.POISON_SHARE * 100 + 0.5) },
		},
		infinite = false,
		durability = spec.durability,
		durability_description_key = "description.tpr-filter-resource-key",
		durability_description_value = "description.tpr-filter-resource-value",
		factoriopedia_durability_description_key = "description.tpr-filter-resource-key",
		subgroup = "armor",
		order = order,
		stack_size = 10,
		custom_tooltip_fields = fields,
	}
end

data:extend({
	mask(C.RESPIRATOR, "f[hazard]-a[respirator]", false),
	mask(C.GAS_MASK, "f[hazard]-b[gas-mask]", true),
})
