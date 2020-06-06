--[[ Copyright (c) 2018 Optera
 * Part of LTN Content Reader
 *
 * See LICENSE.md in the project directory for license information.
--]]

-- sum items and fluids for number of slots required in combinator output
local itemcount = 0
local fluidcount = 0
for type, type_data in pairs(data.raw) do
  for item_name, item in pairs(type_data) do
    if item.stack_size then -- use stack_size to get all "items" since a lot are not type=item
      itemcount = itemcount + 1
    end
    if type == "fluid" then
      fluidcount = fluidcount + 1
    end
  end
end

if 1 + itemcount + fluidcount > 50 then
  log("[LTN Content Reader] setting combinator slots to "..tostring(1 + itemcount + fluidcount) )
  data.raw["constant-combinator"]["ltn-provider-reader"].item_slot_count = 1 + itemcount + fluidcount
  data.raw["constant-combinator"]["ltn-requester-reader"].item_slot_count = 1 + itemcount + fluidcount
  data.raw["constant-combinator"]["ltn-delivery-reader"].item_slot_count = 1 + itemcount + fluidcount
end
