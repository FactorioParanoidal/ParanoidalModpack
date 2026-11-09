local class = require("lib.core.class").class

---@class StateMachine
local StateMachine = class()

---@param initial_state string
function StateMachine:new(initial_state)
	return setmetatable({ state = initial_state }, self)
end

---Change the current state of the state machine.
---@param new_state string
function StateMachine:set_state(new_state)
	if self.is_changing_state then
		local queue = self.queued_state_changes
		if not queue then
			self.queued_state_changes = { new_state }
		else
			queue[#queue + 1] = new_state
		end
		return
	end

	local old_state = self.state
	if old_state == new_state then return end
	if not self:can_change_state(new_state, old_state) then return end

	self.is_changing_state = true
	self.state = new_state
	self:on_changed_state(new_state, old_state)
	self.is_changing_state = nil

	local queue = self.queued_state_changes
	if queue then
		self.queued_state_changes = nil
		for i = 1, #queue do
			self:set_state(queue[i])
		end
	end
end

---Determine if the state machine can change to the new state.
---Override in subclasses.
---@param new_state string
---@param old_state string|nil
function StateMachine:can_change_state(new_state, old_state) return true end

---Fire events for when state changes. By default, calls `enter_state` methods
---when a state is entered and `exit_state` methods when a state is left.
---Override in subclasses.
---@param new_state string
---@param old_state string|nil
function StateMachine:on_changed_state(new_state, old_state)
	local fromh = self["exit_" .. (old_state or "NO_STATE")]
	local toh = self["enter_" .. new_state]
	if fromh then fromh(self, new_state, old_state) end
	if toh then toh(self, new_state, old_state) end
end

return StateMachine
