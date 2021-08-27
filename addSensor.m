%%% SENSOR PROPERTIES
% Add sensor object to satellite
sensor = facility.Children.New('eSensor', 'Sensor');

% Modify sensor properties
sensor.CommonTasks.SetPatternSimpleConic(90, 1);

% Add range constraint
range = sensor.AccessConstraints.AddConstraint('eCstrRange');
range.EnableMin = true;
range.EnableMax = true;
range.min = 0;
range.max = 1500;

% Add elevation angle constraint
elevation_angle = sensor.AccessConstraints.AddConstraint('eCstrElevationAngle');
elevation_angle.EnableMin = true;
elevation_angle.EnableMax = true;
elevation_angle.Min = 45;
elevation_angle.Max = 80;

% Show elevation angle constraint (for graphics)
view = sensor.Graphics.Projection;
view.UseConstraints = true;
view.UseDistance = true;
view.EnableConstraint('ElevationAngle');
view.UseConstraints = true;

% Done
disp("Sensor Created")