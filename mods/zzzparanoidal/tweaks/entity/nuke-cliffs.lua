-- add ability to remove cliffs to nuke waves
table.insert(data.raw.projectile["atomic-bomb-wave"].action, {
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

if data.raw.projectile["atomic-artillery-wave"] then
	table.insert(data.raw.projectile["atomic-artillery-wave"].action, {
		type = "direct",
		action_delivery = {
			type = "instant",
			target_effects = {
				{
					type = "destroy-cliffs",
					radius = 3,
					explosion = "explosion",
				},
			},
		},
	})
end

