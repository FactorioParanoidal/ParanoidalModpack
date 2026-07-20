local mxl_item_types = {
	"item",
	"ammo",
	"capsule",
	"gun",
	"item-with-entity-data",
	"module",
	"tool",
	"armor",
	"repair-tool",
	"selection-tool",
	"blueprint",
	"blueprint-book",
	"deconstruction-item",
	"upgrade-item",
	"item-with-inventory",
	"item-with-label",
	"item-with-tags",
	"rail-planner",
	"spidertron-remote",
	"space-platform-starter-pack",
}

local mxl_extended_names = {}

local mxl_layered_icon_products = {
	["agricultural-science-pack"] = true,
	["agricultural-tower"] = true,
	["artificial-jellynut-soil"] = true,
	["artificial-yumako-soil"] = true,
	["asteroid-collector"] = true,
	["battery-mk3-equipment"] = true,
	["big-mining-drill"] = true,
	["biochamber"] = true,
	["bioflux"] = true,
	["biolab"] = true,
	["biter-egg"] = true,
	["captive-biter-spawner"] = true,
	["carbon-fiber"] = true,
	["carbonic-asteroid-chunk"] = true,
	["cargo-bay"] = true,
	["cliff-explosives"] = true,
	["copper-bacteria"] = true,
	["crusher"] = true,
	["cryogenic-plant"] = true,
	["cryogenic-science-pack"] = true,
	["electromagnetic-plant"] = true,
	["electromagnetic-science-pack"] = true,
	["foundation"] = true,
	["foundry"] = true,
	["fusion-generator"] = true,
	["fusion-power-cell"] = true,
	["fusion-reactor"] = true,
	["heating-tower"] = true,
	["holmium-ore"] = true,
	["holmium-plate"] = true,
	["ice-platform"] = true,
	["iron-bacteria"] = true,
	["jelly"] = true,
	["jellynut"] = true,
	["jellynut-seed"] = true,
	["lightning-collector"] = true,
	["lightning-rod"] = true,
	["lithium"] = true,
	["lithium-plate"] = true,
	["metallic-asteroid-chunk"] = true,
	["metallurgic-science-pack"] = true,
	["nutrients"] = true,
	["overgrowth-jellynut-soil"] = true,
	["overgrowth-yumako-soil"] = true,
	["oxide-asteroid-chunk"] = true,
	["promethium-asteroid-chunk"] = true,
	["promethium-science-pack"] = true,
	["quality-module"] = true,
	["quality-module-2"] = true,
	["quality-module-3"] = true,
	["quantum-processor"] = true,
	["railgun-ammo"] = true,
	["railgun-turret"] = true,
	["recycler"] = true,
	["rocket-turret"] = true,
	["scrap"] = true,
	["selector-combinator"] = true,
	["space-platform-foundation"] = true,
	["spidertron"] = true,
	["spoilage"] = true,
	["stack-inserter"] = true,
	["supercapacitor"] = true,
	["superconductor"] = true,
	["tesla-ammo"] = true,
	["tesla-turret"] = true,
	["thruster"] = true,
	["tree-seed"] = true,
	["turbo-splitter"] = true,
	["turbo-transport-belt"] = true,
	["turbo-underground-belt"] = true,
	["yumako"] = true,
	["yumako-mash"] = true,
	["yumako-seed"] = true,
}

local mxl_product_icon_overrides = {
	["spidertron"] = {
		{
			icon = "__MxlChievements2__/graphics/spidertron-single.png",
			icon_size = 256,
		},
	},
}

local mxl_product_icon_scale = 0.7

local function mxl_has_prototype(type_name, name)
	return data.raw[type_name] and data.raw[type_name][name] ~= nil
end

local function mxl_get_item_product(name)
	for _, type_name in pairs(mxl_item_types) do
		if data.raw[type_name] and data.raw[type_name][name] then
			return data.raw[type_name][name]
		end
	end
	return nil
end

local function mxl_has_item_product(name)
	return mxl_get_item_product(name) ~= nil
end

local function mxl_apply_product_icon(prototype)
	local product_name = prototype.item_product or prototype.fluid_product
	if not product_name or not mxl_layered_icon_products[product_name] or not prototype.icon then
		return
	end

	local product = nil
	if prototype.item_product then
		product = mxl_get_item_product(product_name)
	elseif prototype.fluid_product and data.raw.fluid then
		product = data.raw.fluid[product_name]
	end

	if not product then
		return
	end

	local product_icons = mxl_product_icon_overrides[product_name]
	if product_icons then
		product_icons = table.deepcopy(product_icons)
	elseif product.icons then
		product_icons = table.deepcopy(product.icons)
	elseif product.icon then
		product_icons = {
			{
				icon = product.icon,
				icon_size = product.icon_size or 64,
			},
		}
	else
		return
	end

	local frame = {
		icon = prototype.icon,
		icon_size = prototype.icon_size or 128,
		draw_background = false,
	}

	prototype.icon = nil
	prototype.icon_size = nil
	prototype.icon_mipmaps = nil
	prototype.icons = {frame}

	for _, layer in pairs(product_icons) do
		layer.icon_size = layer.icon_size or product.icon_size or 64
		layer.scale = (layer.scale or 64 / layer.icon_size) * mxl_product_icon_scale
		if layer.shift then
			layer.shift = {
				layer.shift[1] * mxl_product_icon_scale,
				layer.shift[2] * mxl_product_icon_scale,
			}
		end
		layer.draw_background = false
		table.insert(prototype.icons, layer)
	end
end

local function mxl_should_extend(prototype)
	if prototype.item_product and not mxl_has_item_product(prototype.item_product) then
		return false
	end

	if prototype.fluid_product and not mxl_has_prototype("fluid", prototype.fluid_product) then
		return false
	end

	if prototype.limit_quality and not mxl_has_prototype("quality", prototype.limit_quality) then
		return false
	end

	return true
end

local function mxl_extend(prototypes)
	local filtered = {}
	for _, prototype in pairs(prototypes) do
		if mxl_should_extend(prototype) then
			local prototype_name = prototype.name
			if not prototype_name or not mxl_extended_names[prototype_name] then
				mxl_apply_product_icon(prototype)
				table.insert(filtered, prototype)
				if prototype_name then
					mxl_extended_names[prototype_name] = true
				end
			end
		end
	end

	if next(filtered) then
		data:extend(filtered)
	end
end

