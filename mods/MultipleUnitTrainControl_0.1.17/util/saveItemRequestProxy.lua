

function saveItemRequestProxy(target)
	-- Search for item_request_proxy ghosts targeting this entity
	local proxies = target.surface.find_entities_filtered({
					  name = "item-request-proxy",
					  force = target.force,
					  position = target.position
					})
	for _, proxy in pairs(proxies) do
		if proxy.proxy_target == target and proxy.valid then
			local items = {}
			for k,v in pairs(proxy.item_requests) do
				items[k] = v
			end
			return items
		else
			return nil
		end
	end


end

return saveItemRequestProxy
