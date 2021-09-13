--Удаляем из игры имбовые сельскохозяйственные модули, их рецепты и технологии

if data.raw.module["angels-bio-yield-module"] then

data.raw.module["angels-bio-yield-module"] = nil
data.raw.recipe["angels-bio-yield-module"] = nil
data.raw.technology["angels-bio-yield-module"] = nil
data.raw.module["angels-bio-yield-module-2"] = nil
data.raw.recipe["angels-bio-yield-module-2"] = nil
data.raw.technology["angels-bio-yield-module-2"] = nil
data.raw.module["angels-bio-yield-module-3"] = nil
data.raw.recipe["angels-bio-yield-module-3"] = nil
data.raw.technology["angels-bio-yield-module-3"] = nil

if data.raw.module["angels-bio-yield-module-4"] then

data.raw.module["angels-bio-yield-module-4"] = nil
data.raw.module["angels-bio-yield-module-5"] = nil
data.raw.module["angels-bio-yield-module-6"] = nil
data.raw.module["angels-bio-yield-module-7"] = nil
data.raw.module["angels-bio-yield-module-8"] = nil

data.raw.recipe["angels-bio-yield-module-4"] = nil
data.raw.recipe["angels-bio-yield-module-5"] = nil
data.raw.recipe["angels-bio-yield-module-6"] = nil
data.raw.recipe["angels-bio-yield-module-7"] = nil
data.raw.recipe["angels-bio-yield-module-8"] = nil

data.raw.technology["angels-bio-yield-module-4"] = nil
data.raw.technology["angels-bio-yield-module-5"] = nil
data.raw.technology["angels-bio-yield-module-6"] = nil
data.raw.technology["angels-bio-yield-module-7"] = nil
data.raw.technology["angels-bio-yield-module-8"] = nil
end
end