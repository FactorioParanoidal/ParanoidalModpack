require("add-basic-uranium-nukes")

if (data.raw.technology["expanded-atomics"]) then
	data.raw.technology["expanded-atomics"].prerequisites[2] = "plutonium-breeding"
end
if (data.raw.technology["californium-processing"]) then
	data.raw.technology["californium-processing"].prerequisites[1] = "plutonium-breeding"
end

if (data.raw.technology["dense-neutron-flux"]) then
  data.raw.technology["dense-neutron-flux"].effects[1] = nil
end




