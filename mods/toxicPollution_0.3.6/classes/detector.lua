Detector = class(function(self, interval)
    self.name = "Pollution Detector"
    self.signal = {type = "virtual", name = "signal-yellow-more-toxin"}
    self.interval = interval
    self.step = 60
    self.maxTime = interval * self.step
end)

function Detector:init()
    if not global.combinators then
        global.combinators = {}
    end
end

function Detector:CheckEntity(entity)
    if entity.type == "constant-combinator" then
        local behavior = entity.get_control_behavior()
        for i = 1, #behavior.parameters.parameters do
            local signal = behavior.parameters.parameters[i].signal
            if signal ~= nil and signal.name == "signal-yellow-more-toxin" then
                signal.count = math.floor(entity.surface.get_pollution(entity.position))
                if global.combinators[entity.unit_number] == nil then
                    global.combinators[entity.unit_number] = {
                        behavior = behavior,
                        idx = i,
                        surface = entity.surface.name,
                        position = entity.position,
                    }
                end
            end
        end
    end
end

function Detector:DeleteEntity(entity)
    if entity.type == "constant-combinator" then
        global.combinators[entity.unit_number] = nil
    end
end

function Detector:OnTick(event)
    self:init()
    local step = self.step
    while (event.tick - (step * self.interval)) % self.maxTime ~= 0 do
        step = step - 1
    end

    local count = 1
    for _, el in pairs(global.combinators) do
        if el ~= nil then
            if el.behavior.valid == false then
                count = count -1
            elseif (count - step) % self.step == 0 and el.behavior.enabled == true then
                el.behavior.set_signal(el.idx, {
                    signal = self.signal,
                    count = math.floor(game.surfaces[el.surface].get_pollution(el.position))
                })
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