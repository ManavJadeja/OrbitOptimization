function [colorDecimal] = colorCoding(totalTime, requiredTime, threshold)
%%% COLORCODING > Color coding the satellite orbits
%{
Function Information
    Inputs:
        totalTime > satellite total access time
        requiredTime > required access time
        threshold > margin for error
    Output:
        colorDecimal > color based on whether it meets requirements

Written by Manav Jadeja, 2021
%}

if (totalTime > requiredTime*(1+threshold))
    colorDecimal = 16776960;        % Cyan > Good and above threshold
elseif (totalTime > requiredTime)
    colorDecimal = 65280;           % Green > Good, not above threshold
elseif (totalTime > requiredTime*(1-threshold))
    colorDecimal = 65535;           % Yellow > Near, below threshold
elseif (totalTime > 0)
    colorDecimal = 255;             % Red > Below required threshold
else
    colorDecimal = 16777215;        % White > No Access
end

end

