require ("__KaoExtended__/config")
if not KaoExtended then KaoExtended = {} end
KaoExtended.getTech = function(name)
	return data.raw["technology"][name]
end
KaoExtended.NewTechnology = function(Iname, pre, Iorder, Iunit)
	if pre == nil then pre = {} end
	if Iunit == nil then Iunit = {count = 50, ingredients = { {"automation-science-pack", 1} }, time = 15} end
	if Iorder == nil then Iorder = "z-z" end
	data:extend({
		{ type = "technology",
		name = Iname,
		icon = "__KaoExtended__/graphics/advsci-component-3.png",
		icon_size = 32,
		prerequisites = pre,
		effects = {},
		unit = Iunit,
		upgrade = false,
		order = Iorder
		},
	})
end
local getIngredients = function(Iingredients)
	local count = 1
	local ingredient = {}
	local ingredients = {}
	for index, o in ipairs(Iingredients) do
		if index % 2 == 0 then
			ingredient[2] = o
			table.insert(ingredients, ingredient)
		end
	end
	return ingredients
end


KaoExtended.buildUnit = function(technology ,Icount, Itime, Iingredients)
	KaoExtended.getTech(technology).unit = {count = Icount, time = Itime, ingredients = getIngredients(Iingredients)}
end
KaoExtended.TechUnlockRecipe = function(technology, unlock)
  if type(unlock) == "string"then
    table.insert(data.raw["technology"][technology].effects, { type = "unlock-recipe", recipe = unlock })
    return
  end
	for index, o in ipairs(unlock) do
		table.insert(data.raw["technology"][technology].effects, { type = "unlock-recipe", recipe = o })
	end
	unlock = {}
end
KaoExtended.getUnlockRecipe = function(name)
	return { type = "unlock-recipe", recipe = name }
end
KaoExtended.changeUpgrade = function(technology)
	KaoExtended.getTech(technology).upgrade = true
end