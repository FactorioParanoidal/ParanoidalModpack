-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

--- Provides methods and properties for internal use. External use is not recommended.
reskins.internal = reskins.internal or {}

---
---Internal dictionary of deferrable icons, indexed by stage, for assignment in later stages.
---
---@type { [Reskins.Lib.Defines.Stage]: (DeferrableIconData|DeferrableIconDatum)[] }
reskins.internal.deferrable_icons = reskins.internal.deferrable_icons or {}

---
---Performs validation and sanitization of the given `deferrable_icon`, and adds it to the internal
---dictionary of deferrable icons for later assignment in the given `stage`.
---
---### Parameters
---@param stage Reskins.Lib.Defines.Stage # The key to the data stage to store the deferrable icon in.
---@param deferrable_icon DeferrableIconData|DeferrableIconDatum # The icon data to store for deferred assignment.
---
---### See Also
---@see Reskins.Lib.Icons.store_icon_for_deferred_assigment_in_stage
function reskins.internal.store_icon_for_deferred_assigment_in_stage(stage, deferrable_icon)
	reskins.lib.icons.store_icon_for_deferred_assigment_in_stage(reskins.internal.deferrable_icons, stage, deferrable_icon)
end

---
---Assigns the deferrable icons in the internal dictionary of deferrable icons for the given `stage`
---to the associated prototypes.
---
---### Parameters
---@param stage Reskins.Lib.Defines.Stage # The index of the data stage to source deferrable icons from.
---
---### See Also
---@see Reskins.Lib.Icons.assign_icons_deferred_to_stage
function reskins.internal.assign_icons_deferred_to_stage(stage)
	reskins.lib.icons.assign_icons_deferred_to_stage(reskins.internal.deferrable_icons, stage)
end

---@class CreatableLayeredIconDatum
---@field root string
---@field subfolders string[]
---@field name string
---@field base_name? string
---@field mask_name? string
---@field highlight_name? string
---@field icon_size data.SpriteSizeType
---@field layers? 1|2|3 # The number of layers in the icon.

---@class CreatableFlatIconDatum
---@field root string
---@field subfolders string[]
---@field name string

---@class CreatableReskinsIconData
---@field name string
---@field type_name string
---@field reskins_icon_datum CreatableLayeredIconDatum

---@class CreateableFlatIconData
---@field name string
---@field type_name string

---@class AssignOrderInputs
---@field type? string # The type name of the entity to be assigned the order, e.g. `furnace`.
---@field sort_order? data.Order # [Types/Order](https://wiki.factorio.com/Types/Order)
---@field sort_group? string # Unclear; may be deprecated or unused in Factorio
---@field sort_subgroup? string # The name of the `ItemSubGroup` this entity should be sorted into in the map editor building selection.

---@class AssignIconInputs
---@field type string # The type name of the prototype.
---@field icon data.FileName|data.IconData[] # The icon to assign, given as a file name or an array of `IconData` objects.
---@field icon_size? data.SpriteSizeType # Required if `icon` is data.FileName, or not every `IconData` object has an `icon_size` value.
---@field icon_picture? data.SpriteVariations
---@field make_entity_pictures? boolean # When true, entities of type `type` will be assigned the `icon_picture` value.
---@field make_icon_pictures? boolean # When true, valid items will be assigned the `icon_picture` value.

---@class StoreIconsInputs : AssignIconInputs
---@field mod "angels"|"bobs"|"lib"|"compatibility"
---@field defer_to_data_updates? boolean # When `true`, stores the icon for assignment at the end of data-updates. Expected if `defer_to_data_final_fixes` is not set.
---@field defer_to_data_final_fixes? boolean # When `true`, stores the icon for assignment at the end of data-final-fixes. Supersedes `defer_to_data_updates`. Expected if `defer_to_data_updates` is not set.

---The base inputs for `create_icons_from_list`.
---@class CreateIconsFromListInputs : ConstructIconInputsOld, ConstructTechnologyIconInputsOld
---@field type? string # The type name of the prototype; defaults to "item".
---@field mod? "angels"|"bobs"|"lib"|"compatibility" Required if not specified in the overrides.
---@field group? string # Folder under the `graphics/icons` folder. Required if not specified in the overrides.
---@field flat_icon? boolean # When `true`, indicates that the icon is a flat icon with one layer.
---@field image? string # The name of a single image file, without extension, in the `graphics/icons/{group}/{subgroup}` or `graphics/technology/{group}/{subgroup}` folders. Unused if `flat_icon` is not `true`.

---Individual overrides to apply over the base `CreateIconsFromListInputs` object passed to `create_icons_from_list`.
---@class CreateIconsFromListOverrides : CreateIconsFromListInputs
---@field tier? integer # The tier of the icon. An integer value from 0 to 6. Default `nil`.
---@field prog_tier? integer # The tier of the icon, as determined by the progression map. An integer value from 0 to 6. Default `nil`.
---@field uses_belt_mask? boolean # When `true`, indicates that the icon should use the belt tier tint-set. Default `false`.

---A dictionary of `CreateIconsFromListOverrides` objects, keyed by the name of the prototype.
---@class CreateIconsFromListTable : { [string] : CreateIconsFromListOverrides }

