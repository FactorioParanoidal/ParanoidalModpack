table.insert(
	data.raw.recipe['bauxite-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.3})
	data.raw.recipe['bauxite-ore-processing'].main_product = 'processed-aluminium'
--data.raw.recipe['bauxite-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-aluminium-64.png"
--data.raw.recipe['bauxite-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['chrome-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.3})
	data.raw.recipe['chrome-ore-processing'].main_product = 'processed-chrome'
--data.raw.recipe['chrome-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-chrome-64.png"
--data.raw.recipe['chrome-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['copper-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.6})
	data.raw.recipe['copper-ore-processing'].main_product = 'processed-copper'
--data.raw.recipe['copper-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-copper-64.png"
--data.raw.recipe['copper-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['gold-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.2})
	data.raw.recipe['gold-ore-processing'].main_product = 'processed-gold'
--data.raw.recipe['gold-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-gold-64.png"
--data.raw.recipe['gold-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['iron-ore-processing'].results or {},
	{type="item", name="slag", amount=1, probability=0.6})
	data.raw.recipe['iron-ore-processing'].main_product = 'processed-iron'
--data.raw.recipe['iron-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-iron-64.png"
--data.raw.recipe['iron-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['lead-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.5})
	data.raw.recipe['lead-ore-processing'].main_product = 'processed-lead'
--data.raw.recipe['lead-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-lead-64.png"
--data.raw.recipe['lead-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['manganese-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.3})
	data.raw.recipe['manganese-ore-processing'].main_product = 'processed-manganese'
--data.raw.recipe['manganese-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-manganese-64.png"
--data.raw.recipe['manganese-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['nickel-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.3})
	data.raw.recipe['nickel-ore-processing'].main_product = 'processed-nickel'
--data.raw.recipe['nickel-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-nickel-64.png"
--data.raw.recipe['nickel-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['platinum-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.1})
	data.raw.recipe['platinum-ore-processing'].main_product = 'processed-platinum'
--data.raw.recipe['platinum-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-platinum-64.png"
--data.raw.recipe['platinum-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['silica-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.3})
	data.raw.recipe['silica-ore-processing'].main_product = 'processed-silica'
--data.raw.recipe['silica-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-silica-64.png"
--data.raw.recipe['silica-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['silver-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.2})
	data.raw.recipe['silver-ore-processing'].main_product = 'processed-silver'
--data.raw.recipe['silver-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-silver-64.png"
--data.raw.recipe['silver-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['tin-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.5})
	data.raw.recipe['tin-ore-processing'].main_product = 'processed-tin'
--data.raw.recipe['tin-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-tin-64.png"
--data.raw.recipe['tin-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['titanium-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.2})
	data.raw.recipe['titanium-ore-processing'].main_product = 'processed-titanium'
--data.raw.recipe['titanium-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-titanium-64.png"
--data.raw.recipe['titanium-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['tungsten-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.1})
	data.raw.recipe['tungsten-ore-processing'].main_product = 'processed-tungsten'
--data.raw.recipe['tungsten-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-tungsten-64.png"
--data.raw.recipe['tungsten-ore-processing'].icon_size = 64

table.insert(
	data.raw.recipe['zinc-ore-processing'].results,
	{type="item", name="slag", amount=1, probability=0.3})
	data.raw.recipe['zinc-ore-processing'].main_product = 'processed-zinc'
--data.raw.recipe['zinc-ore-processing'].icon = "__bobicons__/graphics/icons/angelssmelting/processed-zinc-64.png"
--data.raw.recipe['zinc-ore-processing'].icon_size = 64

-- CABLES WIRES
 
data.raw.recipe["angels-wire-coil-tin-converting"].results =
	{
		{type="item", name="tinned-copper-cable", amount=8} --DrD 16 angels-wire-tin
	}

data.raw.recipe["angels-wire-coil-gold-converting"].results =
	{
		{type="item", name="gilded-copper-cable", amount=8} --DrD 16 angels-wire-gold
	}

data.raw.recipe["angels-wire-coil-copper-converting"].results =
	{
		{type="item", name="copper-cable", amount=8} --DrD 16 angels-wire-copper
	}

data.raw.recipe["slag-processing-dissolution"].ingredients =
	{
		{type = "item", name = "slag", amount = 5},
        {type = "fluid", name = "sulfuric-acid", amount = 25} --DrD 15
	}
	
data.raw.recipe["angels-solder"].normal.results =
	{
		{type="item", name="solder", amount=3} --DrD angels-solder
	}
data.raw.recipe["angels-solder"].expensive.results =
	{
		{type="item", name="solder", amount=3} --DrD
	}
data.raw.recipe["angels-roll-solder-converting"].results =
	{
		{type="item", name="solder", amount=8} --DrD 12
	}

--remove OV.disable_recipe({ effects

data.raw.recipe["brass-alloy"].hidden = false
data.raw.recipe["bronze-alloy"].hidden = false
data.raw.recipe["solder-alloy"].hidden = false
data.raw.recipe["solder-alloy-lead"].hidden = false
data.raw.recipe["solder"].hidden = false
data.raw.recipe["cobalt-plate"].hidden = false
data.raw.recipe["cobalt-steel-alloy"].hidden = false
data.raw.recipe["bob-zinc-plate"].hidden = false