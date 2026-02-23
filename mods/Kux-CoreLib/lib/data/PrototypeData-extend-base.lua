---@diagnostic disable: param-type-mismatch --justification: self

---@class KuxCoreLib.PrototypeData.ExtendInstanceBase
local extendBase = {}

---@type KuxCoreLib.PrototypeData.Extend.Utils
local utils = nil

---@param t KuxCoreLib.PrototypeData.Extend.Utils
function extendBase.setUtils(t)	utils = t end
---------------------------------------------------------------------------------------------------

--- AmbientSound - ambient-sound
---@class KuxCoreLib.PrototypeData.Extent.AmbientSound : data.AmbientSound
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AmbientSound.html)

--- AmbientSound - ambient-sound constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AmbientSound.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AmbientSound
function extendBase:AmbientSound(t)
	local d = utils.merge(self["common"], t, {
		type          = "ambient-sound",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.ambient_sound = extendBase.AmbientSound

--- AnimationPrototype - animation
---@class KuxCoreLib.PrototypeData.Extent.AnimationPrototype : data.AnimationPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AnimationPrototype.html)

--- AnimationPrototype - animation constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AnimationPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AnimationPrototype
function extendBase:AnimationPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "animation",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.animation = extendBase.AnimationPrototype

--- DeliverCategory - deliver-category
---@class KuxCoreLib.PrototypeData.Extent.DeliverCategory : data.DeliverCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DeliverCategory.html)

--- DeliverCategory - deliver-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DeliverCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DeliverCategory
function extendBase:DeliverCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "deliver-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.deliver_category = extendBase.DeliverCategory

--- DeliverImpactCombination - deliver-impact-combination
---@class KuxCoreLib.PrototypeData.Extent.DeliverImpactCombination : data.DeliverImpactCombination
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DeliverImpactCombination.html)

--- DeliverImpactCombination - deliver-impact-combination constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DeliverImpactCombination.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DeliverImpactCombination
function extendBase:DeliverImpactCombination(t)
	local d = utils.merge(self["common"], t, {
		type          = "deliver-impact-combination",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.deliver_impact_combination = extendBase.DeliverImpactCombination

--- EditorControllerPrototype - editor-controller
---@class KuxCoreLib.PrototypeData.Extent.EditorControllerPrototype : data.EditorControllerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/EditorControllerPrototype.html)

--- EditorControllerPrototype - editor-controller constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/EditorControllerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.EditorControllerPrototype
function extendBase:EditorControllerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "editor-controller",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.editor_controller = extendBase.EditorControllerPrototype

--- FontPrototype - font
---@class KuxCoreLib.PrototypeData.Extent.FontPrototype : data.FontPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FontPrototype.html)

--- FontPrototype - font constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FontPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FontPrototype
function extendBase:FontPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "font",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.font = extendBase.FontPrototype

--- GodControllerPrototype - god-controller
---@class KuxCoreLib.PrototypeData.Extent.GodControllerPrototype : data.GodControllerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/GodControllerPrototype.html)

--- GodControllerPrototype - god-controller constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/GodControllerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.GodControllerPrototype
function extendBase:GodControllerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "god-controller",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.god_controller = extendBase.GodControllerPrototype

--- ImpactCategory - impact-category
---@class KuxCoreLib.PrototypeData.Extent.ImpactCategory : data.ImpactCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ImpactCategory.html)

--- ImpactCategory - impact-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ImpactCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ImpactCategory
function extendBase:ImpactCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "impact-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.impact_category = extendBase.ImpactCategory

--- MapGenPresets - map-gen-presets
---@class KuxCoreLib.PrototypeData.Extent.MapGenPresets : data.MapGenPresets
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/MapGenPresets.html)

--- MapGenPresets - map-gen-presets constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/MapGenPresets.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.MapGenPresets
function extendBase:MapGenPresets(t)
	local d = utils.merge(self["common"], t, {
		type          = "map-gen-presets",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.map_gen_presets = extendBase.MapGenPresets

--- MapSettings - map-settings
---@class KuxCoreLib.PrototypeData.Extent.MapSettings : data.MapSettings
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/MapSettings.html)

--- MapSettings - map-settings constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/MapSettings.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.MapSettings
function extendBase:MapSettings(t)
	local d = utils.merge(self["common"], t, {
		type          = "map-settings",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.map_settings = extendBase.MapSettings

--- MouseCursor - mouse-cursor
---@class KuxCoreLib.PrototypeData.Extent.MouseCursor : data.MouseCursor
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/MouseCursor.html)

--- MouseCursor - mouse-cursor constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/MouseCursor.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.MouseCursor
function extendBase:MouseCursor(t)
	local d = utils.merge(self["common"], t, {
		type          = "mouse-cursor",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.mouse_cursor = extendBase.MouseCursor

--- GuiStyle - gui-style
---@class KuxCoreLib.PrototypeData.Extent.GuiStyle : data.GuiStyle
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/GuiStyle.html)

--- GuiStyle - gui-style constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/GuiStyle.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.GuiStyle
function extendBase:GuiStyle(t)
	local d = utils.merge(self["common"], t, {
		type          = "gui-style",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.gui_style = extendBase.GuiStyle

--- AchievementPrototype - achievement
---@class KuxCoreLib.PrototypeData.Extent.AchievementPrototype : data.AchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AchievementPrototype.html)

--- AchievementPrototype - achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AchievementPrototype
function extendBase:AchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.achievement = extendBase.AchievementPrototype

--- CompleteObjectiveAchievementPrototype - complete-objective-achievement
---@class KuxCoreLib.PrototypeData.Extent.CompleteObjectiveAchievementPrototype : data.CompleteObjectiveAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CompleteObjectiveAchievementPrototype.html)

--- CompleteObjectiveAchievementPrototype - complete-objective-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CompleteObjectiveAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CompleteObjectiveAchievementPrototype
function extendBase:CompleteObjectiveAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "complete-objective-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.complete_objective_achievement = extendBase.CompleteObjectiveAchievementPrototype

--- DontBuildEntityAchievementPrototype - dont-build-entity-achievement
---@class KuxCoreLib.PrototypeData.Extent.DontBuildEntityAchievementPrototype : data.DontBuildEntityAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DontBuildEntityAchievementPrototype.html)

--- DontBuildEntityAchievementPrototype - dont-build-entity-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DontBuildEntityAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DontBuildEntityAchievementPrototype
function extendBase:DontBuildEntityAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "dont-build-entity-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.dont_build_entity_achievement = extendBase.DontBuildEntityAchievementPrototype

--- DontCraftManuallyAchievementPrototype - dont-craft-manually-achievement
---@class KuxCoreLib.PrototypeData.Extent.DontCraftManuallyAchievementPrototype : data.DontCraftManuallyAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DontCraftManuallyAchievementPrototype.html)

--- DontCraftManuallyAchievementPrototype - dont-craft-manually-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DontCraftManuallyAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DontCraftManuallyAchievementPrototype
function extendBase:DontCraftManuallyAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "dont-craft-manually-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.dont_craft_manually_achievement = extendBase.DontCraftManuallyAchievementPrototype

--- DontKillManuallyAchievementPrototype - dont-kill-manually-achievement
---@class KuxCoreLib.PrototypeData.Extent.DontKillManuallyAchievementPrototype : data.DontKillManuallyAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DontKillManuallyAchievementPrototype.html)

--- DontKillManuallyAchievementPrototype - dont-kill-manually-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DontKillManuallyAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DontKillManuallyAchievementPrototype
function extendBase:DontKillManuallyAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "dont-kill-manually-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.dont_kill_manually_achievement = extendBase.DontKillManuallyAchievementPrototype

--- DontResearchBeforeResearchingAchievementPrototype - dont-research-before-researching-achievement
---@class KuxCoreLib.PrototypeData.Extent.DontResearchBeforeResearchingAchievementPrototype : data.DontResearchBeforeResearchingAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DontResearchBeforeResearchingAchievementPrototype.html)

--- DontResearchBeforeResearchingAchievementPrototype - dont-research-before-researching-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DontResearchBeforeResearchingAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DontResearchBeforeResearchingAchievementPrototype
function extendBase:DontResearchBeforeResearchingAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "dont-research-before-researching-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.dont_research_before_researching_achievement = extendBase.DontResearchBeforeResearchingAchievementPrototype

--- DontUseEntityInEnergyProductionAchievementPrototype - dont-use-entity-in-energy-production-achievement
---@class KuxCoreLib.PrototypeData.Extent.DontUseEntityInEnergyProductionAchievementPrototype : data.DontUseEntityInEnergyProductionAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DontUseEntityInEnergyProductionAchievementPrototype.html)

--- DontUseEntityInEnergyProductionAchievementPrototype - dont-use-entity-in-energy-production-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DontUseEntityInEnergyProductionAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DontUseEntityInEnergyProductionAchievementPrototype
function extendBase:DontUseEntityInEnergyProductionAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "dont-use-entity-in-energy-production-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.dont_use_entity_in_energy_production_achievement = extendBase.DontUseEntityInEnergyProductionAchievementPrototype

--- BuildEntityAchievementPrototype - build-entity-achievement
---@class KuxCoreLib.PrototypeData.Extent.BuildEntityAchievementPrototype : data.BuildEntityAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BuildEntityAchievementPrototype.html)

--- BuildEntityAchievementPrototype - build-entity-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BuildEntityAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BuildEntityAchievementPrototype
function extendBase:BuildEntityAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "build-entity-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.build_entity_achievement = extendBase.BuildEntityAchievementPrototype

--- ChangedSurfaceAchievementPrototype - change-surface-achievement
---@class KuxCoreLib.PrototypeData.Extent.ChangedSurfaceAchievementPrototype : data.ChangedSurfaceAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ChangedSurfaceAchievementPrototype.html)

--- ChangedSurfaceAchievementPrototype - change-surface-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ChangedSurfaceAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ChangedSurfaceAchievementPrototype
function extendBase:ChangedSurfaceAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "change-surface-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.change_surface_achievement = extendBase.ChangedSurfaceAchievementPrototype

--- CombatRobotCountAchievementPrototype - combat-robot-count-achievement
---@class KuxCoreLib.PrototypeData.Extent.CombatRobotCountAchievementPrototype : data.CombatRobotCountAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CombatRobotCountAchievementPrototype.html)

--- CombatRobotCountAchievementPrototype - combat-robot-count-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CombatRobotCountAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CombatRobotCountAchievementPrototype
function extendBase:CombatRobotCountAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "combat-robot-count-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.combat_robot_count_achievement = extendBase.CombatRobotCountAchievementPrototype

--- ConstructWithRobotsAchievementPrototype - construct-with-robots-achievement
---@class KuxCoreLib.PrototypeData.Extent.ConstructWithRobotsAchievementPrototype : data.ConstructWithRobotsAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ConstructWithRobotsAchievementPrototype.html)

--- ConstructWithRobotsAchievementPrototype - construct-with-robots-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ConstructWithRobotsAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ConstructWithRobotsAchievementPrototype
function extendBase:ConstructWithRobotsAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "construct-with-robots-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.construct_with_robots_achievement = extendBase.ConstructWithRobotsAchievementPrototype

--- CreatePlatformAchievementPrototype - create-platform-achievement
---@class KuxCoreLib.PrototypeData.Extent.CreatePlatformAchievementPrototype : data.CreatePlatformAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CreatePlatformAchievementPrototype.html)

--- CreatePlatformAchievementPrototype - create-platform-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CreatePlatformAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CreatePlatformAchievementPrototype
function extendBase:CreatePlatformAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "create-platform-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.create_platform_achievement = extendBase.CreatePlatformAchievementPrototype

--- DeconstructWithRobotsAchievementPrototype - deconstruct-with-robots-achievement
---@class KuxCoreLib.PrototypeData.Extent.DeconstructWithRobotsAchievementPrototype : data.DeconstructWithRobotsAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DeconstructWithRobotsAchievementPrototype.html)

--- DeconstructWithRobotsAchievementPrototype - deconstruct-with-robots-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DeconstructWithRobotsAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DeconstructWithRobotsAchievementPrototype
function extendBase:DeconstructWithRobotsAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "deconstruct-with-robots-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.deconstruct_with_robots_achievement = extendBase.DeconstructWithRobotsAchievementPrototype

--- DeliverByRobotsAchievementPrototype - deliver-by-robots-achievement
---@class KuxCoreLib.PrototypeData.Extent.DeliverByRobotsAchievementPrototype : data.DeliverByRobotsAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DeliverByRobotsAchievementPrototype.html)

--- DeliverByRobotsAchievementPrototype - deliver-by-robots-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DeliverByRobotsAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DeliverByRobotsAchievementPrototype
function extendBase:DeliverByRobotsAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "deliver-by-robots-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.deliver_by_robots_achievement = extendBase.DeliverByRobotsAchievementPrototype

--- DepleteResourceAchievementPrototype - deplete-resource-achievement
---@class KuxCoreLib.PrototypeData.Extent.DepleteResourceAchievementPrototype : data.DepleteResourceAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DepleteResourceAchievementPrototype.html)

--- DepleteResourceAchievementPrototype - deplete-resource-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DepleteResourceAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DepleteResourceAchievementPrototype
function extendBase:DepleteResourceAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "deplete-resource-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.deplete_resource_achievement = extendBase.DepleteResourceAchievementPrototype

--- DestroyCliffAchievementPrototype - destroy-cliff-achievement
---@class KuxCoreLib.PrototypeData.Extent.DestroyCliffAchievementPrototype : data.DestroyCliffAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DestroyCliffAchievementPrototype.html)

--- DestroyCliffAchievementPrototype - destroy-cliff-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DestroyCliffAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DestroyCliffAchievementPrototype
function extendBase:DestroyCliffAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "destroy-cliff-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.destroy_cliff_achievement = extendBase.DestroyCliffAchievementPrototype

