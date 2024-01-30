require("prototypes.equipment-grid-updates")

if settings.startup["inserter-immunity"].value == true then
	table.insert(data.raw["car"]["better-cargo-plane"].flags, "no-automated-item-removal")
	table.insert(data.raw["car"]["better-cargo-plane"].flags, "no-automated-item-insertion")
	table.insert(data.raw["car"]["even-better-cargo-plane"].flags, "no-automated-item-removal")
	table.insert(data.raw["car"]["even-better-cargo-plane"].flags, "no-automated-item-insertion")
end

-- AAI
if data.raw["selection-tool"]["unit-remote-control"] then
	-- hauler types, according to AAI, should not have guns, and I'll stick to their... guns... on that topic
	data.raw.car["better-cargo-plane"].guns = nil
	data.raw.car["even-better-cargo-plane"].guns = nil
end
