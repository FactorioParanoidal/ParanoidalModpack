-- Bob's MK2/MK3 night vision reuse the base description; give each tier its own key (texts in ParanoidalLocale).
for _, name in pairs({ "bob-night-vision-equipment-2", "bob-night-vision-equipment-3" }) do
	local item = data.raw.item[name]
	if item then
		item.localised_description = { "item-description." .. name }
	end
end
