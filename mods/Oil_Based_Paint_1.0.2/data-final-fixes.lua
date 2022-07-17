-- Saturate & achieve darker blacks on inventory icons (spidertron & DMVs)
for _, name in ipairs({
	"spidertron",
	"car",
	"tank",
	"ironclad",
	"vehicle-warden",
	"vehicle-flame-tank",
	"vehicle-laser-tank",
	"hcraft-entity",
	"acraft-entity"
}) do
	if data.raw["item-with-entity-data"][name] then -- check the item exists
		local item = data.raw["item-with-entity-data"][name]
		if item.icon_tintable_mask then -- the item has tint
			-- double the color mask
			item.icon_tintable_masks = {
				{ icon_tintable_mask = item.icon_tintable_mask, icon_size = 64 },
				{ icon_tintable_mask = item.icon_tintable_mask, icon_size = 64 }
			}
		end
		item.icon_tintable_mask = nil
	end
end
