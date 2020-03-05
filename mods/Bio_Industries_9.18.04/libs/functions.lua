-- Merges table2's contents into table1.
function thxbob.lib.table_merge(table1, table2)
  for index, value in pairs(table2) do
    if type(value) == "table" then
      if type(table1[index]) == "table" then
        thxbob.lib.table_merge(table1[index], table2[index])
      else
        table1[index] = util.table.deepcopy(table2[index])
      end
    else
      table1[index] = value
    end
  end
end


function thxbob.lib.result_check(object)
  if object then
    if object.results == nil then 
      object.results = {}
    end

    if object.result then
      local item = thxbob.lib.item.basic_item({name = object.result})
      if object.result_count then
        item.amount = object.result_count
        object.result_count = nil
      end
      thxbob.lib.item.add_new(object.results, item)

      if object.ingredients then  -- It's a recipe
        if not object.main_product then
          if object.icon or object.subgroup or object.order or item.type ~= "item" then -- if we already have one, add the rest
            if not object.icon and data.raw[item.type][object.result].icon then
              object.icon = data.raw[item.type][object.result].icon 
              object.icon_size = data.raw[item.type][object.result].icon_size
            end
            if not object.subgroup and data.raw[item.type][object.result].subgroup then
              object.subgroup = data.raw[item.type][object.result].subgroup
            end
            if not object.order and data.raw[item.type][object.result].order then
              object.order = data.raw[item.type][object.result].order 
            end
          else -- otherwise just use main_product as a cheap way to set them all.
            object.main_product = object.result
          end
        end
      end
      object.result = nil
    end

  else
    log(object .. " does not exist.")
  end
end


function thxbob.lib.belt_speed_ips(ips)
  return ips * 1/480
end
