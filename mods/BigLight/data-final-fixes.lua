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
if not mods["trainstopnostalgia"] then
    train_stop("train-stop")
end

--LTN
if mods["LogisticTrainNetwork"] then
    train_stop("logistic-train-stop")
end

if mods["train-scaling"] then
    train_stop("train-scaling-stop")
end

