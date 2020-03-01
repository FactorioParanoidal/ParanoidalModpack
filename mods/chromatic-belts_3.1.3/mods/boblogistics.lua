log("chromatic-belts.boblogistics")

-- bob tier belts
for _, color in pairs{'green', 'purple'}
do
	remaps['__boblogistics__/graphics/entity/transport-belt/' .. color ..'-transport-belt.png'] = graphic(color .. '-transport-belt')
	remaps['__boblogistics__/graphics/entity/transport-belt/hr-' .. color ..'-transport-belt.png'] = graphic('hr-' .. color ..'-transport-belt')
end
