function W93_UpdateRecipesIR3()
	data.raw["recipe"]["w93-scattergun-turret"].ingredients = {{type="item", name="stone-brick", amount=20},
								{type="item", name="iron-plate-heavy", amount=10},
								{type="item", name="iron-gear-wheel", amount=10},
								{type="item", name="iron-motor", amount=1}}
	data.raw["recipe"]["w93-modular-turret-base"].ingredients = {{type="item", name="concrete-block", amount=20},
								{type="item", name="steel-plate-heavy", amount=12},
								{type="item", name="steel-gear-wheel", amount=8},
								{type="item", name="iron-motor", amount=2}}
	data.raw["recipe"]["w93-modular-turret2-base"].ingredients = {{type="item", name="low-density-structure", amount=6},
								{type="item", name="steel-plate-heavy", amount=12},
								{type="item", name="electric-engine-unit", amount=2},
								{type="item", name="gyroscope", amount=2}}
	data.raw["recipe"]["w93-modular-gun-hmg"].ingredients = {{type="item", name="steel-plate", amount=6},
								{type="item", name="steel-rod", amount=4},
								{type="item", name="steel-gear-wheel", amount=4},
								{type="item", name="computer-mk1", amount=1}}
	data.raw["recipe"]["w93-modular-gun-gatling"].ingredients = {{type="item", name="chromium-rod", amount=12},
								{type="item", name="brass-gear-wheel", amount=8},
								{type="item", name="electric-engine-unit", amount=2},
								{type="item", name="computer-mk2", amount=1}}
	data.raw["recipe"]["w93-modular-gun-lcannon"].ingredients = {{type="item", name="steel-plate-heavy", amount=6},
								{type="item", name="steel-rivet", amount=8},
								{type="item", name="advanced-circuit", amount=4},
								{type="item", name="computer-mk2", amount=1}}
	data.raw["recipe"]["w93-modular-gun-dcannon"].ingredients = {{type="item", name="w93-modular-gun-lcannon", amount=2},
								{type="item", name="speed-module-2", amount=1},
								{type="item", name="gyroscope", amount=1},
								{type="item", name="brass-gear-wheel", amount=8}}
	data.raw["recipe"]["w93-modular-gun-hcannon"].ingredients = {{type="item", name="chromium-plate-heavy", amount=8},
								{type="item", name="steel-rivet", amount=12},
								{type="item", name="processing-unit", amount=4},
								{type="item", name="computer-mk3", amount=1}}
	data.raw["recipe"]["w93-modular-gun-hcannon"].category = "crafting"
	data.raw["recipe"]["w93-modular-gun-rocket"].ingredients = {{type="item", name="rocket-launcher", amount=2},
								{type="item", name="steel-rivet", amount=8},
								{type="item", name="computer-mk2", amout=1}}
	data.raw["recipe"]["w93-modular-gun-plaser"].ingredients = {{type="item", name="ruby-laser", amount=1},
								{type="item", name="advanced-battery", amount=1},
								{type="item", name="junction-box", amount=1},
								{type="item", name="computer-mk2", amount=1}}
	data.raw["recipe"]["w93-modular-gun-tlaser"].ingredients = {{type="item", name="ruby-laser", amount=1},
								{type="item", name="electrum-gem", amount=2},
								{type="item", name="nanoglass", amount=6},
								{type="item", name="chromium-frame-small", amount=1},
								{type="item", name="computer-mk2", amount=1}}
	data.raw["recipe"]["w93-modular-gun-beam"].ingredients = {{type="item", name="uranium-fuel-cell", amount=1},
								{type="item", name="lead-plate-special", amount=6},
								{type="item", name="field-effector", amount=4},
								{type="item", name="chromium-frame-small", amount=1},
								{type="item", name="computer-mk3", amount=1}}
	data.raw["recipe"]["w93-modular-gun-radar"].ingredients = {{type="item", name="efficiency-module-3", amount=1},
								{type="item", name="chromium-beam", amount=4},
								{type="item", name="copper-coil", amount=8},
								{type="item", name="computer-mk2", amount=1}}
	data.raw["recipe"]["w93-modular-gun-radar2"].ingredients = {{type="item", name="speed-module-3", amount=1},
								{type="item", name="chromium-rod", amount=16},
								{type="item", name="copper-coil", amount=8},
								{type="item", name="computer-mk2",amount=1}}

	data.raw["recipe"]["w93-hardened-inserter"].ingredients = {{type="item", name="long-handed-inserter", amount=1},
								{type="item", name="steel-plate-heavy", amount=2},
								{type="item", name="steel-rivet", amount=4}}
	data.raw["recipe"]["w93-hardened-inserter"].energy_required = 1

	data.raw["recipe"]["w93-fragmentation-cannon-shell"].ingredients = {{type="item", name="steel-rod", amount=8},
								{type="item", name="steel-plate", amount=2},
								{type="item", name="explosives", amount=1}}
end