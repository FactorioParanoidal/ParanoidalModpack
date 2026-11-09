local gated_technology = "muluna-nanofoamed-polymers"
local conditions = Muluna.exploration_science.detect()

Muluna:extend{
    {
        type = "mod-data",
        name = "muluna-interstellar-science-pack-conditions",
        data_type = "table",
        data = {
            science_packs = conditions.science_packs,
            packs = conditions.packs,
            gated_technology = gated_technology,
            required_science_packs = conditions.required_science_packs,
            diagnostics = conditions.diagnostics,
        }
    }
}
