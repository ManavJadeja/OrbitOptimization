function [colorDecimal, rgbMatrix] = colorCoding(totalTime, requiredTimes)
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

% Colors
cyan = [0 255 255];
green = [0 255 0];
yellow = [255 255 0];
red = [255 0 0];
white = [255 255 255];

% Assigning Colors
if (totalTime > requiredTimes(3))
    % Above Desired
    colorDecimal = rgb2StkColor(cyan);
    rgbMatrix = cyan;
elseif (totalTime > requiredTimes(2))
    % Above Good
    colorDecimal = rgb2StkColor(green);
    rgbMatrix = green;
elseif (totalTime > requiredTimes(1))
    % Above Minimum
    colorDecimal = rgb2StkColor(yellow);
    rgbMatrix = yellow;
elseif (totalTime > 0)
    % Below Minimum
    colorDecimal = rgb2StkColor(red);
    rgbMatrix = red;
else
    % No Access
    colorDecimal = rgb2StkColor(white);
    rgbMatrix = white;
end

end

