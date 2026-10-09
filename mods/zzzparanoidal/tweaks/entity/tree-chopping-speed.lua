-- Рубка деревьев быстрее в TREE_CHOP_SPEED_MULTIPLIER раз (время добычи уменьшается во столько же)
local TREE_CHOP_SPEED_MULTIPLIER = 3

for _, tree in pairs(data.raw.tree or {}) do
	local minable = tree.minable
	if minable then
		if minable.mining_time then
			minable.mining_time = minable.mining_time / TREE_CHOP_SPEED_MULTIPLIER
		end
	end
end
