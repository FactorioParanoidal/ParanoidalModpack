mk_level = {"-1","-2","-3","-4","-5","-6",""}
path = "__ShinyBobGFX__/graphics/entity/"
ipath = "__ShinyBobGFX__/graphics/icons/"
apath = "__ShinyBobGFX__/graphics/icons/old-assembling/"
powerbar = ""

if settings.startup["add-powerbars"].value == true then
powerbar = 1
end

-- function powerbar(name,btype,top)

-- for mk = 1,top do
-- local mk_level = {"","-2","-3","-4","-5","-6",""}
-- local entity = data.raw[btype][name..string.lower(mk_level[mk])]
-- local item = data.raw["item"][name..string.lower(mk_level[mk])]
-- local recipe = data.raw["recipe"][name..string.lower(mk_level[mk])]
-- if entity then
-- if top == 6 then mk = mk-1 end
-- entity.icons.icon[2] = table.deepcopy(entity.icon.layer[1])
-- item.icons.icon[2] = table.deepcopy(item.icon.layer[1])
-- recipe.icons.icon[2] = table.deepcopy(recipe.icon.layer[1])
-- entity.icons.icon[2] = "__ShinyBobGFX__/graphics/icons/num-"..mk..".png"
-- item.icons.icon[2] = "__ShinyBobGFX__/graphics/icons/num-"..mk..".png"
-- recipe.icons.icon[2] = "__ShinyBobGFX__/graphics/icons/num-"..mk..".png"
-- end
-- end
-- end

function bobicon(name,btype,bot,top,off)
for mk = bot,top do
local complete = name..string.lower(mk_level[mk])
local entity = data.raw[btype][complete]
local item = data.raw["item"][complete]
local recipe = data.raw["recipe"][complete]
if mk == 1 then
	if not entity then entity = data.raw[btype][name] end
	if not item then item = data.raw["item"][name] end
	--if not recipe then recipe = data.raw["recipe"][name] end
end


if powerbar == 1 then
	if entity then 
	entity.icon_size = 32
	entity.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} 
	entity.icon = nil
	end
	if item then 
	item.icon_size = 32
	item.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} 
	item.icon = nil
	end
	
	--if recipe then recipe.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
else
	if entity then 
	entity.icon_size = 32
	entity.icon = ipath..complete..".png" end
	if item then 
	item.icon_size = 32
	item.icon = ipath..complete..".png" end
	--if recipe then recipe.icon = ipath..complete..".png" end
end
end
end

function bobicon64(name,btype,bot,top,off)
for mk = bot,top do
local complete = name..string.lower(mk_level[mk])
local entity = data.raw[btype][complete]
local item = data.raw["item"][complete]
local recipe = data.raw["recipe"][complete]
if mk == 1 then
	if not entity then entity = data.raw[btype][name] end
	if not item then item = data.raw["item"][name] end
	--if not recipe then recipe = data.raw["recipe"][name] end
end

if powerbar == 1 then
	if entity then entity.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num64-"..mk-off..".png"}} 
	entity.icon = nil
	end
	if item then item.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num64-"..mk-off..".png"}} 
	item.icon = nil
	end
	
	--if recipe then recipe.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
else
	if entity then entity.icon = ipath..complete..".png" end
	if item then item.icon = ipath..complete..".png" end
	--if recipe then recipe.icon = ipath..complete..".png" end
end
end
end

function powerbaronly(name,btype,bot,top,off)
for mk = bot,top do
local complete = name..string.lower(mk_level[mk])
local entity = data.raw[btype][complete]
local item = data.raw["item"][complete]
local recipe = data.raw["recipe"][complete]
if mk == 1 then
	if not entity then entity = data.raw[btype][name] end
	if not item then item = data.raw["item"][name] end
	--if not recipe then recipe = data.raw["recipe"][name] end
end

