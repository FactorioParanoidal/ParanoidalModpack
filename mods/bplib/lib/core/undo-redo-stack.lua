-- Methods for working with the LuaUndoRedoStack

local lib = {}

---Paper over the fact that LuaUndoRedoStack methods are named differently
---for undo and redo and therefore can't be abstracted over.
---@class (exact) Core.UndoRedoStackView
---@field public get_item_count fun(): uint
---@field public get_item fun(index: uint): UndoRedoAction[]
---@field public get_tag fun(item_index: uint, action_index: uint, tag_name: string): AnyBasic
---@field public get_tags fun(item_index: uint, action_index: uint): Tags
---@field public set_tag fun(item_index: uint, action_index: uint, tag_name: string, tag: AnyBasic)
---@field public remove_tag fun(item_index: uint, action_index: uint, tag_name: string)

---Make a view into the given undo stack.
---@param urs LuaUndoRedoStack
function lib.make_undo_stack_view(urs)
	---@type Core.UndoRedoStackView
	local view = {
		-- This type mismatch is a Factorio doc bug.
		get_item_count = function() return urs.get_undo_item_count() end,
		get_item = function(index) return urs.get_undo_item(index) end,
		get_tag = function(item_index, action_index, tag_name)
			return urs.get_undo_tag(item_index, action_index, tag_name)
		end,
		get_tags = function(item_index, action_index)
			return urs.get_undo_tags(item_index, action_index)
		end,
		set_tag = function(item_index, action_index, tag_name, tag)
			urs.set_undo_tag(item_index, action_index, tag_name, tag)
		end,
		remove_tag = function(item_index, action_index, tag_name)
			urs.remove_undo_tag(item_index, action_index, tag_name)
		end,
	}
	return view
end

---Make a view into the given redo stack.
---@param urs LuaUndoRedoStack
function lib.make_redo_stack_view(urs)
	---@type Core.UndoRedoStackView
	local view = {
		-- This type mismatch is a Factorio doc bug.
		get_item_count = function() return urs.get_redo_item_count() end,
		get_item = function(index) return urs.get_redo_item(index) end,
		get_tag = function(item_index, action_index, tag_name)
			return urs.get_redo_tag(item_index, action_index, tag_name)
		end,
		get_tags = function(item_index, action_index)
			return urs.get_redo_tags(item_index, action_index)
		end,
		set_tag = function(item_index, action_index, tag_name, tag)
			urs.set_redo_tag(item_index, action_index, tag_name, tag)
		end,
		remove_tag = function(item_index, action_index, tag_name)
			urs.remove_redo_tag(item_index, action_index, tag_name)
		end,
	}
	return view
end

return lib