--- EquipArmorAchievementPrototype - equip-armor-achievement
---@class KuxCoreLib.PrototypeData.Extent.EquipArmorAchievementPrototype : data.EquipArmorAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/EquipArmorAchievementPrototype.html)

--- EquipArmorAchievementPrototype - equip-armor-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/EquipArmorAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.EquipArmorAchievementPrototype
function extendBase:EquipArmorAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "equip-armor-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.equip_armor_achievement = extendBase.EquipArmorAchievementPrototype

--- GroupAttackAchievementPrototype - group-attack-achievement
---@class KuxCoreLib.PrototypeData.Extent.GroupAttackAchievementPrototype : data.GroupAttackAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/GroupAttackAchievementPrototype.html)

--- GroupAttackAchievementPrototype - group-attack-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/GroupAttackAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.GroupAttackAchievementPrototype
function extendBase:GroupAttackAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "group-attack-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.group_attack_achievement = extendBase.GroupAttackAchievementPrototype

--- KillAchievementPrototype - kill-achievement
---@class KuxCoreLib.PrototypeData.Extent.KillAchievementPrototype : data.KillAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/KillAchievementPrototype.html)

--- KillAchievementPrototype - kill-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/KillAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.KillAchievementPrototype
function extendBase:KillAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "kill-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.kill_achievement = extendBase.KillAchievementPrototype

--- ModuleTransferAchievementPrototype - module-transfer-achievement
---@class KuxCoreLib.PrototypeData.Extent.ModuleTransferAchievementPrototype : data.ModuleTransferAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ModuleTransferAchievementPrototype.html)

--- ModuleTransferAchievementPrototype - module-transfer-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ModuleTransferAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ModuleTransferAchievementPrototype
function extendBase:ModuleTransferAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "module-transfer-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.module_transfer_achievement = extendBase.ModuleTransferAchievementPrototype

--- PlaceEquipmentAchievementPrototype - place-equipment-achievement
---@class KuxCoreLib.PrototypeData.Extent.PlaceEquipmentAchievementPrototype : data.PlaceEquipmentAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PlaceEquipmentAchievementPrototype.html)

--- PlaceEquipmentAchievementPrototype - place-equipment-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PlaceEquipmentAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PlaceEquipmentAchievementPrototype
function extendBase:PlaceEquipmentAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "place-equipment-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.place_equipment_achievement = extendBase.PlaceEquipmentAchievementPrototype

--- PlayerDamagedAchievementPrototype - player-damaged-achievement
---@class KuxCoreLib.PrototypeData.Extent.PlayerDamagedAchievementPrototype : data.PlayerDamagedAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PlayerDamagedAchievementPrototype.html)

--- PlayerDamagedAchievementPrototype - player-damaged-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PlayerDamagedAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PlayerDamagedAchievementPrototype
function extendBase:PlayerDamagedAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "player-damaged-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.player_damaged_achievement = extendBase.PlayerDamagedAchievementPrototype

--- ProduceAchievementPrototype - produce-achievement
---@class KuxCoreLib.PrototypeData.Extent.ProduceAchievementPrototype : data.ProduceAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ProduceAchievementPrototype.html)

--- ProduceAchievementPrototype - produce-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ProduceAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ProduceAchievementPrototype
function extendBase:ProduceAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "produce-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.produce_achievement = extendBase.ProduceAchievementPrototype

--- ProducePerHourAchievementPrototype - produce-per-hour-achievement
---@class KuxCoreLib.PrototypeData.Extent.ProducePerHourAchievementPrototype : data.ProducePerHourAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ProducePerHourAchievementPrototype.html)

--- ProducePerHourAchievementPrototype - produce-per-hour-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ProducePerHourAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ProducePerHourAchievementPrototype
function extendBase:ProducePerHourAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "produce-per-hour-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.produce_per_hour_achievement = extendBase.ProducePerHourAchievementPrototype

--- ResearchAchievementPrototype - research-achievement
---@class KuxCoreLib.PrototypeData.Extent.ResearchAchievementPrototype : data.ResearchAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ResearchAchievementPrototype.html)

--- ResearchAchievementPrototype - research-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ResearchAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ResearchAchievementPrototype
function extendBase:ResearchAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "research-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.research_achievement = extendBase.ResearchAchievementPrototype

--- ResearchWithSciencePackAchievementPrototype - research-with-science-pack-achievement
---@class KuxCoreLib.PrototypeData.Extent.ResearchWithSciencePackAchievementPrototype : data.ResearchWithSciencePackAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ResearchWithSciencePackAchievementPrototype.html)

--- ResearchWithSciencePackAchievementPrototype - research-with-science-pack-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ResearchWithSciencePackAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ResearchWithSciencePackAchievementPrototype
function extendBase:ResearchWithSciencePackAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "research-with-science-pack-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.research_with_science_pack_achievement = extendBase.ResearchWithSciencePackAchievementPrototype

--- ShootAchievementPrototype - shoot-achievement
---@class KuxCoreLib.PrototypeData.Extent.ShootAchievementPrototype : data.ShootAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ShootAchievementPrototype.html)

--- ShootAchievementPrototype - shoot-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ShootAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ShootAchievementPrototype
function extendBase:ShootAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "shoot-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.shoot_achievement = extendBase.ShootAchievementPrototype

--- SpaceConnectionDistanceTraveledAchievementPrototype - space-connection-distance-traveled-achievement
---@class KuxCoreLib.PrototypeData.Extent.SpaceConnectionDistanceTraveledAchievementPrototype : data.SpaceConnectionDistanceTraveledAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpaceConnectionDistanceTraveledAchievementPrototype.html)

--- SpaceConnectionDistanceTraveledAchievementPrototype - space-connection-distance-traveled-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpaceConnectionDistanceTraveledAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpaceConnectionDistanceTraveledAchievementPrototype
function extendBase:SpaceConnectionDistanceTraveledAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "space-connection-distance-traveled-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.space_connection_distance_traveled_achievement = extendBase.SpaceConnectionDistanceTraveledAchievementPrototype

--- TrainPathAchievementPrototype - train-path-achievement
---@class KuxCoreLib.PrototypeData.Extent.TrainPathAchievementPrototype : data.TrainPathAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TrainPathAchievementPrototype.html)

--- TrainPathAchievementPrototype - train-path-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TrainPathAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TrainPathAchievementPrototype
function extendBase:TrainPathAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "train-path-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.train_path_achievement = extendBase.TrainPathAchievementPrototype

--- UseEntityInEnergyProductionAchievementPrototype - use-entity-in-energy-production-achievement
---@class KuxCoreLib.PrototypeData.Extent.UseEntityInEnergyProductionAchievementPrototype : data.UseEntityInEnergyProductionAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/UseEntityInEnergyProductionAchievementPrototype.html)

--- UseEntityInEnergyProductionAchievementPrototype - use-entity-in-energy-production-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/UseEntityInEnergyProductionAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.UseEntityInEnergyProductionAchievementPrototype
function extendBase:UseEntityInEnergyProductionAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "use-entity-in-energy-production-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.use_entity_in_energy_production_achievement = extendBase.UseEntityInEnergyProductionAchievementPrototype

--- UseItemAchievementPrototype - use-item-achievement
---@class KuxCoreLib.PrototypeData.Extent.UseItemAchievementPrototype : data.UseItemAchievementPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/UseItemAchievementPrototype.html)

--- UseItemAchievementPrototype - use-item-achievement constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/UseItemAchievementPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.UseItemAchievementPrototype
function extendBase:UseItemAchievementPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "use-item-achievement",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.use_item_achievement = extendBase.UseItemAchievementPrototype

--- ChainActiveTriggerPrototype - chain-active-trigger
---@class KuxCoreLib.PrototypeData.Extent.ChainActiveTriggerPrototype : data.ChainActiveTriggerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ChainActiveTriggerPrototype.html)

--- ChainActiveTriggerPrototype - chain-active-trigger constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ChainActiveTriggerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ChainActiveTriggerPrototype
function extendBase:ChainActiveTriggerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "chain-active-trigger",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.chain_active_trigger = extendBase.ChainActiveTriggerPrototype

--- DelayedActiveTriggerPrototype - delayed-active-trigger
---@class KuxCoreLib.PrototypeData.Extent.DelayedActiveTriggerPrototype : data.DelayedActiveTriggerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DelayedActiveTriggerPrototype.html)

--- DelayedActiveTriggerPrototype - delayed-active-trigger constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DelayedActiveTriggerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DelayedActiveTriggerPrototype
function extendBase:DelayedActiveTriggerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "delayed-active-trigger",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.delayed_active_trigger = extendBase.DelayedActiveTriggerPrototype

--- AirbornePollutantPrototype - airborne-pollutant
---@class KuxCoreLib.PrototypeData.Extent.AirbornePollutantPrototype : data.AirbornePollutantPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AirbornePollutantPrototype.html)

--- AirbornePollutantPrototype - airborne-pollutant constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AirbornePollutantPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AirbornePollutantPrototype
function extendBase:AirbornePollutantPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "airborne-pollutant",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.airborne_pollutant = extendBase.AirbornePollutantPrototype

--- AmmoCategory - ammo-category
---@class KuxCoreLib.PrototypeData.Extent.AmmoCategory : data.AmmoCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AmmoCategory.html)

--- AmmoCategory - ammo-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AmmoCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AmmoCategory
function extendBase:AmmoCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "ammo-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.ammo_category = extendBase.AmmoCategory

--- AsteroidChunkPrototype - asteroid-chunk
---@class KuxCoreLib.PrototypeData.Extent.AsteroidChunkPrototype : data.AsteroidChunkPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AsteroidChunkPrototype.html)

--- AsteroidChunkPrototype - asteroid-chunk constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AsteroidChunkPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AsteroidChunkPrototype
function extendBase:AsteroidChunkPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "asteroid-chunk",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.asteroid_chunk = extendBase.AsteroidChunkPrototype

--- AutoplaceControl - autoplace-control
---@class KuxCoreLib.PrototypeData.Extent.AutoplaceControl : data.AutoplaceControl
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AutoplaceControl.html)

--- AutoplaceControl - autoplace-control constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AutoplaceControl.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AutoplaceControl
function extendBase:AutoplaceControl(t)
	local d = utils.merge(self["common"], t, {
		type          = "autoplace-control",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.autoplace_control = extendBase.AutoplaceControl

--- BurnerUsagePrototype - burner-usage
---@class KuxCoreLib.PrototypeData.Extent.BurnerUsagePrototype : data.BurnerUsagePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BurnerUsagePrototype.html)

--- BurnerUsagePrototype - burner-usage constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BurnerUsagePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BurnerUsagePrototype
function extendBase:BurnerUsagePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "burner-usage",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.burner_usage = extendBase.BurnerUsagePrototype

--- CollisionLayerPrototype - collision-layer
---@class KuxCoreLib.PrototypeData.Extent.CollisionLayerPrototype : data.CollisionLayerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CollisionLayerPrototype.html)

--- CollisionLayerPrototype - collision-layer constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CollisionLayerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CollisionLayerPrototype
function extendBase:CollisionLayerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "collision-layer",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.collision_layer = extendBase.CollisionLayerPrototype

--- CustomEventPrototype - custom-event
---@class KuxCoreLib.PrototypeData.Extent.CustomEventPrototype : data.CustomEventPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CustomEventPrototype.html)

--- CustomEventPrototype - custom-event constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CustomEventPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CustomEventPrototype
function extendBase:CustomEventPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "custom-event",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.custom_event = extendBase.CustomEventPrototype

--- CustomInputPrototype - custom-input
---@class KuxCoreLib.PrototypeData.Extent.CustomInputPrototype : data.CustomInputPrototype
---@field [1] string name
---@field [2] string key_sequence
---@field type string?
---@field name string?
---@field key_sequence string?
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CustomInputPrototype.html)

--- CustomInputPrototype - custom-input constructor <br>
--- [1] name, [2] key_sequence, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CustomInputPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CustomInputPrototype
function extendBase:CustomInputPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "custom-input",
		name          = utils.getName(self, t.name or t[1]),
		key_sequence  = t.key_sequence or t[2] or "",
		consuming     = t.consuming or "none",
		-- forced_value -- Only loaded if hidden = true
	})
	data:extend{d}
end
extendBase.custom_input = extendBase.CustomInputPrototype

--- DamageType - damage-type
---@class KuxCoreLib.PrototypeData.Extent.DamageType : data.DamageType
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DamageType.html)

--- DamageType - damage-type constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DamageType.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DamageType
function extendBase:DamageType(t)
	local d = utils.merge(self["common"], t, {
		type          = "damage-type",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.damage_type = extendBase.DamageType

--- DecorativePrototype - optimized-decorative
---@class KuxCoreLib.PrototypeData.Extent.DecorativePrototype : data.DecorativePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DecorativePrototype.html)

--- DecorativePrototype - optimized-decorative constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DecorativePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DecorativePrototype
function extendBase:DecorativePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "optimized-decorative",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.optimized_decorative = extendBase.DecorativePrototype

--- ArrowPrototype - arrow
---@class KuxCoreLib.PrototypeData.Extent.ArrowPrototype : data.ArrowPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ArrowPrototype.html)

--- ArrowPrototype - arrow constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ArrowPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ArrowPrototype
function extendBase:ArrowPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "arrow",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.arrow = extendBase.ArrowPrototype

--- ArtilleryFlarePrototype - artillery-flare
---@class KuxCoreLib.PrototypeData.Extent.ArtilleryFlarePrototype : data.ArtilleryFlarePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ArtilleryFlarePrototype.html)

--- ArtilleryFlarePrototype - artillery-flare constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ArtilleryFlarePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ArtilleryFlarePrototype
function extendBase:ArtilleryFlarePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "artillery-flare",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.artillery_flare = extendBase.ArtilleryFlarePrototype

