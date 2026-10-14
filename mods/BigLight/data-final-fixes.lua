require("lualib/mining-drill/bigLight")
require("lualib/train/bigLight")

----------------------------------- ELECTRIC MINING DRILL

--ritnmods
if ritnmods then
    if ritnmods.glass and ritnmods.electronic then 
        electric_mining_drill("ritn-electric-mining-drill")
    end
end

----------------------------------- TRAIN
--vanilla
local lit_stops = {}
local function light_stop(name)
    if lit_stops[name] or not data.raw["train-stop"][name] then return end
    lit_stops[name] = true
    train_stop(name)
end

if not mods["trainstopnostalgia"] then
    light_stop("train-stop")
end

--LTN
if mods["LogisticTrainNetwork"] then
    light_stop("logistic-train-stop")
end

--Cybersyn (Paranoidal): has no own stop entity and works with the vanilla train stop.
if mods["cybersyn"] then
    light_stop("train-stop")
end

if mods["train-scaling"] then
    train_stop("train-scaling-stop")
end

