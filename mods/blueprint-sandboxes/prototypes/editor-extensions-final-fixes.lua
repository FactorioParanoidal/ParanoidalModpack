if data.raw["string-setting"] ~= nil
        and data.raw["string-setting"]["ee-testing-lab"] ~= nil
then
    data.raw["string-setting"]["ee-testing-lab"].hidden = true
    data.raw["string-setting"]["ee-testing-lab"].allowed_values = { "off" }
    data.raw["string-setting"]["ee-testing-lab"].default_value = "off"
end
