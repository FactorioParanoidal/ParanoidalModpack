-- Ударная волна ядерных зарядов разрушает скалы (KaoExtended, Beta 8).
local function add_cliff_destruction(name)
	local projectile = data.raw.projectile[name]
	if not (projectile and projectile.action) then return end
	if serpent.line(projectile.action):find("destroy-cliffs", 1, true) then return end
	if projectile.action.type then projectile.action = { projectile.action } end
	table.insert(projectile.action, {
		type = "direct",
		action_delivery = {
			type = "instant",
			target_effects = {
				{
					type = "destroy-cliffs",
					radius = 3,
					explosion_at_cliff = "explosion",
				},
			},
		},
	})
end

add_cliff_destruction("atomic-bomb-wave")