--- ArtilleryProjectilePrototype - artillery-projectile
---@class KuxCoreLib.PrototypeData.Extent.ArtilleryProjectilePrototype : data.ArtilleryProjectilePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ArtilleryProjectilePrototype.html)

--- ArtilleryProjectilePrototype - artillery-projectile constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ArtilleryProjectilePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ArtilleryProjectilePrototype
function extendBase:ArtilleryProjectilePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "artillery-projectile",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.artillery_projectile = extendBase.ArtilleryProjectilePrototype

--- BeamPrototype - beam
---@class KuxCoreLib.PrototypeData.Extent.BeamPrototype : data.BeamPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BeamPrototype.html)

--- BeamPrototype - beam constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BeamPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BeamPrototype
function extendBase:BeamPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "beam",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.beam = extendBase.BeamPrototype

--- CharacterCorpsePrototype - character-corpse
---@class KuxCoreLib.PrototypeData.Extent.CharacterCorpsePrototype : data.CharacterCorpsePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CharacterCorpsePrototype.html)

--- CharacterCorpsePrototype - character-corpse constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CharacterCorpsePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CharacterCorpsePrototype
function extendBase:CharacterCorpsePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "character-corpse",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.character_corpse = extendBase.CharacterCorpsePrototype

--- CliffPrototype - cliff
---@class KuxCoreLib.PrototypeData.Extent.CliffPrototype : data.CliffPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CliffPrototype.html)

--- CliffPrototype - cliff constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CliffPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CliffPrototype
function extendBase:CliffPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "cliff",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.cliff = extendBase.CliffPrototype

--- CorpsePrototype - corpse
---@class KuxCoreLib.PrototypeData.Extent.CorpsePrototype : data.CorpsePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CorpsePrototype.html)

--- CorpsePrototype - corpse constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CorpsePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CorpsePrototype
function extendBase:CorpsePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "corpse",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.corpse = extendBase.CorpsePrototype

--- RailRemnantsPrototype - rail-remnants
---@class KuxCoreLib.PrototypeData.Extent.RailRemnantsPrototype : data.RailRemnantsPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RailRemnantsPrototype.html)

--- RailRemnantsPrototype - rail-remnants constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RailRemnantsPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RailRemnantsPrototype
function extendBase:RailRemnantsPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rail-remnants",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rail_remnants = extendBase.RailRemnantsPrototype

--- DeconstructibleTileProxyPrototype - deconstructible-tile-proxy
---@class KuxCoreLib.PrototypeData.Extent.DeconstructibleTileProxyPrototype : data.DeconstructibleTileProxyPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DeconstructibleTileProxyPrototype.html)

--- DeconstructibleTileProxyPrototype - deconstructible-tile-proxy constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DeconstructibleTileProxyPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DeconstructibleTileProxyPrototype
function extendBase:DeconstructibleTileProxyPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "deconstructible-tile-proxy",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.deconstructible_tile_proxy = extendBase.DeconstructibleTileProxyPrototype

--- EntityGhostPrototype - entity-ghost
---@class KuxCoreLib.PrototypeData.Extent.EntityGhostPrototype : data.EntityGhostPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/EntityGhostPrototype.html)

--- EntityGhostPrototype - entity-ghost constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/EntityGhostPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.EntityGhostPrototype
function extendBase:EntityGhostPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "entity-ghost",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.entity_ghost = extendBase.EntityGhostPrototype

--- AccumulatorPrototype - accumulator
---@class KuxCoreLib.PrototypeData.Extent.AccumulatorPrototype : data.AccumulatorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AccumulatorPrototype.html)

--- AccumulatorPrototype - accumulator constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AccumulatorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AccumulatorPrototype
function extendBase:AccumulatorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "accumulator",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.accumulator = extendBase.AccumulatorPrototype

--- AgriculturalTowerPrototype - agricultural-tower
---@class KuxCoreLib.PrototypeData.Extent.AgriculturalTowerPrototype : data.AgriculturalTowerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AgriculturalTowerPrototype.html)

--- AgriculturalTowerPrototype - agricultural-tower constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AgriculturalTowerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AgriculturalTowerPrototype
function extendBase:AgriculturalTowerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "agricultural-tower",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.agricultural_tower = extendBase.AgriculturalTowerPrototype

--- ArtilleryTurretPrototype - artillery-turret
---@class KuxCoreLib.PrototypeData.Extent.ArtilleryTurretPrototype : data.ArtilleryTurretPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ArtilleryTurretPrototype.html)

--- ArtilleryTurretPrototype - artillery-turret constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ArtilleryTurretPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ArtilleryTurretPrototype
function extendBase:ArtilleryTurretPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "artillery-turret",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.artillery_turret = extendBase.ArtilleryTurretPrototype

--- AsteroidCollectorPrototype - asteroid-collector
---@class KuxCoreLib.PrototypeData.Extent.AsteroidCollectorPrototype : data.AsteroidCollectorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AsteroidCollectorPrototype.html)

--- AsteroidCollectorPrototype - asteroid-collector constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AsteroidCollectorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AsteroidCollectorPrototype
function extendBase:AsteroidCollectorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "asteroid-collector",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.asteroid_collector = extendBase.AsteroidCollectorPrototype

--- AsteroidPrototype - asteroid
---@class KuxCoreLib.PrototypeData.Extent.AsteroidPrototype : data.AsteroidPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AsteroidPrototype.html)

--- AsteroidPrototype - asteroid constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AsteroidPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AsteroidPrototype
function extendBase:AsteroidPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "asteroid",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.asteroid = extendBase.AsteroidPrototype

--- BeaconPrototype - beacon
---@class KuxCoreLib.PrototypeData.Extent.BeaconPrototype : data.BeaconPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BeaconPrototype.html)

--- BeaconPrototype - beacon constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BeaconPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BeaconPrototype
function extendBase:BeaconPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "beacon",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.beacon = extendBase.BeaconPrototype

--- BoilerPrototype - boiler
---@class KuxCoreLib.PrototypeData.Extent.BoilerPrototype : data.BoilerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BoilerPrototype.html)

--- BoilerPrototype - boiler constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BoilerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BoilerPrototype
function extendBase:BoilerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "boiler",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.boiler = extendBase.BoilerPrototype

--- BurnerGeneratorPrototype - burner-generator
---@class KuxCoreLib.PrototypeData.Extent.BurnerGeneratorPrototype : data.BurnerGeneratorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BurnerGeneratorPrototype.html)

--- BurnerGeneratorPrototype - burner-generator constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BurnerGeneratorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BurnerGeneratorPrototype
function extendBase:BurnerGeneratorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "burner-generator",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.burner_generator = extendBase.BurnerGeneratorPrototype

--- CargoBayPrototype - cargo-bay
---@class KuxCoreLib.PrototypeData.Extent.CargoBayPrototype : data.CargoBayPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CargoBayPrototype.html)

--- CargoBayPrototype - cargo-bay constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CargoBayPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CargoBayPrototype
function extendBase:CargoBayPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "cargo-bay",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.cargo_bay = extendBase.CargoBayPrototype

--- CargoLandingPadPrototype - cargo-landing-pad
---@class KuxCoreLib.PrototypeData.Extent.CargoLandingPadPrototype : data.CargoLandingPadPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CargoLandingPadPrototype.html)

--- CargoLandingPadPrototype - cargo-landing-pad constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CargoLandingPadPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CargoLandingPadPrototype
function extendBase:CargoLandingPadPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "cargo-landing-pad",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.cargo_landing_pad = extendBase.CargoLandingPadPrototype

--- CargoPodPrototype - cargo-pod
---@class KuxCoreLib.PrototypeData.Extent.CargoPodPrototype : data.CargoPodPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CargoPodPrototype.html)

--- CargoPodPrototype - cargo-pod constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CargoPodPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CargoPodPrototype
function extendBase:CargoPodPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "cargo-pod",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.cargo_pod = extendBase.CargoPodPrototype

--- CharacterPrototype - character
---@class KuxCoreLib.PrototypeData.Extent.CharacterPrototype : data.CharacterPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CharacterPrototype.html)

--- CharacterPrototype - character constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CharacterPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CharacterPrototype
function extendBase:CharacterPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "character",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.character = extendBase.CharacterPrototype

--- ArithmeticCombinatorPrototype - arithmetic-combinator
---@class KuxCoreLib.PrototypeData.Extent.ArithmeticCombinatorPrototype : data.ArithmeticCombinatorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ArithmeticCombinatorPrototype.html)

--- ArithmeticCombinatorPrototype - arithmetic-combinator constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ArithmeticCombinatorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ArithmeticCombinatorPrototype
function extendBase:ArithmeticCombinatorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "arithmetic-combinator",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.arithmetic_combinator = extendBase.ArithmeticCombinatorPrototype

--- DeciderCombinatorPrototype - decider-combinator
---@class KuxCoreLib.PrototypeData.Extent.DeciderCombinatorPrototype : data.DeciderCombinatorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DeciderCombinatorPrototype.html)

--- DeciderCombinatorPrototype - decider-combinator constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DeciderCombinatorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DeciderCombinatorPrototype
function extendBase:DeciderCombinatorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "decider-combinator",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.decider_combinator = extendBase.DeciderCombinatorPrototype

--- SelectorCombinatorPrototype - selector-combinator
---@class KuxCoreLib.PrototypeData.Extent.SelectorCombinatorPrototype : data.SelectorCombinatorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SelectorCombinatorPrototype.html)

--- SelectorCombinatorPrototype - selector-combinator constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SelectorCombinatorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SelectorCombinatorPrototype
function extendBase:SelectorCombinatorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "selector-combinator",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.selector_combinator = extendBase.SelectorCombinatorPrototype

--- ConstantCombinatorPrototype - constant-combinator
---@class KuxCoreLib.PrototypeData.Extent.ConstantCombinatorPrototype : data.ConstantCombinatorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ConstantCombinatorPrototype.html)

--- ConstantCombinatorPrototype - constant-combinator constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ConstantCombinatorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ConstantCombinatorPrototype
function extendBase:ConstantCombinatorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "constant-combinator",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.constant_combinator = extendBase.ConstantCombinatorPrototype

--- ContainerPrototype - container
---@class KuxCoreLib.PrototypeData.Extent.ContainerPrototype : data.ContainerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ContainerPrototype.html)

--- ContainerPrototype - container constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ContainerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ContainerPrototype
function extendBase:ContainerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "container",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.container = extendBase.ContainerPrototype

--- LogisticContainerPrototype - logistic-container
---@class KuxCoreLib.PrototypeData.Extent.LogisticContainerPrototype : data.LogisticContainerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LogisticContainerPrototype.html)

--- LogisticContainerPrototype - logistic-container constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LogisticContainerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LogisticContainerPrototype
function extendBase:LogisticContainerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "logistic-container",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.logistic_container = extendBase.LogisticContainerPrototype

--- InfinityContainerPrototype - infinity-container
---@class KuxCoreLib.PrototypeData.Extent.InfinityContainerPrototype : data.InfinityContainerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/InfinityContainerPrototype.html)

--- InfinityContainerPrototype - infinity-container constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/InfinityContainerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.InfinityContainerPrototype
function extendBase:InfinityContainerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "infinity-container",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.infinity_container = extendBase.InfinityContainerPrototype

--- TemporaryContainerPrototype - temporary-container
---@class KuxCoreLib.PrototypeData.Extent.TemporaryContainerPrototype : data.TemporaryContainerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TemporaryContainerPrototype.html)

--- TemporaryContainerPrototype - temporary-container constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TemporaryContainerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TemporaryContainerPrototype
function extendBase:TemporaryContainerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "temporary-container",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.temporary_container = extendBase.TemporaryContainerPrototype

--- AssemblingMachinePrototype - assembling-machine
---@class KuxCoreLib.PrototypeData.Extent.AssemblingMachinePrototype : data.AssemblingMachinePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AssemblingMachinePrototype.html)

--- AssemblingMachinePrototype - assembling-machine constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AssemblingMachinePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AssemblingMachinePrototype
function extendBase:AssemblingMachinePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "assembling-machine",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.assembling_machine = extendBase.AssemblingMachinePrototype

--- RocketSiloPrototype - rocket-silo
---@class KuxCoreLib.PrototypeData.Extent.RocketSiloPrototype : data.RocketSiloPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RocketSiloPrototype.html)

--- RocketSiloPrototype - rocket-silo constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RocketSiloPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RocketSiloPrototype
function extendBase:RocketSiloPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rocket-silo",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rocket_silo = extendBase.RocketSiloPrototype

--- FurnacePrototype - furnace
---@class KuxCoreLib.PrototypeData.Extent.FurnacePrototype : data.FurnacePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FurnacePrototype.html)

--- FurnacePrototype - furnace constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FurnacePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FurnacePrototype
function extendBase:FurnacePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "furnace",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.furnace = extendBase.FurnacePrototype

--- DisplayPanelPrototype - display-panel
---@class KuxCoreLib.PrototypeData.Extent.DisplayPanelPrototype : data.DisplayPanelPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DisplayPanelPrototype.html)

--- DisplayPanelPrototype - display-panel constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DisplayPanelPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DisplayPanelPrototype
function extendBase:DisplayPanelPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "display-panel",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.display_panel = extendBase.DisplayPanelPrototype

--- ElectricEnergyInterfacePrototype - electric-energy-interface
---@class KuxCoreLib.PrototypeData.Extent.ElectricEnergyInterfacePrototype : data.ElectricEnergyInterfacePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ElectricEnergyInterfacePrototype.html)

--- ElectricEnergyInterfacePrototype - electric-energy-interface constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ElectricEnergyInterfacePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ElectricEnergyInterfacePrototype
function extendBase:ElectricEnergyInterfacePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "electric-energy-interface",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.electric_energy_interface = extendBase.ElectricEnergyInterfacePrototype

