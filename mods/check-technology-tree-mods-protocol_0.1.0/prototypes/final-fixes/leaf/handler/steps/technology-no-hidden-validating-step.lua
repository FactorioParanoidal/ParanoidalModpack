local TechnologyNoHiddenValidatingStep = {}
TechnologyNoHiddenValidatingStep.evaluate = function(technology_name, mode)
	local tree = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)
	if not tree then
		return
	end
	_table.each(tree, function(tree_element_name)
		local modedTreeElement = Utils.getModedObject(data.raw["technology"][tree_element_name], mode)
		if not modedTreeElement or modedTreeElement.hidden then
			error(
				" for tehcnology "
					.. technology_name
					.. " prerequisite called "
					.. tree_element_name
					.. " has HIDDEN or not exists for mode "
					.. mode
			)
		end
	end)
end
return TechnologyNoHiddenValidatingStep
