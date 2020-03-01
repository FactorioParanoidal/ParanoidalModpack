if not KaoExtended then KaoExtended = {} end

-- amount of research pack to complete research (multiple point)
amount = 6
-- amount of research pack to complete automation technology (multiple point)
amount_automation = 2

-- amount of resource multiple (also config in RSO mod)
oreMultiple = 4

-- vanilla resource spawn over angels mod and RSO (may cause error on RSO mod ignore it!)
KaoExtended.vanillaOverAngels = false

	-- override coal resource
	KaoExtended.spawnVanillaCoal = true
	KaoExtended.spawnVanillaStone = false
	KaoExtended.spawnVanillaIron = false
	KaoExtended.spawnVanillaCopper = false
	
-- bob's resource spawn over angels mod and RSO (may cause error on RSO mod ignore it!)
--KaoExtended.bobsOverAngels = true

-- if you update from 0.14.14 you must turn off all below option
-- SETTING BELOW WILL NEED TO NEW GAME OR USING "CTRL + SHIFT + L" IN OLD SAVE TO MATCH RECIPE AND TECHNOLOGY RAW DATA
-- restart my cause your factory to jam or not working in some area.
 
-- enable basic slag processing and prism slag processing
KaoExtended.MoreSlagProcessing = true


-- lower power(nerf) of Quantum module(God)
KaoExtended.OPGodModule = false

-- this setting will make every recipe can use productivity module
-- very extend load time.
KaoExtended.EnableProductivity = true

-- recipe of electronics and module will more complicate
KaoExtended.HarderElectronicsAndModule = true

-- will add "Sturture Components" to craft nearly every machine in game
KaoExtended.HarderSturcture = true
KaoExtended.SilverBateryEverywhere = false
KaoExtended.expendEngineRecipe = true
KaoExtended.HarderAdditionComponent = false

-- will add ore crytal processing must use will angelsrefining
KaoExtended.OreCrystalProcessing = true

-- angels smelting time multiple
KaoExtended.angelsSmeltingTime = 2

-- hard crafting ammo
KaoExtended.hardCraftingAmmo = true
















KaoExtended.oreMultiple = oreMultiple;
KaoExtended.oreMultiple_multiple = oreMultiple / 2;