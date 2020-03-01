				
function setall_icons(technologies_icons)

--[[
	if settings.startup["switch_green_purple_belts"] then
		if not settings.startup["switch_green_purple_belts"].value then
			all_icons.transportbelts = {}
			all_icons.beltsorter = {}
			all_icons.hackedsplitter = {}
			all_icons.loaders = {}
			all_icons.miniloaders = {}
		end
	end
]]--


	for mainname,tech in pairs (technologies_icons) do

			local name = tech[1]
			local icon = tech[2]
			local size = tech[3]
			local order = tech[4]
			
			local picture = ShinyBob_path .. "/graphics/technologies/".. tech[2]

			if not data.raw.technology[name]  then goto skip end
			if not tech[2] then goto skip end
			if tech[2] == nil or tech[2] == "" then goto skip end
			
			if data.raw["technology"][name] then
			
				data.raw.technology[name].icon = picture
				if not data.raw.technology[name].icon_size then
					table.insert(data.raw.technology[name],{icon = {},icon_size = {}})
				end
				data.raw.technology[name].icon_size = size and size or 128
				if order ~= nil and order ~="" then
					data.raw.technology[name].order = tech[4]
				end
			end
			::skip::
	end	
end		


