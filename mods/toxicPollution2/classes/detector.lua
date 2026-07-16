Detector = class(function(self, interval)
    self.name = "Pollution Detector"
    self.signal = {type = "virtual", name = "signal-yellow-more-toxin"}
    self.interval = interval
    self.step = 60
    self.maxTime = interval * self.step
end)

function Detector:init()
    if not storage.combinators then
        storage.combinators = {}
    end
end

function Detector:ReadProperty(object, key)
    local ok, value = pcall(function()
        return object[key]
    end)
    if ok then
        return value
    end
    return nil
end

function Detector:SignalValue(signal)
    return {type = signal.type, name = signal.name, quality = "normal"}
end

function Detector:IsPollutionSignal(signal)
    return signal ~= nil and signal.name == self.signal.name
end

function Detector:SetSignal(combinator, count)
    if combinator.section ~= nil then
        local section = combinator.behavior.get_section(combinator.section)
        if section == nil then
            return false
        end

        local filter = section.get_slot(combinator.idx)
        local value = self:SignalValue(self.signal)
        if filter ~= nil and self:IsPollutionSignal(filter.value) then
            value = filter.value
        end

        section.set_slot(combinator.idx, {
            value = value,
            min = count,
        })
        return true
    end

    local set_signal = self:ReadProperty(combinator.behavior, "set_signal")
    if set_signal ~= nil then
        set_signal(combinator.idx, {
            signal = self.signal,
            count = count,
        })
        return true
    end

    return false
end

function Detector:RegisterCombinator(entity, behavior, idx, section)
    local combinator = storage.combinators[entity.unit_number]
    if combinator == nil then
        combinator = {
            behavior = behavior,
            idx = idx,
            section = section,
            surface = entity.surface.name,
            position = entity.position,
        }
        storage.combinators[entity.unit_number] = combinator
    else
        combinator.idx = idx
        combinator.section = section
    end

    self:SetSignal(combinator, math.floor(entity.surface.get_pollution(entity.position)))
end

function Detector:CheckEntity(entity)
    if entity.type == "constant-combinator" then
        local behavior = entity.get_control_behavior()
        local parameters = self:ReadProperty(behavior, "parameters")
        if parameters then
            for i = 1, #parameters do
                local signal = parameters[i].signal
                if self:IsPollutionSignal(signal) then
                    signal.count = math.floor(entity.surface.get_pollution(entity.position))
                    self:RegisterCombinator(entity, behavior, i, nil)
                end
            end
            return
        end

        local sections_count = self:ReadProperty(behavior, "sections_count")
        if sections_count ~= nil then
            for section_index = 1, sections_count do
                local section = behavior.get_section(section_index)
                if section ~= nil then
                    for i = 1, section.filters_count do
                        local filter = section.get_slot(i)
                        if filter ~= nil and self:IsPollutionSignal(filter.value) then
                            self:RegisterCombinator(entity, behavior, i, section_index)
                        end
                    end
                end
            end
        end
    end
end

function Detector:DeleteEntity(entity)
    if entity.type == "constant-combinator" then
        storage.combinators[entity.unit_number] = nil
    end
end

function Detector:OnTick(event)
    self:init()
    local step = self.step
    while (event.tick - (step * self.interval)) % self.maxTime ~= 0 do
        step = step - 1
    end

    local count = 1
    for _, el in pairs(storage.combinators) do
        if el ~= nil then
            if el.behavior.valid == false then
                count = count -1
            elseif (count - step) % self.step == 0 and el.behavior.enabled == true then
                self:SetSignal(el, math.floor(game.surfaces[el.surface].get_pollution(el.position)))
            end
            count = count + 1
        end
    end
end

function Detector:OnGuiClosed(event)
    if event.gui_type == 1 and event.entity ~= nil then
        self:CheckEntity(event.entity)
    end
end

function Detector:OnBuild(event)
    if event.created_entity ~= nil then
        self:CheckEntity(event.created_entity)
    end
end

function Detector:OnSettingPasted(event)
    if event.destination ~= nil then
        self:CheckEntity(event.destination)
    end
end
