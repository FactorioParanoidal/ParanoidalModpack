--[[ Copyright (c) 2018 Optera
 * Part of Re-Stack
 *
 * See LICENSE.md in the project directory for license information.
--]]

local table = require("__flib__.table")

ReStack_Items = {} -- list of item names to apply new stack size
Launch_Products = {} -- launch products should be skipped

Tile_Whitelist = { -- always apply tile stack size
	["stone-brick"] = true,
}

-- modules filling ReStack_Items
require("modules.lib")
require("modules.military")
require("modules.logistic")
require("modules.production")
require("modules.intermediate")

-- modules setting stacks directly
require("modules.barrel")
require("modules.ammo")

-- get rocket_launch_product list
for _, group in pairs(data.raw) do
	for item_name, item in pairs(group) do
		if item.rocket_launch_product then
			Launch_Products[item.rocket_launch_product.name or item.rocket_launch_product[1]] = item.rocket_launch_product.amount
				or item.rocket_launch_product[2]
				or 1
		end
		if item.rocket_launch_products then
			for _, launch_product in pairs(item.rocket_launch_products) do
				Launch_Products[launch_product.name or launch_product[1]] = launch_product.amount
					or launch_product[2]
					or 1
			end
		end
	end
end

-- apply new stack_size to anything with matching name
-- log(serpent.block(ReStack_Items))
for _, group in pairs(data.raw) do
	for item_name, stack_data in pairs(ReStack_Items) do
		local item = group[item_name]
		if
			item
			and item.stack_size
			and (not item.flags or not table.for_each(item.flags, function(v)
				return v == "not-stackable"
			end))
		then
			if ReStack_Items[item_name].stack_size > 0 then
				--  log("[RS] Setting "..tostring(stack_data.type).."."..tostring(item_name)..".stack_size "..item.stack_size.." -> "..stack_data.stack_size)
				item.stack_size = ReStack_Items[item_name].stack_size
				local launch_product_amount = Launch_Products[item_name]
				if launch_product_amount and launch_product_amount > item.stack_size then
					-- also adjust rocket silo output inventory
					local launch_product_stacks = math.ceil(launch_product_amount / item.stack_size)
					if launch_product_stacks > data.raw["rocket-silo"]["rocket-silo"].rocket_result_inventory_size then
						log(
							"[RS] Setting Rocket Silo output stack size "
								.. data.raw["rocket-silo"]["rocket-silo"].rocket_result_inventory_size
								.. " -> "
								.. launch_product_stacks
						)
						data.raw["rocket-silo"]["rocket-silo"].rocket_result_inventory_size = launch_product_stacks
					end
				end
			end
		end
	end
end
