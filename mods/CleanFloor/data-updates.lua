for _, v in pairs(data.raw.tile or {}) do
  if (v.decorative_removal_probability or 0) > 0 then
    v.decorative_removal_probability = 1
  end
end
