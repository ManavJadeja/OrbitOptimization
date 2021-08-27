%%% FACILITY PROPERTIES
% Add facility object
facility = root.CurrentScenario.Children.New('eFacility', facility_name);

% Modify facility properties
facility.Position.AssignGeodetic(facility_location(1), facility_location(2), facility_location(2)) % Latitude, Longitude, Altitude
disp("Facility Created")