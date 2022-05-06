function [facility] = addFacility(root, gsName, gsLocation)
%%% FACILITY PROPERTIES
% Add facility object
facility = root.CurrentScenario.Children.New('eFacility', gsName);

% Modify facility properties
facility.Position.AssignGeodetic(gsLocation(1), gsLocation(2), gsLocation(3)) % Latitude, Longitude, Altitude

% Done
disp("Facility Created")
end