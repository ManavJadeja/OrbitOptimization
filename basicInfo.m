%%% CLEAN UP
clear; clc

%%% PRELIMINARY INFORMATION FOR THE PROGRAM TO RUN
%%% Scenario Information
scenario_name = "Orbit_Optimization";
scenario_times = ["Today"; "+30 days"]; % GET DAYS AND THEN INPUT IN ACCESS INFORMATION!


%%% Ground Station
% gs > ground station
gsName = "RUGS";
gsLocation = [
    40.5220;    % Latitude (deg)
    -74.4615;   % Longitude (deg)
    0.05];      % Altitude (km)
% gss > ground station sensor
gssName = 'GSS';
gssRange = [0, 1500]; % (km)
gssAngle = [45, 80]; % (deg)


%%% Orbit Constraints
% Range of Parameters
semimajorAxis = 6878 + (300:100:600); % Radius of Earth + Altitude (km)
inclination = 30:5:70; % (deg)
% Constants
eccentricity = 0;
argPerigee = 0;
ascNode = 0;
location = 0;

% Access Information
dailyTime = 9; % Time requirement per day
requiredTime = dailyTime*60*30; % Time requirement per year (
threshold = 0.2; % Giving a 10% margin (not sure whether this is reasonable)


% Done
disp("Basic Info Saved")