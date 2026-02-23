local FluidPermutation = {}

--FluidPermutation.isAvailable = script.active_mods["fluid_permutations"] ~= nil
--FluidPermutation.isAvailable = script.active_mods["fluid_permutations_fixed"] ~= nil
FluidPermutation.isAvailable = remote.interfaces["fluid_permutations"] ~= nil

FluidPermutation.flipRecipe = function(recipeName)
	local v = nil
	local success, ex = pcall(function ()
		v = remote.call("fluid_permutations", "flip_recipe", recipeName)
	end)
	if not success then
		storage.player.print("Kux-BlueprintExtension: Fluid Permutations communication error! see logfile.", Colors.lightred)
		log(ex)
	end
	return iif(success, v, nil )
end

return FluidPermutation