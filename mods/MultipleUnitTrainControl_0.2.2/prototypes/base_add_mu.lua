--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: entity.lua
 * Description: Creates the MU version of the base locomotive.
 *   Adds the dummy technology to store std-mu locomotive mappings, and RET dummy fuel items.
--]]



-- Generate an MU version of the base locomotive
createMuLoco{std="locomotive",mu="locomotive-mu",item="item-with-entity-data",hasDescription=true}

