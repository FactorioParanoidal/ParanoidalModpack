-- from KaoExtened
local function extendVanilla()
	if data.raw["resource"]["iron-ore"] then
		data.raw["resource"]["iron-ore"].minable.required_fluid = "water"
		data.raw["resource"]["iron-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["copper-ore"] then
		data.raw["resource"]["copper-ore"].minable.required_fluid = "steam"
		data.raw["resource"]["copper-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["stone"] then
		data.raw["resource"]["stone"].minable.required_fluid = "steam"
		data.raw["resource"]["stone"].minable.fluid_amount = 20
	end

end

local function extendBobs()
	if data.raw["resource"]["bob-zinc-ore"] then
		data.raw["resource"]["bob-zinc-ore"].minable.required_fluid = "water"
		data.raw["resource"]["bob-zinc-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-tungsten-ore"] then
		data.raw["resource"]["bob-tungsten-ore"].minable.required_fluid = "water"
		data.raw["resource"]["bob-tungsten-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-tin-ore"] then
		data.raw["resource"]["bob-tin-ore"].minable.required_fluid = "water"
		data.raw["resource"]["bob-tin-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-sulfur"] then
		data.raw["resource"]["bob-sulfur"].minable.required_fluid = "steam"
		data.raw["resource"]["bob-sulfur"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-sort-gem-ore"] then
		data.raw["resource"]["bob-sort-gem-ore"].minable.required_fluid = "water"
		data.raw["resource"]["bob-sort-gem-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-silver-ore"] then
		data.raw["resource"]["bob-silver-ore"].minable.required_fluid = "steam"
		data.raw["resource"]["bob-silver-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["rutile"] then
		data.raw["resource"]["rutile"].minable.required_fluid = "water"
		data.raw["resource"]["rutile"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-quartz"] then
		data.raw["resource"]["bob-quartz"].minable.required_fluid = "water"
		data.raw["resource"]["bob-quartz"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-nickel-ore"] then
		data.raw["resource"]["bob-nickel-ore"].minable.required_fluid = "steam"
		data.raw["resource"]["bob-nickel-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-lead-ore"] then
		data.raw["resource"]["bob-lead-ore"].minable.required_fluid = "water"
		data.raw["resource"]["bob-lead-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-gold-ore"] then
		data.raw["resource"]["bob-gold-ore"].minable.required_fluid = "steam"
		data.raw["resource"]["bob-gold-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-gem-ore"] then
		data.raw["resource"]["bob-gem-ore"].minable.required_fluid = "steam"
		data.raw["resource"]["bob-gem-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bob-cobalt-ore"] then
		data.raw["resource"]["bob-cobalt-ore"].minable.required_fluid = "water"
		data.raw["resource"]["bob-cobalt-ore"].minable.fluid_amount = 20
	end

	if data.raw["resource"]["bauxite"] then
		data.raw["resource"]["bauxite"].minable.required_fluid = "water"
		data.raw["resource"]["bauxite"].minable.fluid_amount = 20
	end
end

local function extendAngles()
	if data.raw["resource"]["angels-ore1"] then
		data.raw["resource"]["angels-ore1"].minable.required_fluid = "water"
		data.raw["resource"]["angels-ore1"].minable.fluid_amount = 100
	end
	if data.raw["resource"]["angels-ore2"] then
		data.raw["resource"]["angels-ore2"].minable.required_fluid = "steam"
		data.raw["resource"]["angels-ore2"].minable.fluid_amount = 100
	end
	if data.raw["resource"]["angels-ore3"] then
		data.raw["resource"]["angels-ore3"].minable.required_fluid = "water"
		data.raw["resource"]["angels-ore3"].minable.fluid_amount = 100
	end
	if data.raw["resource"]["angels-ore4"] then
		data.raw["resource"]["angels-ore4"].minable.required_fluid = "steam"
		data.raw["resource"]["angels-ore4"].minable.fluid_amount = 100
	end
	if data.raw["resource"]["angels-ore5"] then
		data.raw["resource"]["angels-ore5"].minable.required_fluid = "steam"
		data.raw["resource"]["angels-ore5"].minable.fluid_amount = 100
	end
	if data.raw["resource"]["angels-ore6"] then
		data.raw["resource"]["angels-ore6"].minable.required_fluid = "steam"
		data.raw["resource"]["angels-ore6"].minable.fluid_amount = 100
	end

	data.raw.resource["infinite-angels-ore1"].minable.required_fluid = "angels-liquid-sulfuric-acid"
	data.raw.resource["infinite-angels-ore1"].mining_time = 7
	data.raw.resource["infinite-angels-ore2"].minable.required_fluid = "angels-liquid-hydrofluoric-acid"
	data.raw.resource["infinite-angels-ore2"].mining_time = 14
	data.raw.resource["infinite-angels-ore3"].minable.required_fluid = "angels-liquid-sulfuric-acid"
	data.raw.resource["infinite-angels-ore3"].mining_time = 7
	data.raw.resource["infinite-angels-ore4"].minable.required_fluid = "angels-liquid-hydrochloric-acid"
	data.raw.resource["infinite-angels-ore4"].mining_time = 12
	data.raw.resource["infinite-angels-ore5"].minable.required_fluid = "angels-liquid-nitric-acid"
	data.raw.resource["infinite-angels-ore5"].mining_time = 10
	data.raw.resource["infinite-angels-ore6"].minable.required_fluid = "angels-liquid-nitric-acid"
	data.raw.resource["infinite-angels-ore6"].mining_time = 10

	data.raw.resource["infinite-angels-ore1"].minable.fluid_amount = 100
	data.raw.resource["infinite-angels-ore2"].minable.fluid_amount = 100
	data.raw.resource["infinite-angels-ore3"].minable.fluid_amount = 100
	data.raw.resource["infinite-angels-ore4"].minable.fluid_amount = 100
	data.raw.resource["infinite-angels-ore5"].minable.fluid_amount = 100
	data.raw.resource["infinite-angels-ore6"].minable.fluid_amount = 100

	data.raw["resource"]["infinite-coal"].minable.required_fluid = nil
	data.raw["resource"]["infinite-coal"].minable.fluid_amount = nil
	data.raw["resource"]["infinite-coal"].mining_time = 15 --4?
end

extendVanilla()
extendBobs()
extendAngles()

