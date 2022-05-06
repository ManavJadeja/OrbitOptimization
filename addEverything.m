%%% ADDING EVERYTHING (FROM ONE SCRIPT)

% Adding singular objects
facility = addFacility(root, gsName, gsLocation);
sensor = addSensor(facility, gssName, gssRange, gssAngle);

% Adding Satellites
color = zeros(length(inclination), length(semimajorAxis), 3);
for a = 1:length(semimajorAxis)
    for b = 1:length(inclination)
        name = ['S_', num2str(semimajorAxis(a)), '_', num2str(inclination(b))];     % Indexing by name
        [satellite, rgbMatrix] = addSatellite(root, scenario, sensor, requiredTimes, convertCharsToStrings(name),...
            semimajorAxis(a), inclination(b), eccentricity, argPerigee, ascNode, location);
        color(b, a, :) = rgbMatrix./255;
    end
end
disp('Satellites Created')

% Reset Scenario
root.Rewind
disp('Done')
