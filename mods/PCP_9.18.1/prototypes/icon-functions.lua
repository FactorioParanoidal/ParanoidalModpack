local tint_table={
	c={r = 047/255, g = 047/255, b = 047/255}, -- Carbon
	h={r = 255/255, g = 255/255, b = 255/255}, -- Hydrogen
	o={r = 229/255, g = 013/255, b = 013/255}, -- Oxygen
	n={r = 041/255, g = 041/255, b = 180/255}, -- Nitrogen
	l={r = 196/255, g = 248/255, b = 042/255}, -- Chlorine
	m={r = 041/255, g = 041/255, b = 180/255}, -- Complex
	f={r = 233/255, g = 254/255, b = 127/255}, -- Fluoride
	t={r = 192/255, g = 192/255, b = 255/255},-- Steam
	s={r = 115/255, g = 063/255, b = 163/255},-- Sodium
	p={r = 244/255, g = 125/255, b = 001/255},-- Phosphorus
	y={r = 255/255, g = 105/255, b = 180/255},-- Syngas
}
local raw_table={
acetylene={name="gas-acetylene",icon="__PCP__/graphics/icons/raw/acetylene.png",icon_size=72},
alien_acid={name="alien-fire",icon="__bobplates__/graphics/icons/alien/alien-acid.png",icon_size=32},
alien_explosive={name="alien-explosive",icon="__bobplates__/graphics/icons/alien/alien-explosive.png",icon_size=32},
alien_fire={name="alien-fire",icon="__bobplates__/graphics/icons/alien/alien-fire.png",icon_size=32},
alien_poison={name="alien-poison",icon="__bobplates__/graphics/icons/alien/alien-poison.png",icon_size=32},
deuterium={name="deuterium",icon="__bobplates__/graphics/icons/deuterium.png",icon_size=64},
acetone={name="gas-acetone",icon="__PCP__/graphics/icons/raw/acetone.png",icon_size=72},
acid={name="gas-acid",icon="__angelspetrochem__/graphics/icons/gas-acid.png",icon_size=32},
allylchlorid={name="gas-allylchlorid",icon="__PCP__/graphics/icons/raw/allyl-chloride.png",icon_size=72},
ammonia={name="gas-ammonia",icon="__PCP__/graphics/icons/raw/ammonia.png",icon_size=72},
ammonium_chloride={name="gas-ammonium_chloride",icon="__PCP__/graphics/icons/raw/ammonium-chloride.png",icon_size=72},
benzene={name="gas-benzene",icon="__PCP__/graphics/icons/raw/benzene.png",icon_size=72},
bisphenol_a={name="gas-bisphenol-a",icon="__PCP__/graphics/icons/raw/bisphenol-a.png",icon_size=72},
butadiene={name="gas-butadiene",icon="__PCP__/graphics/icons/raw/butadiene.png",icon_size=72},
butane={name="gas-butane",icon="__PCP__/graphics/icons/raw/butane.png",icon_size=72},
carbon_dioxide={name="gas-carbon-dioxide",icon="__PCP__/graphics/icons/raw/carbon-dioxide.png",icon_size=72},
carbon_monoxide={name="gas-carbon_monoxide",icon="__PCP__/graphics/icons/raw/carbon-monoxide.png",icon_size=72},
chlorine={name="gas-chlorine",icon="__PCP__/graphics/icons/raw/chlorine.png",icon_size=72},
chlor_methane={name="gas-chlor-methane",icon="__PCP__/graphics/icons/raw/chloromethane.png",icon_size=72},
compressed_air={name="gas-compressed-air",icon="__angelspetrochem__/graphics/icons/gas-compressed-air.png",icon_size=32},
dimethylamine={name="gas-dimethylamine",icon="__PCP__/graphics/icons/raw/dimethylamine.png",icon_size=72},
dimethylhydrazine={name="gas-dimethylhydrazine",icon="__PCP__/graphics/icons/raw/dimethylhydrazine.png",icon_size=72},
dinitrogen_tetroxide={name="gas-dinitrogen-tetroxide",icon="__PCP__/graphics/icons/raw/dinitrogen-tetroxide.png",icon_size=72},
epichlorhydrin={name="gas-epichlorhydrin",icon="__PCP__/graphics/icons/raw/epichlorohydrin.png",icon_size=72},
ethane={name="gas-ethane",icon="__PCP__/graphics/icons/raw/ethane.png",icon_size=72},
ethylbenzene={name="gas-ethylbenzene",icon="__PCP__/graphics/icons/raw/ethylbenzene.png",icon_size=72},
ethylene={name="gas-ethylene",icon="__PCP__/graphics/icons/raw/ethylene.png",icon_size=72},
formaldehyde={name="gas-formaldehyde",icon="__PCP__/graphics/icons/raw/formaldehyde.png",icon_size=72},
glycerol={name="gas-glycerol",icon="__PCP__/graphics/icons/raw/glycerol.png",icon_size=72},
hydrazine={name="gas-hydrazine",icon="__PCP__/graphics/icons/raw/hydrazine.png",icon_size=72},
hydrogen={name="gas-hydrogen",icon="__PCP__/graphics/icons/raw/hydrogen.png",icon_size=72},
hydrogen_chloride={name="gas-hydrogen-chloride",icon="__PCP__/graphics/icons/raw/hydrogen-chloride.png",icon_size=72},
hydrogen_cyanide={name="gas-hydrogen-cyanide",icon="__PCP__/graphics/icons/raw/hydrogen-cyanide.png",icon_size=72},
hydrogen_peroxide={name="gas-hydrogen-peroxide",icon="__PCP__/graphics/icons/raw/hydrogen-peroxide.png",icon_size=72},
hydrogen_sulfide={name="gas-hydrogen-sulfide",icon="__PCP__/graphics/icons/raw/hydrogen-sulfide.png",icon_size=72},
melamine={name="gas-melamine",icon="__PCP__/graphics/icons/raw/melamine.png",icon_size=72},
methane={name="gas-methane",icon="__PCP__/graphics/icons/raw/methane.png",icon_size=72},
methanol={name="gas-methanol",icon="__PCP__/graphics/icons/raw/methanol.png",icon_size=72},
methylamine={name="gas-methylamine",icon="__PCP__/graphics/icons/raw/methylamine.png",icon_size=72},
monochloramine={name="gas-monochloramine",icon="__PCP__/graphics/icons/raw/chloramine.png",icon_size=72},
natural_1={name="gas-natural-1",icon="__angelspetrochem__/graphics/icons/gas-raw-1.png",icon_size=32},
nitric_oxide={name="gas-nitric-oxide",icon="__PCP__/graphics/icons/raw/nitric-oxide.png",icon_size=72},
nitrogen={name="gas-nitrogen",icon="__PCP__/graphics/icons/raw/nitrogen.png",icon_size=72},
nitrogen_dioxide={name="gas-nitrogen-dioxide",icon="__PCP__/graphics/icons/raw/nitrogen-dioxide.png",icon_size=72},
nitrogen_monoxide={name="gas-nitrogen-monoxide",icon="__PCP__/graphics/icons/raw/nitric-oxide.png",icon_size=72},
nitrous_oxide={name="gas-nitrous-oxide",icon="__PCP__/graphics/icons/raw/nitrous-oxide.png",icon_size=72},
oxygen={name="gas-oxygen",icon="__PCP__/graphics/icons/raw/oxygen.png",icon_size=72},
phenol={name="gas-phenol",icon="__PCP__/graphics/icons/raw/phenol.png",icon_size=72},
phosgene={name="gas-phosgene",icon="__PCP__/graphics/icons/raw/phosgene.png",icon_size=72},
polyethylene={name="gas-polyethylene",icon="__PCP__/graphics/icons/raw/polyethylen.png",icon_size=72},
propene={name="gas-propene",icon="__PCP__/graphics/icons/raw/propylene.png",icon_size=72},
raw_1={name="gas-raw-1",icon="__angelspetrochem__/graphics/icons/gas-raw-2.png",icon_size=32},
residual={name="gas-residual",icon="__angelspetrochem__/graphics/icons/gas-residual.png",icon_size=32},
styrene={name="gas-styrene",icon="__PCP__/graphics/icons/raw/styrene.png",icon_size=72},
sulfur_dioxide={name="gas-sulfur-dioxide",icon="__PCP__/graphics/icons/raw/sulfur-dioxide.png",icon_size=72},
synthesis={name="gas-synthesis",icon="__angelspetrochem__/graphics/icons/gas-synthesis.png",icon_size=32},
urea={name="gas-urea",icon="__PCP__/graphics/icons/raw/urea.png",icon_size=72},
vinyl_chloride={name="gas-vinyl-chloride",icon="__PCP__/graphics/icons/raw/vinyl-chloride.png",icon_size=72},
vinyl_acetylene={name="gas-vinyl-acetylene",icon="__PCP__/graphics/icons/raw/vinyl-acetylene.png",icon_size=72},
heavy_water={name="heavy-water",icon="__bobplates__/graphics/icons/heavy-water.png",icon_size=64},
acetone_cyanohydrin={name="liquid-acetone-cyanohydrin",icon="__PCP__/graphics/icons/raw/acetone-cyanohydrin.png",icon_size=72},
acrylonitrile={name="liquid-acrylonitrile",icon="__PCP__/graphics/icons/raw/acrylonitrile.png",icon_size=72},
aqueous_sodium_hydroxide={name="liquid-aqueous-sodium-hydroxide",icon="__angelspetrochem__/graphics/icons/liquid-aqueous-sodium-hydroxide.png",icon_size=32},
chlorobutadiene={name="liquid-chlorobutadiene",icon="__PCP__/graphics/icons/raw/chloroprene.png",icon_size=72},
condensates={name="liquid-condensates",icon="__angelspetrochem__/graphics/icons/liquid-condensates.png",icon_size=32},
cupric_chloride_solution={name="cupric-chloride-solution",icon="__angelspetrochem__/graphics/icons/liquid-cupric-chloride-solution.png",icon_size=32},
dichlorobutene={name="liquid-dichlorobutene",icon="__PCP__/graphics/icons/raw/dichlorobutene.png",icon_size=72},
ferric_chloride_solution={name="liquid-ferric-chloride-solution",icon="__angelspetrochem__/graphics/icons/liquid-ferric-chloride-solution.png",icon_size=32},
fuel_oil={name="liquid-fuel-oil",icon="__angelspetrochem__/graphics/icons/liquid-fuel-oil.png",icon_size=32},
hydrochloric_acid={name="liquid-hydrochloric-acid",icon="__PCP__/graphics/icons/raw/hydrogochloric-acid.png",icon_size=72},
hydrofluoric_acid={name="liquid-hydrofluoric-acid",icon="__PCP__/graphics/icons/raw/hydrofluoric-acid.png",icon_size=72},
lactic_acid={name="liquid-lactic-acid",icon="__PCP__/graphics/icons/raw/lactic-acid.png",icon_size=72},
methyl_methacrylate={name="liquid-methyl-methacrylate",icon="__PCP__/graphics/icons/raw/methyl-methacrylate.png",icon_size=72},
mineral_oil={name="liquid-mineral-oil",icon="__angelspetrochem__/graphics/icons/liquid-mineral-oil.png",icon_size=32},
multi_phase_oil={name="liquid-multi-phase-oil",icon="__angelspetrochem__/graphics/icons/liquid-multi-phase-oil.png",icon_size=32},
naphtha={name="liquid-naphtha",icon="__angelspetrochem__/graphics/icons/liquid-naphtha.png",icon_size=32},
ngl={name="liquid-ngl",icon="__angelspetrochem__/graphics/icons/liquid-ngl.png",icon_size=32},
nitric_acid={name="liquid-nitric-acid",icon="__PCP__/graphics/icons/raw/nitric-acid.png",icon_size=72},
perchloric_acid={name="liquid-perchloric-acid",icon="__PCP__/graphics/icons/raw/perchloric-acid.png",icon_size=72},
plastic={name="liquid-plastic",icon="__angelspetrochem__/graphics/icons/liquid-plastic.png",icon_size=32},
resin={name="liquid-resin",icon="__angelspetrochem__/graphics/icons/liquid-resin.png",icon_size=32},
rubber={name="liquid-rubber",icon="__angelspetrochem__/graphics/icons/liquid-rubber.png",icon_size=32},
sulfuric_acid={name="liquid-sulfuric-acid",icon="__PCP__/graphics/icons/raw/sulfuric-acid.png",icon_size=72},
toluene={name="liquid-toluene",icon="__angelspetrochem__/graphics/icons/liquid-toluene.png",icon_size=32},
sodium_hypochlorite={name="liquid-sodium-hypochlorite",icon="__PCP__/graphics/icons/raw/sodium-hypochlorite.png",icon_size=72},
ammonium_sulphate={name="solid-ammonium-sulphate",icon="__PCP__/graphics/icons/solid-ammonium-sulphate.png", icon_size=32},
}