--- ElectricPolePrototype - electric-pole
---@class KuxCoreLib.PrototypeData.Extent.ElectricPolePrototype : data.ElectricPolePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ElectricPolePrototype.html)

--- ElectricPolePrototype - electric-pole constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ElectricPolePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ElectricPolePrototype
function extendBase:ElectricPolePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "electric-pole",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.electric_pole = extendBase.ElectricPolePrototype

--- EnemySpawnerPrototype - unit-spawner
---@class KuxCoreLib.PrototypeData.Extent.EnemySpawnerPrototype : data.EnemySpawnerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/EnemySpawnerPrototype.html)

--- EnemySpawnerPrototype - unit-spawner constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/EnemySpawnerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.EnemySpawnerPrototype
function extendBase:EnemySpawnerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "unit-spawner",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.unit_spawner = extendBase.EnemySpawnerPrototype

--- CaptureRobotPrototype - capture-robot
---@class KuxCoreLib.PrototypeData.Extent.CaptureRobotPrototype : data.CaptureRobotPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CaptureRobotPrototype.html)

--- CaptureRobotPrototype - capture-robot constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CaptureRobotPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CaptureRobotPrototype
function extendBase:CaptureRobotPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "capture-robot",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.capture_robot = extendBase.CaptureRobotPrototype

--- CombatRobotPrototype - combat-robot
---@class KuxCoreLib.PrototypeData.Extent.CombatRobotPrototype : data.CombatRobotPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CombatRobotPrototype.html)

--- CombatRobotPrototype - combat-robot constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CombatRobotPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CombatRobotPrototype
function extendBase:CombatRobotPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "combat-robot",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.combat_robot = extendBase.CombatRobotPrototype

--- ConstructionRobotPrototype - construction-robot
---@class KuxCoreLib.PrototypeData.Extent.ConstructionRobotPrototype : data.ConstructionRobotPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ConstructionRobotPrototype.html)

--- ConstructionRobotPrototype - construction-robot constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ConstructionRobotPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ConstructionRobotPrototype
function extendBase:ConstructionRobotPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "construction-robot",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.construction_robot = extendBase.ConstructionRobotPrototype

--- LogisticRobotPrototype - logistic-robot
---@class KuxCoreLib.PrototypeData.Extent.LogisticRobotPrototype : data.LogisticRobotPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LogisticRobotPrototype.html)

--- LogisticRobotPrototype - logistic-robot constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LogisticRobotPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LogisticRobotPrototype
function extendBase:LogisticRobotPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "logistic-robot",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.logistic_robot = extendBase.LogisticRobotPrototype

--- FusionGeneratorPrototype - fusion-generator
---@class KuxCoreLib.PrototypeData.Extent.FusionGeneratorPrototype : data.FusionGeneratorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FusionGeneratorPrototype.html)

--- FusionGeneratorPrototype - fusion-generator constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FusionGeneratorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FusionGeneratorPrototype
function extendBase:FusionGeneratorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "fusion-generator",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.fusion_generator = extendBase.FusionGeneratorPrototype

--- FusionReactorPrototype - fusion-reactor
---@class KuxCoreLib.PrototypeData.Extent.FusionReactorPrototype : data.FusionReactorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FusionReactorPrototype.html)

--- FusionReactorPrototype - fusion-reactor constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FusionReactorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FusionReactorPrototype
function extendBase:FusionReactorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "fusion-reactor",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.fusion_reactor = extendBase.FusionReactorPrototype

--- GatePrototype - gate
---@class KuxCoreLib.PrototypeData.Extent.GatePrototype : data.GatePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/GatePrototype.html)

--- GatePrototype - gate constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/GatePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.GatePrototype
function extendBase:GatePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "gate",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.gate = extendBase.GatePrototype

--- GeneratorPrototype - generator
---@class KuxCoreLib.PrototypeData.Extent.GeneratorPrototype : data.GeneratorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/GeneratorPrototype.html)

--- GeneratorPrototype - generator constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/GeneratorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.GeneratorPrototype
function extendBase:GeneratorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "generator",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.generator = extendBase.GeneratorPrototype

--- HeatInterfacePrototype - heat-interface
---@class KuxCoreLib.PrototypeData.Extent.HeatInterfacePrototype : data.HeatInterfacePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/HeatInterfacePrototype.html)

--- HeatInterfacePrototype - heat-interface constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/HeatInterfacePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.HeatInterfacePrototype
function extendBase:HeatInterfacePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "heat-interface",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.heat_interface = extendBase.HeatInterfacePrototype

--- HeatPipePrototype - heat-pipe
---@class KuxCoreLib.PrototypeData.Extent.HeatPipePrototype : data.HeatPipePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/HeatPipePrototype.html)

--- HeatPipePrototype - heat-pipe constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/HeatPipePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.HeatPipePrototype
function extendBase:HeatPipePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "heat-pipe",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.heat_pipe = extendBase.HeatPipePrototype

--- InserterPrototype - inserter
---@class KuxCoreLib.PrototypeData.Extent.InserterPrototype : data.InserterPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/InserterPrototype.html)

--- InserterPrototype - inserter constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/InserterPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.InserterPrototype
function extendBase:InserterPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "inserter",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.inserter = extendBase.InserterPrototype

--- LabPrototype - lab
---@class KuxCoreLib.PrototypeData.Extent.LabPrototype : data.LabPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LabPrototype.html)

--- LabPrototype - lab constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LabPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LabPrototype
function extendBase:LabPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "lab",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.lab = extendBase.LabPrototype

--- LampPrototype - lamp
---@class KuxCoreLib.PrototypeData.Extent.LampPrototype : data.LampPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LampPrototype.html)

--- LampPrototype - lamp constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LampPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LampPrototype
function extendBase:LampPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "lamp",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.lamp = extendBase.LampPrototype

--- LandMinePrototype - land-mine
---@class KuxCoreLib.PrototypeData.Extent.LandMinePrototype : data.LandMinePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LandMinePrototype.html)

--- LandMinePrototype - land-mine constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LandMinePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LandMinePrototype
function extendBase:LandMinePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "land-mine",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.land_mine = extendBase.LandMinePrototype

--- LightningAttractorPrototype - lightning-attractor
---@class KuxCoreLib.PrototypeData.Extent.LightningAttractorPrototype : data.LightningAttractorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LightningAttractorPrototype.html)

--- LightningAttractorPrototype - lightning-attractor constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LightningAttractorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LightningAttractorPrototype
function extendBase:LightningAttractorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "lightning-attractor",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.lightning_attractor = extendBase.LightningAttractorPrototype

--- LinkedContainerPrototype - linked-container
---@class KuxCoreLib.PrototypeData.Extent.LinkedContainerPrototype : data.LinkedContainerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LinkedContainerPrototype.html)

--- LinkedContainerPrototype - linked-container constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LinkedContainerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LinkedContainerPrototype
function extendBase:LinkedContainerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "linked-container",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.linked_container = extendBase.LinkedContainerPrototype

--- MarketPrototype - market
---@class KuxCoreLib.PrototypeData.Extent.MarketPrototype : data.MarketPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/MarketPrototype.html)

--- MarketPrototype - market constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/MarketPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.MarketPrototype
function extendBase:MarketPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "market",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.market = extendBase.MarketPrototype

--- MiningDrillPrototype - mining-drill
---@class KuxCoreLib.PrototypeData.Extent.MiningDrillPrototype : data.MiningDrillPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/MiningDrillPrototype.html)

--- MiningDrillPrototype - mining-drill constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/MiningDrillPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.MiningDrillPrototype
function extendBase:MiningDrillPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "mining-drill",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.mining_drill = extendBase.MiningDrillPrototype

--- OffshorePumpPrototype - offshore-pump
---@class KuxCoreLib.PrototypeData.Extent.OffshorePumpPrototype : data.OffshorePumpPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/OffshorePumpPrototype.html)

--- OffshorePumpPrototype - offshore-pump constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/OffshorePumpPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.OffshorePumpPrototype
function extendBase:OffshorePumpPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "offshore-pump",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.offshore_pump = extendBase.OffshorePumpPrototype

--- PipePrototype - pipe
---@class KuxCoreLib.PrototypeData.Extent.PipePrototype : data.PipePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PipePrototype.html)

--- PipePrototype - pipe constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PipePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PipePrototype
function extendBase:PipePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "pipe",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.pipe = extendBase.PipePrototype

--- InfinityPipePrototype - infinity-pipe
---@class KuxCoreLib.PrototypeData.Extent.InfinityPipePrototype : data.InfinityPipePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/InfinityPipePrototype.html)

--- InfinityPipePrototype - infinity-pipe constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/InfinityPipePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.InfinityPipePrototype
function extendBase:InfinityPipePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "infinity-pipe",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.infinity_pipe = extendBase.InfinityPipePrototype

--- PipeToGroundPrototype - pipe-to-ground
---@class KuxCoreLib.PrototypeData.Extent.PipeToGroundPrototype : data.PipeToGroundPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PipeToGroundPrototype.html)

--- PipeToGroundPrototype - pipe-to-ground constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PipeToGroundPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PipeToGroundPrototype
function extendBase:PipeToGroundPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "pipe-to-ground",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.pipe_to_ground = extendBase.PipeToGroundPrototype

--- PlayerPortPrototype - player-port
---@class KuxCoreLib.PrototypeData.Extent.PlayerPortPrototype : data.PlayerPortPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PlayerPortPrototype.html)

--- PlayerPortPrototype - player-port constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PlayerPortPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PlayerPortPrototype
function extendBase:PlayerPortPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "player-port",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.player_port = extendBase.PlayerPortPrototype

--- PowerSwitchPrototype - power-switch
---@class KuxCoreLib.PrototypeData.Extent.PowerSwitchPrototype : data.PowerSwitchPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PowerSwitchPrototype.html)

--- PowerSwitchPrototype - power-switch constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PowerSwitchPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PowerSwitchPrototype
function extendBase:PowerSwitchPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "power-switch",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.power_switch = extendBase.PowerSwitchPrototype

--- ProgrammableSpeakerPrototype - programmable-speaker
---@class KuxCoreLib.PrototypeData.Extent.ProgrammableSpeakerPrototype : data.ProgrammableSpeakerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ProgrammableSpeakerPrototype.html)

--- ProgrammableSpeakerPrototype - programmable-speaker constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ProgrammableSpeakerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ProgrammableSpeakerPrototype
function extendBase:ProgrammableSpeakerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "programmable-speaker",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.programmable_speaker = extendBase.ProgrammableSpeakerPrototype

--- PumpPrototype - pump
---@class KuxCoreLib.PrototypeData.Extent.PumpPrototype : data.PumpPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PumpPrototype.html)

--- PumpPrototype - pump constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PumpPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PumpPrototype
function extendBase:PumpPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "pump",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.pump = extendBase.PumpPrototype

--- RadarPrototype - radar
---@class KuxCoreLib.PrototypeData.Extent.RadarPrototype : data.RadarPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RadarPrototype.html)

--- RadarPrototype - radar constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RadarPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RadarPrototype
function extendBase:RadarPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "radar",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.radar = extendBase.RadarPrototype

--- CurvedRailAPrototype - curved-rail-a
---@class KuxCoreLib.PrototypeData.Extent.CurvedRailAPrototype : data.CurvedRailAPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CurvedRailAPrototype.html)

--- CurvedRailAPrototype - curved-rail-a constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CurvedRailAPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CurvedRailAPrototype
function extendBase:CurvedRailAPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "curved-rail-a",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.curved_rail_a = extendBase.CurvedRailAPrototype

--- ElevatedCurvedRailAPrototype - elevated-curved-rail-a
---@class KuxCoreLib.PrototypeData.Extent.ElevatedCurvedRailAPrototype : data.ElevatedCurvedRailAPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ElevatedCurvedRailAPrototype.html)

--- ElevatedCurvedRailAPrototype - elevated-curved-rail-a constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ElevatedCurvedRailAPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ElevatedCurvedRailAPrototype
function extendBase:ElevatedCurvedRailAPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "elevated-curved-rail-a",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.elevated_curved_rail_a = extendBase.ElevatedCurvedRailAPrototype

--- CurvedRailBPrototype - curved-rail-b
---@class KuxCoreLib.PrototypeData.Extent.CurvedRailBPrototype : data.CurvedRailBPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CurvedRailBPrototype.html)

--- CurvedRailBPrototype - curved-rail-b constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CurvedRailBPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CurvedRailBPrototype
function extendBase:CurvedRailBPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "curved-rail-b",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.curved_rail_b = extendBase.CurvedRailBPrototype

--- ElevatedCurvedRailBPrototype - elevated-curved-rail-b
---@class KuxCoreLib.PrototypeData.Extent.ElevatedCurvedRailBPrototype : data.ElevatedCurvedRailBPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ElevatedCurvedRailBPrototype.html)

--- ElevatedCurvedRailBPrototype - elevated-curved-rail-b constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ElevatedCurvedRailBPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ElevatedCurvedRailBPrototype
function extendBase:ElevatedCurvedRailBPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "elevated-curved-rail-b",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.elevated_curved_rail_b = extendBase.ElevatedCurvedRailBPrototype

--- HalfDiagonalRailPrototype - half-diagonal-rail
---@class KuxCoreLib.PrototypeData.Extent.HalfDiagonalRailPrototype : data.HalfDiagonalRailPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/HalfDiagonalRailPrototype.html)

--- HalfDiagonalRailPrototype - half-diagonal-rail constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/HalfDiagonalRailPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.HalfDiagonalRailPrototype
function extendBase:HalfDiagonalRailPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "half-diagonal-rail",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.half_diagonal_rail = extendBase.HalfDiagonalRailPrototype

