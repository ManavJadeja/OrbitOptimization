function [satellite, rgbMatrix] = addSatellite(root, scenario, sensor, requiredTimes, name, semimajorAxis, inclination, eccentricity, argPerigee, ascNode, location)
%%% SATELLITE PROPERTIES
% Add satellite object
satellite = root.CurrentScenario.Children.New('eSatellite', name);

% Modify satellite properties
keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical'); % Use the Classical Element interface
keplerian.SizeShapeType = 'eSizeShapeSemimajorAxis';  % Uses Eccentricity and Inclination
keplerian.LocationType = 'eLocationTrueAnomaly'; % Makes sure True Anomaly is being used
keplerian.Orientation.AscNodeType = 'eAscNodeRAAN'; % Use RAAN for data entry

% Assign the perigee and apogee altitude values:
keplerian.SizeShape.SemimajorAxis = semimajorAxis;
keplerian.SizeShape.Eccentricity = eccentricity;

% Assign the other desired orbital parameters:
keplerian.Orientation.Inclination = inclination;
keplerian.Orientation.ArgOfPerigee = argPerigee;
keplerian.Orientation.AscNode.Value = ascNode;
keplerian.Location.Value = location;

% Apply the changes made to the satellite's state and propagate:
satellite.Propagator.InitialState.Representation.Assign(keplerian);
satellite.Propagator.Propagate;

% Get Access (Satellite to Sensor)
[colorDecimal, rgbMatrix] = getAccess(scenario, satellite, sensor, requiredTimes);

% Satellite Graphics
graphics = satellite.Graphics;
graphics.SetAttributesType('eAttributesBasic');
attributes = graphics.Attributes;
attributes.Inherit = false;
attributes.Color = colorDecimal;

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
end