local function generate_base_icons(formcode,state) -- uses the slim icon set
	if state=="gas" then
		return
		{
			{
				icon="__PCP__/graphics/icons/gas-base-top.png",
				tint=tint_table[string.sub(formcode,1,1)],
				icon_size=32,
			},
			{
				icon="__PCP__/graphics/icons/gas-base-mid.png",
				tint=tint_table[string.sub(formcode,2,2)],
				icon_size=32,
			},
			{
				icon="__PCP__/graphics/icons/gas-base-bottom.png",
				tint=tint_table[string.sub(formcode,3,3)],
				icon_size=32,
			},
		}
	elseif state=="liq" then -- uses the fatter icon set
		return
		{
			{
				icon="__PCP__/graphics/icons/liq-base-top.png",
				tint=tint_table[string.sub(formcode,1,1)],
				icon_size=32,
			},
			{
				icon="__PCP__/graphics/icons/liq-base-mid.png",
				tint=tint_table[string.sub(formcode,2,2)],
				icon_size=32,
			},
			{
				icon="__PCP__/graphics/icons/liq-base-bottom.png",
				tint=tint_table[string.sub(formcode,3,3)],
				icon_size=32,
			},
		}
	else --things like natural gas, oil, ferric chloride
		return
		{
			{
				icon="__PCP__/graphics/icons/gen-base-top.png",
				tint=tint_table[string.sub(formcode,1,1)],
				icon_size=32,
			},
			{
				icon="__PCP__/graphics/icons/gen-base-mid.png",
				tint=tint_table[string.sub(formcode,2,2)],
				icon_size=32,
			},
			{
				icon="__PCP__/graphics/icons/gen-base-bottom.png",
				tint=tint_table[string.sub(formcode,3,3)],
				icon_size=32,
			},
		}
	end
