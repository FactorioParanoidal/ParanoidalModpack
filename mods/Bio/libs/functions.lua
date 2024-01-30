local BioInd = require('common')('Bio_Industries')


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


-- Converts recipe.result to recipe.results!
function thxbob.lib.result_check(object)
BioInd.show("Entered function result_check", object)
  if object then
    object.results = object.results or {}

    if object.result then
      local item = thxbob.lib.item.basic_item({name = object.result})
BioInd.show("item", item)
      if object.result_count then
        item.amount = object.result_count
        object.result_count = nil
      end

BioInd.show("object.result", object.result)
      thxbob.lib.item.add_new(object.results, item)
BioInd.show("object.results after add_new", object.results)

      if object.ingredients then  -- It's a recipe
        if not object.main_product then
          if object.icon or object.subgroup or object.order or item.type ~= "item" then -- if we already have one, add the rest
BioInd.writeDebug("data.raw[%s][%s]: %s", {item.type, object.result, data.raw[item.type][object.result] or "nil"})
            if (not object.icon) and data.raw[item.type][object.result] and
                                      data.raw[item.type][object.result].icon then
              object.icon = data.raw[item.type][object.result].icon
              object.icon_size = data.raw[item.type][object.result].icon_size
            --~ end
            -- Make sure objects also have an icons definition
            elseif not object.icons and data.raw[item.type][object.result] and
                                          data.raw[item.type][object.result].icons and
                                          -- Don't assume that an icon already exists,
                                          -- it could be set later on!
                                          data.raw[item.type][object.result].icon then
              object.icons = {
                {icon = data.raw[item.type][object.result].icon, icon_size = 64}
              }
            end
            if not object.subgroup and data.raw[item.type][object.result] and
                                        data.raw[item.type][object.result].subgroup then
              object.subgroup = data.raw[item.type][object.result].subgroup
            end
            if not object.order and data.raw[item.type][object.result] and
                                      data.raw[item.type][object.result].order then
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
    BioInd.writeDebug("%s does not exist.", {object})
  end
end


function thxbob.lib.belt_speed_ips(ips)
  return ips * 1/480
end
