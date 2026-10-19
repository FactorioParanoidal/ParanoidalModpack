-- Factorio 2.0.77 can leave ~0.000119 J after burnout: no flow, but status "working".
-- Clear only sub-millijoule residue; let the engine show its native no-fuel status/icon.
local M = {}
local NAME = "offshore-mk0-pump"
local EPSILON = 0.001 -- joules, not fuel or a usable per-tick energy reserve

function M.init()
	local pumps = {}
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered({ name = NAME })) do
			pumps[entity.unit_number] = entity
		end
	end
	storage.paranoidal_burner_pumps = pumps
end

local function tracked()
	-- Also covers an existing save after a code-only update without a version bump.
	if not storage.paranoidal_burner_pumps then M.init() end
	return storage.paranoidal_burner_pumps
end

local function built(event)
	local entity = event.entity or event.destination
	if entity and entity.valid and entity.name == NAME then
		tracked()[entity.unit_number] = entity
	end
end

-- Required before loader-shells: its dispatcher preserves these earlier handlers.
-- Each filtered event is registered separately, as required by the runtime API.
for _, event in ipairs({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
	defines.events.on_entity_cloned,
}) do
	script.on_event(event, built, { { filter = "name", name = NAME } })
end

script.on_nth_tick(60, function()
	local pumps = tracked()
	for id, entity in pairs(pumps) do
		if not entity.valid or entity.name ~= NAME then
			pumps[id] = nil
		else
			local energy = entity.energy
			if energy > 0 and energy < EPSILON then
				local burner = entity.burner
				if burner and burner.remaining_burning_fuel == 0 and burner.inventory.is_empty() then
					entity.energy = 0
				end
			end
		end
	end
end)

return M
