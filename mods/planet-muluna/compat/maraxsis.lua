if data.raw.planet["maraxsis"] then 
    PlanetsLib.restrict_surface_conditions(data.raw["recipe"]["maraxsis-hydrolox-rocket-fuel"], {property = "pressure", min = 200000})
    --table.insert(data.raw["technology"]["planet-discovery-maraxsis"].prerequisites,"interstellar-science-pack")
end