require("__zzzparanoidal__.paralib")

-- from KaoExtended
paralib.bobmods.lib.tech.add_recipe_unlock("angels-bronze-smelting-1", "bronze-alloy-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-brass-smelting-1", "bob-brass-alloy-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-tungsten-smelting-1", "copper-tungsten-alloy-x")
paralib.bobmods.lib.tech.add_recipe_unlock("bob-tungsten-alloy-processing", "bob-tungsten-carbide-x")
paralib.bobmods.lib.tech.add_recipe_unlock("bob-tungsten-alloy-processing", "bob-tungsten-carbide-2x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-gunmetal-smelting-1", "gunmetal-alloy-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-invar-smelting-1", "bob-invar-alloy-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-nitinol-smelting-1", "nitinol-alloy-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-cobalt-steel-smelting-1", "bob-cobalt-steel-alloy-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-nickel-smelting-1", "bob-nickel-electrolysis-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-zinc-smelting-1", "bob-zinc-electrolysis-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-cobalt-smelting-1", "cobalat-electrolysis-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-titanium-smelting-1", "bob-titanium-electrolysis-x")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-solder-smelting-1", "angel-solder-alloy-x")

--убираем лишние рецепты
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-alloy-processing", "bob-stone-mixing-furnace-from-stone-furnace")
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-alloy-processing", "bob-stone-furnace-from-stone-mixing-furnace")

--разблокируем рецепт для упрощенной плавки бронзы в печах
paralib.bobmods.lib.tech.add_recipe_unlock("angels-bronze-smelting-1", "bob-bronze-alloy")

--bobplates small icon size saves vram
data.raw.technology["bob-fluid-canister-processing"].icon_size = 128
data.raw.technology["bob-fluid-canister-processing"].icon = "__zzzparanoidal__/graphics/bob/fluid-canister.png"
