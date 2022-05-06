%%% CLEAN UP
clear; clc

%%% PRELIMINARY INFORMATION FOR THE PROGRAM TO RUN
%%% Scenario Information
scenario_name = 'Orbit_Optimization';

scenarioDuration = 120; % Days
scenStartTime = '1 Jan 2022 00:00:00.000';
scenStopTime = '1 May 2022 00:00:00.000';
% NEED TO MAKE SURE THESE AGREE

%%% Ground Station
% gs > ground station
gsName = 'rugs';
gsLocation = [
    40.5220;    % Latitude (deg)
    -74.4615;   % Longitude (deg)
    0.05];      % Altitude (km)
% gss > ground station sensor
gssName = 'rugsS';
gssRange = [0, 1500]; % (km)
gssAngle = [25, 90]; % (deg)


%%% Orbit Constraints
% Range of Parameters
semimajorAxis = 6378 + (350:10:450); % Radius of Earth + Altitude (km)
inclination = 30:1:60; % (deg)
% Constants
eccentricity = 0;
argPerigee = 0;
ascNode = 0;
location = 0;

% Access Information
dailyTime = 9; % Time requirement per day
requiredTime = dailyTime*60*scenarioDuration; % Time requirement per months 
threshold = 0.2; % Giving a 10% margin (not sure whether this is reasonable)


% Done
disp("Basic Info Saved")