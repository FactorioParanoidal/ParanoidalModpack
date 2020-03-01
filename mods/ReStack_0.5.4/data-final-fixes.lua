--[[ Copyright (c) 2018 Optera
 * Part of Re-Stack
 *
 * See LICENSE.md in the project directory for license information.
--]]


ReStack_Items = {}    -- list of item names to apply new stack size
Launch_Products = {}  -- launch products should be skipped

Tile_Whitelist = {  -- always apply tile stack size
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
      Launch_Products[item.rocket_launch_product[1]] = item.rocket_launch_product[2]
    end
  end
end

-- apply new stack_size to anything with matching name
-- log(serpent.block(ReStack_Items))
for _, group in pairs(data.raw) do
  for item_name, stack_data in pairs(ReStack_Items) do
    local item = group[item_name]
    if item and item.stack_size then
      if ReStack_Items[item_name].stack_size > 0 and (settings.startup["ReStack-include-launch-products"].value or not Launch_Products[item_name]) then
        log("[RS] Setting "..tostring(stack_data.type).."."..tostring(item_name)..".stack_size "..item.stack_size.." -> "..stack_data.stack_size)
        item.stack_size = ReStack_Items[item_name].stack_size
      -- else
        -- log("[RS] Skipping "..tostring(stack_data.type).."."..tostring(item_name))
      end
    end
  end
end
