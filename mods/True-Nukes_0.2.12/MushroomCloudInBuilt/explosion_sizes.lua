
local small_explosion_LUQ = table.deepcopy(data.raw.explosion["uranium-explosion-LUQ"])
small_explosion_LUQ.name = "small-uranium-explosion-LUQ"
small_explosion_LUQ.animations[1].scale = small_explosion_LUQ.animations[1].scale/2
small_explosion_LUQ.animations[1].shift = {-8,-8}
local small_explosion_RUQ = table.deepcopy(data.raw.explosion["uranium-explosion-RUQ"])
small_explosion_RUQ.name = "small-uranium-explosion-RUQ"
small_explosion_RUQ.animations[1].scale = small_explosion_RUQ.animations[1].scale/2
small_explosion_RUQ.animations[1].shift = {8,-8}
local small_explosion_LLQ = table.deepcopy(data.raw.explosion["uranium-explosion-LLQ"])
small_explosion_LLQ.name = "small-uranium-explosion-LLQ"
small_explosion_LLQ.animations[1].scale = small_explosion_LLQ.animations[1].scale/2
small_explosion_LLQ.animations[1].shift = {-8,8}
local small_explosion_RLQ = table.deepcopy(data.raw.explosion["uranium-explosion-RLQ"])
small_explosion_RLQ.name = "small-uranium-explosion-RLQ"
small_explosion_RLQ.animations[1].scale = small_explosion_RLQ.animations[1].scale/2
small_explosion_RLQ.animations[1].shift = {8,8}
data:extend({small_explosion_LUQ,small_explosion_RUQ,small_explosion_LLQ,small_explosion_RLQ})
	
--allow definition of high-res versions.
if (data.raw.explosion["big-uranium-explosion-LUQ"] ==nil) then
	local big_explosion_LUQ = table.deepcopy(data.raw.explosion["uranium-explosion-LUQ"])
	big_explosion_LUQ.name = "big-uranium-explosion-LUQ"
	big_explosion_LUQ.animations[1].scale = big_explosion_LUQ.animations[1].scale*2
	big_explosion_LUQ.animations[1].shift = {-32,-32}
	local big_explosion_RUQ = table.deepcopy(data.raw.explosion["uranium-explosion-RUQ"])
	big_explosion_RUQ.name = "big-uranium-explosion-RUQ"
	big_explosion_RUQ.animations[1].scale = big_explosion_RUQ.animations[1].scale*2
	big_explosion_RUQ.animations[1].shift = {32,-32}
	local big_explosion_LLQ = table.deepcopy(data.raw.explosion["uranium-explosion-LLQ"])
	big_explosion_LLQ.name = "big-uranium-explosion-LLQ"
	big_explosion_LLQ.animations[1].scale = big_explosion_LLQ.animations[1].scale*2
	big_explosion_LLQ.animations[1].shift = {-32,32}
	local big_explosion_RLQ = table.deepcopy(data.raw.explosion["uranium-explosion-RLQ"])
	big_explosion_RLQ.name = "big-uranium-explosion-RLQ"
	big_explosion_RLQ.animations[1].scale = big_explosion_RLQ.animations[1].scale*2
	big_explosion_RLQ.animations[1].shift = {32,32}
	data:extend({big_explosion_LUQ,big_explosion_RUQ,big_explosion_LLQ,big_explosion_RLQ})
end

local huge_explosion_LUQ = table.deepcopy(data.raw.explosion["big-uranium-explosion-LUQ"])
huge_explosion_LUQ.name = "huge-uranium-explosion-LUQ"
huge_explosion_LUQ.animations[1].scale = huge_explosion_LUQ.animations[1].scale*2
huge_explosion_LUQ.animations[1].shift = {-64,-64}
local huge_explosion_RUQ = table.deepcopy(data.raw.explosion["big-uranium-explosion-RUQ"])
huge_explosion_RUQ.name = "huge-uranium-explosion-RUQ"
huge_explosion_RUQ.animations[1].scale = huge_explosion_RUQ.animations[1].scale*2
huge_explosion_RUQ.animations[1].shift = {64,-64}
local huge_explosion_LLQ = table.deepcopy(data.raw.explosion["big-uranium-explosion-LLQ"])
huge_explosion_LLQ.name = "huge-uranium-explosion-LLQ"
huge_explosion_LLQ.animations[1].scale = huge_explosion_LLQ.animations[1].scale*2
huge_explosion_LLQ.animations[1].shift = {-64,64}
local huge_explosion_RLQ = table.deepcopy(data.raw.explosion["big-uranium-explosion-RLQ"])
huge_explosion_RLQ.name = "huge-uranium-explosion-RLQ"
huge_explosion_RLQ.animations[1].scale = huge_explosion_RLQ.animations[1].scale*2
huge_explosion_RLQ.animations[1].shift = {64,64}
data:extend({huge_explosion_LUQ,huge_explosion_RUQ,huge_explosion_LLQ,huge_explosion_RLQ})


local really_huge_explosion_LUQ = table.deepcopy(data.raw.explosion["big-uranium-explosion-LUQ"])
really_huge_explosion_LUQ.name = "really-huge-uranium-explosion-LUQ"
really_huge_explosion_LUQ.animations[1].scale = really_huge_explosion_LUQ.animations[1].scale*4
really_huge_explosion_LUQ.animations[1].shift = {-128,-128}
local really_huge_explosion_RUQ = table.deepcopy(data.raw.explosion["big-uranium-explosion-RUQ"])
really_huge_explosion_RUQ.name = "really-huge-uranium-explosion-RUQ"
really_huge_explosion_RUQ.animations[1].scale = really_huge_explosion_RUQ.animations[1].scale*4
really_huge_explosion_RUQ.animations[1].shift = {128,-128}
local really_huge_explosion_LLQ = table.deepcopy(data.raw.explosion["big-uranium-explosion-LLQ"])
really_huge_explosion_LLQ.name = "really-huge-uranium-explosion-LLQ"
really_huge_explosion_LLQ.animations[1].scale = really_huge_explosion_LLQ.animations[1].scale*4
really_huge_explosion_LLQ.animations[1].shift = {-128,128}
local really_huge_explosion_RLQ = table.deepcopy(data.raw.explosion["big-uranium-explosion-RLQ"])
really_huge_explosion_RLQ.name = "really-huge-uranium-explosion-RLQ"
really_huge_explosion_RLQ.animations[1].scale = really_huge_explosion_RLQ.animations[1].scale*4
really_huge_explosion_RLQ.animations[1].shift = {128,128}
data:extend({really_huge_explosion_LUQ, really_huge_explosion_RUQ, really_huge_explosion_LLQ, really_huge_explosion_RLQ})
