local categories = {
	"deuterium",
	"thorium",
	"nuclear",
	"PE-MOX",
	"MOX",
}


local function insert_categories(reactor)
	for _, category in pairs(categories) do
		if data.raw["fuel-category"][category] then
			table.insert(reactor.energy_source.fuel_categories, category)
		end
	end
end



insert_categories(data.raw.reactor["realistic-reactor"])
insert_categories(data.raw.reactor["realistic-reactor-normal"])
insert_categories(data.raw.reactor["realistic-reactor-breeder"])

for i=1, 250 do
	insert_categories(data.raw.reactor["realistic-reactor-"..i])
end