end
function generate_fluid_icons(fluid,formcode,state) --letter code for table below, no more than 3 letters
	local icons=generate_base_icons(formcode,state)
		chem_icons={icon=raw_table[fluid].icon,icon_size=raw_table[fluid].icon_size,scale=13/raw_table[fluid].icon_size,shift = {-11, -11}}
		table.insert(icons, chem_icons)
	return icons
end
function generate_fluid_recipe_icons(fluid,formcode,state)
	local icons=generate_base_icons(formcode,state)
	chem_icons={icon=raw_table[fluid].icon,icon_size=raw_table[fluid].icon_size,scale=13/raw_table[fluid].icon_size,shift = {-11, 11}}
	table.insert(icons, chem_icons)
	return icons
end
function generate_complex_fluid_recipe_icons(product1,formcode,state,product2,product3,input1,input2)
	local icons=generate_base_icons(formcode,state)
	local chem_icons={icon=raw_table[product1].icon,icon_size=raw_table[product1].icon_size,scale=10/raw_table[product1].icon_size,shift = {-12, 12}}
		table.insert(icons, chem_icons)
	if string.len(product2)>0 then
		chem_icons={icon=raw_table[product2].icon,icon_size=raw_table[product2].icon_size,scale=10/raw_table[product2].icon_size,shift = {12, 12}}
		table.insert(icons, chem_icons)
	end
	if  string.len(product3)>0 then
		chem_icons={icon=raw_table[product3].icon,icon_size=raw_table[product3].icon_size,scale=10/raw_table[product3].icon_size,shift = {0, 12}}
		table.insert(icons, chem_icons)
	end
	if  string.len(input1)>0 then
		chem_icons={icon=raw_table[input1].icon,icon_size=raw_table[input1].icon_size,scale=10/raw_table[input1].icon_size,shift = {-12, -12}}
		table.insert(icons, chem_icons)
	end
	if  string.len(input2)>0 then
		chem_icons={icon=raw_table[input2].icon,icon_size=raw_table[input2].icon_size,scale=10/raw_table[input2].icon_size,shift = {12, -12}}
		table.insert(icons, chem_icons)
	end
return icons
end
function gen_custom_fluid_icons(icon,icon_size,formcode,state)
	-- icon is the icon location as a string, for example "__PCP__/graphics/icons/solid-ammonium-sulphate.png" (REQUIRED)
	-- icon_size is a number, default is 32 (REQUIRED)
	-- formcode is in relation to the tint_table, 3 letter code in string format for the colours used in the icon, eg "cho" (REQUIRED)
	-- state, picks the icon set, can be either "gas", "liquid" or empty
	local icons=generate_base_icons(formcode,state)
	chem_icons={icon=icon,icon_size=icon_size,scale=13/icon_size,shift={-11,-11}}
	table.insert(icons,chem_icons)
	return icons
end
function gen_custom_fluid_recipe_icons(icon,icon_size,formcode,state)
	local icons=generate_base_icons(formcode,state)
	chem_icons={icon=icon,icon_size=icon_size,scale=13/icon_size,shift={-11,11}}
	table.insert(icons,chem_icons)
	return icons
end
