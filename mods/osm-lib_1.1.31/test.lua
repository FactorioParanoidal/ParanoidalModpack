local icons_path = "__osm-lib__/graphics/icons/utils/"


local decoded_table = {}

local test = {}

function test.data_encode(table_name, data_table)
    
    local function table_length(length)
        local count = 0
        for _ in pairs(length) do count = count + 1 end
        return count
    end
	
	-- Generate raw string table
	local raw_array = {}
	local raw_string = ""
    local count = 0
    local length = table_length(data_table)
	
	for index, value in pairs(data_table) do
        
		local data_index = "|"..index.."="..value
 
		-- If string exceeds 200 chars push iteration to index and build new raw string
		if string.len(raw_string..data_index) > 200 then
			table.insert(raw_array, raw_string)
			raw_string = data_index
 
		-- Push last iteration or repeat
		else
		    raw_string = raw_string..data_index
            count = count+1
            if count == length then
                table.insert(raw_array, raw_string)
            end
		end
	end

	-- Generate encoded string table
	local encoded_array = {}
	local encoded_string = {}

	for i, raw_string in pairs(raw_array) do
        
		if #encoded_string+1 <= 20 then
			table.insert(encoded_string, raw_string)
            if i == #encoded_string then
                table.insert(encoded_array, {"", encoded_string})
            end
		else
			encoded_string = {}
			table.insert(encoded_string, raw_string)
		end
	end
	
	-- Generate encoded item
	for i, encoded_data in pairs(encoded_array) do
	
    	local encoded_item =
    	{
    		type = "item",
    		name = "OSM-encoded-data-"..table_name.."-"..i,
	    	icon = icons_path.."code-data.png",
	    	icon_size = 64,
	    	stack_size = 64,
	    	flags = {"hidden","hide-from-bonus-gui","hide-from-fuel-tooltip"},
	    	localised_name = "OSM-encoded-data-"..table_name.."-"..i,
	    	localised_description = encoded_data,
	    	order = "z",
	   	}	data:extend({encoded_item})
	end
end


-- Decode
--
--for _, raw in pairs(data.raw.item["OSM-encoded-data-"..table_name.."-1"].localised_description) do
function test.data_decode(data_name)
	
	for _, raw in pairs(game.item_prototypes) do
	
		if string.find(raw.name, "OSM-encoded-data-"..data_name, 1, true) then
			for str in string.gmatch(raw.localised_description, "[^|]*") do
				for i, value in string.gmatch(str, "([^=]+)=([^=]+)") do
					game.print(i.." "..value)
					--decoded_table[i] = value
				end
			end
		end
	end
end
--

return test