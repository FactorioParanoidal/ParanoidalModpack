if not settings.startup["SpaceX-classic-mode"].value then
	remote.add_interface("spacex-feoras-fork", {
		milestones_preset_addons = function()
			return {
				["Space Extension (SpaceX) (Feoras Fork)"] = {
					required_mods = { "SpaceModFeorasFork" },
					forbidden_mods = {},
					milestones = {
						{ type = "group", name = "SpaceX" },
						{ type = "item", name = "satellite", quantity = 7 },
						{ type = "technology", name = "space-assembly", quantity = 1 },
						{ type = "item", name = "drydock-structural", quantity = 10 },
						{ type = "item", name = "drydock-assembly", quantity = 2 },
						{ type = "item", name = "protection-field", quantity = 1 },
						{ type = "item", name = "fusion-reactor", quantity = 1 },
						{ type = "item", name = "habitation", quantity = 1 },
						{ type = "item", name = "life-support", quantity = 1 },
						{ type = "item", name = "command", quantity = 1 },
						{ type = "item", name = "laser-cannon", quantity = 2 },
						{ type = "item", name = "fuel-cell", quantity = 2 },
						{ type = "item", name = "space-thruster", quantity = 4 },
						{ type = "item", name = "hull-component", quantity = 10 },
						{ type = "technology", name = "ftl-propulsion", quantity = 1 },
						{ type = "item", name = "ftl-drive", quantity = 1 },
						{ type = "item", name = "exploration-satellite", quantity = 25 },
						{ type = "item", name = "space-ai-robot", quantity = 2 },
						{ type = "item", name = "space-water-tank", quantity = 2 },
						{ type = "item", name = "space-oxygen-tank", quantity = 2 },
						{ type = "item", name = "space-fuel-tank", quantity = 4 },
						{ type = "technology", name = "space-cartography", quantity = 1 },
						{ type = "item", name = "space-map", quantity = 1 },
					},
				},
			}
		end,
	})
else
	remote.add_interface("spacex-feoras-fork", {
		milestones_preset_addons = function()
			return {
				["Space Extension (SpaceX) (Feoras Fork)"] = {
					required_mods = { "SpaceModFeorasFork" },
					forbidden_mods = {},
					milestones = {
						{ type = "group", name = "SpaceX" },
						{ type = "item", name = "satellite", quantity = 7 },
						{ type = "technology", name = "space-assembly", quantity = 1 },
						{ type = "item", name = "drydock-structural", quantity = 10 },
						{ type = "item", name = "drydock-assembly", quantity = 2 },
						{ type = "item", name = "protection-field", quantity = 1 },
						{ type = "item", name = "fusion-reactor", quantity = 1 },
						{ type = "item", name = "habitation", quantity = 1 },
						{ type = "item", name = "life-support", quantity = 1 },
						{ type = "item", name = "command", quantity = 1 },
						{ type = "item", name = "fuel-cell", quantity = 2 },
						{ type = "item", name = "space-thruster", quantity = 4 },
						{ type = "item", name = "hull-component", quantity = 10 },
						{ type = "technology", name = "ftl-propulsion", quantity = 1 },
						{ type = "item", name = "ftl-drive", quantity = 1 },
					},
				},
			}
		end,
	})
end
