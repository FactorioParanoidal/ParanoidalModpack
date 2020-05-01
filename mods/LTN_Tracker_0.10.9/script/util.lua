local util = {}

-- copy/paste from Optera's LTN-Content-Reader
local btest = bit32.btest
function util.get_items_in_network(ltn_item_list, selected_networkID)
	local items = {}
	for networkID, item_data in pairs(ltn_item_list) do
		if btest(selected_networkID, networkID) then
			for item, count in pairs(item_data) do
				items[item] = (items[item] or 0) + count
			end
		end
  end
	return items
end

return util