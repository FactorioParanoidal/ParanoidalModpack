-- Fast Underground
if data.raw.recipe["fast-underground-belt"].normal then
data.raw.recipe["express-underground-belt"].normal.ingredients = {
    {"underground-belt",4},
    {"bronze-alloy",10},
    {"steel-gear-wheel",20},
}
data.raw.recipe["fast-underground-belt"].expensive.ingredients = {
    {"underground-belt",4},
    {"bronze-alloy",15},
    {"steel-gear-wheel",40},
}
else
data.raw.recipe["fast-underground-belt"].ingredients = {
    {"underground-belt",4},
    {"bronze-alloy",10},	
    {"steel-gear-wheel",20},
}
end
if mods.bobplates then
-- Express Transport
if data.raw.recipe["express-transport-belt"].normal then
data.raw.recipe["express-transport-belt"].normal.ingredients = {
    {"fast-transport-belt",2},
    {"titanium-gear-wheel",2},
    {"titanium-bearing",1}
}
data.raw.recipe["express-transport-belt"].expensive.ingredients = {
    {"fast-transport-belt",3},
    {"titanium-gear-wheel",2},
    {"titanium-bearing",1}
}
else
data.raw.recipe["express-transport-belt"].ingredients = {
    {"fast-transport-belt",2},
    {"titanium-gear-wheel",2},
    {"titanium-bearing",1}
}
end

-- Express Underground
if data.raw.recipe["express-underground-belt"].normal then
data.raw.recipe["express-underground-belt"].normal.ingredients = {
    {"fast-underground-belt",3},
    {"titanium-gear-wheel",20},
    {"titanium-bearing",10}
}
data.raw.recipe["express-underground-belt"].expensive.ingredients = {
    {"fast-underground-belt",6},
    {"titanium-gear-wheel",40},
    {"titanium-bearing",10}
}
else
data.raw.recipe["express-underground-belt"].ingredients = {
    {"fast-underground-belt",3},
    {"titanium-gear-wheel",20},
    {"titanium-bearing",10}
}
end

-- Express splitter
if data.raw.recipe["express-splitter"].normal then
data.raw.recipe["express-splitter"].normal.ingredients = {
    {"fast-splitter",2},
    {"titanium-gear-wheel",10},
    {"advanced-circuit",10},
    {"titanium-bearing",2}
}
data.raw.recipe["express-splitter"].expensive.ingredients = {
    {"fast-splitter",3},
    {"titanium-gear-wheel",10},
    {"advanced-circuit",10},
    {"titanium-bearing",2}
}
else
data.raw.recipe["express-splitter"].ingredients = {
    {"fast-splitter",2},
    {"titanium-gear-wheel",10},
    {"advanced-circuit",10},
    {"titanium-bearing",2}
}
end

-- Bobs Belts
if mods.boblogistics then
-- Turbo Transport
if data.raw.recipe["turbo-transport-belt"].normal then
data.raw.recipe["express-transport-belt"].normal.ingredients = {
    {"express-transport-belt",2},
    {"nitinol-gear-wheel",2},
    {"nitinol-bearing",1}
}
data.raw.recipe["turbo-transport-belt"].expensive.ingredients = {
    {"express-transport-belt",3},
    {"nitinol-gear-wheel",2},
    {"nitinol-bearing",1}
}
else
data.raw.recipe["turbo-transport-belt"].ingredients = {
    {"express-transport-belt",2},
    {"nitinol-gear-wheel",2},
    {"nitinol-bearing",1}
}
end
-- Turbo Underground
if data.raw.recipe["turbo-underground-belt"].normal then
data.raw.recipe["turbo-underground-belt"].normal.ingredients = {
    {"express-underground-belt",4},
    {"nitinol-gear-wheel",20},
    {"nitinol-bearing",10}
}
data.raw.recipe["turbo-underground-belt"].expensive.ingredients = {
    {"express-underground-belt",6},
    {"nitinol-gear-wheel",40},
    {"nitinol-bearing",10}
}
data.raw.recipe["turbo-underground-belt"].normal.result_count = 3
else
data.raw.recipe["turbo-underground-belt"].ingredients = {
    {"express-underground-belt",4},
    {"nitinol-gear-wheel",20},
    {"nitinol-bearing",10}
}
data.raw.recipe["turbo-underground-belt"].result_count = 3
end
-- Turbo Splitter
if data.raw.recipe["turbo-splitter"].normal then
data.raw.recipe["express-splitter"].normal.ingredients = {
    {"express-splitter",2},
    {"nitinol-gear-wheel",10},
    {"processing-unit",10},
    {"nitinol-bearing",4}
}
data.raw.recipe["turbo-splitter"].expensive.ingredients = {
    {"express-splitter",3},
    {"nitinol-gear-wheel",4},
    {"processing-unit",20},
    {"nitinol-bearing",8}
}
else
data.raw.recipe["turbo-splitter"].ingredients = {
    {"express-splitter",2},
    {"nitinol-gear-wheel",10},
    {"processing-unit",10},
    {"nitinol-bearing",4}
}
end
end
end