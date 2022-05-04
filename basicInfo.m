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
gssAngle = [10, 90]; % (deg)


%%% Orbit Constraints
% Range of Parameters
semimajorAxis = 6378 + (300:100:500); % Radius of Earth + Altitude (km)
inclination = 25:2:85; % (deg)
% Constants
eccentricity = 0;
argPerigee = 0;
ascNode = 0;
location = 0;

% Access Information
requiredTimes = 60*30*[     % Time Requirements
    10.0;   % Minimum
    12.0;   % Good
    14.0;   % Desired
];

% Done
disp("Basic Info Saved")