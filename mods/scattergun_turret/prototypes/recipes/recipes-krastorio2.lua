function W93_UpdateRecipesKrastorio2()
	data.raw["recipe"]["w93-scattergun-turret"].ingredients = {{type="item", name="automation-core", amount=3},
								{type="item", name="stone-brick", amount=10},
								{type="item", name="iron-gear-wheel", amount=10}}
	data.raw["recipe"]["w93-modular-turret-base"].ingredients = {{type="item", name="concrete", amount=30},
								{type="item", name="steel-plate", amount=8},
								{type="item", name="engine-unit", amount=1}}
	data.raw["recipe"]["w93-modular-gun-lcannon"].ingredients = {{type="item", name="copper-plate", amount=5},
								{type="item", name="steel-plate", amount=4},
								{type="item", name="electronic-components", amount=5},
								{type="item", name="iron-gear-wheel", amount=4}}
	data.raw["recipe"]["w93-modular-gun-hcannon"].ingredients = {{type="item", name="low-density-structure", amount=2},
								{type="item", name="rare-metals", amount=10},
								{type="item", name="advanced-circuit", amount=2},
								{type="fluid", name="lubricant", amount=50}
}
	data.raw["recipe"]["w93-modular-gun-plaser"].ingredients = {{type="item", name="plastic-bar", amount=10},
								{type="item", name="iron-stick", amount=8},
								{type="item", name="electronic-circuit", amount=5},
								{type="item", name="speed-module", amount=1},
								{type="item", name="battery", amount=10},
								{type="item", name="quartz", amount=15}}
	data.raw["recipe"]["w93-modular-gun-tlaser"].ingredients = {{type="item", name="plastic-bar", amount=8},
								{type="item", name="steel-plate", amount=2},
								{type="item", name="processing-unit", amount=2},
								{type="item", name="lithium-sulfur-battery", amount=10},
								{type="item", name="imersite-crystal", amount=5},
								{type="item", name="efficiency-module", amount=1}}
	data.raw["recipe"]["w93-modular-gun-beam"].ingredients = {{type="item", name="uranium-fuel-cell", amount=1},
								{type="item", name="small-lamp", amount=1},
								{type="item", name="low-density-structure", amount=1},
								{type="item", name="poison-capsule", amount=1},
								{type="item", name="processing-unit", amount=2},
								{type="item", name="lithium-sulfur-battery", amount=8}}
	data.raw["recipe"]["w93-uranium-shotgun-shell"].ingredients = {{type="item", name="shotgun-shell", amount=1},
								{type="item", name="uranium-238", amount=2}}
	data.raw["recipe"]["w93-uranium-shotgun-shell"].energy_required = 6
end