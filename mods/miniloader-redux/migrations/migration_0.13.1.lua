for _, ml_entity in pairs(This.MiniLoader:entities()) do
    This.MiniLoader:sanitizeConfiguration(ml_entity.config)
end
