%%% ADDING EVERYTHING (FROM ONE SCRIPT)

% Adding singular objects
facility = addFacility(root, gsName, gsLocation);
sensor = addSensor(facility, gssName, gssRange, gssAngle);

% Adding Satellites
for a = 1:length(semimajorAxis)
    for b = 1:length(inclination)
        name = ['S_', num2str(semimajorAxis(a)), '_', num2str(inclination(b))]; % Add some way of index
        satellite = addSatellite(root, scenario, sensor, requiredTime, threshold, convertCharsToStrings(name), semimajorAxis(a), inclination(b), eccentricity, argPerigee, ascNode, location);
    end
end
disp('Satellites Created')

% Reset Scenario
root.Rewind
disp('Done')
