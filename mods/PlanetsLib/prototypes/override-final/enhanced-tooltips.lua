local rro = PlanetsLib.rro

--- Check that the recipe result references an item prototype that has spoilage.
--- A recipe result is defined as {name="foo", amount=...}.
--- Items and their subtypes (capsule, ammo, etc.) are stored in data.raw under their respective type tables.
--- This function iterates through all "item" prototype types to verify the result's item exists and has a non nil spoil_ticks.
---@param result table A recipe result with a 'name' field
---@return boolean True if the result references an item with spoil_ticks defined
local function assert_recipe_result_is_eligible(result)
	for type_, _ in pairs(defines.prototypes.item) do
		if data.raw[type_] and data.raw[type_][result.name] and data.raw[type_][result.name].spoil_ticks ~= nil then
			return true
		end
	end
	return false
end

local function get_products_with(recipe, field)
	local product_names
	for _, result in pairs(recipe.results) do
		if result.type == "item" and result[field] == true then
			if not product_names then
				product_names = {""}
			end
			table.insert(product_names, "[item="..result.name.."]")
		end
	end
	return product_names
end

if settings.startup["PlanetsLib-enhanced-tooltips"].value == true then
	for _, recipe in pairs(data.raw["recipe"]) do
		if
			recipe.results
			and rro.count(recipe.results, function(result)
					return assert_recipe_result_is_eligible(result)
				end)
				> 0
		then
			local i = 200
			for _, tooltip in ipairs({
				{ "result-is-always-fresh", get_products_with(recipe, "always_fresh") },
				{ "reset-freshness-on-craft", get_products_with(recipe, "reset_freshness_on_craft") },
				{ "preserve-products-in-machine-output", recipe.preserve_products_in_machine_output and { "gui.yes" }},
			}) do
				if tooltip[2] and #tooltip[2] > 0 then
					i = i + 1
					local tooltip_field = {
						name = { "tooltip." .. tooltip[1] },
						value = tooltip[2],
						order = i,
					}
					if not recipe.custom_tooltip_fields then
						recipe.custom_tooltip_fields = {}
					end
					rro.soft_insert(recipe.custom_tooltip_fields, tooltip_field)
				end
			end
		end
	end

	local function parse_energy_string(s) --ChatGPT
		-- Match: number part, optional prefix, and unit
		-- %d+ matches digits, %.? allows decimal point,
		-- ([%a]?) captures single optional letter (prefix),
		-- ([%a]+) captures remaining letters (unit).
		local number, prefix, unit = string.match(s, "^(%d+%.?%d*)([%a]?)([%a])$")

		if not number then
			error("Invalid format: " .. s)
		end

		return number, prefix, unit
	end

	-- Converts an energy string into a localised string.
	local function localise_energy(energy)
		local symbols = {
			k = "si-prefix-symbol-kilo",
			M = "si-prefix-symbol-mega",
			G = "si-prefix-symbol-giga",
			T = "si-prefix-symbol-tera",
			P = "si-prefix-symbol-peta",
			E = "si-prefix-symbol-exa",
			Z = "si-prefix-symbol-zetta",
			Y = "si-prefix-symbol-yotta",
			R = "si-prefix-symbol-ronna",
			Q = "si-prefix-symbol-quetta",
			W = "si-unit-symbol-watt",
			J = "si-unit-symbol-joule",
			N = "si-unit-symbol-newton",
		}

		if type(energy) == "string" then
			--local j_index = string.find(energy,"J")
			--local prefix_index = j_index - 1
			local number, prefix, unit = parse_energy_string(energy)
			return { "", tostring(number), " ", { symbols[prefix] or "" }, { symbols[unit] } }
		else
			return "?"
		end
	end

	-- for _, prototype_type in pairs(data.raw) do
	-- 	for _, prototype in pairs(prototype_type) do
	-- 		if prototype.heating_energy then
	-- 			if not prototype.custom_tooltip_fields then
	-- 				prototype.custom_tooltip_fields = {}
	-- 			end
	-- 			-- if prototype.name == "steam-recycler" then
	-- 			--     error(serpent.block(localise_energy(prototype.heating_energy)))
	-- 			-- end
	-- 			rro.soft_insert(prototype.custom_tooltip_fields, {
	-- 				name = { "tooltip.heating-energy" },
	-- 				--quality_header = "quality-tooltip.decreases",
	-- 				value = localise_energy(prototype.heating_energy),
	-- 				order = 200,
	-- 				--quality_values = {}
	-- 			})
	-- 		end
	-- 	end
	-- end
end
