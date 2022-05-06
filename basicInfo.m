%%% CLEAN UP
clear; clc

%%% PRELIMINARY INFORMATION FOR THE PROGRAM TO RUN
%%% Scenario Information
scenario_name = "Orbit_Optimization";
scenario_times = ["Today"; "+15 days"]; % GET DAYS AND THEN INPUT IN ACCESS INFORMATION!


%%% Ground Station
% gs > ground station
gsName = "RUGS";
gsLocation = [
    40.5220;    % Latitude (deg)
    -74.4615;   % Longitude (deg)
    0.05];      % Altitude (km)
% gss > ground station sensor
gssName = 'GSS';
gssRange = [0, 3000]; % (km)
gssAngle = [15, 90]; % (deg)


%%% Orbit Constraints
% Range of Parameters
semimajorAxis = 6378 + (350:20:450); % Radius of Earth + Altitude (km)
inclination = 25:1:75; % (deg)
% Constants
eccentricity = 0;
argPerigee = 0;
ascNode = 0;
location = 0;

% Access Information
requiredTimes = 60*30*[     % Time Requirements
    08.0;   % Minimum
    10.0;   % Good
    12.0;   % Desired
];

% Done
disp("Basic Info Saved")