--- ElevatedHalfDiagonalRailPrototype - elevated-half-diagonal-rail
---@class KuxCoreLib.PrototypeData.Extent.ElevatedHalfDiagonalRailPrototype : data.ElevatedHalfDiagonalRailPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ElevatedHalfDiagonalRailPrototype.html)

--- ElevatedHalfDiagonalRailPrototype - elevated-half-diagonal-rail constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ElevatedHalfDiagonalRailPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ElevatedHalfDiagonalRailPrototype
function extendBase:ElevatedHalfDiagonalRailPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "elevated-half-diagonal-rail",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.elevated_half_diagonal_rail = extendBase.ElevatedHalfDiagonalRailPrototype

--- LegacyCurvedRailPrototype - legacy-curved-rail
---@class KuxCoreLib.PrototypeData.Extent.LegacyCurvedRailPrototype : data.LegacyCurvedRailPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LegacyCurvedRailPrototype.html)

--- LegacyCurvedRailPrototype - legacy-curved-rail constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LegacyCurvedRailPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LegacyCurvedRailPrototype
function extendBase:LegacyCurvedRailPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "legacy-curved-rail",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.legacy_curved_rail = extendBase.LegacyCurvedRailPrototype

--- LegacyStraightRailPrototype - legacy-straight-rail
---@class KuxCoreLib.PrototypeData.Extent.LegacyStraightRailPrototype : data.LegacyStraightRailPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LegacyStraightRailPrototype.html)

--- LegacyStraightRailPrototype - legacy-straight-rail constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LegacyStraightRailPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LegacyStraightRailPrototype
function extendBase:LegacyStraightRailPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "legacy-straight-rail",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.legacy_straight_rail = extendBase.LegacyStraightRailPrototype

--- RailRampPrototype - rail-ramp
---@class KuxCoreLib.PrototypeData.Extent.RailRampPrototype : data.RailRampPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RailRampPrototype.html)

--- RailRampPrototype - rail-ramp constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RailRampPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RailRampPrototype
function extendBase:RailRampPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rail-ramp",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rail_ramp = extendBase.RailRampPrototype

--- StraightRailPrototype - straight-rail
---@class KuxCoreLib.PrototypeData.Extent.StraightRailPrototype : data.StraightRailPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/StraightRailPrototype.html)

--- StraightRailPrototype - straight-rail constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/StraightRailPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.StraightRailPrototype
function extendBase:StraightRailPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "straight-rail",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.straight_rail = extendBase.StraightRailPrototype

--- ElevatedStraightRailPrototype - elevated-straight-rail
---@class KuxCoreLib.PrototypeData.Extent.ElevatedStraightRailPrototype : data.ElevatedStraightRailPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ElevatedStraightRailPrototype.html)

--- ElevatedStraightRailPrototype - elevated-straight-rail constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ElevatedStraightRailPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ElevatedStraightRailPrototype
function extendBase:ElevatedStraightRailPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "elevated-straight-rail",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.elevated_straight_rail = extendBase.ElevatedStraightRailPrototype

--- RailChainSignalPrototype - rail-chain-signal
---@class KuxCoreLib.PrototypeData.Extent.RailChainSignalPrototype : data.RailChainSignalPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RailChainSignalPrototype.html)

--- RailChainSignalPrototype - rail-chain-signal constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RailChainSignalPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RailChainSignalPrototype
function extendBase:RailChainSignalPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rail-chain-signal",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rail_chain_signal = extendBase.RailChainSignalPrototype

--- RailSignalPrototype - rail-signal
---@class KuxCoreLib.PrototypeData.Extent.RailSignalPrototype : data.RailSignalPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RailSignalPrototype.html)

--- RailSignalPrototype - rail-signal constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RailSignalPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RailSignalPrototype
function extendBase:RailSignalPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rail-signal",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rail_signal = extendBase.RailSignalPrototype

--- RailSupportPrototype - rail-support
---@class KuxCoreLib.PrototypeData.Extent.RailSupportPrototype : data.RailSupportPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RailSupportPrototype.html)

--- RailSupportPrototype - rail-support constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RailSupportPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RailSupportPrototype
function extendBase:RailSupportPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rail-support",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rail_support = extendBase.RailSupportPrototype

--- ReactorPrototype - reactor
---@class KuxCoreLib.PrototypeData.Extent.ReactorPrototype : data.ReactorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ReactorPrototype.html)

--- ReactorPrototype - reactor constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ReactorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ReactorPrototype
function extendBase:ReactorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "reactor",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.reactor = extendBase.ReactorPrototype

--- RoboportPrototype - roboport
---@class KuxCoreLib.PrototypeData.Extent.RoboportPrototype : data.RoboportPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RoboportPrototype.html)

--- RoboportPrototype - roboport constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RoboportPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RoboportPrototype
function extendBase:RoboportPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "roboport",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.roboport = extendBase.RoboportPrototype

--- SegmentPrototype - segment
---@class KuxCoreLib.PrototypeData.Extent.SegmentPrototype : data.SegmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SegmentPrototype.html)

--- SegmentPrototype - segment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SegmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SegmentPrototype
function extendBase:SegmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "segment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.segment = extendBase.SegmentPrototype

--- SegmentedUnitPrototype - segmented-unit
---@class KuxCoreLib.PrototypeData.Extent.SegmentedUnitPrototype : data.SegmentedUnitPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SegmentedUnitPrototype.html)

--- SegmentedUnitPrototype - segmented-unit constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SegmentedUnitPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SegmentedUnitPrototype
function extendBase:SegmentedUnitPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "segmented-unit",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.segmented_unit = extendBase.SegmentedUnitPrototype

--- SimpleEntityWithOwnerPrototype - simple-entity-with-owner
---@class KuxCoreLib.PrototypeData.Extent.SimpleEntityWithOwnerPrototype : data.SimpleEntityWithOwnerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SimpleEntityWithOwnerPrototype.html)

--- SimpleEntityWithOwnerPrototype - simple-entity-with-owner constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SimpleEntityWithOwnerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SimpleEntityWithOwnerPrototype
function extendBase:SimpleEntityWithOwnerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "simple-entity-with-owner",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.simple_entity_with_owner = extendBase.SimpleEntityWithOwnerPrototype

--- SimpleEntityWithForcePrototype - simple-entity-with-force
---@class KuxCoreLib.PrototypeData.Extent.SimpleEntityWithForcePrototype : data.SimpleEntityWithForcePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SimpleEntityWithForcePrototype.html)

--- SimpleEntityWithForcePrototype - simple-entity-with-force constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SimpleEntityWithForcePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SimpleEntityWithForcePrototype
function extendBase:SimpleEntityWithForcePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "simple-entity-with-force",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.simple_entity_with_force = extendBase.SimpleEntityWithForcePrototype

--- SolarPanelPrototype - solar-panel
---@class KuxCoreLib.PrototypeData.Extent.SolarPanelPrototype : data.SolarPanelPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SolarPanelPrototype.html)

--- SolarPanelPrototype - solar-panel constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SolarPanelPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SolarPanelPrototype
function extendBase:SolarPanelPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "solar-panel",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.solar_panel = extendBase.SolarPanelPrototype

--- SpacePlatformHubPrototype - space-platform-hub
---@class KuxCoreLib.PrototypeData.Extent.SpacePlatformHubPrototype : data.SpacePlatformHubPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpacePlatformHubPrototype.html)

--- SpacePlatformHubPrototype - space-platform-hub constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpacePlatformHubPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpacePlatformHubPrototype
function extendBase:SpacePlatformHubPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "space-platform-hub",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.space_platform_hub = extendBase.SpacePlatformHubPrototype

--- SpiderLegPrototype - spider-leg
---@class KuxCoreLib.PrototypeData.Extent.SpiderLegPrototype : data.SpiderLegPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpiderLegPrototype.html)

--- SpiderLegPrototype - spider-leg constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpiderLegPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpiderLegPrototype
function extendBase:SpiderLegPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "spider-leg",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.spider_leg = extendBase.SpiderLegPrototype

--- SpiderUnitPrototype - spider-unit
---@class KuxCoreLib.PrototypeData.Extent.SpiderUnitPrototype : data.SpiderUnitPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpiderUnitPrototype.html)

--- SpiderUnitPrototype - spider-unit constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpiderUnitPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpiderUnitPrototype
function extendBase:SpiderUnitPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "spider-unit",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.spider_unit = extendBase.SpiderUnitPrototype

--- StorageTankPrototype - storage-tank
---@class KuxCoreLib.PrototypeData.Extent.StorageTankPrototype : data.StorageTankPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/StorageTankPrototype.html)

--- StorageTankPrototype - storage-tank constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/StorageTankPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.StorageTankPrototype
function extendBase:StorageTankPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "storage-tank",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.storage_tank = extendBase.StorageTankPrototype

--- ThrusterPrototype - thruster
---@class KuxCoreLib.PrototypeData.Extent.ThrusterPrototype : data.ThrusterPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ThrusterPrototype.html)

--- ThrusterPrototype - thruster constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ThrusterPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ThrusterPrototype
function extendBase:ThrusterPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "thruster",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.thruster = extendBase.ThrusterPrototype

--- TrainStopPrototype - train-stop
---@class KuxCoreLib.PrototypeData.Extent.TrainStopPrototype : data.TrainStopPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TrainStopPrototype.html)

--- TrainStopPrototype - train-stop constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TrainStopPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TrainStopPrototype
function extendBase:TrainStopPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "train-stop",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.train_stop = extendBase.TrainStopPrototype

--- LaneSplitterPrototype - lane-splitter
---@class KuxCoreLib.PrototypeData.Extent.LaneSplitterPrototype : data.LaneSplitterPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LaneSplitterPrototype.html)

--- LaneSplitterPrototype - lane-splitter constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LaneSplitterPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LaneSplitterPrototype
function extendBase:LaneSplitterPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "lane-splitter",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.lane_splitter = extendBase.LaneSplitterPrototype

--- LinkedBeltPrototype - linked-belt
---@class KuxCoreLib.PrototypeData.Extent.LinkedBeltPrototype : data.LinkedBeltPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LinkedBeltPrototype.html)

--- LinkedBeltPrototype - linked-belt constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LinkedBeltPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LinkedBeltPrototype
function extendBase:LinkedBeltPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "linked-belt",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.linked_belt = extendBase.LinkedBeltPrototype

--- Loader1x1Prototype - loader-1x1
---@class KuxCoreLib.PrototypeData.Extent.Loader1x1Prototype : data.Loader1x1Prototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/Loader1x1Prototype.html)

--- Loader1x1Prototype - loader-1x1 constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/Loader1x1Prototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.Loader1x1Prototype
function extendBase:Loader1x1Prototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "loader-1x1",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.loader_1x1 = extendBase.Loader1x1Prototype

--- Loader1x2Prototype - loader
---@class KuxCoreLib.PrototypeData.Extent.Loader1x2Prototype : data.Loader1x2Prototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/Loader1x2Prototype.html)

--- Loader1x2Prototype - loader constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/Loader1x2Prototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.Loader1x2Prototype
function extendBase:Loader1x2Prototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "loader",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.loader = extendBase.Loader1x2Prototype

--- SplitterPrototype - splitter
---@class KuxCoreLib.PrototypeData.Extent.SplitterPrototype : data.SplitterPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SplitterPrototype.html)

--- SplitterPrototype - splitter constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SplitterPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SplitterPrototype
function extendBase:SplitterPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "splitter",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.splitter = extendBase.SplitterPrototype

--- TransportBeltPrototype - transport-belt
---@class KuxCoreLib.PrototypeData.Extent.TransportBeltPrototype : data.TransportBeltPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TransportBeltPrototype.html)

--- TransportBeltPrototype - transport-belt constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TransportBeltPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TransportBeltPrototype
function extendBase:TransportBeltPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "transport-belt",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.transport_belt = extendBase.TransportBeltPrototype

--- UndergroundBeltPrototype - underground-belt
---@class KuxCoreLib.PrototypeData.Extent.UndergroundBeltPrototype : data.UndergroundBeltPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/UndergroundBeltPrototype.html)

--- UndergroundBeltPrototype - underground-belt constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/UndergroundBeltPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.UndergroundBeltPrototype
function extendBase:UndergroundBeltPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "underground-belt",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.underground_belt = extendBase.UndergroundBeltPrototype

--- TurretPrototype - turret
---@class KuxCoreLib.PrototypeData.Extent.TurretPrototype : data.TurretPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TurretPrototype.html)

--- TurretPrototype - turret constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TurretPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TurretPrototype
function extendBase:TurretPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "turret",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.turret = extendBase.TurretPrototype

--- AmmoTurretPrototype - ammo-turret
---@class KuxCoreLib.PrototypeData.Extent.AmmoTurretPrototype : data.AmmoTurretPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AmmoTurretPrototype.html)

--- AmmoTurretPrototype - ammo-turret constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AmmoTurretPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AmmoTurretPrototype
function extendBase:AmmoTurretPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "ammo-turret",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.ammo_turret = extendBase.AmmoTurretPrototype

--- ElectricTurretPrototype - electric-turret
---@class KuxCoreLib.PrototypeData.Extent.ElectricTurretPrototype : data.ElectricTurretPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ElectricTurretPrototype.html)

--- ElectricTurretPrototype - electric-turret constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ElectricTurretPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ElectricTurretPrototype
function extendBase:ElectricTurretPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "electric-turret",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.electric_turret = extendBase.ElectricTurretPrototype

--- FluidTurretPrototype - fluid-turret
---@class KuxCoreLib.PrototypeData.Extent.FluidTurretPrototype : data.FluidTurretPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FluidTurretPrototype.html)

--- FluidTurretPrototype - fluid-turret constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FluidTurretPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FluidTurretPrototype
function extendBase:FluidTurretPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "fluid-turret",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.fluid_turret = extendBase.FluidTurretPrototype

