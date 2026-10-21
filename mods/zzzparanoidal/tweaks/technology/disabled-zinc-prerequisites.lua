-- Extended Angels adds a Bob technology disabled by Angels Smelting.
-- Remove only the agreed stale edges; preserve all other prerequisites.
for _, name in ipairs({
	"angels-bio-farm-3",
	"angels-water-washing-3",
	"angels-bio-refugium-fish-3",
}) do
	local technology = data.raw.technology[name]
	if technology and technology.prerequisites then
		for index = #technology.prerequisites, 1, -1 do
			if technology.prerequisites[index] == "bob-zinc-processing" then
				table.remove(technology.prerequisites, index)
			end
		end
	end
end
