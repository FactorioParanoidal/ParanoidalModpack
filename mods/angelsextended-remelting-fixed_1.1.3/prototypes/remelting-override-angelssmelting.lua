local OV = angelsmods.functions.OV

OV.add_unlock("angels-solder-smelting-1", "molten-solder-alloy-mixing-1")
OV.add_unlock("angels-solder-smelting-2", "molten-solder-alloy-mixing-2")
OV.add_unlock("angels-solder-smelting-3", "molten-solder-alloy-mixing-3")

OV.add_unlock("angels-steel-smelting-1", "molten-steel-alloy-mixing")

if settings.startup["remelting-smooth-integration"].value then
	--ALUMINIUM
	OV.add_unlock("angels-aluminium-smelting-2", "molten-aluminium-remelting")
	--CHROME
	OV.add_unlock("angels-chrome-smelting-2", "molten-chrome-remelting")
	--COBALT
	OV.add_unlock("angels-cobalt-smelting-2", "molten-cobalt-remelting")
	--COPPER
	OV.add_unlock("angels-copper-smelting-2", "molten-copper-remelting")
	--GLASS
	OV.add_unlock("angels-glass-smelting-2", "molten-glass-remelting")
	--GOLD
	OV.add_unlock("angels-gold-smelting-2", "molten-gold-remelting")
	--IRON
	OV.add_unlock("angels-iron-smelting-2", "molten-iron-remelting")
	--LEAD
	OV.add_unlock("angels-lead-smelting-2", "molten-lead-remelting")
	--MANGANESE
	OV.add_unlock("angels-manganese-smelting-2", "molten-manganese-remelting")
	--NICKEL
	OV.add_unlock("angels-nickel-smelting-2", "molten-nickel-remelting")
	--PLATINUM
	OV.add_unlock("angels-platinum-smelting-2", "molten-platinum-remelting")
	--SILICON
	OV.add_unlock("angels-silicon-smelting-2", "molten-silicon-remelting")
	--SILVER
	OV.add_unlock("angels-silver-smelting-2", "molten-silver-remelting")
	--SOLDER
	OV.add_unlock("angels-solder-smelting-2", "molten-solder-remelting")
	--STEEL
	OV.add_unlock("angels-steel-smelting-2", "molten-steel-remelting")
	--TIN
	OV.add_unlock("angels-tin-smelting-2", "molten-tin-remelting")
	--TITANIUM
	OV.add_unlock("angels-titanium-smelting-2", "molten-titanium-remelting")
	--ZINC
	OV.add_unlock("angels-zinc-smelting-2", "molten-zinc-remelting")
else
	require("prototypes.technology.remelting-technology-optional")

	aragasmods.functions.OV.disable_technology("remelting-tier-4")
	aragasmods.functions.OV.disable_technology("remelting-tier-5")
	aragasmods.functions.OV.disable_technology("remelting-tier-6")
end

--DYNAMIC OVERRIDES
require("prototypes.recipes.remelting-entity-angels")