--- UnitPrototype - unit
---@class KuxCoreLib.PrototypeData.Extent.UnitPrototype : data.UnitPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/UnitPrototype.html)

--- UnitPrototype - unit constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/UnitPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.UnitPrototype
function extendBase:UnitPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "unit",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.unit = extendBase.UnitPrototype

--- CarPrototype - car
---@class KuxCoreLib.PrototypeData.Extent.CarPrototype : data.CarPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CarPrototype.html)

--- CarPrototype - car constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CarPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CarPrototype
function extendBase:CarPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "car",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.car = extendBase.CarPrototype

--- ArtilleryWagonPrototype - artillery-wagon
---@class KuxCoreLib.PrototypeData.Extent.ArtilleryWagonPrototype : data.ArtilleryWagonPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ArtilleryWagonPrototype.html)

--- ArtilleryWagonPrototype - artillery-wagon constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ArtilleryWagonPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ArtilleryWagonPrototype
function extendBase:ArtilleryWagonPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "artillery-wagon",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.artillery_wagon = extendBase.ArtilleryWagonPrototype

--- CargoWagonPrototype - cargo-wagon
---@class KuxCoreLib.PrototypeData.Extent.CargoWagonPrototype : data.CargoWagonPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CargoWagonPrototype.html)

--- CargoWagonPrototype - cargo-wagon constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CargoWagonPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CargoWagonPrototype
function extendBase:CargoWagonPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "cargo-wagon",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.cargo_wagon = extendBase.CargoWagonPrototype

--- FluidWagonPrototype - fluid-wagon
---@class KuxCoreLib.PrototypeData.Extent.FluidWagonPrototype : data.FluidWagonPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FluidWagonPrototype.html)

--- FluidWagonPrototype - fluid-wagon constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FluidWagonPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FluidWagonPrototype
function extendBase:FluidWagonPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "fluid-wagon",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.fluid_wagon = extendBase.FluidWagonPrototype

--- LocomotivePrototype - locomotive
---@class KuxCoreLib.PrototypeData.Extent.LocomotivePrototype : data.LocomotivePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LocomotivePrototype.html)

--- LocomotivePrototype - locomotive constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LocomotivePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LocomotivePrototype
function extendBase:LocomotivePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "locomotive",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.locomotive = extendBase.LocomotivePrototype

--- SpiderVehiclePrototype - spider-vehicle
---@class KuxCoreLib.PrototypeData.Extent.SpiderVehiclePrototype : data.SpiderVehiclePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpiderVehiclePrototype.html)

--- SpiderVehiclePrototype - spider-vehicle constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpiderVehiclePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpiderVehiclePrototype
function extendBase:SpiderVehiclePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "spider-vehicle",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.spider_vehicle = extendBase.SpiderVehiclePrototype

--- WallPrototype - wall
---@class KuxCoreLib.PrototypeData.Extent.WallPrototype : data.WallPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/WallPrototype.html)

--- WallPrototype - wall constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/WallPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.WallPrototype
function extendBase:WallPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "wall",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.wall = extendBase.WallPrototype

--- FishPrototype - fish
---@class KuxCoreLib.PrototypeData.Extent.FishPrototype : data.FishPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FishPrototype.html)

--- FishPrototype - fish constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FishPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FishPrototype
function extendBase:FishPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "fish",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.fish = extendBase.FishPrototype

--- SimpleEntityPrototype - simple-entity
---@class KuxCoreLib.PrototypeData.Extent.SimpleEntityPrototype : data.SimpleEntityPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SimpleEntityPrototype.html)

--- SimpleEntityPrototype - simple-entity constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SimpleEntityPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SimpleEntityPrototype
function extendBase:SimpleEntityPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "simple-entity",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.simple_entity = extendBase.SimpleEntityPrototype

--- TreePrototype - tree
---@class KuxCoreLib.PrototypeData.Extent.TreePrototype : data.TreePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TreePrototype.html)

--- TreePrototype - tree constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TreePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TreePrototype
function extendBase:TreePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "tree",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.tree = extendBase.TreePrototype

--- PlantPrototype - plant
---@class KuxCoreLib.PrototypeData.Extent.PlantPrototype : data.PlantPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PlantPrototype.html)

--- PlantPrototype - plant constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PlantPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PlantPrototype
function extendBase:PlantPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "plant",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.plant = extendBase.PlantPrototype

--- ExplosionPrototype - explosion
---@class KuxCoreLib.PrototypeData.Extent.ExplosionPrototype : data.ExplosionPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ExplosionPrototype.html)

--- ExplosionPrototype - explosion constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ExplosionPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ExplosionPrototype
function extendBase:ExplosionPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "explosion",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.explosion = extendBase.ExplosionPrototype

--- FireFlamePrototype - fire
---@class KuxCoreLib.PrototypeData.Extent.FireFlamePrototype : data.FireFlamePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FireFlamePrototype.html)

--- FireFlamePrototype - fire constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FireFlamePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FireFlamePrototype
function extendBase:FireFlamePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "fire",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.fire = extendBase.FireFlamePrototype

--- FluidStreamPrototype - stream
---@class KuxCoreLib.PrototypeData.Extent.FluidStreamPrototype : data.FluidStreamPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FluidStreamPrototype.html)

--- FluidStreamPrototype - stream constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FluidStreamPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FluidStreamPrototype
function extendBase:FluidStreamPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "stream",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.stream = extendBase.FluidStreamPrototype

--- HighlightBoxEntityPrototype - highlight-box
---@class KuxCoreLib.PrototypeData.Extent.HighlightBoxEntityPrototype : data.HighlightBoxEntityPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/HighlightBoxEntityPrototype.html)

--- HighlightBoxEntityPrototype - highlight-box constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/HighlightBoxEntityPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.HighlightBoxEntityPrototype
function extendBase:HighlightBoxEntityPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "highlight-box",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.highlight_box = extendBase.HighlightBoxEntityPrototype

--- ItemEntityPrototype - item-entity
---@class KuxCoreLib.PrototypeData.Extent.ItemEntityPrototype : data.ItemEntityPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemEntityPrototype.html)

--- ItemEntityPrototype - item-entity constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemEntityPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemEntityPrototype
function extendBase:ItemEntityPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "item-entity",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item_entity = extendBase.ItemEntityPrototype

--- ItemRequestProxyPrototype - item-request-proxy
---@class KuxCoreLib.PrototypeData.Extent.ItemRequestProxyPrototype : data.ItemRequestProxyPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemRequestProxyPrototype.html)

--- ItemRequestProxyPrototype - item-request-proxy constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemRequestProxyPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemRequestProxyPrototype
function extendBase:ItemRequestProxyPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "item-request-proxy",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item_request_proxy = extendBase.ItemRequestProxyPrototype

--- LightningPrototype - lightning
---@class KuxCoreLib.PrototypeData.Extent.LightningPrototype : data.LightningPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/LightningPrototype.html)

--- LightningPrototype - lightning constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/LightningPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.LightningPrototype
function extendBase:LightningPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "lightning",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.lightning = extendBase.LightningPrototype

--- ParticleSourcePrototype - particle-source
---@class KuxCoreLib.PrototypeData.Extent.ParticleSourcePrototype : data.ParticleSourcePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ParticleSourcePrototype.html)

--- ParticleSourcePrototype - particle-source constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ParticleSourcePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ParticleSourcePrototype
function extendBase:ParticleSourcePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "particle-source",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.particle_source = extendBase.ParticleSourcePrototype

--- ProjectilePrototype - projectile
---@class KuxCoreLib.PrototypeData.Extent.ProjectilePrototype : data.ProjectilePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ProjectilePrototype.html)

--- ProjectilePrototype - projectile constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ProjectilePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ProjectilePrototype
function extendBase:ProjectilePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "projectile",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.projectile = extendBase.ProjectilePrototype

--- ResourceEntityPrototype - resource
---@class KuxCoreLib.PrototypeData.Extent.ResourceEntityPrototype : data.ResourceEntityPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ResourceEntityPrototype.html)

--- ResourceEntityPrototype - resource constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ResourceEntityPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ResourceEntityPrototype
function extendBase:ResourceEntityPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "resource",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.resource = extendBase.ResourceEntityPrototype

--- RocketSiloRocketPrototype - rocket-silo-rocket
---@class KuxCoreLib.PrototypeData.Extent.RocketSiloRocketPrototype : data.RocketSiloRocketPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RocketSiloRocketPrototype.html)

--- RocketSiloRocketPrototype - rocket-silo-rocket constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RocketSiloRocketPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RocketSiloRocketPrototype
function extendBase:RocketSiloRocketPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rocket-silo-rocket",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rocket_silo_rocket = extendBase.RocketSiloRocketPrototype

--- RocketSiloRocketShadowPrototype - rocket-silo-rocket-shadow
---@class KuxCoreLib.PrototypeData.Extent.RocketSiloRocketShadowPrototype : data.RocketSiloRocketShadowPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RocketSiloRocketShadowPrototype.html)

--- RocketSiloRocketShadowPrototype - rocket-silo-rocket-shadow constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RocketSiloRocketShadowPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RocketSiloRocketShadowPrototype
function extendBase:RocketSiloRocketShadowPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rocket-silo-rocket-shadow",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rocket_silo_rocket_shadow = extendBase.RocketSiloRocketShadowPrototype

--- SmokeWithTriggerPrototype - smoke-with-trigger
---@class KuxCoreLib.PrototypeData.Extent.SmokeWithTriggerPrototype : data.SmokeWithTriggerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SmokeWithTriggerPrototype.html)

--- SmokeWithTriggerPrototype - smoke-with-trigger constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SmokeWithTriggerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SmokeWithTriggerPrototype
function extendBase:SmokeWithTriggerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "smoke-with-trigger",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.smoke_with_trigger = extendBase.SmokeWithTriggerPrototype

--- SpeechBubblePrototype - speech-bubble
---@class KuxCoreLib.PrototypeData.Extent.SpeechBubblePrototype : data.SpeechBubblePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpeechBubblePrototype.html)

--- SpeechBubblePrototype - speech-bubble constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpeechBubblePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpeechBubblePrototype
function extendBase:SpeechBubblePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "speech-bubble",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.speech_bubble = extendBase.SpeechBubblePrototype

--- StickerPrototype - sticker
---@class KuxCoreLib.PrototypeData.Extent.StickerPrototype : data.StickerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/StickerPrototype.html)

--- StickerPrototype - sticker constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/StickerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.StickerPrototype
function extendBase:StickerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "sticker",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.sticker = extendBase.StickerPrototype

--- TileGhostPrototype - tile-ghost
---@class KuxCoreLib.PrototypeData.Extent.TileGhostPrototype : data.TileGhostPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TileGhostPrototype.html)

--- TileGhostPrototype - tile-ghost constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TileGhostPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TileGhostPrototype
function extendBase:TileGhostPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "tile-ghost",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.tile_ghost = extendBase.TileGhostPrototype

--- EquipmentCategory - equipment-category
---@class KuxCoreLib.PrototypeData.Extent.EquipmentCategory : data.EquipmentCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/EquipmentCategory.html)

--- EquipmentCategory - equipment-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/EquipmentCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.EquipmentCategory
function extendBase:EquipmentCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "equipment-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.equipment_category = extendBase.EquipmentCategory

--- EquipmentGridPrototype - equipment-grid
---@class KuxCoreLib.PrototypeData.Extent.EquipmentGridPrototype : data.EquipmentGridPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/EquipmentGridPrototype.html)

--- EquipmentGridPrototype - equipment-grid constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/EquipmentGridPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.EquipmentGridPrototype
function extendBase:EquipmentGridPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "equipment-grid",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.equipment_grid = extendBase.EquipmentGridPrototype

--- ActiveDefenseEquipmentPrototype - active-defense-equipment
---@class KuxCoreLib.PrototypeData.Extent.ActiveDefenseEquipmentPrototype : data.ActiveDefenseEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ActiveDefenseEquipmentPrototype.html)

--- ActiveDefenseEquipmentPrototype - active-defense-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ActiveDefenseEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ActiveDefenseEquipmentPrototype
function extendBase:ActiveDefenseEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "active-defense-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.active_defense_equipment = extendBase.ActiveDefenseEquipmentPrototype

--- BatteryEquipmentPrototype - battery-equipment
---@class KuxCoreLib.PrototypeData.Extent.BatteryEquipmentPrototype : data.BatteryEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BatteryEquipmentPrototype.html)

--- BatteryEquipmentPrototype - battery-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BatteryEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BatteryEquipmentPrototype
function extendBase:BatteryEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "battery-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.battery_equipment = extendBase.BatteryEquipmentPrototype

--- BeltImmunityEquipmentPrototype - belt-immunity-equipment
---@class KuxCoreLib.PrototypeData.Extent.BeltImmunityEquipmentPrototype : data.BeltImmunityEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BeltImmunityEquipmentPrototype.html)

--- BeltImmunityEquipmentPrototype - belt-immunity-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BeltImmunityEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BeltImmunityEquipmentPrototype
function extendBase:BeltImmunityEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "belt-immunity-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.belt_immunity_equipment = extendBase.BeltImmunityEquipmentPrototype

--- EnergyShieldEquipmentPrototype - energy-shield-equipment
---@class KuxCoreLib.PrototypeData.Extent.EnergyShieldEquipmentPrototype : data.EnergyShieldEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/EnergyShieldEquipmentPrototype.html)

--- EnergyShieldEquipmentPrototype - energy-shield-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/EnergyShieldEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.EnergyShieldEquipmentPrototype
function extendBase:EnergyShieldEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "energy-shield-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.energy_shield_equipment = extendBase.EnergyShieldEquipmentPrototype

--- EquipmentGhostPrototype - equipment-ghost
---@class KuxCoreLib.PrototypeData.Extent.EquipmentGhostPrototype : data.EquipmentGhostPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/EquipmentGhostPrototype.html)

