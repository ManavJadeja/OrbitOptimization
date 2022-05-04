function [colorDecimal, rgbMatrix] = getAccess(scenario, satellite, sensor, requiredTimes)
%%% GETACCESS > Get Access between two objects
% Compute access between objects (satellite > facility)
access = satellite.GetAccessToObject(sensor);
access.ComputeAccess();

% Access Duration (data and total)
accessDP = access.DataProviders.Item('Access Data').Exec(scenario.StartTime, scenario.StopTime);
try
    accessDuration = cell2mat(accessDP.DataSets.GetDataSetByName('Duration').GetValues);
    totalTime = sum(accessDuration, 'all');
    % disp(totalTime)
catch
    totalTime = 0;
    % disp('No Access Found')
end

% Color Coding
[colorDecimal, rgbMatrix] = colorCoding(totalTime, requiredTimes);
end



