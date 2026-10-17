-- Teleporters 2.0.0 задаёт key_sequence = "Control + F": движок не распознаёт регистр
-- ("unknown key_sequence" в логе), горячая клавиша поиска телепорта не работает.
local input = data.raw["custom-input"] and data.raw["custom-input"]["teleporter-focus-search"]
if input and input.key_sequence == "Control + F" then
	input.key_sequence = "CONTROL + F"
end