--- EquipmentGhostPrototype - equipment-ghost constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/EquipmentGhostPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.EquipmentGhostPrototype
function extendBase:EquipmentGhostPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "equipment-ghost",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.equipment_ghost = extendBase.EquipmentGhostPrototype

--- GeneratorEquipmentPrototype - generator-equipment
---@class KuxCoreLib.PrototypeData.Extent.GeneratorEquipmentPrototype : data.GeneratorEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/GeneratorEquipmentPrototype.html)

--- GeneratorEquipmentPrototype - generator-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/GeneratorEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.GeneratorEquipmentPrototype
function extendBase:GeneratorEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "generator-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.generator_equipment = extendBase.GeneratorEquipmentPrototype

--- InventoryBonusEquipmentPrototype - inventory-bonus-equipment
---@class KuxCoreLib.PrototypeData.Extent.InventoryBonusEquipmentPrototype : data.InventoryBonusEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/InventoryBonusEquipmentPrototype.html)

--- InventoryBonusEquipmentPrototype - inventory-bonus-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/InventoryBonusEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.InventoryBonusEquipmentPrototype
function extendBase:InventoryBonusEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "inventory-bonus-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.inventory_bonus_equipment = extendBase.InventoryBonusEquipmentPrototype

--- MovementBonusEquipmentPrototype - movement-bonus-equipment
---@class KuxCoreLib.PrototypeData.Extent.MovementBonusEquipmentPrototype : data.MovementBonusEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/MovementBonusEquipmentPrototype.html)

--- MovementBonusEquipmentPrototype - movement-bonus-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/MovementBonusEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.MovementBonusEquipmentPrototype
function extendBase:MovementBonusEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "movement-bonus-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.movement_bonus_equipment = extendBase.MovementBonusEquipmentPrototype

--- NightVisionEquipmentPrototype - night-vision-equipment
---@class KuxCoreLib.PrototypeData.Extent.NightVisionEquipmentPrototype : data.NightVisionEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/NightVisionEquipmentPrototype.html)

--- NightVisionEquipmentPrototype - night-vision-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/NightVisionEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.NightVisionEquipmentPrototype
function extendBase:NightVisionEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "night-vision-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.night_vision_equipment = extendBase.NightVisionEquipmentPrototype

--- RoboportEquipmentPrototype - roboport-equipment
---@class KuxCoreLib.PrototypeData.Extent.RoboportEquipmentPrototype : data.RoboportEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RoboportEquipmentPrototype.html)

--- RoboportEquipmentPrototype - roboport-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RoboportEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RoboportEquipmentPrototype
function extendBase:RoboportEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "roboport-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.roboport_equipment = extendBase.RoboportEquipmentPrototype

--- SolarPanelEquipmentPrototype - solar-panel-equipment
---@class KuxCoreLib.PrototypeData.Extent.SolarPanelEquipmentPrototype : data.SolarPanelEquipmentPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SolarPanelEquipmentPrototype.html)

--- SolarPanelEquipmentPrototype - solar-panel-equipment constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SolarPanelEquipmentPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SolarPanelEquipmentPrototype
function extendBase:SolarPanelEquipmentPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "solar-panel-equipment",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.solar_panel_equipment = extendBase.SolarPanelEquipmentPrototype

--- FluidPrototype - fluid
---@class KuxCoreLib.PrototypeData.Extent.FluidPrototype : data.FluidPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FluidPrototype.html)

--- FluidPrototype - fluid constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FluidPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FluidPrototype
function extendBase:FluidPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "fluid",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.fluid = extendBase.FluidPrototype

--- FuelCategory - fuel-category
---@class KuxCoreLib.PrototypeData.Extent.FuelCategory : data.FuelCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/FuelCategory.html)

--- FuelCategory - fuel-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/FuelCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.FuelCategory
function extendBase:FuelCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "fuel-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.fuel_category = extendBase.FuelCategory

--- ItemGroup - item-group
---@class KuxCoreLib.PrototypeData.Extent.ItemGroup : data.ItemGroup
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemGroup.html)

--- ItemGroup - item-group constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemGroup.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemGroup
function extendBase:ItemGroup(t)
	local d = utils.merge(self["common"], t, {
		type          = "item-group",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item_group = extendBase.ItemGroup

--- ItemPrototype - item
---@class KuxCoreLib.PrototypeData.Extent.ItemPrototype : data.ItemPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemPrototype.html)

--- ItemPrototype - item constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemPrototype
function extendBase:ItemPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "item",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item = extendBase.ItemPrototype

--- AmmoItemPrototype - ammo
---@class KuxCoreLib.PrototypeData.Extent.AmmoItemPrototype : data.AmmoItemPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/AmmoItemPrototype.html)

--- AmmoItemPrototype - ammo constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/AmmoItemPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.AmmoItemPrototype
function extendBase:AmmoItemPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "ammo",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.ammo = extendBase.AmmoItemPrototype

--- CapsulePrototype - capsule
---@class KuxCoreLib.PrototypeData.Extent.CapsulePrototype : data.CapsulePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CapsulePrototype.html)

--- CapsulePrototype - capsule constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CapsulePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CapsulePrototype
function extendBase:CapsulePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "capsule",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.capsule = extendBase.CapsulePrototype

--- GunPrototype - gun
---@class KuxCoreLib.PrototypeData.Extent.GunPrototype : data.GunPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/GunPrototype.html)

--- GunPrototype - gun constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/GunPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.GunPrototype
function extendBase:GunPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "gun",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.gun = extendBase.GunPrototype

--- ItemWithEntityDataPrototype - item-with-entity-data
---@class KuxCoreLib.PrototypeData.Extent.ItemWithEntityDataPrototype : data.ItemWithEntityDataPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemWithEntityDataPrototype.html)

--- ItemWithEntityDataPrototype - item-with-entity-data constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemWithEntityDataPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemWithEntityDataPrototype
function extendBase:ItemWithEntityDataPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "item-with-entity-data",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item_with_entity_data = extendBase.ItemWithEntityDataPrototype

--- ItemWithLabelPrototype - item-with-label
---@class KuxCoreLib.PrototypeData.Extent.ItemWithLabelPrototype : data.ItemWithLabelPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemWithLabelPrototype.html)

--- ItemWithLabelPrototype - item-with-label constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemWithLabelPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemWithLabelPrototype
function extendBase:ItemWithLabelPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "item-with-label",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item_with_label = extendBase.ItemWithLabelPrototype

--- ItemWithInventoryPrototype - item-with-inventory
---@class KuxCoreLib.PrototypeData.Extent.ItemWithInventoryPrototype : data.ItemWithInventoryPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemWithInventoryPrototype.html)

--- ItemWithInventoryPrototype - item-with-inventory constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemWithInventoryPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemWithInventoryPrototype
function extendBase:ItemWithInventoryPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "item-with-inventory",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item_with_inventory = extendBase.ItemWithInventoryPrototype

--- BlueprintBookPrototype - blueprint-book
---@class KuxCoreLib.PrototypeData.Extent.BlueprintBookPrototype : data.BlueprintBookPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BlueprintBookPrototype.html)

--- BlueprintBookPrototype - blueprint-book constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BlueprintBookPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BlueprintBookPrototype
function extendBase:BlueprintBookPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "blueprint-book",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.blueprint_book = extendBase.BlueprintBookPrototype

--- ItemWithTagsPrototype - item-with-tags
---@class KuxCoreLib.PrototypeData.Extent.ItemWithTagsPrototype : data.ItemWithTagsPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemWithTagsPrototype.html)

--- ItemWithTagsPrototype - item-with-tags constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemWithTagsPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemWithTagsPrototype
function extendBase:ItemWithTagsPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "item-with-tags",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item_with_tags = extendBase.ItemWithTagsPrototype

--- SelectionToolPrototype - selection-tool
---@class KuxCoreLib.PrototypeData.Extent.SelectionToolPrototype : data.SelectionToolPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SelectionToolPrototype.html)

--- SelectionToolPrototype - selection-tool constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SelectionToolPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SelectionToolPrototype
function extendBase:SelectionToolPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "selection-tool",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.selection_tool = extendBase.SelectionToolPrototype

--- BlueprintItemPrototype - blueprint
---@class KuxCoreLib.PrototypeData.Extent.BlueprintItemPrototype : data.BlueprintItemPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/BlueprintItemPrototype.html)

--- BlueprintItemPrototype - blueprint constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/BlueprintItemPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.BlueprintItemPrototype
function extendBase:BlueprintItemPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "blueprint",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.blueprint = extendBase.BlueprintItemPrototype

--- CopyPasteToolPrototype - copy-paste-tool
---@class KuxCoreLib.PrototypeData.Extent.CopyPasteToolPrototype : data.CopyPasteToolPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/CopyPasteToolPrototype.html)

--- CopyPasteToolPrototype - copy-paste-tool constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/CopyPasteToolPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CopyPasteToolPrototype
function extendBase:CopyPasteToolPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "copy-paste-tool",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.copy_paste_tool = extendBase.CopyPasteToolPrototype

--- DeconstructionItemPrototype - deconstruction-item
---@class KuxCoreLib.PrototypeData.Extent.DeconstructionItemPrototype : data.DeconstructionItemPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/DeconstructionItemPrototype.html)

--- DeconstructionItemPrototype - deconstruction-item constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/DeconstructionItemPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DeconstructionItemPrototype
function extendBase:DeconstructionItemPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "deconstruction-item",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.deconstruction_item = extendBase.DeconstructionItemPrototype

--- SpidertronRemotePrototype - spidertron-remote
---@class KuxCoreLib.PrototypeData.Extent.SpidertronRemotePrototype : data.SpidertronRemotePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpidertronRemotePrototype.html)

--- SpidertronRemotePrototype - spidertron-remote constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpidertronRemotePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpidertronRemotePrototype
function extendBase:SpidertronRemotePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "spidertron-remote",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.spidertron_remote = extendBase.SpidertronRemotePrototype

--- UpgradeItemPrototype - upgrade-item
---@class KuxCoreLib.PrototypeData.Extent.UpgradeItemPrototype : data.UpgradeItemPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/UpgradeItemPrototype.html)

--- UpgradeItemPrototype - upgrade-item constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/UpgradeItemPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.UpgradeItemPrototype
function extendBase:UpgradeItemPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "upgrade-item",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.upgrade_item = extendBase.UpgradeItemPrototype

--- ModulePrototype - module
---@class KuxCoreLib.PrototypeData.Extent.ModulePrototype : data.ModulePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ModulePrototype.html)

--- ModulePrototype - module constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ModulePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ModulePrototype
function extendBase:ModulePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "module",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.module = extendBase.ModulePrototype

--- RailPlannerPrototype - rail-planner
---@class KuxCoreLib.PrototypeData.Extent.RailPlannerPrototype : data.RailPlannerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RailPlannerPrototype.html)

--- RailPlannerPrototype - rail-planner constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RailPlannerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RailPlannerPrototype
function extendBase:RailPlannerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "rail-planner",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.rail_planner = extendBase.RailPlannerPrototype

--- SpacePlatformStarterPackPrototype - space-platform-starter-pack
---@class KuxCoreLib.PrototypeData.Extent.SpacePlatformStarterPackPrototype : data.SpacePlatformStarterPackPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpacePlatformStarterPackPrototype.html)

--- SpacePlatformStarterPackPrototype - space-platform-starter-pack constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpacePlatformStarterPackPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpacePlatformStarterPackPrototype
function extendBase:SpacePlatformStarterPackPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "space-platform-starter-pack",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.space_platform_starter_pack = extendBase.SpacePlatformStarterPackPrototype

--- ToolPrototype - tool
---@class KuxCoreLib.PrototypeData.Extent.ToolPrototype : data.ToolPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ToolPrototype.html)

--- ToolPrototype - tool constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ToolPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ToolPrototype
function extendBase:ToolPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "tool",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.tool = extendBase.ToolPrototype

--- ArmorPrototype - armor
---@class KuxCoreLib.PrototypeData.Extent.ArmorPrototype : data.ArmorPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ArmorPrototype.html)

--- ArmorPrototype - armor constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ArmorPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ArmorPrototype
function extendBase:ArmorPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "armor",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.armor = extendBase.ArmorPrototype

--- RepairToolPrototype - repair-tool
---@class KuxCoreLib.PrototypeData.Extent.RepairToolPrototype : data.RepairToolPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RepairToolPrototype.html)

--- RepairToolPrototype - repair-tool constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RepairToolPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RepairToolPrototype
function extendBase:RepairToolPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "repair-tool",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.repair_tool = extendBase.RepairToolPrototype

--- ItemSubGroup - item-subgroup
---@class KuxCoreLib.PrototypeData.Extent.ItemSubGroup : data.ItemSubGroup
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ItemSubGroup.html)

--- ItemSubGroup - item-subgroup constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ItemSubGroup.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ItemSubGroup
function extendBase:ItemSubGroup(t)
	local d = utils.merge(self["common"], t, {
		type          = "item-subgroup",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.item_subgroup = extendBase.ItemSubGroup

--- ModuleCategory - module-category
---@class KuxCoreLib.PrototypeData.Extent.ModuleCategory : data.ModuleCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ModuleCategory.html)

--- ModuleCategory - module-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ModuleCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ModuleCategory
function extendBase:ModuleCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "module-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.module_category = extendBase.ModuleCategory

--- NamedNoiseExpression - noise-expression
---@class KuxCoreLib.PrototypeData.Extent.NamedNoiseExpression : data.NamedNoiseExpression
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/NamedNoiseExpression.html)