---Creates icons from a list of prototypes, applying the given inputs and overrides.
---@param table CreateIconsFromListTable # A dictionary of `CreateIconsFromListOverrides` objects, keyed by the name of the prototype.
---@param inputs CreateIconsFromListInputs # The base inputs to apply to all icons.
function reskins.internal.create_icons_from_list(table, inputs)
	for name, overrides in pairs(table) do
		-- Fetch the icon
		local icon_type = overrides.type or inputs.type or "item"
		local icon = data.raw[icon_type][name]

		-- Check if icon exists, if not, skip this iteration
		if not icon then
			goto continue
		end

		-- Work with a local copy of inputs
		---@type CreateIconsFromListInputs
		local inputs_copy = util.copy(inputs)

		-- Set defaults
		inputs_copy.icon_size = inputs.icon_size or 64
		inputs_copy.technology_icon_size = inputs.technology_icon_size or 128
		inputs_copy.tier_labels = (inputs.tier_labels ~= false)

		-- Handle input parameters
		inputs_copy.type = overrides.type or inputs_copy.type or nil
		inputs_copy.mod = overrides.mod or inputs_copy.mod
		assert(inputs_copy.mod, "A mod must be specified for icon creation.")

		inputs_copy.group = overrides.group or inputs_copy.group
		assert(inputs_copy.group, "A group must be specified for icon creation.")

		inputs_copy.icon_size = overrides.icon_size or inputs_copy.icon_size
		inputs_copy.technology_icon_size = overrides.technology_icon_size or inputs_copy.technology_icon_size
		inputs_copy.subgroup = overrides.subgroup or inputs_copy.subgroup or nil

		-- Transcribe icon properties
		inputs_copy.technology_icon_layers = overrides.technology_icon_layers or inputs_copy.technology_icon_layers or nil
		inputs_copy.icon_layers = overrides.icon_layers or inputs_copy.icon_layers or nil
		inputs_copy.technology_icon_extras = overrides.technology_icon_extras or inputs_copy.technology_icon_extras or nil
		inputs_copy.icon_extras = overrides.icon_extras or inputs_copy.icon_extras or nil
		inputs_copy.icon_picture_extras = overrides.icon_picture_extras or inputs_copy.icon_picture_extras or nil

		-- Handle all the boolean overrides
		if overrides.defer_to_data_updates == false then
			inputs_copy.defer_to_data_updates = false
		else
			inputs_copy.defer_to_data_updates = overrides.defer_to_data_updates or inputs_copy.defer_to_data_updates
		end

		if overrides.defer_to_data_final_fixes == false then
			inputs_copy.defer_to_data_final_fixes = false
		else
			inputs_copy.defer_to_data_final_fixes = overrides.defer_to_data_final_fixes or inputs_copy.defer_to_data_final_fixes
		end

		-- Prevent double assignment
		if inputs_copy.defer_to_data_final_fixes then
			inputs_copy.defer_to_data_updates = nil
		end

		local flat_icon
		if overrides.flat_icon == false then
			flat_icon = false
		else
			flat_icon = overrides.flat_icon or inputs_copy.flat_icon
		end

		-- Construct the icon
		if flat_icon then
			-- Setup filename details
			local image = overrides.image or name
			local subfolder = inputs_copy.group
			if inputs_copy.subgroup then
				subfolder = inputs_copy.group .. "/" .. inputs_copy.subgroup
			end

			-- Make the icon
			if inputs_copy.type == "technology" then
				inputs_copy.technology_icon_filename = overrides.technology_icon_filename or inputs_copy.technology_icon_filename or reskins[inputs_copy.mod].directory .. "/graphics/technology/" .. subfolder .. "/" .. image .. ".png"

				reskins.lib.construct_technology_icon(name, inputs_copy)
			else
				inputs_copy.icon_filename = overrides.icon_filename or inputs_copy.icon_filename or reskins[inputs_copy.mod].directory .. "/graphics/icons/" .. subfolder .. "/" .. image .. ".png"

				reskins.lib.construct_icon(name, 0, inputs_copy --[[@as ConstructIconInputsOld]])
			end
		else
			-- Handle tier
			local tier = overrides.tier or 0
			if reskins.lib.settings.get_value("reskins-lib-tier-mapping") == "progression-map" then
				tier = overrides.prog_tier or overrides.tier or 0
			end

			-- Handle tints
			inputs_copy.tint = overrides.tint or inputs_copy.tint or reskins.lib.tiers.get_tint(tier)

			-- Adjust tint to belt-type if necessary
			if overrides.uses_belt_mask == true then
				inputs_copy.tint = reskins.lib.tiers.get_belt_tint(tier)
			end

			-- Handle icon_name and related parameters
			inputs_copy.icon_name = overrides.icon_name or inputs_copy.icon_name
			inputs_copy.icon_base = overrides.icon_base or inputs_copy.icon_base or nil
			inputs_copy.icon_mask = overrides.icon_mask or inputs_copy.icon_mask or nil
			inputs_copy.icon_highlights = overrides.icon_highlights or inputs_copy.icon_highlights or nil

			-- Make the icon
			if inputs_copy.type == "technology" then
				reskins.lib.construct_technology_icon(name, inputs_copy)
			else
				reskins.lib.construct_icon(name, tier, inputs_copy --[[@as ConstructIconInputsOld]])
			end
		end

		-- Label to skip to next iteration
		::continue::
	end
end
