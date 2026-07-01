---
--- Tests for settings.lua
---

local function load_settings_with_mods(loaded_mods)
    local extended = nil

    _G.mods = loaded_mods or {}
    _G.data = {
        extend = function(_, prototypes)
            extended = prototypes
        end
    }

    dofile("settings.lua")

    return extended
end

local function find_setting(settings, name)
    for _, setting in ipairs(settings) do
        if setting.name == name then
            return setting
        end
    end

    return nil
end

describe("settings", function()
    after_each(function()
        _G.mods = nil
        _G.data = nil
    end)

    it("registers all startup settings", function()
        local settings = load_settings_with_mods()

        assert.is_not_nil(settings)
        assert.are.equal(5, #settings)

        assert.is_not_nil(find_setting(settings, "texugo-wind-power"))
        assert.is_not_nil(find_setting(settings, "texugo-wind-turbine4"))
        assert.is_not_nil(find_setting(settings, "texugo-wind-mode"))
        assert.is_not_nil(find_setting(settings, "texugo-wind-extended-collision-area"))
        assert.is_not_nil(find_setting(settings, "texugo-wind-expensive-recipes"))
    end)

    it("defines texugo-wind-power as bounded startup int setting", function()
        local settings = load_settings_with_mods()
        local setting = find_setting(settings, "texugo-wind-power")

        assert.are.equal("int-setting", setting.type)
        assert.are.equal("startup", setting.setting_type)
        assert.are.equal(1, setting.default_value)
        assert.are.equal(1, setting.minimum_value)
        assert.are.equal(20, setting.maximum_value)
        assert.are.equal("a", setting.order)
    end)

    it("defines texugo-wind-turbine4 as enabled startup bool setting", function()
        local settings = load_settings_with_mods()
        local setting = find_setting(settings, "texugo-wind-turbine4")

        assert.are.equal("bool-setting", setting.type)
        assert.are.equal("startup", setting.setting_type)
        assert.is_true(setting.default_value)
        assert.are.equal("b", setting.order)
    end)

    describe("texugo-wind-mode", function()
        it("uses SURFACE+PRESSURE as default wind mode when Space Exploration is not loaded", function()
            local settings = load_settings_with_mods()
            local setting = find_setting(settings, "texugo-wind-mode")

            assert.are.equal("string-setting", setting.type)
            assert.are.equal("startup", setting.setting_type)
            assert.are.equal("c", setting.order)
            assert.are.equal("SURFACE+PRESSURE", setting.default_value)
            assert.are.same({"CLASSICAL", "SURFACE", "SURFACE+PRESSURE" }, setting.allowed_values)
        end)

        it("uses SURFACE as default wind mode when Space Exploration is loaded", function()
            local settings = load_settings_with_mods({ ["space-exploration"] = "0.7.56" })

            local setting = find_setting(settings, "texugo-wind-mode")

            assert.are.equal("string-setting", setting.type)
            assert.are.equal("startup", setting.setting_type)
            assert.are.equal("SURFACE", setting.default_value)
            assert.are.same({"CLASSICAL", "SURFACE"}, setting.allowed_values)
        end)
    end)

    it("defines texugo-wind-extended-collision-area as disabled startup bool setting", function()
        local settings = load_settings_with_mods()
        local setting = find_setting(settings, "texugo-wind-extended-collision-area")

        assert.are.equal("bool-setting", setting.type)
        assert.are.equal("startup", setting.setting_type)
        assert.is_false(setting.default_value)
        assert.are.equal("d", setting.order)
    end)

    it("defines texugo-wind-expensive-recipes as disabled startup bool setting", function()
        local settings = load_settings_with_mods()
        local setting = find_setting(settings, "texugo-wind-expensive-recipes")

        assert.are.equal("bool-setting", setting.type)
        assert.are.equal("startup", setting.setting_type)
        assert.is_false(setting.default_value)
        assert.are.equal("e", setting.order)
    end)
end)
