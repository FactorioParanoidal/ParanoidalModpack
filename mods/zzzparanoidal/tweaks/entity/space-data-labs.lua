-- Run after lab input collectors and the restoration of the super labs.
-- Keep ERP data exclusive to its data center; ordinary white science is unchanged.
for name, lab in pairs(data.raw.lab) do
    if name ~= "erp-lab" then
        local inputs = {}
        for _, input in ipairs(lab.inputs or {}) do
            if input ~= "planetary-data" and input ~= "station-science" then
                inputs[#inputs + 1] = input
            end
        end
        -- Do not mutate an input table potentially shared with erp-lab.
        lab.inputs = inputs
    end
end
