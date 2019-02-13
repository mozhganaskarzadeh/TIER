function height = computeHeight(pressure)
%
%%
%
%
    % constants for pressure variation with altitude (https://en.wikipedia.org/wiki/Atmospheric_pressure)
    p_o = 101325; %Pa, standard sea level pressure
    lapse = 0.0065; %K/m, standard lapse rate
    c_p = 1004.68506; %(J/kg*K) constant-pressure specific heat of air
    t_o = 288.15; %K standard sea level temperature
    g = 9.80665; %m/s^2 surface gravitational acceleration
    mAir = 0.02896969; %kg/mol molar mass of air
    r_o = 8.31582991; %J/(mol*K) universal gas constant

    
    height = ( log(pressure/p_o)*t_o*r_o)/(-g*mAir);
    
end