if powerbar == 1 then
	if entity then 
		if entity.icon then log "zzzz1" end
		if entity.icons then 
			if entity.icon_size == 64 then
				table.insert (entity.icons,{icon = ipath.."num64-"..mk-off..".png"}) 
				log "zzzz2"
			else
				table.insert (entity.icons,{icon = ipath.."num-"..mk-off..".png"}) 
				log "zzzz3"			
			end
		end
	end
	if item then
		if item.icon then log "zzzz4" end
		if item.icons then
			if item.icon_size == 64 then
				table.insert (item.icons,{icon = ipath.."num64-"..mk-off..".png"})
				log "zzzz5"
			else
				table.insert (item.icons,{icon = ipath.."num-"..mk-off..".png"})
				log "zzzz6"
			end
		end
	end
end
end
end

function bobiconspec(name,btype,bot,top,off)
for mk = bot,top do
local complete = name..string.lower(mk_level[mk])
local entity = data.raw[btype][complete]
local item = data.raw["item-with-entity-data"][complete]
local recipe = data.raw["recipe"][complete]
if mk == 1 then
	-- if not entity then entity = data.raw[btype][name] end
	if not item then item = data.raw["item-with-entity-data"][name] end
	-- if not recipe then recipe = data.raw["recipe"][name] end
end
if powerbar == 1 then
	-- if entity then entity.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
	if item then 
	item.icon_size = 32
	item.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
	-- if recipe then recipe.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
else
	-- if entity then entity.icon = ipath..complete..".png" end
	if item then 
	item.icon_size = 32
	item.icon = ipath..complete..".png" end
	-- if recipe then recipe.icon = ipath..complete..".png" end
end
end
end


function bobitem(name,bot,top,off)
for mk = bot,top do
local complete = name..string.lower(mk_level[mk])
local item = data.raw["item"][complete]
local recipe = data.raw["recipe"][complete]
if mk == 1 then
	if not item then item = data.raw["item"][name] end
	if not recipe then recipe = data.raw["recipe"][name] end
end
if powerbar == 1 then
	if item then item.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
	-- if recipe then recipe.icons = {{icon = ipath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
else
	if item then item.icon = ipath..complete..".png" end
	-- if recipe then recipe.icon = ipath..complete..".png" end
end
end
end


function bobiconNA(name,btype,bot,top,off)
for mk = bot,top do
local complete = name..string.lower(mk_level[mk])
local entity = data.raw[btype][complete]
local item = data.raw["item"][complete]
local recipe = data.raw["recipe"][complete]
if mk == 1 then
	-- if not entity then entity = data.raw[btype][name] end
	if not item then item = data.raw["item"][name] end
	-- if not recipe then recipe = data.raw["recipe"][name] end
end
if powerbar == 1 then
	-- if entity then entity.icons = {{icon = apath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
	if item then item.icons = {{icon = apath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
	-- if recipe then recipe.icons = {{icon = apath..complete..".png"},{icon = ipath.."num-"..mk-off..".png"}} end
else
	-- if entity then entity.icon = apath..complete..".png" end
	if item then item.icon = apath..complete..".png" end
	-- if recipe then recipe.icon = apath..complete..".png" end
end
end
end


function iconfix(name,btype,bot,top,off)
for mk = bot,top do
local complete = name..string.lower(mk_level[mk])
local entity = data.raw[btype][complete]
local item = data.raw["item"][complete]
local recipe = data.raw["recipe"][complete]
-- if not entity then entity = data.raw[btype][name] end
if not item then item = data.raw["item"][name] end
-- if not recipe then recipe = data.raw["recipe"][name] end
	
	-- if entity then entity.icon = ipath..complete..".png" end
	if item then item.icon = ipath..complete..".png" end
	-- if recipe then recipe.icon = ipath..complete..".png" end
end
end

function iconfix2(name,btype,bot,top,off)
for mk = bot,top do
local complete = name..string.lower(mk_level[mk])
local entity = data.raw[btype][complete]
local item = data.raw["item"][complete]
local recipe = data.raw["recipe"][complete]
-- if not entity then entity = data.raw[btype][name] end
if not item then item = data.raw["item"][name] end
-- if not recipe then recipe = data.raw["recipe"][name] end
	
	-- if entity then entity.icon = ipath..complete..".png" end
	if item then item.icon = ipath..complete.."a.png" end
	-- if recipe then recipe.icon = ipath..complete..".png" end
end
end