mxl_extend{
	{
		type = "produce-achievement",
		name = "gear-production-1",
		order = "u",
		item_product = "iron-gear-wheel",
		amount = 1000000,
		limit_quality = "normal",
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gear-production-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "gear-production-2",
		order = "u",
		item_product = "iron-gear-wheel",
		amount = 1000000000,
		limit_quality = "normal",
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gear-production-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "gear-production-3",
		order = "u",
		item_product = "iron-gear-wheel",
		amount = 1000000000000,
		limit_quality = "normal",
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gear-production-1.png",
		icon_size = 128
	},
{
		type = "produce-achievement",
		name = "gear-production-1a",
		order = "u",
		item_product = "iron-gear-wheel",
		amount = 10000000,
		limit_quality = "uncommon",
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gear-production-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "gear-production-1b",
		order = "u",
		item_product = "iron-gear-wheel",
		amount = 10000000,
		limit_quality = "rare",
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gear-production-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "gear-production-1c",
		order = "u",
		item_product = "iron-gear-wheel",
		amount = 10000000,
		limit_quality = "epic",
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gear-production-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "gear-production-1d",
		order = "u",
		item_product = "iron-gear-wheel",
		amount = 10000000,
		limit_quality = "legendary",
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gear-production-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "Inserter-Madness-1",
		order = "u",
		item_product = "inserter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Inserter-Madness-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "Inserter-Madness-2",
		order = "u",
		item_product = "inserter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Inserter-Madness-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "Inserter-Madness-3",
		order = "u",
		item_product = "inserter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Inserter-Madness-1.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "iron-bar-1",
		order = "u",
		item_product = "iron-plate",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "iron-bar-2",
		order = "u",
		item_product = "iron-plate",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "iron-bar-3",
		order = "u",
		item_product = "iron-plate",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "copper-bar-1",
		order = "u",
		item_product = "copper-plate",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "copper-bar-2",
		order = "u",
		item_product = "copper-plate",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "copper-bar-3",
		order = "u",
		item_product = "copper-plate",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "ass-machine-1",
		order = "u",
		item_product = "assembling-machine-2",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Ass-Machine-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "ass-machine-2",
		order = "u",
		item_product = "assembling-machine-2",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Ass-Machine-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "ass-machine-3",
		order = "u",
		item_product = "assembling-machine-2",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Ass-Machine-1.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "blue-inserter-1",
		order = "u",
		item_product = "fast-inserter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Inserter-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "blue-inserter-2",
		order = "u",
		item_product = "fast-inserter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Inserter-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "blue-inserter-3",
		order = "u",
		item_product = "fast-inserter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Inserter-1.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "green-card-1",
		order = "u",
		item_product = "electronic-circuit",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Green-Card-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "green-card-2",
		order = "u",
		item_product = "electronic-circuit",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Green-Card-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "green-card-3",
		order = "u",
		item_product = "electronic-circuit",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Green-Card-1.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "red-card-1",
		order = "u",
		item_product = "advanced-circuit",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Card-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "red-card-2",
		order = "u",
		item_product = "advanced-circuit",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Card-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "red-card-3",
		order = "u",
		item_product = "advanced-circuit",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Card-1.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "blue-card-1",
		order = "u",
		item_product = "processing-unit",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Card-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "blue-card-2",
		order = "u",
		item_product = "processing-unit",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Card-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "blue-card-3",
		order = "u",
		item_product = "processing-unit",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Card-1.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "pipe-1",
		order = "u",
		item_product = "pipe",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Pipe-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "pipe-2",
		order = "u",
		item_product = "pipe",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Pipe-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "pipe-3",
		order = "u",
		item_product = "pipe",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Pipe-1.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "red-science-1",
		order = "u",
		item_product = "automation-science-pack",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Red-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "red-science-2",
		order = "u",
		item_product = "automation-science-pack",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Red-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "red-science-3",
		order = "u",
		item_product = "automation-science-pack",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Red-1.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "green-science-1",
		order = "u",
		item_product = "logistic-science-pack",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Green-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "green-science-2",
		order = "u",
		item_product = "logistic-science-pack",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Green-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "green-science-3",
		order = "u",
		item_product = "logistic-science-pack",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Green-1.png",
		icon_size = 128
	},
    }
mxl_extend{
	{
		type = "produce-achievement",
		name = "blue-science-1",
		order = "u",
		item_product = "chemical-science-pack",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Blue-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "blue-science-2",
		order = "u",
		item_product = "chemical-science-pack",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Blue-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "blue-science-3",
		order = "u",
		item_product = "chemical-science-pack",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Blue-1.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "black-science-1",
		order = "u",
		item_product = "military-science-pack",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Black-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "black-science-2",
		order = "u",
		item_product = "military-science-pack",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Black-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "black-science-3",
		order = "u",
		item_product = "military-science-pack",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Black-1.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "yellow-science-1",
		order = "u",
		item_product = "utility-science-pack",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Yellow-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "yellow-science-2",
		order = "u",
		item_product = "utility-science-pack",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Yellow-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "yellow-science-3",
		order = "u",
		item_product = "utility-science-pack",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Yellow-3.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "purple-science-1",
		order = "u",
		item_product = "production-science-pack",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Purple-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "purple-science-2",
		order = "u",
		item_product = "production-science-pack",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Purple-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "purple-science-3",
		order = "u",
		item_product = "production-science-pack",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Sci-Purple-3.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "concrete-1",
		order = "u",
		item_product = "concrete",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/concrete-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "concrete-2",
		order = "u",
		item_product = "concrete",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/concrete-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "concrete-3",
		order = "u",
		item_product = "concrete",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/concrete-3.png",
		icon_size = 128
	},
	}
mxl_extend{
	{
		type = "produce-achievement",
		name = "stone-brick-1",
		order = "u",
		item_product = "stone-brick",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Stone-Brick-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "stone-brick-2",
		order = "u",
		item_product = "stone-brick",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Stone-Brick-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stone-brick-3",
		order = "u",
		item_product = "stone-brick",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Stone-Brick-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "rail-1",
		order = "u",
		item_product = "rail",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rails-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "rail-2",
		order = "u",
		item_product = "rail",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rails-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "rail-3",
		order = "u",
		item_product = "rail",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rails-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "elec-furn-1",
		order = "u",
		item_product = "electric-furnace",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Elec-Furn-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "elec-furn-2",
		order = "u",
		item_product = "electric-furnace",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Elec-Furn-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "elec-furn-3",
		order = "u",
		item_product = "electric-furnace",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Elec-Furn-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "steel-plate-1",
		order = "u",
		item_product = "steel-plate",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Steel-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "steel-plate-2",
		order = "u",
		item_product = "steel-plate",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Steel-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "steel-plate-3",
		order = "u",
		item_product = "steel-plate",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Steel-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "plastic-1",
		order = "u",
		item_product = "plastic-bar",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/plastic-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "plastic-2",
		order = "u",
		item_product = "plastic-bar",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/plastic-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "plastic-3",
		order = "u",
		item_product = "plastic-bar",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/plastic-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "elec-drill-1",
		order = "u",
		item_product = "electric-mining-drill",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Elec-Drill-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "elec-drill-2",
		order = "u",
		item_product = "electric-mining-drill",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Elec-Drill-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "elec-drill-3",
		order = "u",
		item_product = "electric-mining-drill",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Elec-Drill-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "underground-belt-1",
		order = "u",
		item_product = "underground-belt",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/underground-belt-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "underground-belt-2",
		order = "u",
		item_product = "underground-belt",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/underground-belt-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "underground-belt-3",
		order = "u",
		item_product = "underground-belt",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/underground-belt-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "red-under-1",
		order = "u",
		item_product = "fast-underground-belt",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Under-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "red-under-2",
		order = "u",
		item_product = "fast-underground-belt",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Under-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "red-under-3",
		order = "u",
		item_product = "fast-underground-belt",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Under-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "express-underground-belt-1",
		order = "u",
		item_product = "express-underground-belt",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-underground-belt-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "underground-belt-2",
		order = "u",
		item_product = "express-underground-belt",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-underground-belt-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "underground-belt-3",
		order = "u",
		item_product = "express-underground-belt",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-underground-belt-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "underground-belt-1",
		order = "u",
		item_product = "transport-belt",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/transport-belt-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "underground-belt-2",
		order = "u",
		item_product = "transport-belt",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/transport-belt-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "underground-belt-3",
		order = "u",
		item_product = "transport-belt",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/transport-belt-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "red-belt-1",
		order = "u",
		item_product = "fast-transport-belt",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/fast-transport-belt-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "red-belt-2",
		order = "u",
		item_product = "fast-transport-belt",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/fast-transport-belt-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "red-belt-3",
		order = "u",
		item_product = "fast-transport-belt",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/fast-transport-belt-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "blue-belt-1",
		order = "u",
		item_product = "express-transport-belt",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-transport-belt-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "blue-belt-2",
		order = "u",
		item_product = "express-transport-belt",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-transport-belt-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "blue-belt-3",
		order = "u",
		item_product = "express-transport-belt",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-transport-belt-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "splitter-1",
		order = "u",
		item_product = "splitter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/splitter-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "splitter-2",
		order = "u",
		item_product = "splitter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/splitter-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "splitter-3",
		order = "u",
		item_product = "splitter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/splitter-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "fast-splitter-1",
		order = "u",
		item_product = "fast-splitter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/fast-splitter-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "fast-splitter-2",
		order = "u",
		item_product = "fast-splitter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/fast-splitter-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "fast-splitter-3",
		order = "u",
		item_product = "fast-splitter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/fast-splitter-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "express-splitter-1",
		order = "u",
		item_product = "express-splitter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-splitter-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "express-splitter-2",
		order = "u",
		item_product = "express-splitter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-splitter-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "express-splitter-3",
		order = "u",
		item_product = "express-splitter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/express-splitter-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "grenade-1",
		order = "u",
		item_product = "grenade",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/grenade-1.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "grenade-2",
		order = "u",
		item_product = "grenade",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/grenade-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "grenade-3",
		order = "u",
		item_product = "grenade",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/grenade-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "uranium-ore-1",
		order = "u",
		item_product = "uranium-ore",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-ore.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "uranium-ore-2",
		order = "u",
		item_product = "uranium-ore",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-ore.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "uranium-ore-3",
		order = "u",
		item_product = "uranium-ore",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-ore.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "uranium-235-1",
		order = "u",
		item_product = "uranium-235",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-235.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "uranium-235-2",
		order = "u",
		item_product = "uranium-235",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-235.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "uranium-235-3",
		order = "u",
		item_product = "uranium-235",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-235.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "uranium-238-1",
		order = "u",
		item_product = "uranium-ore",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-238.png",
		icon_size = 128
	},
		{
		type = "produce-achievement",
		name = "uranium-238-2",
		order = "u",
		item_product = "uranium-238",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-238.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "uranium-238-3",
		order = "u",
		item_product = "uranium-238",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-238.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "car-production-1",
		order = "u",
		item_product = "car",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/car.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "tank-production-1",
		order = "u",
		item_product = "tank",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/tank.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "locomotive-production-1",
		order = "u",
		item_product = "locomotive",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/locomotive.png",
		icon_size = 128
	},
}	

