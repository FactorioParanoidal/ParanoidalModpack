bobmods.lib.recipe.add_ingredient("solar-panel-small-2", { "solar-panel-small", 3 })
bobmods.lib.recipe.add_ingredient("solar-panel-2", { "solar-panel", 3 })
bobmods.lib.recipe.add_ingredient("solar-panel-large-2", { "solar-panel-large", 3 })

data.raw["solar-panel"]["solar-panel-small-2"].production = "106.68kW"
data.raw["solar-panel"]["solar-panel-2"].production = "240kW"
data.raw["solar-panel"]["solar-panel-large-2"].production = "426.72kW"

bobmods.lib.recipe.add_ingredient("solar-panel-small-3", { "solar-panel-small-2", 3 })
bobmods.lib.recipe.add_ingredient("solar-panel-3", { "solar-panel-2", 3 })
bobmods.lib.recipe.add_ingredient("solar-panel-large-3", { "solar-panel-large-2", 3 })

data.raw["solar-panel"]["solar-panel-small-3"].production = "426.72kW"
data.raw["solar-panel"]["solar-panel-3"].production = "960kW"
data.raw["solar-panel"]["solar-panel-large-3"].production = "1706.88kW"

bobmods.lib.recipe.add_ingredient("fast-accumulator-2", { "fast-accumulator", 3 })
bobmods.lib.recipe.add_ingredient("slow-accumulator-2", { "slow-accumulator", 3 })

data.raw["accumulator"]["large-accumulator-2"].energy_source.buffer_capacity = "40MJ"
data.raw["accumulator"]["large-accumulator-2"].energy_source.input_flow_limit = "240kW"
data.raw["accumulator"]["large-accumulator-2"].energy_source.output_flow_limit = "240kW"

data.raw["accumulator"]["fast-accumulator-2"].energy_source.buffer_capacity = "16MJ"
data.raw["accumulator"]["fast-accumulator-2"].energy_source.input_flow_limit = "960kW"
data.raw["accumulator"]["fast-accumulator-2"].energy_source.output_flow_limit = "3840kW"

data.raw["accumulator"]["slow-accumulator-2"].energy_source.buffer_capacity = "16MJ"
data.raw["accumulator"]["slow-accumulator-2"].energy_source.input_flow_limit = "960kW"
data.raw["accumulator"]["slow-accumulator-2"].energy_source.output_flow_limit = "120kW"

bobmods.lib.recipe.add_ingredient("large-accumulator-3", { "large-accumulator-2", 3 })
bobmods.lib.recipe.add_ingredient("fast-accumulator-3", { "fast-accumulator-2", 3 })
bobmods.lib.recipe.add_ingredient("slow-accumulator-3", { "slow-accumulator-2", 3 })

data.raw["accumulator"]["large-accumulator-3"].energy_source.buffer_capacity = "160MJ"
data.raw["accumulator"]["large-accumulator-3"].energy_source.input_flow_limit = "960kW"
data.raw["accumulator"]["large-accumulator-3"].energy_source.output_flow_limit = "960kW"

data.raw["accumulator"]["fast-accumulator-3"].energy_source.buffer_capacity = "64MJ"
data.raw["accumulator"]["fast-accumulator-3"].energy_source.input_flow_limit = "3840kW"
data.raw["accumulator"]["fast-accumulator-3"].energy_source.output_flow_limit = "15360kW"

data.raw["accumulator"]["slow-accumulator-3"].energy_source.buffer_capacity = "64MJ"
data.raw["accumulator"]["slow-accumulator-3"].energy_source.input_flow_limit = "3840kW"
data.raw["accumulator"]["slow-accumulator-3"].energy_source.output_flow_limit = "480kW"
