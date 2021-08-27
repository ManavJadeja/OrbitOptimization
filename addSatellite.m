%%% SATELLITE PROPERTIES
% Add satellite object
satellite = root.CurrentScenario.Children.New('eSatellite', 'SPICESat');

% Modify satellite properties
keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical'); % Use the Classical Element interface
keplerian.SizeShapeType = 'eSizeShapeSemimajorAxis';  % Uses Eccentricity and Inclination
keplerian.LocationType = 'eLocationTrueAnomaly'; % Makes sure True Anomaly is being used
keplerian.Orientation.AscNodeType = 'eAscNodeRAAN'; % Use RAAN for data entry

% Assign the perigee and apogee altitude values:
keplerian.SizeShape.SemimajorAxis = 500+6878;   % km
keplerian.SizeShape.Eccentricity = 0;           % circle

% Assign the other desired orbital parameters:
keplerian.Orientation.Inclination = 90;         % deg
keplerian.Orientation.ArgOfPerigee = 12;        % deg
keplerian.Orientation.AscNode.Value = 24;       % deg
keplerian.Location.Value = 180;                 % deg

% Apply the changes made to the satellite's state and propagate:
satellite.Propagator.InitialState.Representation.Assign(keplerian);
satellite.Propagator.Propagate;
root.Rewind
disp("Satellite Created")

%{
% Change model of satellite (learn how to make a .dae file)
toSatelliteModel = 'C:\Program Files\AGI\STK 12\STKData\VO\Models\Space\cubesat_3u.dae';
model = satellite.VO.Model;
model.ModelData.Filename = toSatelliteModel;
disp("Satellite Model Updated")

% Resolution changes
resolution = satellite.Graphics.Resolution;
resolution.Orbit = 60;
%}