mxl_extend{
	{
		type = "produce-achievement",
		name = "steam-production",
		order = "u",
		fluid_product = "steam",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/satellite.png",
		icon_size = 128
	}
}

mxl_extend{
	{
		type = "produce-per-hour-achievement",
        name = "copper-madness-1",
		order = "u",
		item_product = "copper-plate",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "copper-madness-2",
		order = "u",
		item_product = "copper-plate",
		amount = 2000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "copper-madness-3",
		order = "u",
		item_product = "copper-plate",
		amount = 3000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "copper-madness-4",
		order = "u",
		item_product = "copper-plate",
		amount = 4000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "copper-madness-5",
		order = "u",
		item_product = "copper-plate",
		amount = 5000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "copper-madness-6",
		order = "u",
		item_product = "copper-plate",
		amount = 6000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "copper-madness-7",
		order = "u",
		item_product = "copper-plate",
		amount = 7000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "copper-madness-8",
		order = "u",
		item_product = "copper-plate",
		amount = 8000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "copper-madness-9",
		order = "u",
		item_product = "copper-plate",
		amount = 9000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "copper-madness-10",
		order = "u",
		item_product = "copper-plate",
		amount = 10000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/copper-bar-1.png",
		icon_size = 128
    	}
}
mxl_extend{
	{
		type = "produce-per-hour-achievement",
        name = "iron-madness-1",
		order = "u",
		item_product = "iron-plate",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "iron-madness-2",
		order = "u",
		item_product = "iron-plate",
		amount = 2000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "iron-madness-3",
		order = "u",
		item_product = "iron-plate",
		amount = 3000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "iron-madness-4",
		order = "u",
		item_product = "iron-plate",
		amount = 4000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "iron-madness-5",
		order = "u",
		item_product = "iron-plate",
		amount = 5000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "iron-madness-6",
		order = "u",
		item_product = "iron-plate",
		amount = 6000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "iron-madness-7",
		order = "u",
		item_product = "iron-plate",
		amount = 7000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "iron-madness-8",
		order = "u",
		item_product = "iron-plate",
		amount = 8000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "iron-madness-9",
		order = "u",
		item_product = "iron-plate",
		amount = 9000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "iron-madness-10",
		order = "u",
		item_product = "iron-plate",
		amount = 10000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/iron-bar-1.png",
		icon_size = 128
    	}
}
mxl_extend{
	{
		type = "produce-per-hour-achievement",
        name = "steel-madness-1",
		order = "u",
		item_product = "steel-plate",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Steel-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "steel-madness-2",
		order = "u",
		item_product = "steel-plate",
		amount = 2000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Steel-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "steel-madness-3",
		order = "u",
		item_product = "steel-plate",
		amount = 3000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Steel-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "steel-madness-4",
		order = "u",
		item_product = "steel-plate",
		amount = 4000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Steel-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "steel-madness-5",
		order = "u",
		item_product = "steel-plate",
		amount = 5000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Steel-1.png",
		icon_size = 128
    },
}	
mxl_extend{
	{
		type = "produce-per-hour-achievement",
        name = "green-machine-1",
		order = "u",
		item_product = "electronic-circuit",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Green-Card-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "green-machine-2",
		order = "u",
		item_product = "electronic-circuit",
		amount = 2000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Green-Card-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "green-machine-3",
		order = "u",
		item_product = "electronic-circuit",
		amount = 3000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Green-Card-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "green-machine-4",
		order = "u",
		item_product = "electronic-circuit",
		amount = 4000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Green-Card-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "green-machine-5",
		order = "u",
		item_product = "electronic-circuit",
		amount = 5000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Green-Card-1.png",
		icon_size = 128
    },
}	
mxl_extend{
	{
		type = "produce-per-hour-achievement",
        name = "big-red-machine-1",
		order = "u",
		item_product = "advanced-circuit",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Card-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "big-red-machine-2",
		order = "u",
		item_product = "advanced-circuit",
		amount = 2000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Card-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "big-red-machine-3",
		order = "u",
		item_product = "advanced-circuit",
		amount = 3000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Card-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "big-red-machine-4",
		order = "u",
		item_product = "advanced-circuit",
		amount = 4000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Card-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "big-red-machine-5",
		order = "u",
		item_product = "advanced-circuit",
		amount = 5000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Red-Card-1.png",
		icon_size = 128
    },
}	
mxl_extend{
	{
		type = "produce-per-hour-achievement",
        name = "keep-on-smurfin-1",
		order = "u",
		item_product = "processing-unit",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Card-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "keep-on-smurfin-2",
        name = "keep-on-smurfin-2",
		order = "u",
		item_product = "processing-unit",
		amount = 2000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Card-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "keep-on-smurfin-3",
		order = "u",
		item_product = "processing-unit",
		amount = 3000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Card-1.png",
		icon_size = 128
    },
    {
		type = "produce-per-hour-achievement",
        name = "keep-on-smurfin-4",
		order = "u",
		item_product = "processing-unit",
		amount = 4000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Card-1.png",
		icon_size = 128
    },
	{
		type = "produce-per-hour-achievement",
        name = "keep-on-smurfin-5",
		order = "u",
		item_product = "processing-unit",
		amount = 5000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/Blue-Card-1.png",
		icon_size = 128
    },
}	
mxl_extend{
    {
		type = "train-path-achievement",
		name = "train-madness-1",
		order = "u",
		minimum_distance = 10000,
		steam_stats_name = "longest-train-path",
		icon = "__MxlChievements2__/graphics/rails-1.png",
		icon_size = 128
    },
	{
		type = "train-path-achievement",
		name = "train-madness-2",
		order = "u",
		minimum_distance = 50000,
		steam_stats_name = "longest-train-path",
		icon = "__MxlChievements2__/graphics/rails-1.png",
		icon_size = 128
    },
	{
		type = "train-path-achievement",
		name = "train-madness-3",
		order = "u",
		minimum_distance = 100000,
		steam_stats_name = "longest-train-path",
		icon = "__MxlChievements2__/graphics/rails-1.png",
		icon_size = 128
    },
	{
		type = "train-path-achievement",
		name = "train-madness-4",
		order = "u",
		minimum_distance = 250000,
		steam_stats_name = "longest-train-path",
		icon = "__MxlChievements2__/graphics/rails-1.png",
		icon_size = 128
    },
	{
		type = "train-path-achievement",
		name = "train-madness-5",
		order = "u",
		minimum_distance = 1000000,
		steam_stats_name = "longest-train-path",
		icon = "__MxlChievements2__/graphics/rails-1.png",
		icon_size = 128
    },
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "car-production-2",
		order = "u",
		item_product = "car",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/car.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "tank-production-2",
		order = "u",
		item_product = "tank",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/tank.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "locomotive-production-2",
		order = "u",
		item_product = "locomotive",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/locomotive.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "car-production-3",
		order = "u",
		item_product = "car",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/car.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "tank-production-3",
		order = "u",
		item_product = "tank",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/tank.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "locomotive-production-3",
		order = "u",
		item_product = "locomotive",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/locomotive.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "burner-inserter-1",
		order = "u",
		item_product = "burner-inserter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/burner-inserter.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "burner-inserter-2",
		order = "u",
		item_product = "burner-inserter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/burner-inserter.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "burner-inserter-3",
		order = "u",
		item_product = "burner-inserter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/burner-inserter.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "long-handed-inserter-1",
		order = "u",
		item_product = "long-handed-inserter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/long-handed-inserter.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "long-handed-inserter-2",
		order = "u",
		item_product = "long-handed-inserter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/long-handed-inserter.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "long-handed-inserter-3",
		order = "u",
		item_product = "long-handed-inserter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/long-handed-inserter.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "stack-inserter-1",
		order = "u",
		item_product = "stack-inserter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stack-inserter.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stack-inserter-2",
		order = "u",
		item_product = "stack-inserter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stack-inserter.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stack-inserter-3",
		order = "u",
		item_product = "stack-inserter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stack-inserter.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "firearm-magazine-1",
		order = "u",
		item_product = "firearm-magazine",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/firearm-magazine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "firearm-magazine-2",
		order = "u",
		item_product = "firearm-magazine",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/firearm-magazine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "firearm-magazine-3",
		order = "u",
		item_product = "firearm-magazine",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/firearm-magazine.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "piercing-rounds-magazine-1",
		order = "u",
		item_product = "piercing-rounds-magazine",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/piercing-rounds-magazine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "piercing-rounds-magazine-2",
		order = "u",
		item_product = "piercing-rounds-magazine",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/piercing-rounds-magazine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "piercing-rounds-magazine-3",
		order = "u",
		item_product = "piercing-rounds-magazine",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/piercing-rounds-magazine.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "uranium-rounds-magazine-1",
		order = "u",
		item_product = "uranium-rounds-magazine",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-rounds-magazine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "uranium-rounds-magazine-2",
		order = "u",
		item_product = "uranium-rounds-magazine",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-rounds-magazine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "uranium-rounds-magazine-3",
		order = "u",
		item_product = "uranium-rounds-magazine",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-rounds-magazine.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "gun-turret-1",
		order = "u",
		item_product = "gun-turret",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gun-turret.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "gun-turret-2",
		order = "u",
		item_product = "gun-turret",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gun-turret.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "gun-turret-3",
		order = "u",
		item_product = "gun-turret",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/gun-turret.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "laser-turret-1",
		order = "u",
		item_product = "laser-turret",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/laser-turret.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "laser-turret-2",
		order = "u",
		item_product = "laser-turret",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/laser-turret.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "laser-turret-3",
		order = "u",
		item_product = "laser-turret",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/laser-turret.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "flamethrower-turret-1",
		order = "u",
		item_product = "flamethrower-turret",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/flamethrower-turret.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "flamethrower-turret-2",
		order = "u",
		item_product = "flamethrower-turret",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/flamethrower-turret.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "flamethrower-turret-3",
		order = "u",
		item_product = "flamethrower-turret",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/flamethrower-turret.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "artillery-turret-1",
		order = "u",
		item_product = "artillery-turret",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/artillery-turret.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "artillery-turret-2",
		order = "u",
		item_product = "artillery-turret",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/artillery-turret.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "artillery-turret-3",
		order = "u",
		item_product = "artillery-turret",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/artillery-turret.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "pipe-to-ground-1",
		order = "u",
		item_product = "pipe-to-ground",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/pipe-to-ground.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "pipe-to-ground-2",
		order = "u",
		item_product = "pipe-to-ground",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/pipe-to-ground.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "pipe-to-ground-3",
		order = "u",
		item_product = "pipe-to-ground",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/pipe-to-ground.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "rail-signal-1",
		order = "u",
		item_product = "rail-signal",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rail-signal.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "rail-signal-2",
		order = "u",
		item_product = "rail-signal",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rail-signal.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "rail-signal-3",
		order = "u",
		item_product = "rail-signal",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rail-signal.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "rail-chain-signal-1",
		order = "u",
		item_product = "rail-chain-signal",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rail-chain-signal.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "rail-chain-signal-2",
		order = "u",
		item_product = "rail-chain-signal",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rail-chain-signal.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "rail-chain-signal-3",
		order = "u",
		item_product = "rail-chain-signal",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rail-chain-signal.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "storage-tank-1",
		order = "u",
		item_product = "storage-tank",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/storage-tank.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "storage-tank-2",
		order = "u",
		item_product = "storage-tank",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/storage-tank.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "storage-tank-3",
		order = "u",
		item_product = "storage-tank",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/storage-tank.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "pumpjack-1",
		order = "u",
		item_product = "pumpjack",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/pumpjack.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "pumpjack-2",
		order = "u",
		item_product = "pumpjack",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/pumpjack.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "pumpjack-3",
		order = "u",
		item_product = "pumpjack",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/pumpjack.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "stone-furnace-1",
		order = "u",
		item_product = "stone-furnace",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stone-furnace.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stone-furnace-2",
		order = "u",
		item_product = "stone-furnace",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stone-furnace.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stone-furnace-3",
		order = "u",
		item_product = "stone-furnace",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stone-furnace.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "steel-furnace-1",
		order = "u",
		item_product = "steel-furnace",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steel-furnace.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "steel-furnace-2",
		order = "u",
		item_product = "steel-furnace",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steel-furnace.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "steel-furnace-3",
		order = "u",
		item_product = "steel-furnace",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steel-furnace.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "oil-refinery-1",
		order = "u",
		item_product = "oil-refinery",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/oil-refinery.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "oil-refinery-2",
		order = "u",
		item_product = "oil-refinery",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/oil-refinery.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "oil-refinery-3",
		order = "u",
		item_product = "oil-refinery",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/oil-refinery.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "chemical-plant-1",
		order = "u",
		item_product = "chemical-plant",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/chemical-plant.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "chemical-plant-2",
		order = "u",
		item_product = "chemical-plant",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/chemical-plant.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "chemical-plant-3",
		order = "u",
		item_product = "chemical-plant",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/chemical-plant.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "centrifuge-1",
		order = "u",
		item_product = "centrifuge",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/centrifuge.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "centrifuge-2",
		order = "u",
		item_product = "centrifuge",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/centrifuge.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "centrifuge-3",
		order = "u",
		item_product = "centrifuge",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/centrifuge.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "heat-pipe-1",
		order = "u",
		item_product = "heat-pipe",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/heat-pipe.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "heat-pipe-2",
		order = "u",
		item_product = "heat-pipe",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/heat-pipe.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "heat-pipe-3",
		order = "u",
		item_product = "heat-pipe",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/heat-pipe.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "heat-exchanger-1",
		order = "u",
		item_product = "heat-exchanger",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/heat-exchanger.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "heat-exchanger-2",
		order = "u",
		item_product = "heat-exchanger",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/heat-exchanger.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "heat-exchanger-3",
		order = "u",
		item_product = "heat-exchanger",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/heat-exchanger.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "boiler-1",
		order = "u",
		item_product = "boiler",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/boiler.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "boiler-2",
		order = "u",
		item_product = "boiler",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/boiler.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "boiler-3",
		order = "u",
		item_product = "boiler",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/boiler.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "steam-turbine-1",
		order = "u",
		item_product = "steam-turbine",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steam-turbine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "steam-turbine-2",
		order = "u",
		item_product = "steam-turbine",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steam-turbine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "steam-turbine-3",
		order = "u",
		item_product = "steam-turbine",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steam-turbine.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "steam-engine-1",
		order = "u",
		item_product = "steam-engine",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steam-engine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "steam-engine-2",
		order = "u",
		item_product = "steam-engine",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steam-engine.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "steam-engine-3",
		order = "u",
		item_product = "steam-engine",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/steam-engine.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "nuclear-reactor-1",
		order = "u",
		item_product = "nuclear-reactor",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/nuclear-reactor.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "nuclear-reactor-2",
		order = "u",
		item_product = "nuclear-reactor",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/nuclear-reactor.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "nuclear-reactor-3",
		order = "u",
		item_product = "nuclear-reactor",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/nuclear-reactor.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "low-density-structure-1",
		order = "u",
		item_product = "low-density-structure",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/low-density-structure.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "low-density-structure-2",
		order = "u",
		item_product = "low-density-structure",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/low-density-structure.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "low-density-structure-3",
		order = "u",
		item_product = "low-density-structure",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/low-density-structure.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "battery-1",
		order = "u",
		item_product = "battery",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/battery.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "battery-2",
		order = "u",
		item_product = "battery",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/battery.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "battery-3",
		order = "u",
		item_product = "battery",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/battery.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "solid-fuel-1",
		order = "u",
		item_product = "solid-fuel",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/solid-fuel.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "solid-fuel-2",
		order = "u",
		item_product = "solid-fuel",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/solid-fuel.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "solid-fuel-3",
		order = "u",
		item_product = "solid-fuel",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/solid-fuel.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "rocket-fuel-1",
		order = "u",
		item_product = "rocket-fuel",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rocket-fuel.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "rocket-fuel-2",
		order = "u",
		item_product = "rocket-fuel",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rocket-fuel.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "rocket-fuel-3",
		order = "u",
		item_product = "rocket-fuel",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/rocket-fuel.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "nuclear-fuel-1",
		order = "u",
		item_product = "nuclear-fuel",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/nuclear-fuel.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "nuclear-fuel-2",
		order = "u",
		item_product = "nuclear-fuel",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/nuclear-fuel.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "nuclear-fuel-3",
		order = "u",
		item_product = "nuclear-fuel",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/nuclear-fuel.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "stone-wall-1",
		order = "u",
		item_product = "stone-wall",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stone-wall.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stone-wall-2",
		order = "u",
		item_product = "stone-wall",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stone-wall.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stone-wall-3",
		order = "u",
		item_product = "stone-wall",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/stone-wall.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "artillery-shell-1",
		order = "u",
		item_product = "artillery-shell",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/artillery-shell.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "artillery-shell-2",
		order = "u",
		item_product = "artillery-shell",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/artillery-shell.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "artillery-shell-3",
		order = "u",
		item_product = "artillery-shell",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/artillery-shell.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "explosives-1",
		order = "u",
		item_product = "explosives",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/explosives.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "explosives-2",
		order = "u",
		item_product = "explosives",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/explosives.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "explosives-3",
		order = "u",
		item_product = "explosives",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/explosives.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "uranium-fuel-cell-1",
		order = "u",
		item_product = "uranium-fuel-cell",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-fuel-cell.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "uranium-fuel-cell-2",
		order = "u",
		item_product = "uranium-fuel-cell",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-fuel-cell.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "uranium-fuel-cell-3",
		order = "u",
		item_product = "uranium-fuel-cell",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/uranium-fuel-cell.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "sulfur-1",
		order = "u",
		item_product = "sulfur",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/sulfur.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "sulfur-2",
		order = "u",
		item_product = "sulfur",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/sulfur.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "sulfur-3",
		order = "u",
		item_product = "sulfur",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/sulfur.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "speed-module-1-1",
		order = "u",
		item_product = "speed-module",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "speed-module-1-2",
		order = "u",
		item_product = "speed-module",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "speed-module-1-3",
		order = "u",
		item_product = "speed-module",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-1.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "speed-module-2-1",
		order = "u",
		item_product = "speed-module-2",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "speed-module-2-2",
		order = "u",
		item_product = "speed-module-2",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "speed-module-2-3",
		order = "u",
		item_product = "speed-module-2",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-2.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "speed-module-3-1",
		order = "u",
		item_product = "speed-module-3",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-3.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "speed-module-3-2",
		order = "u",
		item_product = "speed-module-3",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-3.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "speed-module-3-3",
		order = "u",
		item_product = "speed-module-3",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/speed-module-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "productivity-module-3-1",
		order = "u",
		item_product = "productivity-module-3",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-3.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "productivity-module-3-2",
		order = "u",
		item_product = "productivity-module-3",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-3.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "productivity-module-3-3",
		order = "u",
		item_product = "productivity-module-3",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-3.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "productivity-module-1-1",
		order = "u",
		item_product = "productivity-module",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "productivity-module-1-2",
		order = "u",
		item_product = "productivity-module",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-1.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "productivity-module-1-3",
		order = "u",
		item_product = "productivity-module",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-1.png",
		icon_size = 128
	},
}
mxl_extend{
	{
		type = "produce-achievement",
		name = "productivity-module-2-1",
		order = "u",
		item_product = "productivity-module-2",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "productivity-module-2-2",
		order = "u",
		item_product = "productivity-module-2",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-2.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "productivity-module-2-3",
		order = "u",
		item_product = "productivity-module-2",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/productivity-module-2.png",
		icon_size = 128
	},
}
mxl_extend{
    -- Turbo Transport Belt
    {
        type = "produce-achievement",
        name = "turbo-transport-belt-1",
        order = "u",
        item_product = "turbo-transport-belt",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "turbo-transport-belt-2",
        order = "u",
        item_product = "turbo-transport-belt",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "turbo-transport-belt-3",
        order = "u",
        item_product = "turbo-transport-belt",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
	-- Turbo Underground Belt Achievements
	{
		type = "produce-achievement",
		name = "turbo-underground-belt-1",
		order = "u",
		item_product = "turbo-underground-belt",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "turbo-underground-belt-2",
		order = "u",
		item_product = "turbo-underground-belt",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base-silver.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "turbo-underground-belt-3",
		order = "u",
		item_product = "turbo-underground-belt",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base-gold.png",
		icon_size = 128
	},

	-- Turbo Splitter Achievements
	{
		type = "produce-achievement",
		name = "turbo-splitter-1",
		order = "u",
		item_product = "turbo-splitter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "turbo-splitter-2",
		order = "u",
		item_product = "turbo-splitter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base-silver.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "turbo-splitter-3",
		order = "u",
		item_product = "turbo-splitter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base-gold.png",
		icon_size = 128
	},

	-- Stack Inserter Achievements
	{
		type = "produce-achievement",
		name = "stack-inserter-1",
		order = "u",
		item_product = "stack-inserter",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stack-inserter-2",
		order = "u",
		item_product = "stack-inserter",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base-silver.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "stack-inserter-3",
		order = "u",
		item_product = "stack-inserter",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base-gold.png",
		icon_size = 128
	},

	-- Selector Combinator Achievements
	{
		type = "produce-achievement",
		name = "selector-combinator-1",
		order = "u",
		item_product = "selector-combinator",
		amount = 1000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "selector-combinator-2",
		order = "u",
		item_product = "selector-combinator",
		amount = 1000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base-silver.png",
		icon_size = 128
	},
	{
		type = "produce-achievement",
		name = "selector-combinator-3",
		order = "u",
		item_product = "selector-combinator",
		amount = 1000000000000,
		limited_to_one_game = false,
		icon = "__MxlChievements2__/graphics/base-gold.png",
		icon_size = 128
	},
}
mxl_extend{
    --=== Soil Types ===--
    -- Artificial Yumako Soil
    {
        type = "produce-achievement",
        name = "artificial-yumako-soil-1",
        order = "u",
        item_product = "artificial-yumako-soil",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "artificial-yumako-soil-2",
        order = "u",
        item_product = "artificial-yumako-soil",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "artificial-yumako-soil-3",
        order = "u",
        item_product = "artificial-yumako-soil",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Overgrowth Yumako Soil
    {
        type = "produce-achievement",
        name = "overgrowth-yumako-soil-1",
        order = "u",
        item_product = "overgrowth-yumako-soil",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "overgrowth-yumako-soil-2",
        order = "u",
        item_product = "overgrowth-yumako-soil",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "overgrowth-yumako-soil-3",
        order = "u",
        item_product = "overgrowth-yumako-soil",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Artificial Jellynut Soil
    {
        type = "produce-achievement",
        name = "artificial-jellynut-soil-1",
        order = "u",
        item_product = "artificial-jellynut-soil",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "artificial-jellynut-soil-2",
        order = "u",
        item_product = "artificial-jellynut-soil",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "artificial-jellynut-soil-3",
        order = "u",
        item_product = "artificial-jellynut-soil",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Overgrowth Jellynut Soil
    {
        type = "produce-achievement",
        name = "overgrowth-jellynut-soil-1",
        order = "u",
        item_product = "overgrowth-jellynut-soil",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "overgrowth-jellynut-soil-2",
        order = "u",
        item_product = "overgrowth-jellynut-soil",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "overgrowth-jellynut-soil-3",
        order = "u",
        item_product = "overgrowth-jellynut-soil",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },
}
mxl_extend{
    -- Ice Platform
    {
        type = "produce-achievement",
        name = "ice-platform-1",
        order = "u",
        item_product = "ice-platform",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "ice-platform-2",
        order = "u",
        item_product = "ice-platform",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "ice-platform-3",
        order = "u",
        item_product = "ice-platform",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Foundation (Note: Fixed "foundation" spelling from original "foundation")
    {
        type = "produce-achievement",
        name = "foundation-1",
        order = "u",
        item_product = "foundation",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "foundation-2",
        order = "u",
        item_product = "foundation",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "foundation-3",  -- Note: Kept original name but fixed item_product
        order = "u",
        item_product = "foundation",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Cliff Explosives
    {
        type = "produce-achievement",
        name = "cliff-explosives-1",
        order = "u",
        item_product = "cliff-explosives",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "cliff-explosives-2",
        order = "u",
        item_product = "cliff-explosives",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "cliff-explosives-3",
        order = "u",
        item_product = "cliff-explosives",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Fusion Generator
    {
        type = "produce-achievement",
        name = "fusion-generator-1",
        order = "u",
        item_product = "fusion-generator",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "fusion-generator-2",
        order = "u",
        item_product = "fusion-generator",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "fusion-generator-3",
        order = "u",
        item_product = "fusion-generator",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Fusion Reactor
    {
        type = "produce-achievement",
        name = "fusion-reactor-1",
        order = "u",
        item_product = "fusion-reactor",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "fusion-reactor-2",
        order = "u",
        item_product = "fusion-reactor",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "fusion-reactor-3",
        order = "u",
        item_product = "fusion-reactor",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Big Mining Drill
    {
        type = "produce-achievement",
        name = "big-mining-drill-1",
        order = "u",
        item_product = "big-mining-drill",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "big-mining-drill-2",
        order = "u",
        item_product = "big-mining-drill",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "big-mining-drill-3",
        order = "u",
        item_product = "big-mining-drill",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Foundry
    {
        type = "produce-achievement",
        name = "foundry-1",
        order = "u",
        item_product = "foundry",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "foundry-2",
        order = "u",
        item_product = "foundry",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "foundry-3",
        order = "u",
        item_product = "foundry",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Recycler
    {
        type = "produce-achievement",
        name = "recycler-1",
        order = "u",
        item_product = "recycler",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "recycler-2",
        order = "u",
        item_product = "recycler",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "recycler-3",
        order = "u",
        item_product = "recycler",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Agricultural Tower
    {
        type = "produce-achievement",
        name = "agricultural-tower-1",
        order = "u",
        item_product = "agricultural-tower",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "agricultural-tower-2",
        order = "u",
        item_product = "agricultural-tower",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "agricultural-tower-3",
        order = "u",
        item_product = "agricultural-tower",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Biochamber
    {
        type = "produce-achievement",
        name = "biochamber-1",
        order = "u",
        item_product = "biochamber",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "biochamber-2",
        order = "u",
        item_product = "biochamber",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "biochamber-3",
        order = "u",
        item_product = "biochamber",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Captive Biter Spawner
    {
        type = "produce-achievement",
        name = "captive-biter-spawner-1",
        order = "u",
        item_product = "captive-biter-spawner",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "captive-biter-spawner-2",
        order = "u",
        item_product = "captive-biter-spawner",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "captive-biter-spawner-3",
        order = "u",
        item_product = "captive-biter-spawner",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Electromagnetic Plant
    {
        type = "produce-achievement",
        name = "electromagnetic-plant-1",
        order = "u",
        item_product = "electromagnetic-plant",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "electromagnetic-plant-2",
        order = "u",
        item_product = "electromagnetic-plant",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "electromagnetic-plant-3",
        order = "u",
        item_product = "electromagnetic-plant",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Cryogenic Plant
    {
        type = "produce-achievement",
        name = "cryogenic-plant-1",
        order = "u",
        item_product = "cryogenic-plant",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "cryogenic-plant-2",
        order = "u",
        item_product = "cryogenic-plant",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "cryogenic-plant-3",
        order = "u",
        item_product = "cryogenic-plant",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Biolab
    {
        type = "produce-achievement",
        name = "biolab-1",
        order = "u",
        item_product = "biolab",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "biolab-2",
        order = "u",
        item_product = "biolab",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "biolab-3",
        order = "u",
        item_product = "biolab",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Lightning Rod
    {
        type = "produce-achievement",
        name = "lightning-rod-1",
        order = "u",
        item_product = "lightning-rod",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "lightning-rod-2",
        order = "u",
        item_product = "lightning-rod",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "lightning-rod-3",
        order = "u",
        item_product = "lightning-rod",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Lightning Collector
    {
        type = "produce-achievement",
        name = "lightning-collector-1",
        order = "u",
        item_product = "lightning-collector",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "lightning-collector-2",
        order = "u",
        item_product = "lightning-collector",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "lightning-collector-3",
        order = "u",
        item_product = "lightning-collector",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Heating Tower
    {
        type = "produce-achievement",
        name = "heating-tower-1",
        order = "u",
        item_product = "heating-tower",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "heating-tower-2",
        order = "u",
        item_product = "heating-tower",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "heating-tower-3",
        order = "u",
        item_product = "heating-tower",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Quality Module
    {
        type = "produce-achievement",
        name = "quality-module-1",
        order = "u",
        item_product = "quality-module",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "quality-module-2",
        order = "u",
        item_product = "quality-module",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "quality-module-3",
        order = "u",
        item_product = "quality-module",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Quality Module 2
    {
        type = "produce-achievement",
        name = "quality-module-2-1",
        order = "u",
        item_product = "quality-module-2",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "quality-module-2-2",
        order = "u",
        item_product = "quality-module-2",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "quality-module-2-3",
        order = "u",
        item_product = "quality-module-2",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Quality Module 3
    {
        type = "produce-achievement",
        name = "quality-module-3-1",
        order = "u",
        item_product = "quality-module-3",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "quality-module-3-2",
        order = "u",
        item_product = "quality-module-3",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "quality-module-3-3",
        order = "u",
        item_product = "quality-module-3",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Spidertron (Note: Achievement names use capital 'S' while product uses lowercase)
    {
        type = "produce-achievement",
        name = "spidertron-1",
        order = "u",
        item_product = "spidertron",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "spidertron-2",
        order = "u",
        item_product = "spidertron",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "spidertron-3",
        order = "u",
        item_product = "spidertron",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Biter Egg
    {
        type = "produce-achievement",
        name = "biter-egg-1",
        order = "u",
        item_product = "biter-egg",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "biter-egg-2",
        order = "u",
        item_product = "biter-egg",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "biter-egg-3",
        order = "u",
        item_product = "biter-egg",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Nutrients
    {
        type = "produce-achievement",
        name = "nutrients-1",
        order = "u",
        item_product = "nutrients",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "nutrients-2",
        order = "u",
        item_product = "nutrients",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "nutrients-3",
        order = "u",
        item_product = "nutrients",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Spoilage
    {
        type = "produce-achievement",
        name = "spoilage-1",
        order = "u",
        item_product = "spoilage",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "spoilage-2",
        order = "u",
        item_product = "spoilage",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "spoilage-3",
        order = "u",
        item_product = "spoilage",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Copper Bacteria
    {
        type = "produce-achievement",
        name = "copper-bacteria-1",
        order = "u",
        item_product = "copper-bacteria",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "copper-bacteria-2",
        order = "u",
        item_product = "copper-bacteria",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "copper-bacteria-3",
        order = "u",
        item_product = "copper-bacteria",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Iron Bacteria
    {
        type = "produce-achievement",
        name = "iron-bacteria-1",
        order = "u",
        item_product = "iron-bacteria",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "iron-bacteria-2",
        order = "u",
        item_product = "iron-bacteria",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "iron-bacteria-3",
        order = "u",
        item_product = "iron-bacteria",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Jellynut
    {
        type = "produce-achievement",
        name = "jellynut-1",
        order = "u",
        item_product = "jellynut",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "jellynut-2",
        order = "u",
        item_product = "jellynut",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "jellynut-3",
        order = "u",
        item_product = "jellynut",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Yumako (Note: Achievement names use capital 'Y' while product uses lowercase)
    {
        type = "produce-achievement",
        name = "yumako-1",
        order = "u",
        item_product = "yumako",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "yumako-2",
        order = "u",
        item_product = "yumako",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "yumako-3",
        order = "u",
        item_product = "yumako",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Tree Seed
    {
        type = "produce-achievement",
        name = "tree-seed-1",
        order = "u",
        item_product = "tree-seed",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "tree-seed-2",
        order = "u",
        item_product = "tree-seed",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "tree-seed-3",
        order = "u",
        item_product = "tree-seed",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Jellynut Seed
    {
        type = "produce-achievement",
        name = "jellynut-seed-1",
        order = "u",
        item_product = "jellynut-seed",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "jellynut-seed-2",
        order = "u",
        item_product = "jellynut-seed",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "jellynut-seed-3",
        order = "u",
        item_product = "jellynut-seed",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Yumako Seed
    {
        type = "produce-achievement",
        name = "yumako-seed-1",
        order = "u",
        item_product = "yumako-seed",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "yumako-seed-2",
        order = "u",
        item_product = "yumako-seed",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "yumako-seed-3",
        order = "u",
        item_product = "yumako-seed",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Carbon Fiber
    {
        type = "produce-achievement",
        name = "carbon-fiber-1",
        order = "u",
        item_product = "carbon-fiber",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "carbon-fiber-2",
        order = "u",
        item_product = "carbon-fiber",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "carbon-fiber-3",
        order = "u",
        item_product = "carbon-fiber",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Jelly
    {
        type = "produce-achievement",
        name = "jelly-1",
        order = "u",
        item_product = "jelly",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "jelly-2",
        order = "u",
        item_product = "jelly",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "jelly-3",
        order = "u",
        item_product = "jelly",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Yumako Mash
    {
        type = "produce-achievement",
        name = "yumako-mash-1",
        order = "u",
        item_product = "yumako-mash",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "yumako-mash-2",
        order = "u",
        item_product = "yumako-mash",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "yumako-mash-3",
        order = "u",
        item_product = "yumako-mash",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Bioflux
    {
        type = "produce-achievement",
        name = "bioflux-1",
        order = "u",
        item_product = "bioflux",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "bioflux-2",
        order = "u",
        item_product = "bioflux",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "bioflux-3",
        order = "u",
        item_product = "bioflux",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Fusion Power Cell
    {
        type = "produce-achievement",
        name = "fusion-power-cell-1",
        order = "u",
        item_product = "fusion-power-cell",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "fusion-power-cell-2",
        order = "u",
        item_product = "fusion-power-cell",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "fusion-power-cell-3",
        order = "u",
        item_product = "fusion-power-cell",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Quantum Processor
    {
        type = "produce-achievement",
        name = "quantum-processor-1",
        order = "u",
        item_product = "quantum-processor",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "quantum-processor-2",
        order = "u",
        item_product = "quantum-processor",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "quantum-processor-3",
        order = "u",
        item_product = "quantum-processor",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Lithium Plate
    {
        type = "produce-achievement",
        name = "lithium-plate-1",
        order = "u",
        item_product = "lithium-plate",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "lithium-plate-2",
        order = "u",
        item_product = "lithium-plate",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "lithium-plate-3",
        order = "u",
        item_product = "lithium-plate",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Lithium
    {
        type = "produce-achievement",
        name = "lithium-1",
        order = "u",
        item_product = "lithium",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "lithium-2",
        order = "u",
        item_product = "lithium",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "lithium-3",
        order = "u",
        item_product = "lithium",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Metallurgic Science Pack
    {
        type = "produce-achievement",
        name = "metallurgic-science-pack-1",
        order = "u",
        item_product = "metallurgic-science-pack",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "metallurgic-science-pack-2",
        order = "u",
        item_product = "metallurgic-science-pack",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "metallurgic-science-pack-3",
        order = "u",
        item_product = "metallurgic-science-pack",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Electromagnetic Science Pack (Note: Fixed hyphen in item_product name)
    {
        type = "produce-achievement",
        name = "electromagnetic-science-pack-1",
        order = "u",
        item_product = "electromagnetic-science-pack",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "electromagnetic-science-pack-2",
        order = "u",
        item_product = "electromagnetic-science-pack",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "electromagnetic-science-pack-3",
        order = "u",
        item_product = "electromagnetic-science-pack",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Agricultural Science Pack
    {
        type = "produce-achievement",
        name = "agricultural-science-pack-1",
        order = "u",
        item_product = "agricultural-science-pack",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "agricultural-science-pack-2",
        order = "u",
        item_product = "agricultural-science-pack",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "agricultural-science-pack-3",
        order = "u",
        item_product = "agricultural-science-pack",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Cryogenic Science Pack
    {
        type = "produce-achievement",
        name = "cryogenic-science-pack-1",
        order = "u",
        item_product = "cryogenic-science-pack",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "cryogenic-science-pack-2",
        order = "u",
        item_product = "cryogenic-science-pack",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "cryogenic-science-pack-3",
        order = "u",
        item_product = "cryogenic-science-pack",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Promethium Science Pack
    {
        type = "produce-achievement",
        name = "promethium-science-pack-1",
        order = "u",
        item_product = "promethium-science-pack",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "promethium-science-pack-2",
        order = "u",
        item_product = "promethium-science-pack",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "promethium-science-pack-3",
        order = "u",
        item_product = "promethium-science-pack",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Scrap
    {
        type = "produce-achievement",
        name = "scrap-1",
        order = "u",
        item_product = "scrap",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "scrap-2",
        order = "u",
        item_product = "scrap",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "scrap-3",
        order = "u",
        item_product = "scrap",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Holmium Ore
    {
        type = "produce-achievement",
        name = "holmium-ore-1",
        order = "u",
        item_product = "holmium-ore",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "holmium-ore-2",
        order = "u",
        item_product = "holmium-ore",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "holmium-ore-3",
        order = "u",
        item_product = "holmium-ore",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Holmium Plate
    {
        type = "produce-achievement",
        name = "holmium-plate-1",
        order = "u",
        item_product = "holmium-plate",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "holmium-plate-2",
        order = "u",
        item_product = "holmium-plate",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "holmium-plate-3",
        order = "u",
        item_product = "holmium-plate",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Superconductor
    {
        type = "produce-achievement",
        name = "superconductor-1",
        order = "u",
        item_product = "superconductor",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "superconductor-2",
        order = "u",
        item_product = "superconductor",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "superconductor-3",
        order = "u",
        item_product = "superconductor",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Supercapacitor
    {
        type = "produce-achievement",
        name = "supercapacitor-1",
        order = "u",
        item_product = "supercapacitor",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "supercapacitor-2",
        order = "u",
        item_product = "supercapacitor",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "supercapacitor-3",
        order = "u",
        item_product = "supercapacitor",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Asteroid Chunk
    {
        type = "produce-achievement",
        name = "metallic-asteroid-chunk-1",
        order = "u",
        item_product = "metallic-asteroid-chunk",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "metallic-asteroid-chunk-2",
        order = "u",
        item_product = "metallic-asteroid-chunk",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "metallic-asteroid-chunk-3",
        order = "u",
        item_product = "metallic-asteroid-chunk",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Carbonic Asteroid Chunk
    {
        type = "produce-achievement",
        name = "carbonic-asteroid-chunk-1",
        order = "u",
        item_product = "carbonic-asteroid-chunk",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "carbonic-asteroid-chunk-2",
        order = "u",
        item_product = "carbonic-asteroid-chunk",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "carbonic-asteroid-chunk-3",
        order = "u",
        item_product = "carbonic-asteroid-chunk",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Oxide Asteroid Chunk
    {
        type = "produce-achievement",
        name = "oxide-asteroid-chunk-1",
        order = "u",
        item_product = "oxide-asteroid-chunk",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "oxide-asteroid-chunk-2",
        order = "u",
        item_product = "oxide-asteroid-chunk",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "oxide-asteroid-chunk-3",
        order = "u",
        item_product = "oxide-asteroid-chunk",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Promethium Asteroid Chunk
    {
        type = "produce-achievement",
        name = "promethium-asteroid-chunk-1",
        order = "u",
        item_product = "promethium-asteroid-chunk",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "promethium-asteroid-chunk-2",
        order = "u",
        item_product = "promethium-asteroid-chunk",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "promethium-asteroid-chunk-3",
        order = "u",
        item_product = "promethium-asteroid-chunk",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Space Platform Foundation
    {
        type = "produce-achievement",
        name = "space-platform-foundation-1",
        order = "u",
        item_product = "space-platform-foundation",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "space-platform-foundation-2",
        order = "u",
        item_product = "space-platform-foundation",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "space-platform-foundation-3",
        order = "u",
        item_product = "space-platform-foundation",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Cargo Bay
    {
        type = "produce-achievement",
        name = "cargo-bay-1",
        order = "u",
        item_product = "cargo-bay",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "cargo-bay-2",
        order = "u",
        item_product = "cargo-bay",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "cargo-bay-3",
        order = "u",
        item_product = "cargo-bay",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Asteroid Collector
    {
        type = "produce-achievement",
        name = "asteroid-collector-1",
        order = "u",
        item_product = "asteroid-collector",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "asteroid-collector-2",
        order = "u",
        item_product = "asteroid-collector",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "asteroid-collector-3",
        order = "u",
        item_product = "asteroid-collector",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Crusher
    {
        type = "produce-achievement",
        name = "crusher-1",
        order = "u",
        item_product = "crusher",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "crusher-2",
        order = "u",
        item_product = "crusher",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "crusher-3",
        order = "u",
        item_product = "crusher",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Thruster
    {
        type = "produce-achievement",
        name = "thruster-1",
        order = "u",
        item_product = "thruster",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "thruster-2",
        order = "u",
        item_product = "thruster",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "thruster-3",
        order = "u",
        item_product = "thruster",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    }
}
mxl_extend{
    -- Rocket Turret
    {
        type = "produce-achievement",
        name = "rocket-turret-1",
        order = "u",
        item_product = "rocket-turret",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "rocket-turret-2",
        order = "u",
        item_product = "rocket-turret",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "rocket-turret-3",
        order = "u",
        item_product = "rocket-turret",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Tesla Turret
    {
        type = "produce-achievement",
        name = "tesla-turret-1",
        order = "u",
        item_product = "tesla-turret",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "tesla-turret-2",
        order = "u",
        item_product = "tesla-turret",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "tesla-turret-3",
        order = "u",
        item_product = "tesla-turret",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Railgun Turret (Note: Fixed typo from "railgun-turret-3" to match pattern)
    {
        type = "produce-achievement",
        name = "railgun-turret-1",
        order = "u",
        item_product = "railgun-turret",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "railgun-turret-2",
        order = "u",
        item_product = "railgun-turret",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "railgun-turret-3",
        order = "u",
        item_product = "railgun-turret",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Tesla Ammo
    {
        type = "produce-achievement",
        name = "tesla-ammo-1",
        order = "u",
        item_product = "tesla-ammo",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "tesla-ammo-2",
        order = "u",
        item_product = "tesla-ammo",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "tesla-ammo-3",
        order = "u",
        item_product = "tesla-ammo",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Railgun Ammo
    {
        type = "produce-achievement",
        name = "railgun-ammo-1",
        order = "u",
        item_product = "railgun-ammo",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "railgun-ammo-2",
        order = "u",
        item_product = "railgun-ammo",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "railgun-ammo-3",
        order = "u",
        item_product = "railgun-ammo",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },

    -- Battery MK3 Equipment
    {
        type = "produce-achievement",
        name = "battery-mk3-equipment-1",
        order = "u",
        item_product = "battery-mk3-equipment",
        amount = 1000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "battery-mk3-equipment-2",
        order = "u",
        item_product = "battery-mk3-equipment",
        amount = 1000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-silver.png",
        icon_size = 128
    },
    {
        type = "produce-achievement",
        name = "battery-mk3-equipment-3",
        order = "u",
        item_product = "battery-mk3-equipment",
        amount = 1000000000000,
        limited_to_one_game = false,
        icon = "__MxlChievements2__/graphics/base-gold.png",
        icon_size = 128
    },
}
