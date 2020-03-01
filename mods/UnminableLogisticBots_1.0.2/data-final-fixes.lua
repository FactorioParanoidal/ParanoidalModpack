--Initialization
local unminableConstruction = settings.startup["unminableConstruction"].value
local unminableLogistic = settings.startup["unminableLogistic"].value

--Unminable Construction
local types = {"construction-robot"}
local bots = {}

for _, bot in pairs(types) do
    for _, e in pairs(data.raw[bot]) do
        if bot == "construction-robot" and unminableConstruction then
            e.minable = nil
        end
    end
end

--Unminable Logistic
local types = {"logistic-robot"}
local bots = {}

for _, bot in pairs(types) do
    for _, e in pairs(data.raw[bot]) do
        if bot == "logistic-robot" and unminableLogistic then
            e.minable = nil
        end
    end
end