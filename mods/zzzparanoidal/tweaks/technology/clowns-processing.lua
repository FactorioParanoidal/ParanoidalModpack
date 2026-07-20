-- Clowns-Processing 2.0.14 references the retired Bob's tungsten alloy technology.
local technology = data.raw.technology["centrifuging-2"]
if technology then
    for index, prerequisite in pairs(technology.prerequisites or {}) do
        if prerequisite == "bob-tungsten-alloy-processing" then
            technology.prerequisites[index] = "bob-tungsten-processing"
        end
    end
end
