aircraft_geometry = {
    gunship={weight=750,wing_area=2,C_lift=1.75},
    cargo_plane={weight=3500,wing_area=12,C_lift=1.75},
    jet={weight=500,wing_area=1,C_lift=1.75},
    flying_fortress={weight=3000,wing_area=6,C_lift=1.75},
  } --Defines geometric information of aircraft that determines liftoff speed  
    

function v_liftoff(aircraft,material) --When AircraftRealism is enabled, this function determines v_liftoff.
    
    local R = 8.314472 --m^2 kg s^-2 K^-1 mol^-1 
    local kelvin = 273.15
    local T_nauvis=20+kelvin
    local g = 10
    log(aircraft)
    log(aircraft_geometry[aircraft]["weight"])
    local m= aircraft_geometry[aircraft]["weight"]
    if material=="carbon-fiber" then
      m=m/2
    end
    local P =1000
    local C_lift=aircraft_geometry[aircraft]["C_lift"]
    local wing_area=aircraft_geometry[aircraft]["wing_area"]

    local v=math.sqrt((2*R*T_nauvis*m*g)/C_lift/P/wing_area) --(The velocity when lift = weight)
    return v
  end