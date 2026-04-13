require('lib.init')

local Is = require('stdlib.utils.is')
local table = require('stdlib.utils.table')

local const = require('lib.constants')

if storage.ml_data and storage.ml_data.VERSION >= const.CURRENT_VERSION then return end

-- add gui reference
storage.ml_data.open_guis = storage.ml_data.open_guis or {}

-- rebuild all miniloaders
local keys = table.keys(This.MiniLoader:entities())

for _, idx in pairs(keys) do
    local ml_entity = This.MiniLoader:getEntity(idx)
    assert(ml_entity)
    local main = ml_entity.main
    This.MiniLoader:destroy(idx)
    if (Is.Valid(main)) then
        This.MiniLoader:create(main)
    end
end

storage.ml_data.VERSION = const.CURRENT_VERSION
