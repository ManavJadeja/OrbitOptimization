%%% CLEAN UP
clear; clc

%%% PRELIMINARY INFORMATION FOR THE PROGRAM TO RUN
%%% Scenario Information
scenario_name = "Orbit_Optimization";
scenario_times = ["Today"; "+1 year"];


%%% Facility information
facility_name = "RUGS";
facility_location = [
    40.5220;    % Latitude (deg)
    -74.4615;   % Longitude (deg)
    0.05];      % Altitude (km)

%%% Orbit Constraints
% For orbit optimization, these are the bounds for the orbital elements
% Inclination, eccentricity, semimajor axis, perigee, acending node, location
% Of these, some are constant (eccentricity, and others)

% Done
disp("Basic Info Saved")