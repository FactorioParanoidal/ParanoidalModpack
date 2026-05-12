for _, factory in pairs(storage.factories or {}) do
    if factory.roboport_upgrade and factory.roboport_upgrade.item_request_proxies then
        for k, proxy in pairs(factory.roboport_upgrade.item_request_proxies) do
            if type(proxy) == "userdata" then
                proxy.destroy()
                factory.roboport_upgrade.item_request_proxies[k] = nil
            end
        end
    end
end
