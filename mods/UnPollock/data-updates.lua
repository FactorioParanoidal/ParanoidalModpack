local rock_control = "control:rocks"

local nillist, thing = {}

local rate,frocks,collide = settings.startup["unpollock-decorative-rate"].value, settings.startup["unpollock-fake-rocks"].value, settings.startup["unpollock-avoid-resources"].value

local raw_resources, raw_decoratives, raw_expressions = data.raw.resource, data.raw["optimized-decorative"], data.raw["noise-expression"]


local find,gmatch = string.find,string.gmatch

local function has_word(s,word)
	for maybe in gmatch(s,'%w*'..word..'%w*') do
		if maybe==word then return true end
	end
end

local function has_from_list(s,list)
	if type(s)=="string" then
		for i in pairs(list) do
			if has_word(s,i) then return true end
		end
	end
end

local function expression_uses(e,list)
	if type(e)=="string" then return has_from_list(e,list) end
	if type(e)~="table" then return false end--not list then return nil end
	
	if has_from_list(e.expression or e.probability_expression,list) then return true end
	if e.local_expressions then
		for _,s in pairs(e.local_expressions) do
			if has_from_list(s,list) then return true end
		end
	end
	if e.local_functions then
		for _,f in pairs(e.local_functions) do
			if has_from_list(f.expression,list) then return true end
		end
	end
end

local edge, rock_expressions, flag = {},{[rock_control]=true},true

local function collapse_from(defs)
	local edge,flag,bflag={},true,false
	for n,d in pairs(defs) do
		if not rock_expressions[n] then edge[n]=d end
	end
	while flag do
		flag=false
		for n,e in pairs(edge) do
			if expression_uses(e,rock_expressions) then
				edge[n]=nil
				rock_expressions[n] = true
				flag=true
				bflag=true
			end
		end
	end
	return bflag
end

if frocks=="keep" then frocks = nil end

if frocks=="by-control" then
	while collapse_from(data.raw["noise-function"]) or collapse_from(data.raw["noise-expression"]) do end
end

local function is_rockish(d)
	local a=d.autoplace
	if frocks=="by-control" then
		if a.control == "rocks" then return true end
		if expression_uses(a,rock_expressions) then return true end
	elseif frocks=="by-order" then
		if d.order and find(d.order, '%[rock%]') then return true end
		if a.order and find(a.order, '%[rock%]') then return true end
	elseif frocks=="by-name" then
		for word in gmatch(d.name,'%w*rock%w*') do
			if word=='rock' or word=='rocks' then return true end
		end
	end
end

--[[
local resource_layers = data.raw["utility-constants"].default.default_collision_masks.resource.layers
local decor_default_collision = data.raw["utility-constants"].default.default_collision_masks.decorative
for layer,v in pairs(resource_layers) do
	decor_default_collision.layers[layer] = decor_default_collision.layer or v
end
--]]

if collide then
	local expressions_to_modify = {}
	for pname,planet in pairs(data.raw.planet) do
		local mgs = planet.map_gen_settings
		if mgs then
			local build, kname = {}, "unpollock_resource_cutout_"..pname
			--hold = mgs.autoplace_settings and mgs.autoplace_settings.entity
			for entity in pairs(mgs.autoplace_settings and mgs.autoplace_settings.entity and mgs.autoplace_settings.entity.settings or nillist) do
				if raw_resources[entity] and raw_resources[entity].autoplace then
					build[#build+1] = mgs.property_expression_names and mgs.property_expression_names["entity:"..entity..":probability"] or "var('entity:"..entity..":probability')"
				end
			end
	--		log(planet.name..serpent.line(build))

			data:extend{{ type = "noise-expression",
				name = "unpollock_resource_knockout_template",
				expression = "1"
			}}

			if #build==0 then
			--[[
				data:extend{{ type = "noise-expression",
					name = kname,
					expression = "1"
				}}
				--]]
			elseif #build==1 then
				data:extend{{ type = "noise-expression",
					name = kname,
					expression = "1-4*"..build[1]
				}}
				mgs.property_expression_names["unpollock_resource_knockout_template"] = kname
			else
				data:extend{{ type = "noise-expression",
					name = kname,
					expression = "1-4*max("..table.concat(build,',')..")"
				}}
				mgs.property_expression_names["unpollock_resource_knockout_template"] = kname
			end

			if not mgs.property_expression_names then mgs.property_expression_names={} end
			
			
			for decorative in pairs(mgs.autoplace_settings and mgs.autoplace_settings.decorative and mgs.autoplace_settings.decorative.settings or nillist) do				
				expressions_to_modify[#expressions_to_modify+1]=mgs.property_expression_names["decorative:"..decorative..":probability"]
			end
		end
	end

	for _,expression in pairs(expressions_to_modify) do raw_expressions[expression].expression = "min("..raw_expressions[expression].expression..",var('unpollock_resource_knockout_template'))" end

end

if frocks or rate<1 or collide then
	if rate>0 then rate = ')*'..rate end
	
	for _,d in pairs(raw_decoratives) do
		a=d.autoplace
		if a then
			if rate==0 then
				a.probability_expression = '0'
			elseif frocks and is_rockish(d) then
				log("Suppressing rockish decorative ".._)
				a.probability_expression = '0'
			else
				a.probability_expression = '('..a.probability_expression..rate
				
				if collide then
					a.probability_expression = "min("..a.probability_expression..",var('unpollock_resource_knockout_template'))"
				end
			end
		end
	end
end
