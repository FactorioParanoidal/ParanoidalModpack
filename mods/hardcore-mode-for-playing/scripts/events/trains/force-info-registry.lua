require("force-info-holder")
ForceTrainsInfoHolderRegistry = Class()

function ForceTrainsInfoHolderRegistry:init()
    self.registry = {}
    _table.each(
        game.forces,
        function(force)
            self:create_force_info_holder_entry(force)
        end
    )
    self.force_count = _table.size(self.registry)
    self.current_index = 1
end

function ForceTrainsInfoHolderRegistry:handle_found_train(new_holder, train)
    new_holder:insert_train_info_in_holder(train)
end

function ForceTrainsInfoHolderRegistry:handle_surface(new_holder, surface, force)
    _table.each(
        surface.get_trains(force),
        function(train)
            self:handle_found_train(new_holder, train)
            new_holder.count = new_holder.count + 1
        end
    )
end

function ForceTrainsInfoHolderRegistry:create_force_info_holder_entry(force)
    local new_holder = ForceTrainInfoHolder(force)
    local index = 1
    _table.each(
        game.surfaces,
        function(surface)
            self:handle_surface(new_holder, surface, force)
        end
    )
    self.registry[force.index] = new_holder
end

function ForceTrainsInfoHolderRegistry:next_force()
    local result = self.registry[self.current_index]
    if (result.count == result.current_index) or result.count == 0 then
        self.current_index = self.current_index + 1
    end
    if self.current_index == self.force_count then
        self.current_index = 1
    end
    return result
end

function ForceTrainsInfoHolderRegistry:get_by_index(force_index)
    return self.registry[force_index]
end

local force_trains_info_holder_registry_instance = nil
function ForceTrainsInfoHolderRegistry.get_registry_instance()
    if not force_trains_info_holder_registry_instance then
        -- log("create new instance ForceTrainsInfoHolderRegistry")
        force_trains_info_holder_registry_instance = ForceTrainsInfoHolderRegistry()
    end
    return force_trains_info_holder_registry_instance
end
