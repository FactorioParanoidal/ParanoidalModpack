local setting = data.raw["bool-setting"]["bobmods-burnerphase"]

-- Bob's burner phase stays off, as bobtech and angelsrefining intend with aai-industry:
-- with it on, bobtech adds the "bob-electricity" and "bob-burner-lab" trigger technologies
-- and rebuilds the early electronics/lab progression that the modpack is not balanced for.
-- forced_value applies only to a hidden setting.
if setting then
	setting.hidden = true
	setting.forced_value = false
	setting.default_value = false
end
