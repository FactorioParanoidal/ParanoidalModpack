if storage.excluded ~= nil then
  -- Remove ControlRoom (out-dated mod "Mobile Factory")
  storage.excluded["ControlRoom"] = nil

  -- Factorissimo3
  storage.excluded["factory-floor"] = true
end
