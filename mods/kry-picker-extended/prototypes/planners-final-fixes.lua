local Data = require('__kry_stdlib__/stdlib/data/data')

if mods["tile-upgrade-planner-muluna"] then
	table.insert(data.raw["selection-tool"]["tile-upgrade-planner"].flags,"only-in-cursor")
	table.insert(data.raw["selection-tool"]["tile-upgrade-planner"].flags,"not-stackable")
end

-- Sorting for the Picker Blueprint Menu
if settings.startup["picker-planner-sorter"].value then
    local planners = {}
    local plannerTypes = {
        "blueprint", "deconstruction-item","upgrade-item", "blueprint-book", "selection-tool"
    }
    -- "c-a" Vanilla planners
    planners["blueprint"] = "c[automated-construction]-a-a[blueprint]"
    planners["deconstruction-planner"] = "c[automated-construction]-a-b[deconstruction-planner]"
    planners["upgrade-planner"] = "c[automated-construction]-a-c[upgrade-planner]"
    planners["blueprint-book"] = "c[automated-construction]-a-d[blueprint-book]"
	-- "c-b" Tile Upgrade Planner
    planners["tile-upgrade-planner"] = "c[automated-construction]-b-b[tile-upgrade-tool]"
	-- "c-b" Quality Upgrade Planner
    planners["quality-upgrade-planner"] = "c[automated-construction]-b-c[quality-upgrade-planner]"
    -- "c-c" justarandomgeek Wire Stripper
    planners["wirestripper-tool"] = "c[automated-construction]-c-a[wirestripper-tool]"
	-- "c-c" jxy3958's Circuit Wire Eraser
    planners["wire-eraser-tool"] = "c[automated-construction]-c-b[wire-eraser-tool]"
	-- "c-c" Mining Patch Planner
    planners["mining-patch-planner"] = "c[automated-construction]-c-c[mining-patch-planner]"
    planners["mpp-blueprint-belt-planner"] = "c[automated-construction]-c-d[mpp-blueprint-belt-planner]"
	-- "c-c" Resource Compression Planner
    planners["stacked-mining-planner"] = "c[automated-construction]-c-e[stacked-mining-planner]"
	-- "c-c" Rail Signal Planner
    planners["rail-signal-planner"] = "c[automated-construction]-c-f[rail-signal-planner]"
	-- "c-c" Rail Deconstruction Planner
    planners["rdp-segment-planner"] = "c[automated-construction]-c-g[rdp-segment-planner]"
    -- "c-e" Shortcuts for 2.0 planners
    planners["tree-killer"] = "c[automated-construction]-c-e[tree-killer]"
    planners["artillery-jammer-tool"] = "c[automated-construction]-d-a[artillery-jammer]"
    -- "c-d" dbots artillery bombardment remote
    planners["artillery-bombardment-remote"] = "c[automated-construction]-d-b[dumb-bombardment]"
    planners["smart-artillery-bombardment-remote"] = "c[automated-construction]-d-c[smart-bombardment]"
    planners["smart-artillery-exploration-remote"] = "c[automated-construction]-d-d[smart-exploration]"
    -- "c-e" domisum ResourceEraser
    planners["ResourceEraser"] = "c[automated-construction]-e-b[ResourceEraser]"
    -- "c-e" No0Vad planners
    planners["tree-eraser"] = "c[automated-construction]-e-c[tree-eraser]"
    planners["rock-eraser"] = "c[automated-construction]-e-d[rock-eraser]"
    planners["ore-eraser"] = "c[automated-construction]-e-e[ore-eraser]"
    planners["ore-swapper"] = "c[automated-construction]-e-f[ore-swapper]"
    planners["ore-unlimited"] = "c[automated-construction]-e-g[ore-unlimited]"
    -- "c-e" Resource Manager
    planners["resource-manager-mover"] = "c[automated-construction]-e-i[resource-manager-mover]"
    planners["resource-manager-deleter"] = "c[automated-construction]-e-j[resource-manager-deleter]"
    -- "c-e" Ore Patch Organizer
    planners["ore-patch-organizer"] = "c[automated-construction]-e-k[ore-patch-organizer]"
	-- "c-e" Player Entity Eraser Tool
    planners["player-entity-eraser-tool"] = "c[automated-construction]-e-l[player-entity-eraser-tool]"
    -- "c-e" Big Pink Eraser
    planners["big-pink-eraser"] = "c[automated-construction]-e-m[big-pink-eraser]"
	-- "z-a" Module Inserter Simplified planners
	planners["mis-insert-remove-modules"] = "z[module-inserter]-a[remove-modules]"
	for _, item in pairs(data.raw["selection-tool"] or {}) do
		-- look for all Module Inserter Simplified planners
		if item.name:match("^mis%-insert%-") then
			-- skip the module removal planner, we already fixed that
			if item.name == "mis-insert-remove-modules" then goto continue end
			-- grab the name of the original module from the planner
			local module_name = item.name:sub(#"mis-insert-" + 1)
			local orig_module = Data(module_name,"module")
			-- then attempt to apply the original sort order to the planner
			if orig_module:is_valid() and orig_module.order then
				planners[item.name] = "z[module-inserter]-" .. orig_module.order
			else	-- otherwise fallback to the item name at the end of the menu
				planners[item.name] ="z[module-inserter]-z[" .. item.name .. "]"
			end
			::continue::
		end
	end

    for planner, order in pairs(planners) do
        for _, plannerType in pairs(plannerTypes) do
            if Data(planner,plannerType):is_valid() then
                Data(planner,plannerType):set_field("order",order)
            end
        end
    end
end