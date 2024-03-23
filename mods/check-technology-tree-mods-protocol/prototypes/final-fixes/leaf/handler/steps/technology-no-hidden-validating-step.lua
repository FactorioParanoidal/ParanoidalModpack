local TechnologyNoHiddenValidatingStep = {}
TechnologyNoHiddenValidatingStep.evaluate = function(technology_name, mode)
	local tree = EvaluatingStepStatusHolder.get_tree_from_technology_status(mode, technology_name)
	if not tree then
		return
	end
	_table.each(tree, function(tree_element_name)
		local modedTreeElement = Utils.get_moded_object(data.raw["technology"][tree_element_name], mode)
		if
			not modedTreeElement
			or modedTreeElement.hidden
				-- исключаем технические технологии, которые будут являться маркерами при "знакомстве" с базовыми ресурсами
				and not _string.ends_with(tree_element_name, DETECTED_RESOURCE_TECHNOLOGY_SUFFIX)
		then
			EvaluatingStepStatusHolder.print_technology_tree(mode, technology_name)
			error(
				" for technology "
					.. technology_name
					.. " prerequisite called "
					.. tree_element_name
					.. " has HIDDEN or not exists for mode "
					.. mode
					.. ".\nTechnology object is "
					.. mode
					.. Utils.dump_to_console(data.raw["technology"][technology_name])
					.. ".\nTree element for mode "
					.. mode
					.. " is "
					.. Utils.dump_to_console(modedTreeElement)
					.. ".\nTree for technology "
					.. technology_name
					.. " is "
					.. Utils.dump_to_console(tree)
			)
		end
	end)
end
return TechnologyNoHiddenValidatingStep
