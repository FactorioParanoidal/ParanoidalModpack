-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Import flib migration module
local migration = require("__flib__.migration")

-- Setup additional version comparison functions

--- Check if current_version is newer than target_version
-- @tparam string current_version
-- @tparam string target_version
-- @tparam[opt=%02d] string format
-- @treturn boolean|nil
function migration.is_newer_version(current_version, target_version, format)
    local v1 = migration.format_version(current_version, format)
    local v2 = migration.format_version(target_version, format)

    if v1 and v2 then
        if v1 > v2 then
            return true
        else
            return false
        end
    end

    return nil
end

--- Check if current_version is equal to or newer than target_version
-- @tparam string current_version
-- @tparam string target_version
-- @tparam[opt=%02d] string format
-- @treturn boolean|nil
function migration.is_version_or_newer(current_version, target_version, format)
    local v1 = migration.format_version(current_version, format)
    local v2 = migration.format_version(target_version, format)

    if v1 and v2 then
        if v1 >= v2 then
            return true
        else
            return false
        end
    end

    return nil
end

--- Check if current_version is equal to target_version
-- @tparam string current_version
-- @tparam string target_version
-- @tparam[opt=%02d] string format
-- @treturn boolean|nil
function migration.is_version(current_version, target_version, format)
    local v1 = migration.format_version(current_version, format)
    local v2 = migration.format_version(target_version, format)

    if v1 and v2 then
        if v1 == v2 then
            return true
        else
            return false
        end
    end

    return nil
end

--- Check if current_version is equal to or older than target_version
-- @tparam string current_version
-- @tparam string target_version
-- @tparam[opt=%02d] string format
-- @treturn boolean|nil
function migration.is_version_or_older(current_version, target_version, format)
    local v1 = migration.format_version(current_version, format)
    local v2 = migration.format_version(target_version, format)

    if v1 and v2 then
        if v1 <= v2 then
            return true
        else
            return false
        end
    end

    return nil
end

--- Check if current_version is older than target_version
-- @tparam string current_version
-- @tparam string target_version
-- @tparam[opt=%02d] string format
-- @treturn boolean|nil
function migration.is_older_version(current_version, target_version, format)
    local v1 = migration.format_version(current_version, format)
    local v2 = migration.format_version(target_version, format)

    if v1 and v2 then
        if v1 < v2 then
            return true
        else
            return false
        end
    end

    return nil
end

return migration