---
--- Tests for prototypes/common.lua
---
local Require = require("test.require")
require = Require.replace(require)

-- Mocks for Factorio APIs.
_G.settings = {
    startup = {
        ["texugo-wind-expensive-recipes"] = { value = false },
    }
}

-- Mock for the handle_settings module.
local mock_handle_settings = {
    constructionMoreExpensive = function()
        return _G.settings.startup["texugo-wind-expensive-recipes"].value
    end
}

-- Replace the handle_settings module with a mock.
local original_require = require
require = function(module_name)
    if module_name == "scripts/handle_settings" then
        return mock_handle_settings
    end

    return original_require(module_name)
end

local common = require("prototypes.common")

describe("common", function()
    before_each(function()
        -- Reset settings for each test.
        _G.settings.startup["texugo-wind-expensive-recipes"].value = false
    end)

    after_each(function()
        -- Force reload for subsequent tests.
        package.loaded["scripts/handle_settings"] = nil
    end)

    it("exports the expected module members", function()
        assert.is_not_nil(common)
        assert.are.equal("table", type(common))
        assert.is_not_nil(common.make_recipe)
        assert.are.equal("function", type(common.make_recipe))
    end)

    it("creates a cheap recipe when expensive recipes are disabled", function()
        local base_recipe = {
            name = "test-recipe",
            type = "recipe"
        }

        local cheap_config = {
            energy = 5,
            ingredients = {
                { "iron-plate", 2 },
                { "copper-plate", 1 }
            }
        }

        local expensive_config = {
            energy = 10,
            ingredients = {
                { "iron-plate", 5 },
                { "copper-plate", 3 },
                { "steel-plate", 1 }
            }
        }

        _G.settings.startup["texugo-wind-expensive-recipes"].value = false

        local result = common.make_recipe(base_recipe, cheap_config, expensive_config)

        assert.are.equal(5, result.energy)
        assert.are.equal(2, #result.ingredients)
        assert.are.equal("iron-plate", result.ingredients[1].name)
        assert.are.equal(2, result.ingredients[1].amount)
        assert.are.equal("item", result.ingredients[1].type)
        assert.are.equal("copper-plate", result.ingredients[2].name)
        assert.are.equal(1, result.ingredients[2].amount)
        assert.are.equal("item", result.ingredients[2].type)
    end)

    it("creates an expensive recipe when expensive recipes are enabled", function()
        local base_recipe = {
            name = "test-recipe",
            type = "recipe"
        }

        local cheap_config = {
            energy = 5,
            ingredients = {
                { "iron-plate", 2 },
                { "copper-plate", 1 },
            }
        }

        local expensive_config = {
            energy = 10,
            ingredients = {
                { "iron-plate", 5 },
                { "copper-plate", 3 },
                { "steel-plate", 1 },
            }
        }

        _G.settings.startup["texugo-wind-expensive-recipes"].value = true

        local result = common.make_recipe(base_recipe, cheap_config, expensive_config)

        assert.are.equal(10, result.energy)
        assert.are.equal(3, #result.ingredients)

        -- Check ingredients by name.
        local ingredients_by_name = {}
        for _, ingredient in ipairs(result.ingredients) do
            ingredients_by_name[ingredient.name] = ingredient
        end

        assert.are.equal(5, ingredients_by_name["iron-plate"].amount)
        assert.are.equal("item", ingredients_by_name["iron-plate"].type)
        assert.are.equal(3, ingredients_by_name["copper-plate"].amount)
        assert.are.equal("item", ingredients_by_name["copper-plate"].type)
        assert.are.equal(1, ingredients_by_name["steel-plate"].amount)
        assert.are.equal("item", ingredients_by_name["steel-plate"].type)
    end)

    it("modifies and returns the base recipe", function()
        local base_recipe = {
            name = "test-recipe",
            type = "recipe",
            existing_field = "should_remain"
        }

        local cheap_config = {
            energy = 15,
            ingredients = {
                { "wood", 10 },
            }
        }

        local expensive_config = {
            energy = 30,
            ingredients = {
                { "wood", 20 },
            }
        }

        _G.settings.startup["texugo-wind-expensive-recipes"].value = false

        local result = common.make_recipe(base_recipe, cheap_config, expensive_config)

        -- Check original fields.
        assert.are.equal("test-recipe", result.name)
        assert.are.equal("recipe", result.type)
        assert.are.equal("should_remain", result.existing_field)

        -- Check new fields.
        assert.are.equal(15, result.energy)
        assert.is_not_nil(result.ingredients)

        -- Check that the returned object is the same table as the base recipe.
        assert.are.same(base_recipe, result)
    end)

    it("creates a recipe with empty ingredients", function()
        local base_recipe = {
            name = "empty-recipe",
            type = "recipe"
        }

        local config = {
            energy = 1,
            ingredients = {}
        }

        local result = common.make_recipe(base_recipe, config, config)

        assert.are.equal(1, result.energy)
        assert.are.equal(0, #result.ingredients)
    end)

    it("creates a recipe with a single ingredient", function()
        local base_recipe = {
            name = "single-ingredient-recipe",
            type = "recipe"
        }

        local config = {
            energy = 2,
            ingredients = {
                { "electronic-circuit", 3 },
            }
        }

        local result = common.make_recipe(base_recipe, config, config)

        assert.are.equal(2, result.energy)
        assert.are.equal(1, #result.ingredients)
        assert.are.equal("electronic-circuit", result.ingredients[1].name)
        assert.are.equal(3, result.ingredients[1].amount)
        assert.are.equal("item", result.ingredients[1].type)
    end)
end)