--- NamedNoiseExpression - noise-expression constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/NamedNoiseExpression.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.NamedNoiseExpression
function extendBase:NamedNoiseExpression(t)
	local d = utils.merge(self["common"], t, {
		type          = "noise-expression",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.noise_expression = extendBase.NamedNoiseExpression

--- NamedNoiseFunction - noise-function
---@class KuxCoreLib.PrototypeData.Extent.NamedNoiseFunction : data.NamedNoiseFunction
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/NamedNoiseFunction.html)

--- NamedNoiseFunction - noise-function constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/NamedNoiseFunction.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.NamedNoiseFunction
function extendBase:NamedNoiseFunction(t)
	local d = utils.merge(self["common"], t, {
		type          = "noise-function",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.noise_function = extendBase.NamedNoiseFunction

--- ParticlePrototype - optimized-particle
---@class KuxCoreLib.PrototypeData.Extent.ParticlePrototype : data.ParticlePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ParticlePrototype.html)

--- ParticlePrototype - optimized-particle constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ParticlePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ParticlePrototype
function extendBase:ParticlePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "optimized-particle",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.optimized_particle = extendBase.ParticlePrototype

--- ProcessionLayerInheritanceGroup - procession-layer-inheritance-group
---@class KuxCoreLib.PrototypeData.Extent.ProcessionLayerInheritanceGroup : data.ProcessionLayerInheritanceGroup
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ProcessionLayerInheritanceGroup.html)

--- ProcessionLayerInheritanceGroup - procession-layer-inheritance-group constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ProcessionLayerInheritanceGroup.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ProcessionLayerInheritanceGroup
function extendBase:ProcessionLayerInheritanceGroup(t)
	local d = utils.merge(self["common"], t, {
		type          = "procession-layer-inheritance-group",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.procession_layer_inheritance_group = extendBase.ProcessionLayerInheritanceGroup

--- ProcessionPrototype - procession
---@class KuxCoreLib.PrototypeData.Extent.ProcessionPrototype : data.ProcessionPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ProcessionPrototype.html)

--- ProcessionPrototype - procession constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ProcessionPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ProcessionPrototype
function extendBase:ProcessionPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "procession",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.procession = extendBase.ProcessionPrototype

--- QualityPrototype - quality
---@class KuxCoreLib.PrototypeData.Extent.QualityPrototype : data.QualityPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/QualityPrototype.html)

--- QualityPrototype - quality constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/QualityPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.QualityPrototype
function extendBase:QualityPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "quality",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.quality = extendBase.QualityPrototype

--- RecipeCategory - recipe-category
---@class KuxCoreLib.PrototypeData.Extent.RecipeCategory : data.RecipeCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RecipeCategory.html)

--- RecipeCategory - recipe-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RecipeCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RecipeCategory
function extendBase:RecipeCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "recipe-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.recipe_category = extendBase.RecipeCategory

--- RecipePrototype - recipe
---@class KuxCoreLib.PrototypeData.Extent.RecipePrototype : data.RecipePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RecipePrototype.html)

--- RecipePrototype - recipe constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RecipePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RecipePrototype
function extendBase:RecipePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "recipe",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.recipe = extendBase.RecipePrototype

--- ResourceCategory - resource-category
---@class KuxCoreLib.PrototypeData.Extent.ResourceCategory : data.ResourceCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ResourceCategory.html)

--- ResourceCategory - resource-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ResourceCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ResourceCategory
function extendBase:ResourceCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "resource-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.resource_category = extendBase.ResourceCategory

--- ShortcutPrototype - shortcut
---@class KuxCoreLib.PrototypeData.Extent.ShortcutPrototype : data.ShortcutPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/ShortcutPrototype.html)

--- ShortcutPrototype - shortcut constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/ShortcutPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.ShortcutPrototype
function extendBase:ShortcutPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "shortcut",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.shortcut = extendBase.ShortcutPrototype

--- SpaceConnectionPrototype - space-connection
---@class KuxCoreLib.PrototypeData.Extent.SpaceConnectionPrototype : data.SpaceConnectionPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpaceConnectionPrototype.html)

--- SpaceConnectionPrototype - space-connection constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpaceConnectionPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpaceConnectionPrototype
function extendBase:SpaceConnectionPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "space-connection",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.space_connection = extendBase.SpaceConnectionPrototype

--- SpaceLocationPrototype - space-location
---@class KuxCoreLib.PrototypeData.Extent.SpaceLocationPrototype : data.SpaceLocationPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpaceLocationPrototype.html)

--- SpaceLocationPrototype - space-location constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpaceLocationPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpaceLocationPrototype
function extendBase:SpaceLocationPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "space-location",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.space_location = extendBase.SpaceLocationPrototype

--- PlanetPrototype - planet
---@class KuxCoreLib.PrototypeData.Extent.PlanetPrototype : data.PlanetPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/PlanetPrototype.html)

--- PlanetPrototype - planet constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/PlanetPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.PlanetPrototype
function extendBase:PlanetPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "planet",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.planet = extendBase.PlanetPrototype

--- SurfacePropertyPrototype - surface-property
---@class KuxCoreLib.PrototypeData.Extent.SurfacePropertyPrototype : data.SurfacePropertyPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SurfacePropertyPrototype.html)

--- SurfacePropertyPrototype - surface-property constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SurfacePropertyPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SurfacePropertyPrototype
function extendBase:SurfacePropertyPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "surface-property",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.surface_property = extendBase.SurfacePropertyPrototype

--- SurfacePrototype - surface
---@class KuxCoreLib.PrototypeData.Extent.SurfacePrototype : data.SurfacePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SurfacePrototype.html)

--- SurfacePrototype - surface constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SurfacePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SurfacePrototype
function extendBase:SurfacePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "surface",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.surface = extendBase.SurfacePrototype

--- TechnologyPrototype - technology
---@class KuxCoreLib.PrototypeData.Extent.TechnologyPrototype : data.TechnologyPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TechnologyPrototype.html)

--- TechnologyPrototype - technology constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TechnologyPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TechnologyPrototype
function extendBase:TechnologyPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "technology",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.technology = extendBase.TechnologyPrototype

--- TilePrototype - tile
---@class KuxCoreLib.PrototypeData.Extent.TilePrototype : data.TilePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TilePrototype.html)

--- TilePrototype - tile constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TilePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TilePrototype
function extendBase:TilePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "tile",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.tile = extendBase.TilePrototype

--- TrivialSmokePrototype - trivial-smoke
---@class KuxCoreLib.PrototypeData.Extent.TrivialSmokePrototype : data.TrivialSmokePrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TrivialSmokePrototype.html)

--- TrivialSmokePrototype - trivial-smoke constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TrivialSmokePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TrivialSmokePrototype
function extendBase:TrivialSmokePrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "trivial-smoke",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.trivial_smoke = extendBase.TrivialSmokePrototype

--- VirtualSignalPrototype - virtual-signal
---@class KuxCoreLib.PrototypeData.Extent.VirtualSignalPrototype : data.VirtualSignalPrototype
---@field type string?
---@field name string?
---@field [1] string name
---@field [2] string icon
---@field [3] int? icon_size
---[View documentation](https://lua-api.factorio.com/latest/prototypes/VirtualSignalPrototype.html)

--- VirtualSignalPrototype - virtual-signal constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/VirtualSignalPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.VirtualSignalPrototype
function extendBase:VirtualSignalPrototype(t)
	local path = (self["common"] and self["common"].path) or "";
	local d = utils.merge(self["common"], t, {
		type       = "virtual-signal",
		name       = utils.getName(self, t.name or t[1]),
		icon       = path..(t[2] or t.icon or (t.icons == nil and error("filename is required"))),
		icon_size  = self["common"].icon_size or t[3],-- or 64,
	})
	d.path = nil --clear auxiliary field from common
	data:extend{d}
	return d
end
extendBase.virtual_signal = extendBase.VirtualSignalPrototype

--- TipsAndTricksItem - tips-and-tricks-item
---@class KuxCoreLib.PrototypeData.Extent.TipsAndTricksItem : data.TipsAndTricksItem
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TipsAndTricksItem.html)

--- TipsAndTricksItem - tips-and-tricks-item constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TipsAndTricksItem.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TipsAndTricksItem
function extendBase:TipsAndTricksItem(t)
	local d = utils.merge(self["common"], t, {
		type          = "tips-and-tricks-item",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.tips_and_tricks_item = extendBase.TipsAndTricksItem

--- TutorialDefinition - tutorial
---@class KuxCoreLib.PrototypeData.Extent.TutorialDefinition : data.TutorialDefinition
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TutorialDefinition.html)

--- TutorialDefinition - tutorial constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TutorialDefinition.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TutorialDefinition
function extendBase:TutorialDefinition(t)
	local d = utils.merge(self["common"], t, {
		type          = "tutorial",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.tutorial = extendBase.TutorialDefinition

--- UtilityConstants - utility-constants
---@class KuxCoreLib.PrototypeData.Extent.UtilityConstants : data.UtilityConstants
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/UtilityConstants.html)

--- UtilityConstants - utility-constants constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/UtilityConstants.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.UtilityConstants
function extendBase:UtilityConstants(t)
	local d = utils.merge(self["common"], t, {
		type          = "utility-constants",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.utility_constants = extendBase.UtilityConstants

--- UtilitySounds - utility-sounds
---@class KuxCoreLib.PrototypeData.Extent.UtilitySounds : data.UtilitySounds
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/UtilitySounds.html)

--- UtilitySounds - utility-sounds constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/UtilitySounds.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.UtilitySounds
function extendBase:UtilitySounds(t)
	local d = utils.merge(self["common"], t, {
		type          = "utility-sounds",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.utility_sounds = extendBase.UtilitySounds

--- UtilitySprites - utility-sprites
---@class KuxCoreLib.PrototypeData.Extent.UtilitySprites : data.UtilitySprites
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/UtilitySprites.html)

--- UtilitySprites - utility-sprites constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/UtilitySprites.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.UtilitySprites
function extendBase:UtilitySprites(t)
	local d = utils.merge(self["common"], t, {
		type          = "utility-sprites",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.utility_sprites = extendBase.UtilitySprites

--- RemoteControllerPrototype - remote-controller
---@class KuxCoreLib.PrototypeData.Extent.RemoteControllerPrototype : data.RemoteControllerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/RemoteControllerPrototype.html)

--- RemoteControllerPrototype - remote-controller constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/RemoteControllerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.RemoteControllerPrototype
function extendBase:RemoteControllerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "remote-controller",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.remote_controller = extendBase.RemoteControllerPrototype

--- SoundPrototype - sound
---@class KuxCoreLib.PrototypeData.Extent.SoundPrototype : data.SoundPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SoundPrototype.html)

--- SoundPrototype - sound constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SoundPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SoundPrototype
function extendBase:SoundPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "sound",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.sound = extendBase.SoundPrototype

--- SpectatorControllerPrototype - spectator-controller
---@class KuxCoreLib.PrototypeData.Extent.SpectatorControllerPrototype : data.SpectatorControllerPrototype
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpectatorControllerPrototype.html)

--- SpectatorControllerPrototype - spectator-controller constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpectatorControllerPrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpectatorControllerPrototype
function extendBase:SpectatorControllerPrototype(t)
	local d = utils.merge(self["common"], t, {
		type          = "spectator-controller",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.spectator_controller = extendBase.SpectatorControllerPrototype

--- SpritePrototype - sprite
---@class KuxCoreLib.PrototypeData.Extent.SpritePrototype : data.SpritePrototype
---@field type string?
---@field name string?
---@field [1] string name
---@field [2] string filename
---[View documentation](https://lua-api.factorio.com/latest/prototypes/SpritePrototype.html)

--- SpritePrototype - sprite constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/SpritePrototype.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.SpritePrototype
function extendBase:SpritePrototype(t)
	local path = (self["common"] and self["common"].path) or "";
	local d = utils.merge(self["common"], t, {
		type          = "sprite",
		name          = utils.getName(self, t.name or t[1]),
		filename      = path..(t[2] or t.filename or error("filename is required")),
	})
	d.path = nil --clear auxiliary field from common
	data:extend{d}
	return d
end
extendBase.sprite = extendBase.SpritePrototype

--- TileEffectDefinition - tile-effect
---@class KuxCoreLib.PrototypeData.Extent.TileEffectDefinition : data.TileEffectDefinition
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TileEffectDefinition.html)

--- TileEffectDefinition - tile-effect constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TileEffectDefinition.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TileEffectDefinition
function extendBase:TileEffectDefinition(t)
	local d = utils.merge(self["common"], t, {
		type          = "tile-effect",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.tile_effect = extendBase.TileEffectDefinition

--- TipsAndTricksItemCategory - tips-and-tricks-item-category
---@class KuxCoreLib.PrototypeData.Extent.TipsAndTricksItemCategory : data.TipsAndTricksItemCategory
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TipsAndTricksItemCategory.html)

--- TipsAndTricksItemCategory - tips-and-tricks-item-category constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TipsAndTricksItemCategory.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TipsAndTricksItemCategory
function extendBase:TipsAndTricksItemCategory(t)
	local d = utils.merge(self["common"], t, {
		type          = "tips-and-tricks-item-category",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.tips_and_tricks_item_category = extendBase.TipsAndTricksItemCategory

--- TriggerTargetType - trigger-target-type
---@class KuxCoreLib.PrototypeData.Extent.TriggerTargetType : data.TriggerTargetType
---@field type string?
---@field name string?
---@field [1] string name
---[View documentation](https://lua-api.factorio.com/latest/prototypes/TriggerTargetType.html)

--- TriggerTargetType - trigger-target-type constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/prototypes/TriggerTargetType.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.TriggerTargetType
function extendBase:TriggerTargetType(t)
	local d = utils.merge(self["common"], t, {
		type          = "trigger-target-type",
		name          = utils.getName(self, t.name or t[1]),
	})
	data:extend{d}
	return d
end
extendBase.trigger_target_type = extendBase.TriggerTargetType



return extendBase